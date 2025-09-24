class PaymentModel {
  String? id;
  String? orderId;
  String paymentMethod;
  double amount;
  String? currencyId;
  String? transactionId;
  String status;
  DateTime? paymentDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentModel({
    this.id,
    this.orderId,
    required this.paymentMethod,
    required this.amount,
    this.currencyId,
    this.transactionId,
    this.status = 'pending',
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> data) {
    return PaymentModel(
      id: data['id'],
      orderId: data['order_id'],
      paymentMethod: data['payment_method'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currencyId: data['currency_id'],
      transactionId: data['transaction_id'],
      status: data['status'] ?? 'pending',
      paymentDate:
          data['payment_date'] != null
              ? DateTime.parse(data['payment_date'])
              : null,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency_id': currencyId,
      'transaction_id': transactionId,
      'status': status,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create empty payment
  static PaymentModel empty() => PaymentModel(paymentMethod: '', amount: 0.0);

  // Copy with method for updates
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? paymentMethod,
    double? amount,
    String? currencyId,
    String? transactionId,
    String? status,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currencyId: currencyId ?? this.currencyId,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  PaymentModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if payment is valid
  bool get isValid {
    return paymentMethod.isNotEmpty &&
        amount > 0 &&
        orderId != null &&
        orderId!.isNotEmpty;
  }

  // Check if payment is completed
  bool get isCompleted {
    return status == 'completed';
  }

  // Check if payment is pending
  bool get isPending {
    return status == 'pending';
  }

  // Check if payment is failed
  bool get isFailed {
    return status == 'failed';
  }

  // Check if payment is refunded
  bool get isRefunded {
    return status == 'refunded';
  }

  // Get formatted amount
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  // Get payment method display text
  String get paymentMethodDisplayText {
    switch (paymentMethod.toLowerCase()) {
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      default:
        return paymentMethod;
    }
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, orderId: $orderId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
