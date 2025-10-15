-- ============================================
-- نظام الدردشة الكامل مع RLS Policies
-- Chat System with Complete RLS Policies
-- ============================================

-- 1. إنشاء جدول المحادثات (Conversations)
-- ============================================

CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    
    -- آخر رسالة
    last_message_id UUID,
    last_message_text TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    
    -- إعدادات المستخدم
    is_archived BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,
    is_muted BOOLEAN DEFAULT FALSE,
    user_unread_count INTEGER DEFAULT 0,
    last_read_by_user_at TIMESTAMP WITH TIME ZONE,
    
    -- إعدادات التاجر
    vendor_unread_count INTEGER DEFAULT 0,
    last_read_by_vendor_at TIMESTAMP WITH TIME ZONE,
    
    -- تواريخ الإنشاء والتحديث
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- قيد فريد لضمان محادثة واحدة بين مستخدم وتاجر
    UNIQUE (user_id, vendor_id)
);

-- 2. إنشاء جدول الرسائل (Messages)
-- ============================================

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    
    -- معلومات المرسل
    sender_id UUID NOT NULL,
    sender_type TEXT NOT NULL CHECK (sender_type IN ('user', 'vendor')),
    
    -- محتوى الرسالة
    message_text TEXT,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location', 'video', 'audio')),
    
    -- المرفقات
    attachment_url TEXT,
    attachment_name TEXT,
    attachment_size INTEGER,
    
    -- حالة القراءة
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- الرد على رسالة
    reply_to_message_id UUID REFERENCES public.messages(id) ON DELETE SET NULL,
    
    -- التواريخ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. إنشاء Indexes للأداء
-- ============================================

-- Indexes للمحادثات
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_vendor_id ON public.conversations(vendor_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at ON public.conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_user_archived ON public.conversations(user_id, is_archived);
CREATE INDEX IF NOT EXISTS idx_conversations_user_favorite ON public.conversations(user_id, is_favorite);

-- Indexes للرسائل
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON public.messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON public.messages(conversation_id, is_read);

-- 4. إنشاء Functions و Triggers
-- ============================================

-- Function لتحديث updated_at
CREATE OR REPLACE FUNCTION update_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث updated_at عند تعديل المحادثة
DROP TRIGGER IF EXISTS update_conversations_updated_at_trigger ON public.conversations;
CREATE TRIGGER update_conversations_updated_at_trigger
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_conversations_updated_at();

-- Function لتحديث المحادثة عند إضافة رسالة جديدة
CREATE OR REPLACE FUNCTION update_conversation_on_new_message()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_vendor_id UUID;
BEGIN
    -- الحصول على معلومات المحادثة
    SELECT user_id, vendor_id INTO v_user_id, v_vendor_id
    FROM public.conversations
    WHERE id = NEW.conversation_id;
    
    -- تحديث آخر رسالة في المحادثة
    UPDATE public.conversations
    SET 
        last_message_id = NEW.id,
        last_message_text = NEW.message_text,
        last_message_at = NEW.created_at,
        updated_at = NOW(),
        -- زيادة عداد الرسائل غير المقروءة حسب المرسل
        user_unread_count = CASE 
            WHEN NEW.sender_type = 'vendor' THEN user_unread_count + 1
            ELSE user_unread_count
        END,
        vendor_unread_count = CASE 
            WHEN NEW.sender_type = 'user' THEN vendor_unread_count + 1
            ELSE vendor_unread_count
        END
    WHERE id = NEW.conversation_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث المحادثة عند إضافة رسالة
DROP TRIGGER IF EXISTS update_conversation_on_new_message_trigger ON public.messages;
CREATE TRIGGER update_conversation_on_new_message_trigger
    AFTER INSERT ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_on_new_message();

-- Function لتمييز الرسائل كمقروءة
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    p_conversation_id UUID,
    p_reader_id UUID,
    p_reader_type TEXT
)
RETURNS void AS $$
BEGIN
    -- تحديث الرسائل غير المقروءة
    UPDATE public.messages
    SET 
        is_read = TRUE,
        read_at = NOW()
    WHERE 
        conversation_id = p_conversation_id
        AND is_read = FALSE
        AND (
            (p_reader_type = 'user' AND sender_type = 'vendor') OR
            (p_reader_type = 'vendor' AND sender_type = 'user')
        );
    
    -- إعادة تعيين عداد الرسائل غير المقروءة
    IF p_reader_type = 'user' THEN
        UPDATE public.conversations
        SET 
            user_unread_count = 0,
            last_read_by_user_at = NOW()
        WHERE id = p_conversation_id;
    ELSIF p_reader_type = 'vendor' THEN
        UPDATE public.conversations
        SET 
            vendor_unread_count = 0,
            last_read_by_vendor_at = NOW()
        WHERE id = p_conversation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function للحصول على محادثة أو إنشاؤها إذا لم تكن موجودة
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
    
    -- إرجاع المحادثة مع التفاصيل الكاملة
    RETURN QUERY
    SELECT * FROM conversations_with_details
    WHERE conversations_with_details.id = v_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. إنشاء View للمحادثات مع التفاصيل
