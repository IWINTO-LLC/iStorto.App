# Banner Upload System Guide

This guide explains the updated banner upload system that uses Supabase Storage with progress tracking, similar to how categories and products handle image uploads.

## 🏗️ **System Overview**

The banner upload system has been completely updated to use:
- ✅ **Supabase Storage** instead of the old upload service
- ✅ **Progress tracking** with percentage indicators
- ✅ **Image validation** and error handling
- ✅ **Real-time progress updates** in the UI
- ✅ **Consistent upload method** with categories and products

## 📊 **Key Components**

### 1. **BannerController Updates**
- ✅ Added `ImageUploadService` integration
- ✅ Added progress tracking variables (`uploadProgress`, `isUploading`)
- ✅ Updated `addBanner` method to use Supabase Storage
- ✅ Added `_uploadBannerImageWithProgress` method

### 2. **Progress Tracking**
- ✅ Real-time upload progress (0.0 to 1.0)
- ✅ Percentage display in UI
- ✅ Visual progress indicators (Circular + Linear)
- ✅ Upload status indicators

### 3. **Image Validation**
- ✅ File type validation (JPG, PNG, GIF, WebP)
- ✅ File size validation (max 10MB)
- ✅ Image format validation
- ✅ Error handling with user-friendly messages

## 🔧 **Technical Implementation**

### **BannerController Changes:**

```dart
class BannerController extends GetxController {
  // New progress tracking variables
  RxDouble uploadProgress = 0.0.obs;
  RxBool isUploading = false.obs;
  
  // ImageUploadService integration
  final imageUploadService = Get.find<ImageUploadService>();
  
  // Updated addBanner method with Supabase Storage
  Future<void> addBanner(String mode, String vendorId) async {
    // ... image picker and cropping logic ...
    
    // Upload to Supabase with progress tracking
    final uploadResult = await _uploadBannerImageWithProgress(img, vendorId);
    
    if (uploadResult['success'] == true) {
      // Create banner with Supabase URL
      var newBanner = BannerModel(
        image: uploadResult['url'],
        vendorId: vendorId,
        scope: BannerScope.vendor,
        // ... other properties
      );
    }
  }
}
```

### **Progress Tracking Method:**

```dart
Future<Map<String, dynamic>> _uploadBannerImageWithProgress(
  File imageFile,
  String vendorId,
) async {
  try {
    uploadProgress.value = 0.1; // Start progress
    
    // Validate image type
    if (!imageUploadService.isValidImageType(imageFile)) {
      throw Exception('Invalid image type');
    }
    
    uploadProgress.value = 0.2;
    
    // Get image info
    final imageInfo = await imageUploadService.getImageInfo(imageFile);
    uploadProgress.value = 0.3;
    
    // Upload to Supabase Storage
    final result = await imageUploadService.uploadImage(
      imageFile: imageFile,
      folderName: 'banners',
      customFileName: 'banner_${vendorId}_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    uploadProgress.value = 0.9;
    
    if (result['success'] == true) {
      uploadProgress.value = 1.0;
      return {
        'success': true,
        'url': result['url'],
        'path': result['path'],
        'fileName': result['fileName'],
      };
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

## 🎨 **UI Progress Indicators**

### **Enhanced Upload Dialog:**

```dart
dialogBuilder: (context, _) {
  return AlertDialog(
    content: Obx(() => Column(
      children: [
        // Circular Progress with Percentage
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: isUploading.value ? uploadProgress.value : null,
                strokeWidth: 4,
              ),
            ),
            if (isUploading.value)
              Text('${(uploadProgress.value * 100).toInt()}%'),
          ],
        ),
        
        // Message
        Text(message.value),
        
        // Linear Progress Bar
        if (isUploading.value) ...[
          LinearProgressIndicator(
            value: uploadProgress.value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
        ],
      ],
    )),
  );
}
```

## 🧪 **Testing Capabilities**

### **Banner Upload Test Page**
**Location:** Admin Zone → Banner Upload Test

**Features:**
- ✅ Real-time upload progress display
- ✅ Upload status indicators
- ✅ Test upload functionality
- ✅ Progress bar visualization
- ✅ Current banners display
- ✅ Upload system validation

### **Test Features:**
- ✅ **Progress Tracking** - Real-time upload progress with percentage
- ✅ **Status Indicators** - Visual upload status (Ready/Uploading)
- ✅ **Error Handling** - Comprehensive error messages
- ✅ **Image Validation** - File type and size validation
- ✅ **Supabase Integration** - Direct upload to Supabase Storage

## 🚀 **How to Use**

### **1. Basic Banner Upload:**

```dart
// Add banner from gallery
await bannerController.addBanner('gallery', vendorId);

// Add banner from camera
await bannerController.addBanner('camera', vendorId);
```

### **2. Monitor Upload Progress:**

```dart
// Check upload status
bool isUploading = bannerController.isUploading.value;

// Get upload progress (0.0 to 1.0)
double progress = bannerController.uploadProgress.value;

