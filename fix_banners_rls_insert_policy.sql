-- إصلاح سياسة INSERT لجدول banners
-- Fix INSERT policy for banners table

-- 1. إنشاء سياسة INSERT للباحثين (authenticated users)
CREATE POLICY "Allow authenticated users to insert banners" 
ON public.banners
FOR INSERT 
TO authenticated
WITH CHECK (true);

-- 2. إنشاء سياسة INSERT للمديرين
CREATE POLICY "Allow admins to insert banners" 
ON public.banners
FOR INSERT 
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.account_type = 'admin'
  )
);

-- 3. إنشاء سياسة SELECT لجميع المستخدمين
CREATE POLICY "Allow all users to view banners" 
ON public.banners
FOR SELECT 
TO authenticated, anon
USING (active = true);

-- 4. إنشاء سياسة UPDATE للمديرين فقط
CREATE POLICY "Allow admins to update banners" 
ON public.banners
FOR UPDATE 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.account_type = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.account_type = 'admin'
  )
);

-- 5. إنشاء سياسة DELETE للمديرين فقط
CREATE POLICY "Allow admins to delete banners" 
ON public.banners
FOR DELETE 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE user_profiles.id = auth.uid() 
    AND user_profiles.account_type = 'admin'
  )
);

-- 6. التأكد من تفعيل RLS
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
