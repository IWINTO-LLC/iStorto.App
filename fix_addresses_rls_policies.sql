-- ============================================
-- إصلاح RLS Policies لجدول العناوين (Addresses)
-- Fix RLS Policies for Addresses Table
-- ============================================

-- 1. تفعيل Row Level Security على جدول addresses
-- ============================================
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

-- 2. حذف جميع Policies القديمة (إن وجدت)
-- ============================================
DROP POLICY IF EXISTS "Users can view their own addresses" ON public.addresses;
DROP POLICY IF EXISTS "Users can insert their own addresses" ON public.addresses;
DROP POLICY IF EXISTS "Users can update their own addresses" ON public.addresses;
DROP POLICY IF EXISTS "Users can delete their own addresses" ON public.addresses;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.addresses;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.addresses;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON public.addresses;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON public.addresses;

-- 3. إنشاء Policies الجديدة الصحيحة
-- ============================================

-- Policy للقراءة: المستخدمون يمكنهم رؤية عناوينهم فقط
CREATE POLICY "Users can view their own addresses"
    ON public.addresses
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy للإدراج: المستخدمون يمكنهم إضافة عناوين جديدة
CREATE POLICY "Users can insert their own addresses"
    ON public.addresses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy للتحديث: المستخدمون يمكنهم تحديث عناوينهم فقط
CREATE POLICY "Users can update their own addresses"
    ON public.addresses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy للحذف: المستخدمون يمكنهم حذف عناوينهم فقط
CREATE POLICY "Users can delete their own addresses"
    ON public.addresses
    FOR DELETE
    USING (auth.uid() = user_id);

-- 4. التحقق من هيكل الجدول
-- ============================================

-- التأكد من وجود الأعمدة المطلوبة
DO $$ 
BEGIN
    -- إضافة عمود user_id إذا لم يكن موجوداً
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'addresses' 
                   AND column_name = 'user_id') THEN
        ALTER TABLE public.addresses ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;

    -- إضافة عمود created_at إذا لم يكن موجوداً
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'addresses' 
                   AND column_name = 'created_at') THEN
        ALTER TABLE public.addresses ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;

    -- إضافة عمود updated_at إذا لم يكن موجوداً
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'addresses' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE public.addresses ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- 5. إنشاء Indexes للأداء
-- ============================================

CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_addresses_is_default ON public.addresses(user_id, is_default);
CREATE INDEX IF NOT EXISTS idx_addresses_created_at ON public.addresses(created_at DESC);

-- 6. إنشاء Function لتحديث updated_at تلقائياً
-- ============================================

CREATE OR REPLACE FUNCTION update_addresses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. إنشاء Trigger لتحديث updated_at
-- ============================================

DROP TRIGGER IF EXISTS update_addresses_updated_at_trigger ON public.addresses;
CREATE TRIGGER update_addresses_updated_at_trigger
    BEFORE UPDATE ON public.addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_addresses_updated_at();

-- 8. Function للتأكد من عنوان افتراضي واحد فقط
-- ============================================

CREATE OR REPLACE FUNCTION ensure_single_default_address()
RETURNS TRIGGER AS $$
BEGIN
    -- إذا كان العنوان الجديد افتراضي
    IF NEW.is_default = TRUE THEN
        -- إلغاء جميع العناوين الافتراضية الأخرى لنفس المستخدم
        UPDATE public.addresses
        SET is_default = FALSE
        WHERE user_id = NEW.user_id
        AND id != NEW.id
        AND is_default = TRUE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9. إنشاء Trigger لضمان عنوان افتراضي واحد
-- ============================================

DROP TRIGGER IF EXISTS ensure_single_default_address_trigger ON public.addresses;
CREATE TRIGGER ensure_single_default_address_trigger
    BEFORE INSERT OR UPDATE ON public.addresses
    FOR EACH ROW
    WHEN (NEW.is_default = TRUE)
    EXECUTE FUNCTION ensure_single_default_address();

-- 10. منح الصلاحيات
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.addresses TO authenticated;

-- منح صلاحيات على SEQUENCE فقط إذا كان موجوداً (للـ id من نوع SERIAL)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'addresses_id_seq' AND relkind = 'S') THEN
        GRANT USAGE, SELECT ON SEQUENCE addresses_id_seq TO authenticated;
    END IF;
END $$;

GRANT EXECUTE ON FUNCTION update_addresses_updated_at() TO authenticated;
GRANT EXECUTE ON FUNCTION ensure_single_default_address() TO authenticated;

-- 11. إضافة تعليقات توضيحية
-- ============================================

COMMENT ON TABLE public.addresses IS 'جدول العناوين للمستخدمين';
COMMENT ON POLICY "Users can view their own addresses" ON public.addresses IS 'المستخدمون يمكنهم رؤية عناوينهم فقط';
COMMENT ON POLICY "Users can insert their own addresses" ON public.addresses IS 'المستخدمون يمكنهم إضافة عناوين جديدة';
COMMENT ON POLICY "Users can update their own addresses" ON public.addresses IS 'المستخدمون يمكنهم تحديث عناوينهم فقط';
COMMENT ON POLICY "Users can delete their own addresses" ON public.addresses IS 'المستخدمون يمكنهم حذف عناوينهم فقط';
COMMENT ON FUNCTION update_addresses_updated_at() IS 'تحديث وقت التعديل تلقائياً عند تحديث العنوان';
COMMENT ON FUNCTION ensure_single_default_address() IS 'التأكد من وجود عنوان افتراضي واحد فقط لكل مستخدم';

-- 12. التحقق من نجاح التثبيت
-- ============================================

-- التحقق من تفعيل RLS
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'addresses';

-- التحقق من Policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'addresses';

-- ============================================
-- انتهى سكريبت إصلاح RLS Policies للعناوين
-- ============================================

-- ملاحظات مهمة:
-- 1. تأكد من أن جدول addresses موجود قبل تشغيل هذا السكريبت
-- 2. تأكد من أن عمود user_id موجود ومرتبط بـ auth.users
-- 3. بعد تشغيل السكريبت، حاول إضافة عنوان جديد من التطبيق
-- 4. إذا واجهت مشكلة، تحقق من قيمة auth.uid() في التطبيق

-- اختبار بسيط:
-- SELECT auth.uid(); -- يجب أن يرجع UUID المستخدم الحالي
-- SELECT * FROM addresses WHERE user_id = auth.uid(); -- يجب أن يعرض العناوين