// Get progress percentage
int percentage = (progress * 100).toInt();
```

### **3. Display Progress in UI:**

```dart
Obx(() {
  if (bannerController.isUploading.value) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: bannerController.uploadProgress.value,
        ),
        Text('${(bannerController.uploadProgress.value * 100).toInt()}%'),
      ],
    );
  }
  return Text('Ready to upload');
})
```

## 📱 **User Experience Improvements**

### **Visual Progress Indicators:**
- ✅ **Circular Progress** - Shows upload progress with percentage
- ✅ **Linear Progress Bar** - Additional visual progress indicator
- ✅ **Status Icons** - Upload/Ready status indicators
- ✅ **Color Coding** - Orange for uploading, Green for ready

### **Enhanced Feedback:**
- ✅ **Real-time Updates** - Progress updates as upload progresses
- ✅ **Clear Messages** - User-friendly status messages
- ✅ **Error Handling** - Detailed error messages with solutions
- ✅ **Success Confirmation** - Clear success indicators

## 🔒 **Security & Validation**

### **Image Validation:**
- ✅ **File Type Check** - Only JPG, PNG, GIF, WebP allowed
- ✅ **File Size Limit** - Maximum 10MB per image
- ✅ **Image Format Validation** - Ensures valid image files
- ✅ **Error Prevention** - Prevents invalid uploads

### **Supabase Security:**
- ✅ **Storage Bucket** - Images stored in 'images' bucket
- ✅ **Folder Organization** - Banners stored in 'banners/' folder
- ✅ **Unique Naming** - Timestamp-based unique filenames
- ✅ **Access Control** - Proper RLS policies

## 📈 **Performance Optimizations**

### **Upload Efficiency:**
- ✅ **Direct Supabase Upload** - No intermediate server
- ✅ **Binary Upload** - Efficient binary data transfer
- ✅ **Progress Tracking** - Real-time progress updates
- ✅ **Error Recovery** - Graceful error handling

### **Memory Management:**
- ✅ **File Validation** - Early validation prevents unnecessary processing
- ✅ **Progress Updates** - Efficient progress tracking
- ✅ **Cleanup** - Proper resource cleanup after upload

## 🔮 **Future Enhancements**

### **Planned Features:**
1. **Resume Upload** - Resume interrupted uploads
2. **Batch Upload** - Upload multiple banners at once
3. **Image Compression** - Automatic image optimization
4. **Upload Queue** - Queue multiple uploads
5. **Background Upload** - Upload in background

### **Advanced Features:**
1. **Image Processing** - Automatic resizing and optimization
2. **Format Conversion** - Convert to optimal formats
3. **Thumbnail Generation** - Generate thumbnails automatically
4. **CDN Integration** - Fast image delivery
5. **Analytics** - Upload performance metrics

## 🛠️ **Setup Instructions**

### **1. Initialize Services:**
```dart
// In your main.dart or app initialization
Get.put(ImageUploadService());
Get.put(BannerController());
```

### **2. Supabase Storage Setup:**
```sql
-- Ensure 'images' bucket exists
-- Ensure 'banners' folder is accessible
-- Set proper RLS policies for storage
```

### **3. UI Integration:**
```dart
// Use progress tracking in your UI
Obx(() {
  if (bannerController.isUploading.value) {
    return LinearProgressIndicator(
      value: bannerController.uploadProgress.value,
    );
  }
  return ElevatedButton(
    onPressed: () => bannerController.addBanner('gallery', vendorId),
    child: Text('Add Banner'),
  );
})
```

## 📞 **Support & Troubleshooting**

### **Common Issues:**
1. **Upload Fails** - Check image format and size
2. **Progress Not Updating** - Ensure Obx wrapper is used
3. **Images Not Displaying** - Check Supabase Storage permissions
4. **Slow Upload** - Check network connection

### **Debug Tools:**
- Banner Upload Test page in Admin Zone
- Console logging for upload operations
- Supabase Storage monitoring
- Network request tracking

### **Error Handling:**
- Graceful fallbacks for failed uploads
- User-friendly error messages
- Automatic retry mechanisms
- Comprehensive logging

---

**🎉 The banner upload system is now fully integrated with Supabase Storage and progress tracking!**

## 📚 **API Reference**

### **BannerController Methods:**
- `addBanner(mode, vendorId)` - Add banner with progress tracking
- `_uploadBannerImageWithProgress(file, vendorId)` - Upload with progress
- `uploadProgress` - Observable progress value (0.0-1.0)
- `isUploading` - Observable upload status
- `message` - Observable status message

### **ImageUploadService Methods:**
- `uploadImage(imageFile, folderName, customFileName)` - Upload image
- `isValidImageType(imageFile)` - Validate image type
- `getImageInfo(imageFile)` - Get image information
- `uploadImageSimple(imageFile, folderName)` - Simple upload
- `uploadMultipleImages(imageFiles, folderName)` - Batch upload

### **Progress Tracking:**
- `uploadProgress.value` - Current progress (0.0 to 1.0)
- `isUploading.value` - Upload status (true/false)
- `message.value` - Current status message
- Progress updates in real-time during upload

**The system is now ready for production use with comprehensive testing capabilities!**
