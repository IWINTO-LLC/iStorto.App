# Major Category System Documentation

## 📋 Overview

This system provides a complete hierarchical category management solution for the `categories` table in Supabase. It includes Model, Repository, and Controller with full CRUD operations and hierarchical support.

## 🗂️ Files Structure

```
lib/
├── data/
│   ├── models/
│   │   └── major_category_model.dart          # Data model with hierarchy support
│   └── repositories/
│       └── major_category_repository.dart     # Supabase CRUD operations
├── controllers/
│   └── major_category_controller.dart         # GetX state management
└── examples/
    └── major_category_usage_example.dart      # Complete usage example
```

## 🗄️ Database Schema

```sql
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  arabic_name text NULL,
  image text NULL,
  is_feature boolean NULL DEFAULT false,
  status integer NULL DEFAULT 2,
  parent_id uuid NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES categories (id)
);
```

## 🏗️ Model Features

### MajorCategoryModel

- **Hierarchical Structure**: Support for parent-child relationships
- **Multi-language**: English and Arabic names
- **Status Management**: Active (1), Pending (2), Inactive (3)
- **Featured Categories**: Special highlighting
- **Image Support**: Category images
- **Utility Methods**: Depth calculation, path building, descendants/ancestors

### Key Methods:

```dart
// Hierarchy utilities
bool get isRoot                    // Check if root category
bool get isLeaf                    // Check if leaf category
int get depth                      // Get hierarchy depth
String get fullPath               // Get full path from root
List<MajorCategoryModel> get allDescendants  // Get all children
List<MajorCategoryModel> get allAncestors    // Get all parents

// Static methods
static List<MajorCategoryModel> buildHierarchy(List<MajorCategoryModel> flatList)
```

## 🔧 Repository Features

### MajorCategoryRepository

Complete CRUD operations with Supabase:

```dart
// Basic CRUD
Future<List<MajorCategoryModel>> getAllCategories()
Future<MajorCategoryModel?> getCategoryById(String id)
Future<MajorCategoryModel> createCategory(MajorCategoryModel category)
Future<MajorCategoryModel> updateCategory(MajorCategoryModel category)
Future<void> deleteCategory(String id)

// Hierarchy operations
Future<List<MajorCategoryModel>> getCategoriesHierarchy()
Future<List<MajorCategoryModel>> getRootCategories()
Future<List<MajorCategoryModel>> getCategoriesByParent(String parentId)

// Filtering and search
Future<List<MajorCategoryModel>> getFeaturedCategories()
Future<List<MajorCategoryModel>> getActiveCategories()
Future<List<MajorCategoryModel>> searchCategories(String query)
Future<List<MajorCategoryModel>> getCategoriesByStatus(int status)

// Status management
Future<MajorCategoryModel> updateCategoryStatus(String id, int status)
Future<MajorCategoryModel> toggleFeatured(String id, bool isFeatured)

// Bulk operations
Future<List<MajorCategoryModel>> bulkUpdateCategories(List<String> ids, Map<String, dynamic> updates)
Future<Map<String, int>> getCategoryStats()
```

## 🎮 Controller Features

### MajorCategoryController

GetX-based state management with reactive updates:

```dart
// Observable data
RxList<MajorCategoryModel> allCategories
RxList<MajorCategoryModel> hierarchicalCategories
RxList<MajorCategoryModel> rootCategories
RxList<MajorCategoryModel> featuredCategories
RxList<MajorCategoryModel> activeCategories

// State management
RxBool isLoading, isCreating, isUpdating, isDeleting
RxString searchQuery
RxList<MajorCategoryModel> searchResults

// Filtering
RxInt selectedStatus (0: All, 1: Active, 2: Pending, 3: Inactive)
RxBool showFeaturedOnly

// Computed properties
List<MajorCategoryModel> get filteredCategories
```

### Key Methods:

