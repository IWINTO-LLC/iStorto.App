-- ═══════════════════════════════════════════════════════════════
-- Add Cover Image Column to user_profiles Table
-- إضافة عمود صورة الغلاف لجدول user_profiles
-- ═══════════════════════════════════════════════════════════════
-- Date: October 11, 2025
-- Purpose: Add cover image support for user profiles
-- ═══════════════════════════════════════════════════════════════

-- 1. Add cover column to user_profiles table
-- إضافة عمود cover لجدول user_profiles
DO $$ 
BEGIN
    -- Check if cover column doesn't exist, then add it
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'cover'
    ) THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN cover TEXT DEFAULT '';
        
        RAISE NOTICE 'Column "cover" added to user_profiles table successfully';
    ELSE
        RAISE NOTICE 'Column "cover" already exists in user_profiles table';
    END IF;
END $$;

-- 2. Add comment to describe the column
-- إضافة تعليق توضيحي للعمود
COMMENT ON COLUMN public.user_profiles.cover IS 'Cover image URL for business/vendor accounts';

-- 3. Update existing vendor users with their organization_cover from vendors table
-- تحديث المستخدمين التجاريين الحاليين بصورة الغلاف من جدول vendors
UPDATE public.user_profiles up
SET cover = v.organization_cover
FROM public.vendors v
WHERE up.vendor_id = v.id
  AND v.organization_cover IS NOT NULL
  AND v.organization_cover != ''
  AND (up.cover IS NULL OR up.cover = '');

-- 4. Create index on cover column for faster queries (optional)
-- إنشاء فهرس على عمود cover لتسريع الاستعلامات (اختياري)
CREATE INDEX IF NOT EXISTS idx_user_profiles_cover 
ON public.user_profiles(cover) 
WHERE cover IS NOT NULL AND cover != '';

-- ═══════════════════════════════════════════════════════════════
-- Verification Queries
-- استعلامات التحقق
-- ═══════════════════════════════════════════════════════════════

-- Check if column exists
-- التحقق من وجود العمود
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'user_profiles' 
  AND column_name = 'cover';

-- Check users with cover images
-- التحقق من المستخدمين الذين لديهم صور غلاف
SELECT 
    id,
    user_id,
    name,
    account_type,
    CASE 
        WHEN cover IS NULL OR cover = '' THEN 'No Cover'
        ELSE 'Has Cover'
    END as cover_status,
    cover
FROM public.user_profiles
WHERE account_type = 1  -- Business accounts only
ORDER BY created_at DESC
LIMIT 10;

-- Count users with and without cover images
-- عد المستخدمين الذين لديهم وليس لديهم صور غلاف
SELECT 
    account_type,
    CASE account_type 
        WHEN 0 THEN 'Regular'
        WHEN 1 THEN 'Business'
        ELSE 'Unknown'
    END as account_type_name,
    COUNT(*) as total_users,
    COUNT(CASE WHEN cover IS NOT NULL AND cover != '' THEN 1 END) as with_cover,
    COUNT(CASE WHEN cover IS NULL OR cover = '' THEN 1 END) as without_cover
FROM public.user_profiles
GROUP BY account_type
ORDER BY account_type;

-- ═══════════════════════════════════════════════════════════════
-- Rollback (if needed)
-- التراجع عن التغييرات (إذا لزم الأمر)
-- ═══════════════════════════════════════════════════════════════

-- CAUTION: Only run this if you want to remove the cover column
-- تحذير: قم بتشغيل هذا فقط إذا كنت تريد إزالة عمود cover

-- ALTER TABLE public.user_profiles DROP COLUMN IF EXISTS cover;

-- ═══════════════════════════════════════════════════════════════
-- Migration Complete | اكتملت عملية الترحيل
-- ═══════════════════════════════════════════════════════════════

-- Summary:
-- ✅ Added 'cover' column to user_profiles table
-- ✅ Set default value to empty string
-- ✅ Added column comment/description
-- ✅ Synced existing vendor covers from vendors table
-- ✅ Created index for performance
-- ✅ Provided verification queries

RAISE NOTICE '✅ Migration completed successfully! Cover column is ready to use.';

