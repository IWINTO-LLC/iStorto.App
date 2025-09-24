import 'package:supabase_flutter/supabase_flutter.dart';
import 'order.dart';

class OrderRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new order
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final orderData = order.toJson();
      // Remove product_list from the main order data as it's not part of the orders table
      orderData.remove('product_list');

      final response =
          await _client.from('orders').insert(orderData).select().single();

      return OrderModel.fromJson(response);
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response =
          await _client.from('orders').select().eq('id', orderId).maybeSingle();

      if (response == null) return null;
      return OrderModel.fromJson(response);
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  // Get order by doc_id
  Future<OrderModel?> getOrderByDocId(String docId) async {
    try {
      final response =
          await _client
              .from('orders')
              .select()
              .eq('doc_id', docId)
              .maybeSingle();

      if (response == null) return null;
      return OrderModel.fromJson(response);
    } catch (e) {
      print('Error getting order by doc_id: $e');
      return null;
    }
  }

  // Get orders by buyer ID
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('buyer_id', buyerId)
          .order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by buyer: $e');
      return [];
    }
  }

  // Get orders by vendor ID
  Future<List<OrderModel>> getOrdersByVendor(String vendorId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('vendor_id', vendorId)
          .order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by vendor: $e');
      return [];
    }
  }

  // Update order state
  Future<bool> updateOrderState(String orderId, String newState) async {
    try {
      await _client
          .from('orders')
          .update({
            'state': newState,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return true;
    } catch (e) {
      print('Error updating order state: $e');
      return false;
    }
  }

  // Update order
  Future<OrderModel?> updateOrder(OrderModel order) async {
    try {
      final orderData = order.toJson();
      // Remove product_list from the main order data
      orderData.remove('product_list');
      orderData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('orders')
              .update(orderData)
              .eq('id', order.id!)
              .select()
              .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      print('Error updating order: $e');
      return null;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _client.from('orders').delete().eq('id', orderId);

      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  // Get orders by state
  Future<List<OrderModel>> getOrdersByState(String state) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('state', state)
          .order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by state: $e');
      return [];
    }
  }

  // Get orders by payment method
  Future<List<OrderModel>> getOrdersByPaymentMethod(
    String paymentMethod,
  ) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('payment_method', paymentMethod)
          .order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by payment method: $e');
      return [];
    }
  }

  // Search orders
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .or(
            'doc_id.ilike.%$query%,full_address.ilike.%$query%,phone_number.ilike.%$query%',
          )
          .order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error searching orders: $e');
      return [];
    }
  }

  // Get orders count
  Future<int> getOrdersCount() async {
    try {
      final response = await _client.from('orders').select('id');

      return (response as List).length;
    } catch (e) {
      print('Error getting orders count: $e');
      return 0;
    }
  }

  // Get orders count by buyer
  Future<int> getOrdersCountByBuyer(String buyerId) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('buyer_id', buyerId);

      return (response as List).length;
    } catch (e) {
      print('Error getting orders count by buyer: $e');
      return 0;
    }
  }

  // Get orders count by vendor
  Future<int> getOrdersCountByVendor(String vendorId) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('vendor_id', vendorId);

      return (response as List).length;
    } catch (e) {
      print('Error getting orders count by vendor: $e');
      return 0;
    }
  }

  // Get orders count by state
  Future<int> getOrdersCountByState(String state) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('state', state);

      return (response as List).length;
    } catch (e) {
      print('Error getting orders count by state: $e');
      return 0;
    }
  }

  // Get orders with pagination
  Future<List<OrderModel>> getOrdersPaginated({
    int page = 0,
    int limit = 20,
    String? buyerId,
    String? vendorId,
    String? state,
  }) async {
    try {
      var query = _client.from('orders').select();

      if (buyerId != null) {
        query = query.eq('buyer_id', buyerId);
      }
      if (vendorId != null) {
        query = query.eq('vendor_id', vendorId);
      }
      if (state != null) {
        query = query.eq('state', state);
      }

      final response = await query
          .order('order_date', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders paginated: $e');
      return [];
    }
  }

  // Get orders stream for real-time updates
  Stream<List<OrderModel>> getOrdersStream({
    String? buyerId,
    String? vendorId,
    String? state,
  }) {
    try {
      var query = _client.from('orders').stream(primaryKey: ['id']);

      // Apply filters before ordering
      // if (buyerId != null) {
      //   query = query.eq('buyer_id', buyerId);
      // }
      // if (vendorId != null) {
      //   query = query.eq('vendor_id', vendorId);
      // }
      // if (state != null) {
      //   query = query.eq('state', state);
      // }

      // // Apply ordering after filters
      // query = query.order('order_date', ascending: false);

      return query.map(
        (data) =>
            (data as List).map((order) => OrderModel.fromJson(order)).toList(),
      );
    } catch (e) {
      print('Error getting orders stream: $e');
      return Stream.value([]);
    }
  }

  // Check if vendor has orders
  Future<bool> hasOrders(String vendorId) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('vendor_id', vendorId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if vendor has orders: $e');
      return false;
    }
  }

  // Get total sales amount for vendor
  Future<double> getTotalSalesForVendor(String vendorId) async {
    try {
      final response = await _client
          .from('orders')
          .select('total_price')
          .eq('vendor_id', vendorId);

      double total = 0.0;
      for (var order in response as List) {
        total += (order['total_price'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total sales for vendor: $e');
      return 0.0;
    }
  }

  // Get orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? buyerId,
    String? vendorId,
  }) async {
    try {
      var query = _client.from('orders').select();

      // Apply date range filters first
      query = query
          .gte('order_date', startDate.toIso8601String())
          .lte('order_date', endDate.toIso8601String());

      // Apply additional filters
      if (buyerId != null) {
        query = query.eq('buyer_id', buyerId);
      }
      if (vendorId != null) {
        query = query.eq('vendor_id', vendorId);
      }

      // Apply ordering
      final response = await query.order('order_date', ascending: false);

      return (response as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      print('Error getting orders by date range: $e');
      return [];
    }
  }
}