```dart
// Data loading
Future<void> loadAllCategories()
Future<void> loadHierarchicalCategories()
Future<void> loadRootCategories()
Future<void> loadFeaturedCategories()
Future<void> loadActiveCategories()

// CRUD operations
Future<bool> createCategory(MajorCategoryModel category)
Future<bool> updateCategory(MajorCategoryModel category)
Future<bool> deleteCategory(String id)

// Status management
Future<bool> updateCategoryStatus(String id, int status)
Future<bool> toggleFeatured(String id, bool isFeatured)

// Search and filtering
Future<void> searchCategories(String query)
void setStatusFilter(int status)
void toggleFeaturedFilter()
void clearFilters()

// Utilities
MajorCategoryModel? getCategoryById(String id)
List<MajorCategoryModel> getCategoriesByParent(String parentId)
Future<Map<String, int>> getCategoryStats()
Future<void> refreshAll()
```

## 🚀 Usage Examples

### 1. Basic Setup

```dart
// Initialize controller
final controller = Get.put(MajorCategoryController());

// Load data
await controller.loadAllCategories();
```

### 2. Display Categories

```dart
Obx(() => ListView.builder(
  itemCount: controller.allCategories.length,
  itemBuilder: (context, index) {
    final category = controller.allCategories[index];
    return ListTile(
      title: Text(category.displayName),
      subtitle: Text('Status: ${category.status}'),
      trailing: category.isFeature ? Icon(Icons.star) : null,
    );
  },
))
```

### 3. Create Category

```dart
final category = MajorCategoryModel(
  name: 'Electronics',
  arabicName: 'إلكترونيات',
  isFeature: true,
  status: 1, // Active
);

await controller.createCategory(category);
```

### 4. Search Categories

```dart
// Search by name
await controller.searchCategories('electronics');

// Filter by status
controller.setStatusFilter(1); // Active only

// Show featured only
controller.toggleFeaturedFilter();
```

### 5. Hierarchy Operations

```dart
// Get root categories
final rootCategories = controller.rootCategories;

// Get children of a category
final children = controller.getCategoriesByParent(parentId);

// Build hierarchy
final hierarchy = MajorCategoryModel.buildHierarchy(flatList);
```

## 🎯 Status Codes

- **1**: Active - Category is live and visible
- **2**: Pending - Category is awaiting approval
- **3**: Inactive - Category is disabled

## 🔍 Search Features

- Search by English name
- Search by Arabic name
- Case-insensitive search
- Real-time search results

## 📊 Statistics

Get category statistics:

```dart
final stats = await controller.getCategoryStats();
// Returns: {total: 50, active: 30, pending: 15, inactive: 5, featured: 10}
```

## 🛡️ Error Handling

All operations include comprehensive error handling with user-friendly messages:

```dart
try {
  await controller.createCategory(category);
} catch (e) {
  Get.snackbar('Error', 'Failed to create category: $e');
}
```

## 🔄 Real-time Updates

The controller automatically updates all relevant lists when categories are modified:

- Creating a category updates all applicable lists
- Updating status/featured status updates filtered lists
- Deleting removes from all lists
- Search results are maintained separately

## 📱 Complete Example

See `lib/examples/major_category_usage_example.dart` for a complete implementation with:

- Search functionality
- Filtering by status and featured
- CRUD operations with dialogs
- Real-time updates
- Error handling
- Loading states

## 🎨 UI Components

The example includes:

- Search bar with clear functionality
- Status and featured filters
- Category tiles with actions
- Create/Edit dialogs
- Delete confirmation
- Category details view

## 🔧 Customization

### Adding New Fields

1. Update the model with new properties
2. Update `toJson()` and `fromJson()` methods
3. Update repository methods if needed
4. Update controller if filtering is required

### Adding New Status Codes

1. Update the model documentation
2. Update the example UI dropdowns
3. Update any status-specific logic

### Adding New Filters

1. Add new Rx variables to controller
2. Update `filteredCategories` getter
3. Add UI components for the new filter
4. Update `clearFilters()` method

## 🚀 Performance Tips

1. Use `loadHierarchicalCategories()` for tree views
2. Use `loadRootCategories()` for main navigation
3. Use `loadFeaturedCategories()` for homepage
4. Implement pagination for large datasets
5. Cache frequently accessed data

## 🔒 Security Considerations

1. Validate all inputs before creating/updating
2. Implement proper authorization checks
3. Sanitize search queries
4. Validate parent-child relationships
5. Implement soft delete if needed

This system provides a robust foundation for hierarchical category management with full CRUD operations, search, filtering, and real-time updates.
