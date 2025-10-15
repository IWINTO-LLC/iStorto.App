-- نظام الدردشة الكامل للتطبيق
-- Chat System Database Tables

-- جدول المحادثات الرئيسي
CREATE TABLE public.conversations (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    vendor_id UUID NOT NULL,
    last_message_id UUID NULL,
    last_message_text TEXT NULL,
    last_message_at TIMESTAMP WITH TIME ZONE NULL,
    last_message_type VARCHAR(20) DEFAULT 'text' CHECK (last_message_type IN ('text', 'image', 'file')),
    
    -- حالة المحادثة
    is_archived BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,
    is_muted BOOLEAN DEFAULT FALSE,
    
    -- حالة القراءة
    user_unread_count INTEGER DEFAULT 0,
    vendor_unread_count INTEGER DEFAULT 0,
    last_read_by_user_at TIMESTAMP WITH TIME ZONE NULL,
    last_read_by_vendor_at TIMESTAMP WITH TIME ZONE NULL,
    
    -- التواريخ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT conversations_pkey PRIMARY KEY (id),
    CONSTRAINT conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    CONSTRAINT conversations_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id) ON DELETE CASCADE,
    CONSTRAINT conversations_last_message_id_fkey FOREIGN KEY (last_message_id) REFERENCES public.messages(id) ON DELETE SET NULL,
    CONSTRAINT conversations_unique_user_vendor UNIQUE (user_id, vendor_id)
) TABLESPACE pg_default;

-- جدول الرسائل
CREATE TABLE public.messages (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL, -- يمكن أن يكون user_id أو vendor_id
    sender_type VARCHAR(10) NOT NULL CHECK (sender_type IN ('user', 'vendor')),
    
    -- محتوى الرسالة
    message_text TEXT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location')),
    
    -- المرفقات (للصور والملفات)
    attachment_url TEXT NULL,
    attachment_name TEXT NULL,
    attachment_size INTEGER NULL,
    
    -- حالة الرسالة
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE NULL,
    
    -- رد على رسالة سابقة
    reply_to_message_id UUID NULL,
    
    -- التواريخ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT messages_pkey PRIMARY KEY (id),
    CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE,
    CONSTRAINT messages_reply_to_message_id_fkey FOREIGN KEY (reply_to_message_id) REFERENCES public.messages(id) ON DELETE SET NULL
) TABLESPACE pg_default;

-- تحديث foreign key للـ last_message_id بعد إنشاء جدول الرسائل
ALTER TABLE public.conversations 
ADD CONSTRAINT conversations_last_message_id_fkey 
FOREIGN KEY (last_message_id) REFERENCES public.messages(id) ON DELETE SET NULL;

-- فهارس للأداء
CREATE INDEX idx_conversations_user_id ON public.conversations USING btree (user_id);
CREATE INDEX idx_conversations_vendor_id ON public.conversations USING btree (vendor_id);
CREATE INDEX idx_conversations_last_message_at ON public.conversations USING btree (last_message_at DESC);
CREATE INDEX idx_conversations_is_archived ON public.conversations USING btree (is_archived);
CREATE INDEX idx_conversations_is_favorite ON public.conversations USING btree (is_favorite);

CREATE INDEX idx_messages_conversation_id ON public.messages USING btree (conversation_id);
CREATE INDEX idx_messages_sender_id ON public.messages USING btree (sender_id);
CREATE INDEX idx_messages_created_at ON public.messages USING btree (created_at DESC);
CREATE INDEX idx_messages_is_read ON public.messages USING btree (is_read);

-- دالة تحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- تريجرز لتحديث updated_at
CREATE TRIGGER update_conversations_updated_at 
    BEFORE UPDATE ON public.conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at 
    BEFORE UPDATE ON public.messages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- دالة تحديث إحصائيات المحادثة عند إضافة رسالة جديدة
CREATE OR REPLACE FUNCTION update_conversation_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث آخر رسالة في المحادثة
    UPDATE public.conversations 
    SET 
        last_message_id = NEW.id,
        last_message_text = NEW.message_text,
        last_message_at = NEW.created_at,
        last_message_type = NEW.message_type,
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    
    -- زيادة عدد الرسائل غير المقروءة للطرف الآخر
    IF NEW.sender_type = 'user' THEN
        UPDATE public.conversations 
        SET vendor_unread_count = vendor_unread_count + 1
        WHERE id = NEW.conversation_id;
    ELSE
        UPDATE public.conversations 
        SET user_unread_count = user_unread_count + 1
        WHERE id = NEW.conversation_id;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- تريجر لتحديث إحصائيات المحادثة
CREATE TRIGGER update_conversation_stats_trigger
    AFTER INSERT ON public.messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_stats();

