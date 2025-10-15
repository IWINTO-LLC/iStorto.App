-- ============================================
-- إصلاح Function get_or_create_conversation
-- Fix: Structure of query does not match function result type
-- ============================================

-- حذف Function القديمة
DROP FUNCTION IF EXISTS get_or_create_conversation(UUID, UUID);

-- إعادة إنشاء Function بالهيكل الصحيح
CREATE OR REPLACE FUNCTION get_or_create_conversation(
    p_user_id UUID,
    p_vendor_id UUID
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    vendor_id UUID,
    last_message_id UUID,
    last_message_text TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    is_archived BOOLEAN,
    is_favorite BOOLEAN,
    is_muted BOOLEAN,
    user_unread_count INTEGER,
    vendor_unread_count INTEGER,
    last_read_by_user_at TIMESTAMP WITH TIME ZONE,
    last_read_by_vendor_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    vendor_store_name TEXT,
    vendor_image_url TEXT,
    vendor_brief TEXT,
    user_name TEXT,
    user_image_url TEXT,
    last_message_content TEXT,
    last_message_sender_type TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE
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
    END IF;
    
    -- إرجاع المحادثة مع التفاصيل الكاملة من الـ View
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
        cd.user_unread_count,
        cd.vendor_unread_count,
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

-- تعليق
COMMENT ON FUNCTION get_or_create_conversation IS 'يبحث عن محادثة موجودة أو ينشئ واحدة جديدة ويرجع التفاصيل الكاملة';

-- ============================================
-- اختبار Function
-- ============================================

-- للاختبار (استبدل بمعرفات حقيقية):
-- SELECT * FROM get_or_create_conversation(
--     'user-uuid-here'::UUID,
--     'vendor-uuid-here'::UUID
-- );

-- ============================================
-- تحقق من الهيكل
-- ============================================

-- عرض هيكل Function للتأكد من صحته
SELECT 
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
WHERE p.proname = 'get_or_create_conversation';

-- ✅ يجب أن ترى:
-- return_type: TABLE(id uuid, user_id uuid, ... user_unread_count integer ...)

RAISE NOTICE '✅ Function تم إصلاحها بنجاح!';

