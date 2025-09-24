import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_model.dart';

class PaymentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new payment
  Future<PaymentModel?> createPayment(PaymentModel payment) async {
    try {
      final response =
          await _client
              .from('payments')
              .insert(payment.toJson())
              .select()
              .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final response =
          await _client
              .from('payments')
              .select()
              .eq('id', paymentId)
              .maybeSingle();

      if (response == null) return null;
      return PaymentModel.fromJson(response);
    } catch (e) {
      print('Error getting payment by ID: $e');
      return null;
    }
  }

  // Get payments by order ID
  Future<List<PaymentModel>> getPaymentsByOrder(String orderId) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error getting payments by order: $e');
      return [];
    }
  }

  // Get payments by status
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error getting payments by status: $e');
      return [];
    }
  }

  // Get payments by payment method
  Future<List<PaymentModel>> getPaymentsByMethod(String paymentMethod) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('payment_method', paymentMethod)
          .order('created_at', ascending: false);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error getting payments by method: $e');
      return [];
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String newStatus) async {
    try {
      await _client
          .from('payments')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Update payment
  Future<PaymentModel?> updatePayment(PaymentModel payment) async {
    try {
      final paymentData = payment.toJson();
      paymentData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('payments')
              .update(paymentData)
              .eq('id', payment.id!)
              .select()
              .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      print('Error updating payment: $e');
      return null;
    }
  }

  // Delete payment
  Future<bool> deletePayment(String paymentId) async {
    try {
      await _client.from('payments').delete().eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error deleting payment: $e');
      return false;
    }
  }

  // Search payments by transaction ID
  Future<List<PaymentModel>> searchPaymentsByTransactionId(
    String transactionId,
  ) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .ilike('transaction_id', '%$transactionId%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error searching payments by transaction ID: $e');
      return [];
    }
  }

  // Get payments count
  Future<int> getPaymentsCount() async {
    try {
      final response = await _client.from('payments').select('id');

      return (response as List).length;
    } catch (e) {
      print('Error getting payments count: $e');
      return 0;
    }
  }

  // Get payments count by status
  Future<int> getPaymentsCountByStatus(String status) async {
    try {
      final response = await _client
          .from('payments')
          .select('id')
          .eq('status', status);

      return (response as List).length;
    } catch (e) {
      print('Error getting payments count by status: $e');
      return 0;
    }
  }

  // Get payments count by order
  Future<int> getPaymentsCountByOrder(String orderId) async {
    try {
      final response = await _client
          .from('payments')
          .select('id')
          .eq('order_id', orderId);

      return (response as List).length;
    } catch (e) {
      print('Error getting payments count by order: $e');
      return 0;
    }
  }

  // Get payments with pagination
  Future<List<PaymentModel>> getPaymentsPaginated({
    int page = 0,
    int limit = 20,
    String? orderId,
    String? status,
    String? paymentMethod,
  }) async {
    try {
      var query = _client.from('payments').select();

      if (orderId != null) {
        query = query.eq('order_id', orderId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      if (paymentMethod != null) {
        query = query.eq('payment_method', paymentMethod);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error getting payments paginated: $e');
      return [];
    }
  }

  // Get total amount by status
  Future<double> getTotalAmountByStatus(String status) async {
    try {
      final response = await _client
          .from('payments')
          .select('amount')
          .eq('status', status);

      double total = 0.0;
      for (var payment in response as List) {
        total += (payment['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total amount by status: $e');
      return 0.0;
    }
  }

  // Get total amount by order
  Future<double> getTotalAmountByOrder(String orderId) async {
    try {
      final response = await _client
          .from('payments')
          .select('amount')
          .eq('order_id', orderId);

      double total = 0.0;
      for (var payment in response as List) {
        total += (payment['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total amount by order: $e');
      return 0.0;
    }
  }

  // Get payments by date range
  Future<List<PaymentModel>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? orderId,
    String? status,
  }) async {
    try {
      var query = _client
          .from('payments')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (orderId != null) {
        query = query.eq('order_id', orderId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      print('Error getting payments by date range: $e');
      return [];
    }
  }

  // Mark payment as completed
  Future<bool> markPaymentCompleted(
    String paymentId,
    String transactionId,
  ) async {
    try {
      await _client
          .from('payments')
          .update({
            'status': 'completed',
            'transaction_id': transactionId,
            'payment_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error marking payment as completed: $e');
      return false;
    }
  }

  // Mark payment as failed
  Future<bool> markPaymentFailed(String paymentId) async {
    try {
      await _client
          .from('payments')
          .update({
            'status': 'failed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error marking payment as failed: $e');
      return false;
    }
  }

  // Mark payment as refunded
  Future<bool> markPaymentRefunded(String paymentId) async {
    try {
      await _client
          .from('payments')
          .update({
            'status': 'refunded',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error marking payment as refunded: $e');
      return false;
    }
  }
}
