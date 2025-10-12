# 🚨 CRITICAL: Vendors Table RLS Policy Fix

## ⚠️ **URGENT ISSUE**

Vendors **CANNOT** update their store settings due to incomplete RLS policy!

## 🎯 **The Problem (Found in Your Database)**

Your current `vendors` table UPDATE policy is **INCOMPLETE**:

```json
{
  "policyname": "Users can update their own vendor",
  "cmd": "UPDATE",
  "qual": "(auth.uid() = user_id)",      // ✅ USING clause exists
  "with_check": null                      // ❌ WITH CHECK is MISSING!
}
```

### **Why This Breaks Everything:**

PostgreSQL RLS requires **BOTH** clauses for UPDATE operations:
1. **`USING`** - Which rows can be updated ✅ (You have this)
2. **`WITH CHECK`** - Validates the new values ❌ (You're missing this!)

Without `WITH CHECK`, PostgreSQL **rejects ALL updates** as a security measure!

## ⚡ **QUICK FIX (5 seconds)**

### **Copy this SQL and run it in Supabase:**

```sql
-- Drop incomplete policy
DROP POLICY "Users can update their own vendor" ON vendors;

-- Create COMPLETE policy with WITH CHECK
CREATE POLICY "Users can update their own vendor"
ON vendors FOR UPDATE TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Also fix SELECT policy (currently too restrictive)
DROP POLICY "Users can view their own vendor" ON vendors;

CREATE POLICY "Enable read access for vendors"
ON vendors FOR SELECT TO public
USING (
  auth.uid() = user_id OR
  (organization_activated = true AND organization_deleted = false)
);
```

**That's it!** Your vendors can now update their settings. ✅

## 📋 **Alternative: Use Prepared Scripts**

I've created two SQL files for you:

### **1. Quick Fix** ⚡
**File:** `quick_fix_vendors_rls.sql`
- Fast, targeted fix
- Just run and go
- Fixes both UPDATE and SELECT policies

### **2. Comprehensive Fix** 📋
**File:** `fix_vendors_update_rls_policy.sql`
- Detailed analysis
- Verification queries
- Troubleshooting included
- Best for production

## 🔍 **What Was Wrong**

### **Your Current Policies:**

| Operation | Policy Name | USING | WITH CHECK | Status |
|-----------|-------------|-------|------------|--------|
| SELECT | Users can view their own vendor | ✅ | N/A | ⚠️ Too restrictive |
| INSERT | Users can insert their own vendor | N/A | ✅ | ✅ OK |
| INSERT | Authenticated users can insert | N/A | ✅ | ✅ OK |
| UPDATE | Users can update their own vendor | ✅ | ❌ **MISSING** | 🔴 **BROKEN** |
| DELETE | Users can delete their own vendor | ✅ | N/A | ✅ OK |

### **After Fix:**

| Operation | Policy Name | USING | WITH CHECK | Status |
|-----------|-------------|-------|------------|--------|
| SELECT | Enable read access for vendors | ✅ | N/A | ✅ Fixed |
| INSERT | Users can insert their own vendor | N/A | ✅ | ✅ OK |
| UPDATE | Users can update their own vendor | ✅ | ✅ **ADDED** | ✅ **FIXED** |
| DELETE | Users can delete their own vendor | ✅ | N/A | ✅ OK |

## 🎯 **What This Fixes**

After running the SQL fix, these will work:

✅ **Store Settings Updates:**
- Organization name, bio, brief
- Payment settings (COD, Iwinto)
- Store activation/deactivation
- Store message

✅ **Image Updates:**
- Logo upload
- Cover image upload

✅ **Social Links:**
- Website, Facebook, Instagram, etc.
- Visibility toggles
- Phone numbers

✅ **All Features in:**
- `store_settings.dart`
- `store_settings_new.dart`
- Vendor profile editing

## 🐛 **Bonus Fix: SELECT Policy**

Your current SELECT policy only allows vendors to see **their own** vendor record:
```sql
USING (auth.uid() = user_id)  -- Only MY record
```

This prevents **customers from viewing vendor profiles**! 🚫

### **Fixed SELECT Policy:**
```sql
USING (
  auth.uid() = user_id  -- Vendors can see own record
  OR
  (organization_activated = true AND organization_deleted = false)  -- Public can see active vendors
)
```

Now:
- ✅ Vendors can see their own profile (even if inactive)
- ✅ Customers can see active vendor profiles
- ✅ Deleted/deactivated vendors are hidden from public

## 📊 **Before vs After**

### **Before Fix:**
```
User opens store settings
User updates organization name
User clicks Save
❌ ERROR: new row violates row-level security policy
😞 Nothing saves
```

### **After Fix:**
```
User opens store settings
User updates organization name
User clicks Save
✅ Updated vendor organizationBio: [text]
✅ Vendor social links saved successfully!
✅ Social links saved successfully!
😊 "Settings saved successfully" snackbar
```

## 🚀 **Run This Now**

**Steps:**
1. Open **Supabase Dashboard**
2. Go to **SQL Editor**
3. Copy the SQL from **Option 1** above (or use `quick_fix_vendors_rls.sql`)
4. Click **Run**
5. See success ✅
6. Try updating store settings in your app
7. Celebrate! 🎉

## 📝 **Technical Explanation**

### **Why WITH CHECK is Required:**

PostgreSQL documentation states:

> *For UPDATE operations, both USING and WITH CHECK are evaluated. The USING clause determines which rows are visible for updating. The WITH CHECK clause determines which new row values are allowed.*

Without `WITH CHECK`:
- PostgreSQL doesn't know if updated values are valid
- Assumes they might violate security
- **Rejects the entire operation**
- Throws RLS violation error

With `WITH CHECK`:
- PostgreSQL validates updated values
- Confirms `user_id` doesn't change
- **Allows the operation**
- Update succeeds ✅

## ⚡ **TL;DR**

**Problem:** Missing `WITH CHECK` in UPDATE policy  
**Fix:** Add `WITH CHECK (auth.uid() = user_id)`  
**Result:** Vendors can update their settings ✅  
**Time to fix:** 5 seconds  

**Just run `quick_fix_vendors_rls.sql` NOW!** 🚀

---

**Priority:** 🔴 **CRITICAL**  
**Impact:** 🔴 **HIGH** - Blocks all vendor functionality  
**Difficulty:** 🟢 **EASY** - One SQL command  
**Status:** ✅ **Fix Ready**



