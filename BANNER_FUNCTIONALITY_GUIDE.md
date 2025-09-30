# Banner Functionality Guide

This guide explains how the banner system works with vendorId integration and provides comprehensive testing capabilities.

## 🏗️ **Architecture Overview**

The banner system consists of several key components:

1. **BannerModel** - Data model with vendorId support
2. **BannerController** - State management for banners
3. **BannerRepository** - Database operations
4. **TPromoSlider** - UI component for displaying banners
5. **Test Pages** - Comprehensive testing interface

## 📊 **BannerModel Structure**

### Key Fields:
```dart
class BannerModel {
  String? id;                    // Unique banner identifier
  String image;                  // Banner image URL
  String targetScreen;           // Target screen for banner
  bool active;                   // Banner active status
  String? vendorId;              // Vendor ID (null for company banners)
  BannerScope scope;             // Banner scope (company/vendor)
  String? title;                 // Banner title
  String? description;           // Banner description
  int? priority;                 // Display priority
  DateTime? createdAt;           // Creation timestamp
  DateTime? updatedAt;           // Update timestamp
}
```

### BannerScope Enum:
- `BannerScope.company` - Company-wide banners
- `BannerScope.vendor` - Vendor-specific banners

## 🔧 **VendorId Integration**

### Banner Creation with VendorId:
```dart
// When creating a banner, vendorId is automatically set
var newBanner = BannerModel(
  image: bannerImageHostUrl,
  targetScreen: '',
  active: true,
  vendorId: vendorId,           // ✅ VendorId is set here
  scope: BannerScope.vendor,    // ✅ Scope is set to vendor
  title: 'New Banner',
  description: 'Banner created via gallery',
  priority: 1,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Banner Filtering by Vendor:
```dart
// Get banners for specific vendor
Future<List<BannerModel>> getVendorBannersById(String vendorId) async {
  final response = await _client
      .from('banners')
      .select()
      .eq('active', true)
      .eq('vendor_id', vendorId)  // ✅ Filter by vendorId
      .order('priority', ascending: false)
      .order('created_at', ascending: false);
}
```

## 🎨 **TPromoSlider Component**

### Key Features:
- ✅ Displays vendor-specific banners
- ✅ Edit mode for banner management
- ✅ Auto-play functionality
- ✅ Responsive design
- ✅ Image cropping with proper aspect ratio
- ✅ Add/remove banner functionality

### Usage:
```dart
TPromoSlider(
  editMode: editMode,           // Enable/disable edit mode
  autoPlay: autoPlay,           // Enable/disable auto-play
  vendorId: vendorId,           // Vendor ID for banner filtering
)
```

## 🧪 **Testing Capabilities**

### 1. Banner Test Page
**Location:** Admin Zone → Banner Test

**Features:**
- ✅ Test banner operations
- ✅ Test banner controller functionality
- ✅ Banner validation testing
- ✅ Vendor filtering tests
- ✅ Priority sorting tests
- ✅ Mixed banner tests (company + vendor)

### 2. Promo Slider Test Page
**Location:** Admin Zone → Promo Slider Test

**Features:**
- ✅ Live promo slider display
- ✅ Edit mode testing
- ✅ Auto-play testing
- ✅ Dynamic banner addition/removal
- ✅ Configuration testing
- ✅ Banner list display

## 🚀 **How to Use**

### 1. Creating Banners for Vendors

#### Via Controller:
```dart
// Add banner with vendorId
await bannerController.addBanner('gallery', vendorId);
```

#### Via Repository:
```dart
final banner = BannerModel(
  image: 'https://example.com/banner.jpg',
  targetScreen: 'home',
  active: true,
  vendorId: 'vendor-123',
  scope: BannerScope.vendor,
  title: 'My Banner',
  description: 'Banner description',
  priority: 1,
);

final createdBanner = await bannerRepository.createBanner(banner);
```

### 2. Displaying Vendor Banners

#### Using Promo Slider:
```dart
TPromoSlider(
  editMode: true,              // Enable editing
  autoPlay: true,              // Enable auto-play
  vendorId: 'vendor-123',      // Specific vendor ID
)
```

#### Fetching Banners:
```dart
// Get vendor banners
final vendorBanners = await bannerRepository.getVendorBannersById(vendorId);

// Get mixed banners (company + vendor)
final mixedBanners = await bannerRepository.getMixedBannersForScreen(
  'home',
  vendorId,
);
```

### 3. Banner Management

#### Update Banner:
```dart
final updatedBanner = banner.copyWith(
  title: 'Updated Title',
  active: false,
  priority: 5,
);

