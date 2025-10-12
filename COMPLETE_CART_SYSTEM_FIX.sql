-- ═══════════════════════════════════════════════════════════════
-- سكريبت إصلاح شامل لنظام السلة (Cart System)
-- هذا السكريبت يصلح جميع المشاكل المحتملة في نظام السلة
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 1: حذف الجدول والسياسات القديمة (إعادة تعيين كاملة)
-- ═══════════════════════════════════════════════════════════════

-- حذف السياسات القديمة
DROP POLICY IF EXISTS "Users can view their own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can insert their own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can update their own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can delete their own cart items" ON cart_items;

-- حذف المشغلات (Triggers)
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON cart_items;

-- حذف الفهارس (Indexes)
DROP INDEX IF EXISTS idx_cart_items_user_id;
DROP INDEX IF EXISTS idx_cart_items_product_id;
DROP INDEX IF EXISTS idx_cart_items_vendor_id;

-- حذف العروض (Views)
DROP VIEW IF EXISTS cart_summary;

-- حذف الدوال (Functions)
DROP FUNCTION IF EXISTS clear_user_cart(UUID);
DROP FUNCTION IF EXISTS get_cart_items_count(UUID);
DROP FUNCTION IF EXISTS get_cart_total_value(UUID);

-- حذف الجدول (⚠️ سيحذف جميع البيانات!)
-- DROP TABLE IF EXISTS cart_items CASCADE;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 2: إنشاء جدول cart_items
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  vendor_id TEXT,
  title TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  image TEXT,
  total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- قيد فريد: منتج واحد لكل مستخدم (منع التكرار)
  CONSTRAINT unique_user_product UNIQUE (user_id, product_id)
);

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 3: إنشاء الفهارس (Indexes) لتحسين الأداء
-- ═══════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_cart_items_user_id 
ON cart_items(user_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_product_id 
ON cart_items(product_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_vendor_id 
ON cart_items(vendor_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_created_at 
ON cart_items(created_at DESC);

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 4: إنشاء دالة تحديث updated_at تلقائياً
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 5: إنشاء المشغل (Trigger)
-- ═══════════════════════════════════════════════════════════════

CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON cart_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 6: تفعيل Row Level Security (RLS)
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 7: إنشاء سياسات RLS الصحيحة
-- ═══════════════════════════════════════════════════════════════

-- سياسة القراءة (SELECT)
CREATE POLICY "cart_items_select_policy" 
ON cart_items 
FOR SELECT 
USING (auth.uid() = user_id);

-- سياسة الإضافة (INSERT)
CREATE POLICY "cart_items_insert_policy" 
ON cart_items 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- سياسة التحديث (UPDATE)
CREATE POLICY "cart_items_update_policy" 
ON cart_items 
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- سياسة الحذف (DELETE)
CREATE POLICY "cart_items_delete_policy" 
ON cart_items 
FOR DELETE 
USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 8: منح الصلاحيات (Permissions)
-- ═══════════════════════════════════════════════════════════════

-- منح صلاحيات CRUD للمستخدمين المصادق عليهم
GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;
GRANT USAGE ON SEQUENCE cart_items_id_seq TO authenticated;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 9: إنشاء عرض (View) لملخص السلة
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW cart_summary AS
SELECT 
    user_id,
    COUNT(*) as total_items,
    SUM(quantity) as total_quantity,
    SUM(total_price) as total_value,
    COUNT(DISTINCT vendor_id) as unique_vendors,
    MIN(created_at) as first_added,
    MAX(updated_at) as last_updated
FROM cart_items
GROUP BY user_id;

-- منح صلاحية القراءة على العرض
GRANT SELECT ON cart_summary TO authenticated;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 10: إنشاء الدوال المساعدة (Helper Functions)
-- ═══════════════════════════════════════════════════════════════

-- دالة مسح سلة المستخدم
CREATE OR REPLACE FUNCTION clear_user_cart(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cart_items WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة الحصول على عدد العناصر
CREATE OR REPLACE FUNCTION get_cart_items_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(quantity), 0)::INTEGER
        FROM cart_items 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة الحصول على إجمالي قيمة السلة
CREATE OR REPLACE FUNCTION get_cart_total_value(user_uuid UUID)
RETURNS DECIMAL(10,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(total_price), 0.00)
        FROM cart_items 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة إضافة أو تحديث عنصر في السلة
CREATE OR REPLACE FUNCTION upsert_cart_item(
    p_user_id UUID,
    p_product_id TEXT,
    p_vendor_id TEXT,
    p_title TEXT,
    p_price DECIMAL,
    p_quantity INTEGER,
    p_image TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO cart_items (
        user_id, 
        product_id, 
        vendor_id, 
        title, 
        price, 
        quantity, 
        image, 
        total_price
    )
    VALUES (
        p_user_id,
        p_product_id,
        p_vendor_id,
        p_title,
        p_price,
        p_quantity,
        p_image,
        p_price * p_quantity
    )
    ON CONFLICT (user_id, product_id) 
    DO UPDATE SET
        quantity = cart_items.quantity + EXCLUDED.quantity,
        total_price = (cart_items.quantity + EXCLUDED.quantity) * cart_items.price,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- منح صلاحيات التنفيذ للدوال
GRANT EXECUTE ON FUNCTION clear_user_cart(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_cart_items_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_cart_total_value(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_cart_item(UUID, TEXT, TEXT, TEXT, DECIMAL, INTEGER, TEXT) TO authenticated;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 11: التحقق من التطبيق
-- ═══════════════════════════════════════════════════════════════

-- التحقق من بنية الجدول
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'cart_items'
ORDER BY ordinal_position;

-- التحقق من RLS
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'cart_items';

-- التحقق من السياسات
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual as "using_condition",
    with_check as "with_check_condition"
FROM pg_policies
WHERE tablename = 'cart_items'
ORDER BY cmd, policyname;

-- التحقق من الفهارس
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'cart_items'
ORDER BY indexname;

-- التحقق من الصلاحيات
SELECT 
    grantee,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'cart_items'
    AND grantee = 'authenticated'
ORDER BY privilege_type;

-- التحقق من الدوال
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_name IN (
    'clear_user_cart',
    'get_cart_items_count',
    'get_cart_total_value',
    'upsert_cart_item',
    'update_updated_at_column'
)
ORDER BY routine_name;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 12: اختبار النظام
-- ═══════════════════════════════════════════════════════════════

-- اختبار إضافة عنصر للسلة
-- استبدل القيم التالية:
-- - auth.uid(): معرف المستخدم الحالي
-- - 'product_123': معرف المنتج
-- - 'vendor_456': معرف البائع
-- - 'Test Product': اسم المنتج
-- - 19.99: السعر
-- - 1: الكمية
-- - 'https://...': رابط الصورة

/*
-- اختبار الإضافة
INSERT INTO cart_items (user_id, product_id, vendor_id, title, price, quantity, image, total_price)
VALUES (
    auth.uid(),
    'test_product_id',
    'test_vendor_id',
    'Test Product',
    19.99,
    1,
    'https://example.com/image.jpg',
    19.99
);

-- التحقق من الإضافة
SELECT * FROM cart_items WHERE user_id = auth.uid();

-- اختبار التحديث
UPDATE cart_items 
SET quantity = 2,
    total_price = 2 * price
WHERE user_id = auth.uid() 
    AND product_id = 'test_product_id';

-- اختبار الحذف
DELETE FROM cart_items 
WHERE user_id = auth.uid() 
    AND product_id = 'test_product_id';

-- اختبار دالة upsert
SELECT upsert_cart_item(
    auth.uid(),
    'test_product_id',
    'test_vendor_id',
    'Test Product',
    19.99,
    1,
    'https://example.com/image.jpg'
);

-- التحقق من النتيجة
SELECT * FROM cart_items WHERE user_id = auth.uid();
*/

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 13: فحص الأخطاء الشائعة
-- ═══════════════════════════════════════════════════════════════

-- 1. التحقق من أن الجدول موجود
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'cart_items'
) as table_exists;

-- 2. التحقق من تفعيل RLS
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'cart_items';

-- 3. التحقق من وجود السياسات الأربعة
SELECT COUNT(*) as policy_count,
    SUM(CASE WHEN cmd = 'SELECT' THEN 1 ELSE 0 END) as select_policies,
    SUM(CASE WHEN cmd = 'INSERT' THEN 1 ELSE 0 END) as insert_policies,
    SUM(CASE WHEN cmd = 'UPDATE' THEN 1 ELSE 0 END) as update_policies,
    SUM(CASE WHEN cmd = 'DELETE' THEN 1 ELSE 0 END) as delete_policies
FROM pg_policies
WHERE tablename = 'cart_items';

-- يجب أن تكون النتيجة:
-- policy_count = 4
-- select_policies = 1
-- insert_policies = 1
-- update_policies = 1
-- delete_policies = 1

-- 4. التحقق من الصلاحيات
SELECT 
    COUNT(*) as privilege_count,
    array_agg(DISTINCT privilege_type ORDER BY privilege_type) as privileges
FROM information_schema.table_privileges
WHERE table_name = 'cart_items'
    AND grantee = 'authenticated';

-- يجب أن تحتوي على: SELECT, INSERT, UPDATE, DELETE

-- 5. التحقق من القيود (Constraints)
SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'cart_items'
ORDER BY constraint_type, constraint_name;

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 14: إنشاء بيانات اختبارية (اختياري)
-- ═══════════════════════════════════════════════════════════════

/*
-- ⚠️ فقط للاختبار - احذف هذا في الإنتاج
INSERT INTO cart_items (user_id, product_id, vendor_id, title, price, quantity, image, total_price)
VALUES 
    (auth.uid(), 'prod_001', 'vendor_001', 'Product 1', 10.00, 1, null, 10.00),
    (auth.uid(), 'prod_002', 'vendor_001', 'Product 2', 15.00, 2, null, 30.00),
    (auth.uid(), 'prod_003', 'vendor_002', 'Product 3', 20.00, 1, null, 20.00)
ON CONFLICT (user_id, product_id) DO NOTHING;

-- عرض البيانات الاختبارية
SELECT 
    product_id,
    title,
    price,
    quantity,
    total_price,
    vendor_id
FROM cart_items 
WHERE user_id = auth.uid()
ORDER BY created_at;

-- حذف البيانات الاختبارية
-- DELETE FROM cart_items WHERE user_id = auth.uid();
*/

-- ═══════════════════════════════════════════════════════════════
-- الخطوة 15: تقرير نهائي
-- ═══════════════════════════════════════════════════════════════

DO $$
DECLARE
    table_exists BOOLEAN;
    rls_enabled BOOLEAN;
    policy_count INTEGER;
    privilege_count INTEGER;
BEGIN
    -- التحقق من الجدول
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'cart_items'
    ) INTO table_exists;
    
    -- التحقق من RLS
    SELECT rowsecurity 
    FROM pg_tables 
    WHERE tablename = 'cart_items'
    INTO rls_enabled;
    
    -- عدد السياسات
    SELECT COUNT(*) 
    FROM pg_policies 
    WHERE tablename = 'cart_items'
    INTO policy_count;
    
    -- عدد الصلاحيات
    SELECT COUNT(DISTINCT privilege_type)
    FROM information_schema.table_privileges
    WHERE table_name = 'cart_items' AND grantee = 'authenticated'
    INTO privilege_count;
    
    -- طباعة التقرير
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'تقرير نظام السلة (Cart System Report)';
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE 'الجدول موجود: %', CASE WHEN table_exists THEN '✅ نعم' ELSE '❌ لا' END;
    RAISE NOTICE 'RLS مفعل: %', CASE WHEN rls_enabled THEN '✅ نعم' ELSE '❌ لا' END;
    RAISE NOTICE 'عدد السياسات: % (المطلوب: 4)', policy_count;
    RAISE NOTICE 'عدد الصلاحيات: % (المطلوب: 4)', privilege_count;
    RAISE NOTICE '═══════════════════════════════════════════════';
    
    IF table_exists AND rls_enabled AND policy_count >= 4 AND privilege_count >= 4 THEN
        RAISE NOTICE '🎉 النظام جاهز وصحيح!';
    ELSE
        RAISE NOTICE '⚠️ هناك مشاكل تحتاج إلى إصلاح';
    END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- ملاحظات مهمة:
-- ═══════════════════════════════════════════════════════════════
-- 
-- 1. نفذ هذا السكريبت بالكامل في Supabase SQL Editor
-- 2. إذا كنت تريد الاحتفاظ بالبيانات الحالية، لا تحذف الجدول
-- 3. السياسات تسمح للمستخدمين بالوصول لسلتهم فقط
-- 4. الدالة upsert_cart_item تضيف أو تحدث الكمية تلقائياً
-- 5. القيد UNIQUE يمنع تكرار نفس المنتج لنفس المستخدم
-- 
-- ═══════════════════════════════════════════════════════════════

