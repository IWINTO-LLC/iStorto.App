-- حل مؤقت: إيقاف RLS مؤقتاً لجدول banners
-- Temporary solution: Disable RLS temporarily for banners table

-- إيقاف RLS مؤقتاً
ALTER TABLE public.banners DISABLE ROW LEVEL SECURITY;

-- ملاحظة: هذا حل مؤقت فقط للاختبار
-- يجب إعادة تفعيل RLS بعد إصلاح السياسات
