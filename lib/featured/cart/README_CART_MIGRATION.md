# Cart Migration from Firestore to Supabase

This document explains the migration of the cart functionality from Firestore to Supabase.

## Changes Made

### 1. Created Cart Repository (`lib/featured/cart/data/cart_repository.dart`)
- **Purpose**: Handles all Supabase database operations for cart functionality
- **Key Methods**:
  - `saveCartItems()` - Save cart items to Supabase
  - `loadCartItems()` - Load cart items from Supabase
  - `clearCart()` - Clear all cart items for current user
  - `removeProductFromCart()` - Remove specific product from cart
  - `updateProductQuantity()` - Update product quantity in cart
  - `getCartItemsCount()` - Get total items count
  - `getCartTotalValue()` - Get total cart value
  - `isProductInCart()` - Check if product exists in cart
  - `getProductQuantity()` - Get product quantity in cart

### 2. Updated Cart Controller (`lib/featured/cart/controller/cart_controller.dart`)
- **Removed**: All Firestore dependencies and methods
- **Added**: Supabase integration through cart repository
- **Updated Methods**:
  - `loadCartFromSupabase()` - Replaces `loadCartFromFirestore()`
  - `saveCartToSupabase()` - Replaces `saveCartToFirestore()`
  - `clearCart()` - Now async and uses repository
  - `removeFromCart()` - Now async and uses repository
  - `updateQuantity()` - Now async and uses repository
  - `addToCart()` - Now async
  - `decreaseQuantity()` - Now async
  - `saveToSupabaseAndGetDocId()` - Replaces Firestore version

### 3. Database Schema (`lib/utils/supabase_cart_schema.sql`)
- **Table**: `cart_items`
- **Features**:
  - Row Level Security (RLS) enabled
  - Automatic timestamp updates
  - Indexes for performance
  - Helper functions for cart operations
  - Cart summary view

## Database Setup Instructions

### Step 1: Run the SQL Schema
Execute the SQL commands in `lib/utils/supabase_cart_schema.sql` in your Supabase SQL editor:

```sql
-- Copy and paste the entire content of supabase_cart_schema.sql
-- into your Supabase SQL editor and run it
```

### Step 2: Verify Table Creation
After running the SQL, verify that the following are created:
- ✅ `cart_items` table
- ✅ RLS policies
- ✅ Indexes
- ✅ Helper functions
- ✅ `cart_summary` view

### Step 3: Test RLS Policies
Make sure the Row Level Security policies are working:
- Users can only see their own cart items
- Users can only modify their own cart items
- Anonymous users cannot access cart data

## Key Differences from Firestore

### Data Structure
**Firestore (Old)**:
```json
{
  "items": [
    {
      "productId": "123",
      "vendorId": "vendor1",
      "title": "Product Name",
      "price": 29.99,
      "quantity": 2,
      "image": "image_url"
    }
  ],
  "total": 59.98,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**Supabase (New)**:
```sql
-- Each cart item is a separate row
cart_items:
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- product_id (TEXT)
- vendor_id (TEXT)
- title (TEXT)
- price (DECIMAL)
- quantity (INTEGER)
- image (TEXT)
- total_price (DECIMAL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Performance Benefits
1. **Better Query Performance**: Indexed columns for faster lookups
2. **Atomic Operations**: Database-level constraints and transactions
3. **Real-time Subscriptions**: Built-in real-time capabilities
4. **Better Security**: Row Level Security at database level

### Error Handling
- All repository methods include proper error handling
- User-friendly error messages via GetX snackbars
- Loading states for better UX

## Usage Examples

### Adding Items to Cart
```dart
final cartController = Get.find<CartController>();
await cartController.addToCart(product);
```

### Removing Items from Cart
```dart
await cartController.removeFromCart(product);
```

### Updating Quantities
```dart
await cartController.updateQuantity(product, 1); // Increase by 1
await cartController.updateQuantity(product, -1); // Decrease by 1
```

### Clearing Cart
```dart
await cartController.clearCart();
```

### Getting Cart Data
```dart
// Cart items
final items = cartController.cartItems;

// Total items count
final count = cartController.getTotalItems();

// Total price
final total = cartController.totalPrice;

// Selected items total
final selectedTotal = cartController.selectedTotalPrice;
```

## Migration Checklist

- [x] Create cart repository
- [x] Update cart controller
- [x] Create database schema
- [x] Remove Firestore dependencies
- [x] Fix linting errors
- [x] Add error handling
- [x] Add loading states
- [x] Test functionality

## Testing

To test the cart functionality:

1. **Add items to cart**: Use the `addToCart()` method
2. **Update quantities**: Use `updateQuantity()` method
3. **Remove items**: Use `removeFromCart()` method
4. **Clear cart**: Use `clearCart()` method
5. **Load cart**: Cart loads automatically on app start

## Troubleshooting

### Common Issues

1. **RLS Policy Errors**: Make sure RLS policies are properly set up
2. **Authentication Errors**: Ensure user is logged in before cart operations
3. **Type Errors**: Check that product IDs and quantities are correct types
4. **Network Errors**: Handle network connectivity issues gracefully

### Debug Tips

1. Check Supabase logs for database errors
2. Use `debugPrint()` statements to trace cart operations
3. Verify user authentication status
4. Check RLS policies in Supabase dashboard

## Future Enhancements

1. **Real-time Updates**: Implement real-time cart synchronization
2. **Cart Persistence**: Add offline cart support
3. **Cart Analytics**: Track cart abandonment and conversion rates
4. **Bulk Operations**: Add bulk add/remove operations
5. **Cart Sharing**: Allow users to share cart contents