-- ============================================

CREATE OR REPLACE VIEW conversations_with_details AS
SELECT 
    c.*,
    -- معلومات التاجر
    v.organization_name AS vendor_store_name,
    v.organization_logo AS vendor_image_url,
    v.brief AS vendor_brief,
    -- معلومات المستخدم
    up.name AS user_name,
    up.profile_image AS user_image_url,
    -- معلومات آخر رسالة
    m.message_text AS last_message_content,
    m.sender_type AS last_message_sender_type,
    m.created_at AS last_message_time
FROM 
    public.conversations c
    LEFT JOIN public.vendors v ON c.vendor_id = v.id
    LEFT JOIN public.user_profiles up ON c.user_id = up.id
    LEFT JOIN public.messages m ON c.last_message_id = m.id;

-- 6. إنشاء View للرسائل مع تفاصيل المرسل
-- ============================================

CREATE OR REPLACE VIEW messages_with_sender_details AS
SELECT 
    m.*,
    -- تفاصيل المرسل (مستخدم)
    CASE 
        WHEN m.sender_type = 'user' THEN up.name
        ELSE NULL
    END AS user_sender_name,
    CASE 
        WHEN m.sender_type = 'user' THEN up.profile_image
        ELSE NULL
    END AS user_sender_image,
    -- تفاصيل المرسل (تاجر)
    CASE 
        WHEN m.sender_type = 'vendor' THEN v.organization_name
        ELSE NULL
    END AS vendor_sender_name,
    CASE 
        WHEN m.sender_type = 'vendor' THEN v.organization_logo
        ELSE NULL
    END AS vendor_sender_image,
    -- اسم وصورة المرسل (موحد)
    CASE 
        WHEN m.sender_type = 'user' THEN up.name
        WHEN m.sender_type = 'vendor' THEN v.organization_name
        ELSE 'Unknown'
    END AS sender_name,
    CASE 
        WHEN m.sender_type = 'user' THEN up.profile_image
        WHEN m.sender_type = 'vendor' THEN v.organization_logo
        ELSE NULL
    END AS sender_image_url
FROM 
    public.messages m
    LEFT JOIN public.user_profiles up ON m.sender_id = up.id AND m.sender_type = 'user'
    LEFT JOIN public.vendors v ON m.sender_id = v.id AND m.sender_type = 'vendor';

-- 7. تفعيل Row Level Security (RLS)
-- ============================================

-- تفعيل RLS على جدول المحادثات
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- تفعيل RLS على جدول الرسائل
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 8. إنشاء RLS Policies للمحادثات
-- ============================================

-- حذف Policies القديمة إن وجدت
DROP POLICY IF EXISTS "Users can view their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Vendors can view their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Vendors can update their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can delete their own conversations" ON public.conversations;

-- Policy: المستخدمون يمكنهم رؤية محادثاتهم
CREATE POLICY "Users can view their own conversations"
    ON public.conversations
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: التجار يمكنهم رؤية محادثاتهم
CREATE POLICY "Vendors can view their conversations"
    ON public.conversations
    FOR SELECT
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy: المستخدمون يمكنهم إنشاء محادثات
CREATE POLICY "Users can create conversations"
    ON public.conversations
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: المستخدمون يمكنهم تحديث محادثاتهم
CREATE POLICY "Users can update their own conversations"
    ON public.conversations
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: التجار يمكنهم تحديث محادثاتهم
CREATE POLICY "Vendors can update their conversations"
    ON public.conversations
    FOR UPDATE
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy: المستخدمون يمكنهم حذف محادثاتهم
CREATE POLICY "Users can delete their own conversations"
    ON public.conversations
    FOR DELETE
    USING (auth.uid() = user_id);

-- 9. إنشاء RLS Policies للرسائل
-- ============================================

-- حذف Policies القديمة إن وجدت
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Vendors can view messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
DROP POLICY IF EXISTS "Vendors can send messages" ON public.messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON public.messages;
DROP POLICY IF EXISTS "Vendors can update their own messages" ON public.messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON public.messages;

-- Policy: المستخدمون يمكنهم رؤية رسائل محادثاتهم
CREATE POLICY "Users can view messages in their conversations"
    ON public.messages
    FOR SELECT
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    );

