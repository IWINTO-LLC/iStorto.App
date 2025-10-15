-- ============================================
-- الإصلاح النهائي لـ get_or_create_conversation
-- مطابق تماماً لبنية الجداول
-- ============================================
-- الأخطاء المصححة:
-- 1. up.full_name → up.name ✅
-- 2. ترتيب الأعمدة الصحيح ✅
-- ============================================

-- الخطوة 1: حذف الـ Function والـ View القديمة
DROP FUNCTION IF EXISTS get_or_create_conversation(UUID, UUID) CASCADE;
DROP VIEW IF EXISTS conversations_with_details CASCADE;

-- الخطوة 2: إعادة إنشاء الـ View بأسماء الأعمدة الصحيحة
CREATE OR REPLACE VIEW conversations_with_details AS
SELECT 
    -- معلومات المحادثة الأساسية (1-9)
    c.id,                           -- 1: UUID
    c.user_id,                      -- 2: UUID
    c.vendor_id,                    -- 3: UUID
    c.last_message_id,              -- 4: UUID
    c.last_message_text,            -- 5: TEXT
    c.last_message_at,              -- 6: TIMESTAMP
    c.is_archived,                  -- 7: BOOLEAN
    c.is_favorite,                  -- 8: BOOLEAN
    c.is_muted,                     -- 9: BOOLEAN
    
    -- العدادات (10-11) - INTEGER
    c.user_unread_count,            -- 10: INTEGER ✅
    c.vendor_unread_count,          -- 11: INTEGER ✅
    
    -- تواريخ القراءة (12-13)
    c.last_read_by_user_at,         -- 12: TIMESTAMP
    c.last_read_by_vendor_at,       -- 13: TIMESTAMP
    
    -- تواريخ الإنشاء والتحديث (14-15)
    c.created_at,                   -- 14: TIMESTAMP
    c.updated_at,                   -- 15: TIMESTAMP
    
    -- معلومات التاجر (16-18) - من جدول vendors
    v.organization_name AS vendor_store_name,   -- 16: TEXT ✅
    v.organization_logo AS vendor_image_url,    -- 17: TEXT ✅
    v.brief AS vendor_brief,                    -- 18: TEXT ✅
    
    -- معلومات المستخدم (19-20) - من جدول user_profiles
    up.name AS user_name,                       -- 19: TEXT ✅ (name وليس full_name)
    up.profile_image AS user_image_url,         -- 20: TEXT ✅
    
    -- معلومات آخر رسالة (21-23) - من جدول messages
    m.message_text AS last_message_content,     -- 21: TEXT ✅ (message_text وليس content)
    m.sender_type AS last_message_sender_type,  -- 22: TEXT
    m.created_at AS last_message_time           -- 23: TIMESTAMP
    
FROM public.conversations c
LEFT JOIN public.vendors v ON c.vendor_id = v.id
LEFT JOIN public.user_profiles up ON c.user_id = up.id
LEFT JOIN public.messages m ON c.last_message_id = m.id;

-- منح الصلاحيات على الـ View
GRANT SELECT ON conversations_with_details TO authenticated;
GRANT SELECT ON conversations_with_details TO anon;

COMMENT ON VIEW conversations_with_details IS 'عرض تفاصيل المحادثات مع معلومات التاجر والمستخدم وآخر رسالة (مصحح)';

-- الخطوة 3: إنشاء الـ Function بنفس الترتيب
CREATE OR REPLACE FUNCTION get_or_create_conversation(
    p_user_id UUID,
    p_vendor_id UUID
)
RETURNS TABLE (
    id UUID,                                    -- 1
    user_id UUID,                               -- 2
    vendor_id UUID,                             -- 3
    last_message_id UUID,                       -- 4
    last_message_text TEXT,                     -- 5
    last_message_at TIMESTAMP WITH TIME ZONE,   -- 6
    is_archived BOOLEAN,                        -- 7
    is_favorite BOOLEAN,                        -- 8
    is_muted BOOLEAN,                           -- 9
    user_unread_count INTEGER,                  -- 10 ✅
    vendor_unread_count INTEGER,                -- 11 ✅
    last_read_by_user_at TIMESTAMP WITH TIME ZONE,      -- 12
    last_read_by_vendor_at TIMESTAMP WITH TIME ZONE,    -- 13
    created_at TIMESTAMP WITH TIME ZONE,        -- 14
    updated_at TIMESTAMP WITH TIME ZONE,        -- 15
    vendor_store_name TEXT,                     -- 16
    vendor_image_url TEXT,                      -- 17
    vendor_brief TEXT,                          -- 18
    user_name TEXT,                             -- 19
    user_image_url TEXT,                        -- 20
    last_message_content TEXT,                  -- 21
    last_message_sender_type TEXT,              -- 22
    last_message_time TIMESTAMP WITH TIME ZONE  -- 23
) AS $$
DECLARE
    v_conversation_id UUID;
