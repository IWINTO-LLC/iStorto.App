# Major Categories Widgets Documentation

## 📋 Overview

This system provides complete UI widgets for displaying and managing major categories with hierarchical support. It includes a home page section widget and a full categories management page.

## 🗂️ Files Structure

```
lib/featured/
├── home-page/
│   └── views/
│       └── widgets/
│           └── major_category_section.dart      # Home page categories section
├── all-categories/
│   ├── views/
│   │   └── all_categories_page.dart            # Full categories page
│   └── widgets/
│       ├── category_grid_item.dart             # Grid view item
│       ├── category_list_item.dart             # List view item
│       ├── category_search_bar.dart            # Search functionality
│       └── category_filter_chips.dart          # Filter chips
└── examples/
    └── home_page_with_categories_example.dart  # Usage example
```

## 🎯 Features

### MajorCategorySection (Home Page Widget)
- **Horizontal scrolling** categories display
- **Featured categories** priority display
- **Fallback to root categories** if no featured
- **Category icons** with automatic color assignment
- **Status indicators** (Active, Pending, Inactive)
- **Tap navigation** to category details
- **"See All" button** navigation to full categories page

### AllCategoriesPage (Full Categories Page)
- **Grid and List view** toggle
- **Search functionality** with real-time filtering
- **Status filtering** (All, Active, Pending, Inactive)
- **Featured filtering** toggle
- **Category management** actions
- **Modal bottom sheet** for category details
- **Responsive design** for different screen sizes

## 🚀 Usage Examples

### 1. Basic Home Page Integration

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'featured/home-page/views/widgets/major_category_section.dart';
import 'controllers/major_category_controller.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(MajorCategoryController());
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Other widgets...
            
            // Categories Section
            const MajorCategorySection(),
            
            // Other widgets...
          ],
        ),
      ),
    );
  }
}
```

### 2. Direct Navigation to Categories Page

```dart
import 'featured/all-categories/views/all_categories_page.dart';

// Navigate to categories page
Get.to(() => const AllCategoriesPage());
```

### 3. Custom Category Actions

```dart
// Toggle featured status
controller.toggleFeatured(categoryId, !isFeatured);

// Update category status
controller.updateCategoryStatus(categoryId, newStatus);

// Search categories
controller.searchCategories(searchQuery);
```

## 🎨 Widget Customization

### Category Icons and Colors

The system automatically assigns icons and colors based on category names:

```dart
// Supported category types:
- Clothing/Clothes → Pink, Checkroom icon
- Shoes/Footwear → Brown, Shopping bag icon
- Bags/Handbags → Purple, Shopping basket icon
- Accessories/Watch → Blue, Watch icon
- Electronics/Phone → Blue Grey, Phone icon
- Home/Furniture → Green, Home icon
- Beauty/Cosmetics → Pink Accent, Face icon
- Sports/Fitness → Orange, Sports icon
- Books/Education → Indigo, Book icon
- Toys/Games → Red, Toys icon
- Default → Grey, Category icon
```

### Status Colors

```dart
- Active (1) → Green
- Pending (2) → Orange  
- Inactive (3) → Red
- Unknown → Grey
```

## 🔧 Controller Integration

### Required Controller Setup

```dart
// Initialize controller
final controller = Get.put(MajorCategoryController());

// Load data
await controller.loadAllCategories();
await controller.loadFeaturedCategories();
```

### Available Controller Methods

```dart
// Data loading
controller.loadAllCategories()
controller.loadFeaturedCategories()
controller.loadRootCategories()
controller.loadActiveCategories()

// Search and filtering
controller.searchCategories(query)
controller.setStatusFilter(status)
controller.toggleFeaturedFilter()
controller.clearFilters()

// CRUD operations
controller.createCategory(category)
controller.updateCategory(category)
controller.deleteCategory(id)
controller.toggleFeatured(id, isFeatured)
controller.updateCategoryStatus(id, status)
```

## 📱 Responsive Design

### Grid View (Default)
- **2 columns** on mobile
- **3-4 columns** on tablet
- **5+ columns** on desktop
- **Aspect ratio** 0.8 for optimal display

### List View
- **Full width** items
- **60x60** category images
- **Action buttons** on the right
- **Status and featured badges**

## 🌐 Internationalization

### Required Translation Keys

```dart
// Arabic (ar.dart)
'all_categories': 'جميع الفئات',
'category_selected': 'تم اختيار الفئة',
'active': 'نشط',
'pending': 'معلق',
'inactive': 'غير نشط',
'featured': 'مميز',
'search_categories': 'البحث في الفئات',
// ... and more

// English (en.dart)
'all_categories': 'All Categories',
'category_selected': 'Category Selected',
'active': 'Active',
'pending': 'Pending',
'inactive': 'Inactive',
'featured': 'Featured',
'search_categories': 'Search Categories',
// ... and more
```

## 🎯 Navigation Flow

```
Home Page
├── MajorCategorySection
│   ├── Category Item Tap → Category Details Modal
│   └── "See All" Button → AllCategoriesPage
└── AllCategoriesPage
    ├── Grid/List Toggle
    ├── Search Bar
    ├── Filter Chips
    ├── Category Item Tap → Category Details Modal
    └── Category Actions (Featured, Status)
```

## 🔍 Search Functionality

### Real-time Search
- **Instant filtering** as user types
- **Search in both** English and Arabic names
- **Clear search** button
- **No results** state with helpful message

### Search Implementation
```dart
// In CategorySearchBar
TextField(
  onChanged: onSearchChanged,
  decoration: InputDecoration(
    hintText: 'search_categories'.tr,
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: onClearSearch,
    ),
  ),
)
```

## 🎨 UI Components

### CategoryGridItem
- **Card-based** design with elevation
- **Category image** with fallback icon
- **Featured star** badge
- **Status indicator** badge
- **Action buttons** (Featured toggle, Navigate)

### CategoryListItem
- **Horizontal layout** with image and details
- **Status and featured** badges
- **Popup menu** for status changes
- **Featured toggle** button

### CategoryFilterChips
- **Horizontal scrolling** chips
- **Color-coded** status filters
- **Featured filter** with star icon
- **Clear filters** option

## 🚀 Performance Tips

1. **Lazy loading** for large category lists
2. **Image caching** for category images
3. **Debounced search** to avoid excessive API calls
4. **Controller singleton** pattern with GetX
5. **Efficient filtering** with computed properties

## 🔒 Error Handling

### Network Errors
- **Loading states** with CircularProgressIndicator
- **Error messages** with Get.snackbar
- **Retry mechanisms** for failed operations

### Empty States
- **No categories** message
- **No search results** with search hint
- **Placeholder content** for missing data

## 🎯 Future Enhancements

1. **Category hierarchy** display in list view
2. **Drag and drop** reordering
3. **Bulk operations** (select multiple categories)
4. **Category analytics** and statistics
5. **Offline support** with local caching
6. **Category templates** for quick creation

## 📝 Example Implementation

See `lib/examples/home_page_with_categories_example.dart` for a complete implementation example showing how to integrate the categories widgets into a home page.

This system provides a complete, production-ready solution for category management with modern UI/UX patterns and full internationalization support.
