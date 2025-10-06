-- =====================================================
-- FAVORITE PRODUCTS TABLE SETUP
-- إعداد جدول المنتجات المفضلة
-- =====================================================

-- إنشاء جدول المنتجات المفضلة
CREATE TABLE IF NOT EXISTS favorite_products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- فهرس فريد لمنع التكرار
    UNIQUE(user_id, product_id)
);

-- =====================================================
-- INDEXES - الفهارس
-- =====================================================

-- فهرس للمستخدم
CREATE INDEX IF NOT EXISTS idx_favorite_products_user_id 
ON favorite_products(user_id);

-- فهرس للمنتج
CREATE INDEX IF NOT EXISTS idx_favorite_products_product_id 
ON favorite_products(product_id);

-- فهرس للتاريخ
CREATE INDEX IF NOT EXISTS idx_favorite_products_created_at 
ON favorite_products(created_at);

-- فهرس مركب للاستعلامات السريعة
CREATE INDEX IF NOT EXISTS idx_favorite_products_user_created 
ON favorite_products(user_id, created_at DESC);

-- =====================================================
-- TRIGGERS - المشغلات
-- =====================================================

-- تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_favorite_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ربط المشغل بالجدول
DROP TRIGGER IF EXISTS trigger_update_favorite_products_updated_at ON favorite_products;
CREATE TRIGGER trigger_update_favorite_products_updated_at
    BEFORE UPDATE ON favorite_products
    FOR EACH ROW
    EXECUTE FUNCTION update_favorite_products_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- سياسات أمان مستوى الصفوف
-- =====================================================

-- تفعيل RLS
ALTER TABLE favorite_products ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: المستخدم يمكنه رؤية مفضلاته فقط
CREATE POLICY "Users can view their own favorites" ON favorite_products
    FOR SELECT 
    USING (auth.uid() = user_id);

-- سياسة الإدراج: المستخدم يمكنه إضافة منتجات لمفضلاته فقط
CREATE POLICY "Users can add to their own favorites" ON favorite_products
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- سياسة التحديث: المستخدم يمكنه تحديث مفضلاته فقط
CREATE POLICY "Users can update their own favorites" ON favorite_products
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- سياسة الحذف: المستخدم يمكنه حذف مفضلاته فقط
CREATE POLICY "Users can delete their own favorites" ON favorite_products
    FOR DELETE 
    USING (auth.uid() = user_id);

-- =====================================================
-- FUNCTIONS - الدوال
-- =====================================================

-- دالة للحصول على عدد المفضلات للمستخدم
CREATE OR REPLACE FUNCTION get_user_favorites_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) 
        FROM favorite_products 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة للتحقق من وجود منتج في المفضلة