BEGIN
    -- محاولة العثور على محادثة موجودة
    SELECT c.id INTO v_conversation_id
    FROM public.conversations c
    WHERE c.user_id = p_user_id AND c.vendor_id = p_vendor_id;
    
    -- إذا لم توجد محادثة، أنشئ واحدة جديدة
    IF v_conversation_id IS NULL THEN
        INSERT INTO public.conversations (user_id, vendor_id)
        VALUES (p_user_id, p_vendor_id)
        RETURNING conversations.id INTO v_conversation_id;
        
        RAISE NOTICE '✅ محادثة جديدة تم إنشاؤها: %', v_conversation_id;
    ELSE
        RAISE NOTICE '✅ محادثة موجودة: %', v_conversation_id;
    END IF;
    
    -- إرجاع المحادثة مع التفاصيل الكاملة
    RETURN QUERY
    SELECT 
        cd.id,
        cd.user_id,
        cd.vendor_id,
        cd.last_message_id,
        cd.last_message_text,
        cd.last_message_at,
        cd.is_archived,
        cd.is_favorite,
        cd.is_muted,
        cd.user_unread_count,           -- INTEGER
        cd.vendor_unread_count,         -- INTEGER
        cd.last_read_by_user_at,
        cd.last_read_by_vendor_at,
        cd.created_at,
        cd.updated_at,
        cd.vendor_store_name,
        cd.vendor_image_url,
        cd.vendor_brief,
        cd.user_name,
        cd.user_image_url,
        cd.last_message_content,
        cd.last_message_sender_type,
        cd.last_message_time
    FROM conversations_with_details cd
    WHERE cd.id = v_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION get_or_create_conversation(UUID, UUID) TO authenticated;

COMMENT ON FUNCTION get_or_create_conversation IS 'يبحث عن محادثة موجودة أو ينشئ واحدة جديدة ويرجع التفاصيل الكاملة (مصحح)';

-- ============================================
-- التحقق من الإصلاح
-- ============================================

-- 1. التحقق من هيكل الـ View
SELECT 
    column_name,
    ordinal_position,
    data_type
FROM information_schema.columns
WHERE table_name = 'conversations_with_details'
ORDER BY ordinal_position;

-- النتيجة المتوقعة:
-- العمود 10: user_unread_count - integer
-- العمود 11: vendor_unread_count - integer
-- العمود 19: user_name - text (من up.name)

-- 2. التحقق من الـ Function
SELECT 
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
WHERE p.proname = 'get_or_create_conversation';

-- ============================================
-- اختبار الـ Function
-- ============================================

-- للاختبار (استبدل بمعرفات حقيقية):
/*
SELECT * FROM get_or_create_conversation(
    'user-uuid-here'::UUID,
    'vendor-uuid-here'::UUID
);
*/

-- ============================================
-- مرجع أسماء الأعمدة الصحيحة
-- ============================================

/*
من جدول vendors:
  ✅ organization_name (store name)
  ✅ organization_logo (vendor image)
  ✅ brief (vendor brief/slug)

من جدول user_profiles:
  ✅ name (اسم المستخدم) - وليس full_name
  ✅ profile_image (صورة المستخدم)
  ✅ user_id (معرف المستخدم في Auth)
  ✅ id (UUID الأساسي)
*/

-- ============================================
-- ملخص التصحيحات
-- ============================================

/*
✅ تم إصلاح:
1. up.full_name → up.name (صحيح الآن)
2. ترتيب الأعمدة بحيث:
   - العمود 10: user_unread_count (INTEGER)
   - العمود 11: vendor_unread_count (INTEGER)
3. جميع أسماء الأعمدة تطابق البنية الفعلية في ss.sql

⚠️ الأخطاء السابقة:
1. up.full_name (غير موجود) → up.name (صحيح)
2. العمود 11 كان timestamp → الآن integer

📝 الاختبار:
1. شغّل هذا السكريبت في Supabase
2. أعد تشغيل التطبيق
3. جرّب بدء محادثة
4. يجب أن يعمل بدون أخطاء! ✅
*/

RAISE NOTICE '✅✅✅ تم إصلاح get_or_create_conversation بأسماء الأعمدة الصحيحة! ✅✅✅';

