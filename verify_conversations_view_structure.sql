-- ============================================
-- التحقق من هيكل conversations_with_details View
-- ============================================

-- 1. عرض أعمدة الـ View
SELECT 
    column_name,
    ordinal_position,
    data_type
FROM information_schema.columns
WHERE table_name = 'conversations_with_details'
ORDER BY ordinal_position;

-- ============================================
-- النتيجة المتوقعة (يجب أن يكون الترتيب كالتالي):
-- ============================================
/*
1.  id - uuid
2.  user_id - uuid
3.  vendor_id - uuid
4.  last_message_id - uuid
5.  last_message_text - text
6.  last_message_at - timestamp with time zone
7.  is_archived - boolean
8.  is_favorite - boolean
9.  is_muted - boolean
10. user_unread_count - integer  ← يجب أن يكون integer
11. vendor_unread_count - integer
12. last_read_by_user_at - timestamp with time zone
13. last_read_by_vendor_at - timestamp with time zone
14. created_at - timestamp with time zone
15. updated_at - timestamp with time zone
16. vendor_store_name - text
17. vendor_image_url - text
18. vendor_brief - text
19. user_name - text
20. user_image_url - text
21. last_message_content - text
22. last_message_sender_type - text
23. last_message_time - timestamp with time zone
*/

-- ============================================
-- إذا كان هناك خطأ، أعد إنشاء الـ View:
-- ============================================

DROP VIEW IF EXISTS conversations_with_details CASCADE;

CREATE OR REPLACE VIEW conversations_with_details AS
SELECT 
    c.id,
    c.user_id,
    c.vendor_id,
    c.last_message_id,
    c.last_message_text,
    c.last_message_at,
    c.is_archived,
    c.is_favorite,
    c.is_muted,
    c.user_unread_count,        -- integer (العمود 10)
    c.vendor_unread_count,      -- integer (العمود 11)
    c.last_read_by_user_at,     -- timestamp (العمود 12)
    c.last_read_by_vendor_at,   -- timestamp (العمود 13)
    c.created_at,
    c.updated_at,
    
    -- معلومات التاجر
    v.organization_name AS vendor_store_name,
    v.organization_logo AS vendor_image_url,
    v.brief AS vendor_brief,
    
    -- معلومات المستخدم
    up.full_name AS user_name,
    up.profile_image AS user_image_url,
    
    -- معلومات آخر رسالة
    m.content AS last_message_content,
    m.sender_type AS last_message_sender_type,
    m.created_at AS last_message_time
    
FROM public.conversations c
LEFT JOIN public.vendors v ON c.vendor_id = v.id
LEFT JOIN public.user_profiles up ON c.user_id = up.id
LEFT JOIN public.messages m ON c.last_message_id = m.id;

-- منح الصلاحيات
GRANT SELECT ON conversations_with_details TO authenticated;
GRANT SELECT ON conversations_with_details TO anon;

-- تعليق
COMMENT ON VIEW conversations_with_details IS 'عرض تفاصيل المحادثات مع معلومات التاجر والمستخدم وآخر رسالة';

-- ============================================
-- اختبار النتيجة
-- ============================================

-- عرض أول محادثة للتحقق من الهيكل
SELECT * FROM conversations_with_details LIMIT 1;

RAISE NOTICE '✅ View تم التحقق منها وإعادة إنشائها!';

