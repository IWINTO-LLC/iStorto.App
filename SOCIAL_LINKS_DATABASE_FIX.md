# Social Links Database Update Fix

## 🐛 Problem
Social links were not being saved to the database when updated in the store settings page. The data was updating in the UI but not persisting to the `social_links` table.

## 🔍 Root Cause
There were **two critical issues**:

### **Issue 1: Wrong Table and Column Names**
The `vendor_repository.dart` was using incorrect table and column names:
- ❌ Table name: `vendor_social_links` (doesn't exist)
- ❌ Column name: `vendor_id` (incorrect)
- ✅ Correct table: `social_links`
- ✅ Correct column: `user_id` (references `user_profiles.id`)

### **Issue 2: Invalid Fields in VendorModel.toJson()**
The `VendorModel.toJson()` was including fields that don't exist in the `vendors` table:
- ❌ `toJson()` included: `'social_link': socialLink?.toJson()`
- ❌ `toJson()` included: `'website': website`
- ✅ Fixed: Removed both fields as they're stored in the separate `social_links` table

## 🔧 Solution Applied

### 1. **Fixed VendorModel.toJson() Method**
**File:** `lib/featured/shop/data/vendor_model.dart`

**Problem:** The `toJson()` method was including `'social_link'` and `'website'` fields, causing PostgrestException when updating vendors table.

**Solution:** Removed both `'social_link'` and `'website'` from `toJson()` as they are stored in the separate `social_links` table and handled via `VendorRepository.updateVendorSocialLinks()`.

```dart
Map<String, dynamic> toJson() {
  final Map<String, dynamic> json = {
    'user_id': userId,
    'organization_name': organizationName,
    'organization_bio': organizationBio,
    // ... other vendor fields ...
    // NOTE: 'website' is NOT included - it's stored in social_links table
    // NOTE: 'social_link' is NOT included - it's stored in social_links table
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
  return json;
}
```

### 2. **Updated `updateVendorSocialLinks` Method**
**File:** `lib/featured/shop/data/vendor_repository.dart`

**Changes:**
- First fetches `user_id` from the `vendors` table using `vendor_id`
- Uses correct table name: `social_links`
- Uses correct foreign key: `user_id` instead of `vendor_id`
- Properly handles both INSERT and UPDATE operations
- Added debug logging for better troubleshooting

```dart
// Get user_id from vendor
final vendorResponse = await _client
    .from('vendors')
    .select('user_id')
    .eq('id', vendorId)
    .maybeSingle();

final userId = vendorResponse['user_id'];

// Check if social links exist
final existingRecord = await _client
    .from('social_links')
    .select('id')
    .eq('user_id', userId)
    .maybeSingle();

// Insert or Update
if (existingRecord != null) {
    await _client
        .from('social_links')
        .update(socialLinkData)
        .eq('user_id', userId);
} else {
    await _client.from('social_links').insert(socialLinkData);
}
```

### 3. **Updated `getVendorSocialLinks` Method**
**File:** `lib/featured/shop/data/vendor_repository.dart`

**Changes:**
- First fetches `user_id` from the `vendors` table
- Queries `social_links` table using `user_id`
- Returns null gracefully if vendor has no `user_id`

### 4. **Enhanced `saveVendorUpdates` Method**
**File:** `lib/featured/shop/controller/vendor_controller.dart`

**Changes:**
- Ensures social links from both `profileData` and `vendorData` are synchronized
- **Removed `website` field** from vendor update (it's in social_links table)
- Added comprehensive debug logging
- Explicitly saves social links after vendor profile update
- Better error handling with `rethrow`

```dart
// Ensure both profileData and vendorData have the same social links
final currentSocialLink = profileData.value.socialLink ?? vendorData.value.socialLink;

// Create updated vendor (WITHOUT website - it's in social_links)
final updatedVendor = profileData.value.copyWith(
  enableCod: enableCOD.value,
  enableIwintoPayment: enableIwintoPayment.value,
  // NOTE: website is NOT included - it's saved in social_links table
  organizationBio: organizationBioController.text.trim(),
  // ...
);

// Update vendor profile
await repository.updateVendorProfile(vendorId, updatedVendor);

// Explicitly save social links (including website)
if (currentSocialLink != null) {
    debugPrint("📤 Saving social links to database...");
    await repository.updateVendorSocialLinks(vendorId, currentSocialLink);
    debugPrint("✅ Social links saved successfully!");
}
```

### 5. **Switch Responsiveness Fix**
**File:** `lib/featured/shop/view/store_settings.dart`

**Changes:**
- Wrapped all `Switch` and `SwitchListTile` widgets with `Obx` for reactive updates
- Applied to:
  - ✅ COD Payment Switch
  - ✅ Iwinto Payment Switch
  - ✅ Phone Visibility Switch
  - ✅ Website Visibility Switch
  - ✅ Facebook Visibility Switch
  - ✅ Instagram Visibility Switch
  - ✅ WhatsApp Visibility Switch
  - ✅ TikTok Visibility Switch
  - ✅ YouTube Visibility Switch
  - ✅ X (Twitter) Visibility Switch
  - ✅ LinkedIn Visibility Switch

## 📊 Database Schema Reference

```sql
create table public.social_links (
  id uuid not null default gen_random_uuid(),
  user_id uuid null,
  facebook text null default ''::text,
  x text null default ''::text,
  instagram text null default ''::text,
  website text null default ''::text,
  linkedin text null default ''::text,
  whatsapp text null default ''::text,
  tiktok text null default ''::text,
  youtube text null default ''::text,
  location text null default ''::text,
  phones text[] null default '{}'::text[],
  visible_facebook boolean null default true,
  visible_x boolean null default true,
  visible_instagram boolean null default true,
  visible_website boolean null default true,
  visible_linkedin boolean null default true,
  visible_whatsapp boolean null default true,
  visible_tiktok boolean null default true,
  visible_youtube boolean null default true,
  visible_phones boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint social_links_pkey primary key (id),
  constraint social_links_user_id_fkey foreign key (user_id) 
    references user_profiles (id) on delete cascade
);
```

## ✅ Testing Checklist

1. **Update Social Links:**
   - [ ] Open store settings
   - [ ] Update Facebook, Instagram, X, etc.
   - [ ] Toggle visibility switches
   - [ ] Click "Save" button
   - [ ] Check database to confirm data is persisted

2. **Verify Switches Work:**
   - [ ] Toggle any visibility switch
   - [ ] Confirm switch state changes immediately
   - [ ] Confirm "Save" button becomes active

3. **Check Debug Console:**
   - [ ] Look for "📤 Saving social links to database..." message
   - [ ] Look for "✅ Social links saved successfully!" message
   - [ ] Look for "✅ Vendor social links saved successfully: vendorId=..., userId=..." message

4. **Database Verification:**
   ```sql
   -- Check if social links are saved
   SELECT * FROM social_links 
   WHERE user_id = 'YOUR_USER_ID';
   ```

## 🎯 Expected Behavior

### Before Fix:
- ❌ Social links updated in UI but not saved to database
- ❌ Switches not responsive on tap
- ❌ No data in `social_links` table after save

### After Fix:
- ✅ Social links saved to `social_links` table using correct `user_id`
- ✅ All switches respond immediately to user interaction
- ✅ Data persists correctly in database
- ✅ Debug logs show successful save operations
- ✅ Updates and inserts work correctly

## 📝 Notes

- The fix maintains backward compatibility
- All social link fields are properly mapped
- Visibility toggles are correctly saved
- Phone numbers array is handled properly
- Debug logging helps track the save process

## 🔗 Related Files

- `lib/featured/shop/data/vendor_repository.dart` - Repository layer
- `lib/featured/shop/controller/vendor_controller.dart` - Controller layer
- `lib/featured/shop/view/store_settings.dart` - UI layer
- `lib/featured/shop/data/social-link.dart` - Model definition

