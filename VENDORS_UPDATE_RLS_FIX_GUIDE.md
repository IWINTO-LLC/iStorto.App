# Vendors Table UPDATE RLS Policy Fix

## 🐛 Problem

When vendors try to update their store settings (organization name, bio, payment settings, etc.), the update fails with:

```
PostgrestException: new row violates row-level security policy for table "vendors"
Code: 42501 (Forbidden)
```

## 🔍 Root Cause

The `vendors` table has an **incomplete UPDATE policy**. The policy has a `USING` clause but is **missing the `WITH CHECK` clause**.

### **Current Policy (Incomplete):**
```
policyname: "Users can update their own vendor"
USING: (auth.uid() = user_id) ✅
WITH CHECK: null ❌ MISSING!
```

### **Why This Causes the Error:**
Without the `WITH CHECK` clause, PostgreSQL cannot validate that the updated row meets security requirements, causing RLS to reject all UPDATE operations.

## ✅ Solution

Run the SQL script `fix_vendors_update_rls_policy.sql` in your Supabase SQL Editor to create the proper UPDATE policy.

## 🚀 Quick Fix

### **Option 1: Quick Fix (⚡ Fastest)**

**File:** `quick_fix_vendors_rls.sql`

1. Open **Supabase Dashboard** → **SQL Editor**
2. Copy and paste the contents of `quick_fix_vendors_rls.sql`
3. Click **Run**
4. Done! ✅

**What it does:**
- Drops the incomplete UPDATE policy
- Creates new UPDATE policy with BOTH `USING` and `WITH CHECK` clauses
- Also fixes the SELECT policy to allow public viewing of vendor profiles

### **Option 2: Comprehensive Fix (📋 Recommended for Production)**

**File:** `fix_vendors_update_rls_policy.sql`

1. Open Supabase SQL Editor
2. Run the complete script
3. The script will:
   - Check existing policies
   - Remove conflicting policies
   - Create proper UPDATE policy with WITH CHECK
   - Fix SELECT policy for public access
   - Verify all policies
   - Grant necessary permissions
   - Display verification results

### **Option 3: Manual SQL (Copy-Paste)**

```sql
-- Drop incomplete policy
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;

-- Create complete UPDATE policy with WITH CHECK
CREATE POLICY "Users can update their own vendor"
ON vendors
FOR UPDATE
TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Fix SELECT policy for public access
DROP POLICY IF EXISTS "Users can view their own vendor" ON vendors;
CREATE POLICY "Enable read access for vendors"
ON vendors
FOR SELECT
TO public
USING (
  auth.uid() = user_id
  OR
  (organization_activated = true AND organization_deleted = false)
);

-- Grant permissions
GRANT UPDATE ON vendors TO authenticated;
```

## 📋 What the Policy Does

### **USING Clause**
```sql
USING (auth.uid() = user_id)
```
- Determines **which rows** can be updated
- Only allows updates where the current user is the owner
- Prevents updating other vendors' records

### **WITH CHECK Clause**
```sql
WITH CHECK (auth.uid() = user_id)
```
- Validates the **updated data**
- Ensures `user_id` cannot be changed to someone else
- Maintains data integrity

## 🎯 What Vendors Can Now Update

With this policy, vendors can update:

✅ **Basic Information:**
- `organization_name`
- `organization_bio`
- `brief`
- `store_message`

✅ **Images:**
- `organization_logo`
- `organization_cover`
- `banner_image`

✅ **Settings:**
- `organization_activated` (activate/deactivate store)
- `organization_deleted` (soft delete)
- `enable_cod` (cash on delivery)
- `enable_iwinto_payment` (payment gateway)
- `default_currency`

✅ **Metadata:**
- `selected_major_categories`
- `exclusive_id`
- `in_exclusive`

✅ **Status Flags:**
- `is_subscriber`
- `is_verified` (admin only)
- `is_royal` (admin only)

## 🚫 What Vendors Cannot Do

❌ **Cannot change:**
- `id` (primary key)
- `user_id` (foreign key to user_profiles)
- `created_at` (creation timestamp)

❌ **Cannot update:**
- Other vendors' records
- Records where they are not the owner

## 🔐 Complete RLS Policy Set

A properly configured `vendors` table should have these policies:

| Operation | Policy Name | Purpose |
|-----------|-------------|---------|
| **SELECT** | Enable read access for all users | All authenticated users can view vendor profiles |
| **INSERT** | Enable insert for authenticated users | Users can create their own vendor record |
| **UPDATE** | Enable update for vendor owners | Vendors can update their own records |
| **DELETE** | Enable delete for vendor owners | Vendors can delete their own records |

## 🧪 Testing

### **1. Test Update Query**
```sql
-- Replace with actual user_id
UPDATE vendors 
SET organization_name = 'Test Store Name'
WHERE user_id = auth.uid();
```

### **2. Verify Policies**
```sql
SELECT 
    policyname,
    cmd as operation,
    roles,
    qual as using_clause,
    with_check
FROM pg_policies
WHERE tablename = 'vendors'
ORDER BY cmd;
```

### **3. Test from Flutter App**
1. Open Store Settings
2. Update organization name or bio
3. Click "Save"
4. Should see: ✅ "Settings saved successfully"
5. Check database to confirm changes