await bannerRepository.updateBanner(updatedBanner);
```

#### Delete Banner:
```dart
await bannerRepository.deleteBanner(bannerId);
```

#### Toggle Banner Status:
```dart
await bannerController.updateStatus(banner, vendorId);
```

## 🔍 **Testing the System**

### Access Test Pages:
1. Open your app
2. Navigate to **Admin Zone**
3. Click **"Banner Test"** (teal campaign icon)
4. Click **"Promo Slider Test"** (indigo slideshow icon)

### Test Features:

#### Banner Test Page:
- **Test Banner Operations** - Comprehensive banner functionality testing
- **Test Controller** - Banner controller state management testing
- **Vendor ID Input** - Test with different vendor IDs
- **Banner Display** - Visual representation of test banners

#### Promo Slider Test Page:
- **Live Slider** - Real-time promo slider display
- **Configuration Controls** - Toggle edit mode and auto-play
- **Banner Management** - Add/remove test banners dynamically
- **Test Controls** - Run comprehensive slider tests

### Test Scenarios:

#### 1. Basic Banner Operations:
- ✅ Create banner with vendorId
- ✅ Filter banners by vendor
- ✅ Sort banners by priority
- ✅ Toggle banner active status
- ✅ Update banner properties

#### 2. Promo Slider Functionality:
- ✅ Display vendor banners
- ✅ Edit mode functionality
- ✅ Auto-play behavior
- ✅ Banner addition/removal
- ✅ Page indicator updates

#### 3. Vendor-Specific Features:
- ✅ Vendor banner isolation
- ✅ Mixed banner display (company + vendor)
- ✅ Vendor banner priority handling
- ✅ Vendor banner management

## 📱 **UI Components**

### TPromoSlider Features:
- **Responsive Design** - Adapts to different screen sizes
- **Image Cropping** - Proper aspect ratio (364:214)
- **Edit Mode** - Add/remove banners interface
- **Auto-play** - Configurable auto-play functionality
- **Page Indicators** - Visual page indicators
- **Smooth Animations** - Smooth transitions between banners

### Banner Display:
- **Image Loading** - Cached network image loading
- **Error Handling** - Fallback for failed image loads
- **Aspect Ratio** - Maintains proper banner dimensions
- **Touch Interactions** - Tap to view full screen

## 🔒 **Security & Validation**

### Database Level:
- ✅ RLS policies for vendor data access
- ✅ Foreign key constraints
- ✅ Data validation triggers

### Application Level:
- ✅ Input validation
- ✅ Vendor ownership verification
- ✅ Error handling and logging

### User Permissions:
- ✅ Vendors can only manage their own banners
- ✅ Company banners are global
- ✅ Proper scope separation

## 📈 **Performance Considerations**

### Optimization Strategies:
1. **Caching** - Banner data cached in controller
2. **Lazy Loading** - Images loaded on demand
3. **Pagination** - Large banner lists paginated
4. **Image Optimization** - Proper image sizing and compression

### Monitoring:
- Banner loading performance
- Image load success rates
- User interaction tracking
- Error rate monitoring

## 🔮 **Future Enhancements**

### Planned Features:
1. **Banner Analytics** - Track banner performance
2. **A/B Testing** - Multiple banner variants
3. **Scheduled Banners** - Time-based banner display
4. **Geographic Targeting** - Location-based banners
5. **Advanced Targeting** - User behavior-based display

### Advanced Features:
1. **Banner Templates** - Pre-designed banner templates
2. **Rich Media Banners** - Video and interactive banners
3. **Banner Rotation** - Smart banner rotation algorithms
4. **Performance Metrics** - Click-through rates and conversions

## 🛠️ **Setup Instructions**

### 1. Initialize Services:
```dart
// In your main.dart or app initialization
Get.put(BannerController());
Get.put(BannerRepository());
```

### 2. Database Setup:
```sql
-- Ensure banners table has vendor_id column
ALTER TABLE banners ADD COLUMN IF NOT EXISTS vendor_id UUID;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS scope TEXT DEFAULT 'company';
ALTER TABLE banners ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_banners_vendor_id ON banners(vendor_id);
CREATE INDEX IF NOT EXISTS idx_banners_scope ON banners(scope);
CREATE INDEX IF NOT EXISTS idx_banners_active_priority ON banners(active, priority);
```

### 3. UI Integration:
```dart
// Use promo slider in your vendor pages
TPromoSlider(
  editMode: isVendorOwner,
  autoPlay: true,
  vendorId: currentVendorId,
)
```

## 📞 **Support & Troubleshooting**

### Common Issues:
1. **Banners Not Loading** - Check vendorId and active status
2. **Edit Mode Not Working** - Verify vendor ownership
3. **Images Not Displaying** - Check image URLs and network connectivity
4. **Performance Issues** - Monitor image sizes and caching

### Debug Tools:
- Banner test pages in Admin Zone
- Console logging for banner operations
- Database query monitoring
- Image load tracking

### Error Handling:
- Graceful fallbacks for failed image loads
- User-friendly error messages
- Automatic retry mechanisms
- Comprehensive logging

---

**🎉 The banner system is now fully integrated with vendorId support and ready for production use!**

For questions or support, refer to the test pages in the Admin Zone or check the console logs for detailed error information.

## 📚 **API Reference**

### BannerController Methods:
- `fetchUserBanners(vendorId)` - Fetch banners for specific vendor
- `addBanner(mode, vendorId)` - Add new banner with vendorId
- `deleteBanner(banner)` - Delete banner
- `updateStatus(banner, vendorId)` - Update banner status
- `updatePageIndicator(index)` - Update carousel page indicator

### BannerRepository Methods:
- `getVendorBannersById(vendorId)` - Get vendor-specific banners
- `getMixedBannersForScreen(screen, vendorId)` - Get mixed banners
- `createBanner(banner)` - Create new banner
- `updateBanner(banner)` - Update existing banner
- `deleteBanner(bannerId)` - Delete banner

### BannerModel Methods:
- `isValid` - Check if banner data is valid
- `isActive` - Check if banner is active
- `isVendorBanner` - Check if banner is vendor-specific
- `belongsToVendor(vendorId)` - Check vendor ownership
- `copyWith(...)` - Create copy with updated fields