-- دالة لتمييز الرسائل كمقروءة
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    p_conversation_id UUID,
    p_reader_id UUID,
    p_reader_type VARCHAR(10)
)
RETURNS VOID AS $$
BEGIN
    -- تحديث حالة الرسائل كمقروءة
    UPDATE public.messages 
    SET 
        is_read = TRUE,
        read_at = NOW()
    WHERE conversation_id = p_conversation_id 
    AND sender_id != p_reader_id;
    
    -- تحديث إحصائيات المحادثة
    IF p_reader_type = 'user' THEN
        UPDATE public.conversations 
        SET 
            user_unread_count = 0,
            last_read_by_user_at = NOW()
        WHERE id = p_conversation_id;
    ELSE
        UPDATE public.conversations 
        SET 
            vendor_unread_count = 0,
            last_read_by_vendor_at = NOW()
        WHERE id = p_conversation_id;
    END IF;
END;
$$ language 'plpgsql';

-- RLS Policies للأمان

-- تفعيل RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- سياسات المحادثات
CREATE POLICY "Users can view their own conversations" ON public.conversations
    FOR SELECT USING (
        user_id = auth.uid() OR 
        vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can insert their own conversations" ON public.conversations
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own conversations" ON public.conversations
    FOR UPDATE USING (
        user_id = auth.uid() OR 
        vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid())
    );

-- سياسات الرسائل
CREATE POLICY "Users can view messages in their conversations" ON public.messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT id FROM public.conversations 
            WHERE user_id = auth.uid() OR 
            vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert messages in their conversations" ON public.messages
    FOR INSERT WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.conversations 
            WHERE user_id = auth.uid() OR 
            vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid())
        ) AND (
            (sender_type = 'user' AND sender_id = auth.uid()) OR
            (sender_type = 'vendor' AND sender_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid()))
        )
    );

CREATE POLICY "Users can update their own messages" ON public.messages
    FOR UPDATE USING (
        (sender_type = 'user' AND sender_id = auth.uid()) OR
        (sender_type = 'vendor' AND sender_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid()))
    );

-- إنشاء View للعرض المحسن للمحادثات مع معلومات التاجر والمستخدم
CREATE VIEW public.conversations_with_details AS
SELECT 
    c.*,
    u.name as user_name,
    u.profile_image_url as user_image_url,
    v.store_name as vendor_store_name,
    v.store_image_url as vendor_image_url,
    v.user_id as vendor_user_id
FROM public.conversations c
LEFT JOIN public.user_profiles u ON c.user_id = u.id
LEFT JOIN public.vendors v ON c.vendor_id = v.id;

-- View للرسائل مع تفاصيل المرسل
CREATE VIEW public.messages_with_sender_details AS
SELECT 
    m.*,
    CASE 
        WHEN m.sender_type = 'user' THEN u.name
        WHEN m.sender_type = 'vendor' THEN v.store_name
    END as sender_name,
    CASE 
        WHEN m.sender_type = 'user' THEN u.profile_image_url
        WHEN m.sender_type = 'vendor' THEN v.store_image_url
    END as sender_image_url
FROM public.messages m
LEFT JOIN public.user_profiles u ON m.sender_type = 'user' AND m.sender_id = u.id
LEFT JOIN public.vendors v ON m.sender_type = 'vendor' AND m.sender_id = v.id;

-- دالة للحصول على محادثة أو إنشاء جديدة
CREATE OR REPLACE FUNCTION get_or_create_conversation(
    p_user_id UUID,
    p_vendor_id UUID
)
RETURNS UUID AS $$
DECLARE
    conversation_id UUID;
BEGIN
    -- البحث عن محادثة موجودة
    SELECT id INTO conversation_id
    FROM public.conversations
    WHERE user_id = p_user_id AND vendor_id = p_vendor_id;
    
    -- إذا لم توجد، أنشئ محادثة جديدة
    IF conversation_id IS NULL THEN
        INSERT INTO public.conversations (user_id, vendor_id)
        VALUES (p_user_id, p_vendor_id)
        RETURNING id INTO conversation_id;
    END IF;
    
    RETURN conversation_id;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- دالة للحصول على عدد الرسائل غير المقروءة
CREATE OR REPLACE FUNCTION get_unread_count(
    p_user_id UUID,
    p_user_type VARCHAR(10) -- 'user' أو 'vendor'
)
RETURNS INTEGER AS $$
DECLARE
    unread_count INTEGER;
BEGIN
    IF p_user_type = 'user' THEN
        SELECT COALESCE(SUM(user_unread_count), 0) INTO unread_count
        FROM public.conversations
        WHERE user_id = p_user_id;
    ELSE
        SELECT COALESCE(SUM(vendor_unread_count), 0) INTO unread_count
        FROM public.conversations
        WHERE vendor_id IN (SELECT id FROM public.vendors WHERE user_id = p_user_id);
    END IF;
    
    RETURN COALESCE(unread_count, 0);
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- تعليقات على الجداول
COMMENT ON TABLE public.conversations IS 'جدول المحادثات بين المستخدمين والتجار';
COMMENT ON TABLE public.messages IS 'جدول الرسائل في المحادثات';