-- Policy: التجار يمكنهم رؤية رسائل محادثاتهم
CREATE POLICY "Vendors can view messages in their conversations"
    ON public.messages
    FOR SELECT
    USING (
        conversation_id IN (
            SELECT c.id 
            FROM public.conversations c
            INNER JOIN public.vendors v ON c.vendor_id = v.id
            WHERE v.user_id = auth.uid()
        )
    );

-- Policy: المستخدمون يمكنهم إرسال رسائل
CREATE POLICY "Users can send messages"
    ON public.messages
    FOR INSERT
    WITH CHECK (
        sender_type = 'user' 
        AND sender_id = auth.uid()
        AND conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    );

-- Policy: التجار يمكنهم إرسال رسائل
CREATE POLICY "Vendors can send messages"
    ON public.messages
    FOR INSERT
    WITH CHECK (
        sender_type = 'vendor'
        AND sender_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
        AND conversation_id IN (
            SELECT c.id 
            FROM public.conversations c
            INNER JOIN public.vendors v ON c.vendor_id = v.id
            WHERE v.user_id = auth.uid()
        )
    );

-- Policy: المستخدمون يمكنهم تحديث رسائلهم (مثل تمييزها كمقروءة)
CREATE POLICY "Users can update their own messages"
    ON public.messages
    FOR UPDATE
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    );

-- Policy: التجار يمكنهم تحديث رسائلهم
CREATE POLICY "Vendors can update their own messages"
    ON public.messages
    FOR UPDATE
    USING (
        conversation_id IN (
            SELECT c.id 
            FROM public.conversations c
            INNER JOIN public.vendors v ON c.vendor_id = v.id
            WHERE v.user_id = auth.uid()
        )
    )
    WITH CHECK (
        conversation_id IN (
            SELECT c.id 
            FROM public.conversations c
            INNER JOIN public.vendors v ON c.vendor_id = v.id
            WHERE v.user_id = auth.uid()
        )
    );

-- Policy: المستخدمون يمكنهم حذف رسائلهم
CREATE POLICY "Users can delete their own messages"
    ON public.messages
    FOR DELETE
    USING (
        sender_type = 'user' 
        AND sender_id = auth.uid()
    );

-- 10. منح الصلاحيات
-- ============================================

-- منح صلاحيات على الجداول
GRANT SELECT, INSERT, UPDATE, DELETE ON public.conversations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.messages TO authenticated;

-- منح صلاحيات على Views
GRANT SELECT ON conversations_with_details TO authenticated;
GRANT SELECT ON messages_with_sender_details TO authenticated;

-- منح صلاحيات على Functions
GRANT EXECUTE ON FUNCTION mark_messages_as_read(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_or_create_conversation(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_conversations_updated_at() TO authenticated;
GRANT EXECUTE ON FUNCTION update_conversation_on_new_message() TO authenticated;

-- 11. إضافة تعليقات توضيحية
-- ============================================

COMMENT ON TABLE public.conversations IS 'جدول المحادثات بين المستخدمين والتجار';
COMMENT ON TABLE public.messages IS 'جدول الرسائل في المحادثات';
COMMENT ON FUNCTION mark_messages_as_read IS 'دالة لتمييز الرسائل كمقروءة وتحديث العدادات';
COMMENT ON FUNCTION get_or_create_conversation IS 'دالة للحصول على محادثة موجودة أو إنشاء محادثة جديدة';
COMMENT ON VIEW conversations_with_details IS 'عرض المحادثات مع تفاصيل التاجر والمستخدم';
COMMENT ON VIEW messages_with_sender_details IS 'عرض الرسائل مع تفاصيل المرسل';

-- ============================================
-- انتهى سكريبت إنشاء نظام الدردشة
-- ============================================

-- ملاحظات مهمة:
-- 1. تأكد من وجود جدول vendors وجدول user_profiles قبل تشغيل هذا السكريبت
-- 2. تأكد من تفعيل Row Level Security على قاعدة البيانات
-- 3. يمكنك تعديل الـ RLS Policies حسب احتياجاتك
-- 4. تم إنشاء Indexes للأداء العالي
-- 5. تم إنشاء Functions و Triggers للتحديث التلقائي
-- 6. تم إنشاء Function get_or_create_conversation للاستخدام من التطبيق

-- للتحقق من نجاح التثبيت:
-- SELECT * FROM conversations_with_details LIMIT 1;
-- SELECT * FROM messages_with_sender_details LIMIT 1;

-- اختبار get_or_create_conversation:
-- SELECT * FROM get_or_create_conversation(auth.uid(), 'vendor-uuid-here');

-- التحقق من Functions:
-- SELECT routine_name FROM information_schema.routines 
-- WHERE routine_schema = 'public' 
-- AND routine_name IN ('mark_messages_as_read', 'get_or_create_conversation');