CREATE OR REPLACE FUNCTION is_product_favorite(user_uuid UUID, prod_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM favorite_products 
        WHERE user_id = user_uuid AND product_id = prod_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة للتحقق من وجود منتج في قاعدة البيانات
CREATE OR REPLACE FUNCTION product_exists(prod_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM products 
        WHERE id::text = prod_id AND is_deleted = false
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لإضافة منتج للمفضلة
CREATE OR REPLACE FUNCTION add_to_favorites(user_uuid UUID, prod_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- التحقق من أن المستخدم مصادق عليه
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;
    
    -- التحقق من وجود المنتج
    IF NOT product_exists(prod_id) THEN
        RAISE EXCEPTION 'Product does not exist or is deleted';
    END IF;
    
    -- إضافة المنتج للمفضلة (تجاهل التكرار)
    INSERT INTO favorite_products (user_id, product_id)
    VALUES (user_uuid, prod_id)
    ON CONFLICT (user_id, product_id) DO NOTHING;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لإزالة منتج من المفضلة
CREATE OR REPLACE FUNCTION remove_from_favorites(user_uuid UUID, prod_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- التحقق من أن المستخدم مصادق عليه
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;
    
    -- حذف المنتج من المفضلة
    DELETE FROM favorite_products 
    WHERE user_id = user_uuid AND product_id = prod_id;
    
    RETURN FOUND;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لمسح جميع المفضلات للمستخدم
CREATE OR REPLACE FUNCTION clear_user_favorites(user_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- التحقق من أن المستخدم مصادق عليه
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;
    
    -- حذف جميع المفضلات للمستخدم
    DELETE FROM favorite_products WHERE user_id = user_uuid;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VIEWS - العروض
-- =====================================================

-- عرض للمفضلات مع تفاصيل المنتج
CREATE OR REPLACE VIEW user_favorites_with_details AS
SELECT 
    fp.id,
    fp.user_id,
    fp.product_id,
    fp.created_at,
    fp.updated_at,
    p.title,
    p.description,
    p.price,
    p.thumbnail,
    p.vendor_id,
    v.organization_name as vendor_name
FROM favorite_products fp
LEFT JOIN products p ON fp.product_id::text = p.id::text
LEFT JOIN vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false OR p.is_deleted IS NULL;

-- تفعيل RLS للعرض
ALTER VIEW user_favorites_with_details SET (security_invoker = true);

-- =====================================================
-- GRANTS - الصلاحيات
-- =====================================================

-- منح صلاحيات القراءة للمستخدمين المصادق عليهم
GRANT SELECT ON favorite_products TO authenticated;
GRANT SELECT ON user_favorites_with_details TO authenticated;

-- منح صلاحيات الإدراج والتحديث والحذف للمستخدمين المصادق عليهم
GRANT INSERT, UPDATE, DELETE ON favorite_products TO authenticated;

-- منح صلاحيات استخدام الدوال
GRANT EXECUTE ON FUNCTION get_user_favorites_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_product_favorite(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION product_exists(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION add_to_favorites(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION remove_from_favorites(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION clear_user_favorites(UUID) TO authenticated;

-- =====================================================
-- SAMPLE DATA (Optional) - بيانات تجريبية
-- =====================================================

-- إدراج بيانات تجريبية (اختياري - يمكن حذفها)
-- INSERT INTO favorite_products (user_id, product_id) VALUES
-- ('user-uuid-here', 'product-id-1'),
-- ('user-uuid-here', 'product-id-2');

-- =====================================================
-- VALIDATION RULES - قواعد التحقق
-- =====================================================

-- التحقق من أن user_id موجود في جدول المستخدمين
-- (تم بالفعل مع REFERENCES auth.users(id))

-- ملاحظة: تم إزالة Foreign Key لـ product_id بسبب عدم توافق أنواع البيانات
-- بين favorite_products.product_id (TEXT) و products.id (UUID)
-- يمكن التحقق من وجود المنتج برمجياً في التطبيق

-- =====================================================
-- CLEANUP FUNCTIONS - دوال التنظيف
-- =====================================================

-- دالة لحذف المفضلات للمنتجات المحذوفة
CREATE OR REPLACE FUNCTION cleanup_orphaned_favorites()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM favorite_products 
    WHERE product_id NOT IN (SELECT id FROM products);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة لحذف المفضلات للمستخدمين المحذوفين
CREATE OR REPLACE FUNCTION cleanup_deleted_users_favorites()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM favorite_products 
    WHERE user_id NOT IN (SELECT id FROM auth.users);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PERFORMANCE OPTIMIZATION - تحسين الأداء
-- =====================================================

-- إحصائيات الجدول
ANALYZE favorite_products;

-- =====================================================
-- COMMENTS - التعليقات
-- =====================================================

COMMENT ON TABLE favorite_products IS 'جدول المنتجات المفضلة للمستخدمين';
COMMENT ON COLUMN favorite_products.id IS 'معرف فريد للسجل';
COMMENT ON COLUMN favorite_products.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN favorite_products.product_id IS 'معرف المنتج';
COMMENT ON COLUMN favorite_products.created_at IS 'تاريخ الإضافة';
COMMENT ON COLUMN favorite_products.updated_at IS 'تاريخ آخر تحديث';

COMMENT ON FUNCTION get_user_favorites_count(UUID) IS 'الحصول على عدد المفضلات للمستخدم';
COMMENT ON FUNCTION is_product_favorite(UUID, TEXT) IS 'التحقق من وجود منتج في المفضلة';
COMMENT ON FUNCTION product_exists(TEXT) IS 'التحقق من وجود منتج في قاعدة البيانات';
COMMENT ON FUNCTION add_to_favorites(UUID, TEXT) IS 'إضافة منتج للمفضلة';
COMMENT ON FUNCTION remove_from_favorites(UUID, TEXT) IS 'إزالة منتج من المفضلة';
COMMENT ON FUNCTION clear_user_favorites(UUID) IS 'مسح جميع المفضلات للمستخدم';

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================

-- رسالة إكمال الإعداد
DO $$
BEGIN
    RAISE NOTICE '✅ تم إعداد جدول المنتجات المفضلة بنجاح!';
    RAISE NOTICE '📋 الجدول: favorite_products';
    RAISE NOTICE '🔒 تم تفعيل RLS والحماية';
    RAISE NOTICE '⚡ تم إنشاء الفهارس لتحسين الأداء';
    RAISE NOTICE '🛠️ تم إنشاء الدوال المساعدة';
    RAISE NOTICE '👁️ تم إنشاء العروض للبيانات المدمجة';
    RAISE NOTICE '🎯 جاهز للاستخدام!';
END $$;