COMMENT ON COLUMN public.conversations.user_unread_count IS 'عدد الرسائل غير المقروءة للمستخدم';
COMMENT ON COLUMN public.conversations.vendor_unread_count IS 'عدد الرسائل غير المقروءة للتاجر';
COMMENT ON COLUMN public.conversations.last_read_by_user_at IS 'آخر وقت قراءة المستخدم للرسائل';
COMMENT ON COLUMN public.conversations.last_read_by_vendor_at IS 'آخر وقت قراءة التاجر للرسائل';

COMMENT ON COLUMN public.messages.sender_type IS 'نوع المرسل: user أو vendor';
COMMENT ON COLUMN public.messages.message_type IS 'نوع الرسالة: text, image, file, location';
COMMENT ON COLUMN public.messages.reply_to_message_id IS 'الرسالة التي يتم الرد عليها';

-- إدراج بيانات تجريبية (اختياري)
-- يمكن حذف هذا القسم في الإنتاج
INSERT INTO public.conversations (user_id, vendor_id, last_message_text, last_message_at) 
SELECT 
    (SELECT id FROM public.user_profiles LIMIT 1),
    (SELECT id FROM public.vendors LIMIT 1),
    'مرحباً! أريد الاستفسار عن منتج معين',
    NOW() - INTERVAL '1 hour'
WHERE EXISTS (SELECT 1 FROM public.user_profiles LIMIT 1) 
AND EXISTS (SELECT 1 FROM public.vendors LIMIT 1);

-- رسائل تجريبية
INSERT INTO public.messages (conversation_id, sender_id, sender_type, message_text, created_at)
SELECT 
    c.id,
    c.user_id,
    'user',
    'مرحباً! أريد الاستفسار عن منتج معين',
    NOW() - INTERVAL '1 hour'
FROM public.conversations c
WHERE c.last_message_text = 'مرحباً! أريد الاستفسار عن منتج معين';

INSERT INTO public.messages (conversation_id, sender_id, sender_type, message_text, created_at)
SELECT 
    c.id,
    c.vendor_id,
    'vendor',
    'مرحباً! أهلاً وسهلاً، كيف يمكنني مساعدتك؟',
    NOW() - INTERVAL '30 minutes'
FROM public.conversations c
WHERE c.last_message_text = 'مرحباً! أريد الاستفسار عن منتج معين';

-- تحديث إحصائيات المحادثة التجريبية
UPDATE public.conversations 
SET 
    last_message_id = (SELECT id FROM public.messages WHERE message_text = 'مرحباً! أهلاً وسهلاً، كيف يمكنني مساعدتك؟' LIMIT 1),
    last_message_text = 'مرحباً! أهلاً وسهلاً، كيف يمكنني مساعدتك؟',
    last_message_at = NOW() - INTERVAL '30 minutes',
    vendor_unread_count = 1
WHERE last_message_text = 'مرحباً! أريد الاستفسار عن منتج معين';

-- رسالة إضافية تجريبية
INSERT INTO public.messages (conversation_id, sender_id, sender_type, message_text, created_at)
SELECT 
    c.id,
    c.user_id,
    'user',
    'شكراً لك! المنتج متوفر الآن؟',
    NOW() - INTERVAL '10 minutes'
FROM public.conversations c
WHERE c.last_message_text = 'مرحباً! أهلاً وسهلاً، كيف يمكنني مساعدتك؟';

-- تحديث الإحصائيات مرة أخرى
UPDATE public.conversations 
SET 
    last_message_id = (SELECT id FROM public.messages WHERE message_text = 'شكراً لك! المنتج متوفر الآن؟' LIMIT 1),
    last_message_text = 'شكراً لك! المنتج متوفر الآن؟',
    last_message_at = NOW() - INTERVAL '10 minutes',
    vendor_unread_count = vendor_unread_count + 1
WHERE last_message_text = 'مرحباً! أهلاً وسهلاً، كيف يمكنني مساعدتك؟';

COMMENT ON FUNCTION get_or_create_conversation(UUID, UUID) IS 'الحصول على محادثة موجودة أو إنشاء جديدة بين مستخدم وتاجر';
COMMENT ON FUNCTION mark_messages_as_read(UUID, UUID, VARCHAR) IS 'تمييز الرسائل كمقروءة في محادثة معينة';
COMMENT ON FUNCTION get_unread_count(UUID, VARCHAR) IS 'الحصول على عدد الرسائل غير المقروءة للمستخدم أو التاجر';