## 🔧 Troubleshooting

### **Issue: Still Getting RLS Error**

**Check 1: Verify Policy Exists**
```sql
SELECT * FROM pg_policies 
WHERE tablename = 'vendors' 
AND cmd = 'UPDATE';
```

**Check 2: Verify User is Owner**
```sql
SELECT id, user_id, organization_name 
FROM vendors 
WHERE user_id = auth.uid();
```

**Check 3: Check Auth Context**
```sql
SELECT auth.uid(); -- Should return current user's UUID
```

**Check 4: Verify Permissions**
```sql
SELECT 
    grantee, 
    privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'vendors';
```

### **Issue: Policy Not Working**

Try recreating the policy:
```sql
-- Drop all UPDATE policies
DROP POLICY IF EXISTS "Enable update for vendor owners" ON vendors;

-- Recreate with explicit USING and WITH CHECK
CREATE POLICY "Enable update for vendor owners"
ON vendors
FOR UPDATE
TO authenticated
USING (auth.uid()::text = user_id::text)
WITH CHECK (auth.uid()::text = user_id::text);
```

### **Emergency: Disable RLS Temporarily**

⚠️ **Use only for debugging!**

```sql
-- Disable RLS (DO NOT USE IN PRODUCTION!)
ALTER TABLE vendors DISABLE ROW LEVEL SECURITY;

-- Test your update
-- ...

-- Re-enable RLS immediately after testing
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
```

## 📊 Related Tables

Remember to also check RLS policies for related tables:

### **Social Links Table**
```sql
-- Should allow updates via user_id FK
CREATE POLICY "Enable update for social link owners"
ON social_links
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

### **User Profiles Table**
```sql
-- Should allow users to update their own profile
CREATE POLICY "Enable update for profile owners"
ON user_profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

## 🎯 Expected Behavior After Fix

### **Before Fix:**
- ❌ Vendor updates fail with RLS error
- ❌ Settings cannot be saved
- ❌ Profile changes rejected
- ❌ Error: "new row violates row-level security policy"

### **After Fix:**
- ✅ Vendors can update their own records
- ✅ Store settings save successfully
- ✅ Profile changes persist
- ✅ Social links update correctly
- ✅ No RLS errors

## 📝 Important Notes

1. **User ID Must Match:**
   - The `user_id` in the `vendors` table must match the authenticated user's ID
   - Check with: `SELECT auth.uid()` vs `SELECT user_id FROM vendors WHERE id = 'vendor_id'`

2. **Authentication Required:**
   - User must be logged in (authenticated)
   - Anonymous users cannot update vendor records

3. **Social Links Separate:**
   - Social links are stored in `social_links` table
   - They have their own RLS policies
   - Updates happen via separate repository method

4. **Vendor ID vs User ID:**
   - `vendors.id` = Vendor's unique ID (UUID)
   - `vendors.user_id` = Foreign key to `user_profiles.id`
   - RLS policies use `user_id` to match `auth.uid()`

## 🔗 Related Files

- `lib/featured/shop/data/vendor_repository.dart` - Update method
- `lib/featured/shop/controller/vendor_controller.dart` - Save logic
- `lib/featured/shop/view/store_settings.dart` - UI for updates
- `fix_vendors_update_rls_policy.sql` - SQL fix script

## 🎓 Understanding RLS Policies

### **USING Clause:**
- Controls **which existing rows** a user can update
- Evaluated **before** the update
- Example: `USING (auth.uid() = user_id)` means "can only update rows I own"

### **WITH CHECK Clause:**
- Controls **what values** can be written
- Evaluated **after** the update
- Example: `WITH CHECK (auth.uid() = user_id)` means "cannot change ownership"

### **Both Together:**
```sql
USING (auth.uid() = user_id)      -- Can only update MY records
WITH CHECK (auth.uid() = user_id) -- Cannot change user_id to someone else
```

## 🚀 Deployment Steps

1. **Backup Database** (recommended)
   ```sql
   -- Create backup of vendors table
   CREATE TABLE vendors_backup AS SELECT * FROM vendors;
   ```

2. **Run Fix Script**
   - Open Supabase SQL Editor
   - Paste and run `fix_vendors_update_rls_policy.sql`

3. **Verify Policies**
   - Check policies are created
   - Test update from app

4. **Test Thoroughly**
   - Update organization name
   - Update bio
   - Toggle payment settings
   - Save social links

5. **Monitor Logs**
   - Check Flutter console for success messages
   - Verify database updates

## ✅ Success Indicators

You'll know it's fixed when you see:

```
I/flutter: Updated vendor organizationBio: [your bio text]
I/flutter: 📤 Saving social links to database...
I/flutter: ✅ Vendor social links saved successfully: vendorId=..., userId=...
I/flutter: Social links updated for user_id: ...
I/flutter: ✅ Social links saved successfully!
```

And in the UI:
- ✅ "Settings saved successfully" snackbar appears
- ✅ Save button becomes inactive after save
- ✅ Changes persist after page reload
- ✅ No RLS errors in console

---

**Created:** 2025-10-09  
**Status:** Ready to Apply  
**Priority:** 🔴 Critical - Required for vendor functionality

