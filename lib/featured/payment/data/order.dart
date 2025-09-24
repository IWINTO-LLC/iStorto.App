import 'package:istoreto/featured/cart/model/cart_item.dart';
import 'package:istoreto/models/user_model.dart';

class OrderModel {
  String? id;
  String docId;
  String buyerId;
  String vendorId;
  String state;
  double totalPrice;
  DateTime orderDate;
  String? phoneNumber;
  String? fullAddress;
  String? buildingNumber;
  String paymentMethod;
  double? locationLat;
  double? locationLng;
  UserModel buyerDetails;
  String? currencyId;
  String? addressId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<CartItem> productList;

  OrderModel({
    this.id,
    required this.docId,
    required this.buyerId,
    required this.vendorId,
    this.state = '0',
    required this.totalPrice,
    required this.orderDate,
    required this.productList,
    this.phoneNumber,
    required this.buyerDetails,
    this.fullAddress,
    this.buildingNumber,
    this.paymentMethod = 'cod',
    this.locationLat,
    this.locationLng,
    this.currencyId,
    this.addressId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'doc_id': docId,
    'buyer_id': buyerId,
    'vendor_id': vendorId,
    'state': state,
    'total_price': totalPrice,
    'order_date': orderDate.toIso8601String(),
    'phone_number': phoneNumber,
    'full_address': fullAddress,
    'building_number': buildingNumber,
    'payment_method': paymentMethod,
    'location_lat': locationLat,
    'location_lng': locationLng,
    'currency_id': currencyId,
    'address_id': addressId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'buyer_details': buyerDetails.toJson(),
    'product_list': productList.map((item) => item.toJson()).toList(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    docId: json['doc_id'] ?? json['docId'] ?? '',
    buyerId: json['buyer_id'] ?? json['buyerId'] ?? '',
    vendorId: json['vendor_id'] ?? json['sellerId'] ?? '',
    state: json['state'] ?? '0',
    totalPrice: (json['total_price'] ?? json['price'] ?? 0.0).toDouble(),
    orderDate:
        json['order_date'] != null
            ? DateTime.parse(json['order_date'])
            : json['orderDate'] != null
            ? DateTime.parse(json['orderDate'])
            : DateTime.now(),
    productList:
        json['product_list'] != null
            ? (json['product_list'] as List<dynamic>)
                .map((e) => CartItem.fromJson(e))
                .toList()
            : json['productList'] != null
            ? (json['productList'] as List<dynamic>)
                .map((e) => CartItem.fromJson(e))
                .toList()
            : [],
    phoneNumber: json['phone_number'] ?? json['phoneNumber'],
    fullAddress: json['full_address'] ?? json['fullAddress'],
    buildingNumber: json['building_number'] ?? json['buildingNumber'],
    paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? 'cod',
    locationLat:
        json['location_lat'] != null
            ? (json['location_lat'] as num).toDouble()
            : null,
    locationLng:
        json['location_lng'] != null
            ? (json['location_lng'] as num).toDouble()
            : null,
    currencyId: json['currency_id'],
    addressId: json['address_id'],
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt:
        json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    buyerDetails:
        json['buyer_details'] != null
            ? UserModel.fromJson(json['buyer_details'] as Map<String, dynamic>)
            : UserModel(
              id: '',
              userId: json['buyer_id'] ?? '',
              name: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
  );

  OrderModel copyWith({
    String? id,
    String? docId,
    String? buyerId,
    String? vendorId,
    String? state,
    double? totalPrice,
    DateTime? orderDate,
    String? phoneNumber,
    String? fullAddress,
    String? buildingNumber,
    String? paymentMethod,
    double? locationLat,
    double? locationLng,
    String? currencyId,
    String? addressId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CartItem>? productList,
    UserModel? buyerDetails,
  }) {
    return OrderModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      buyerId: buyerId ?? this.buyerId,
      vendorId: vendorId ?? this.vendorId,
      state: state ?? this.state,
      totalPrice: totalPrice ?? this.totalPrice,
      orderDate: orderDate ?? this.orderDate,
      productList: productList ?? this.productList,
      fullAddress: fullAddress ?? this.fullAddress,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      currencyId: currencyId ?? this.currencyId,
      addressId: addressId ?? this.addressId,
      buyerDetails: buyerDetails ?? this.buyerDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create empty order
  static OrderModel empty() => OrderModel(
    docId: '',
    buyerId: '',
    vendorId: '',
    totalPrice: 0.0,
    orderDate: DateTime.now(),
    productList: [],
    buyerDetails: UserModel(
      id: '',
      userId: '',
      name: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  // Update timestamp
  OrderModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if order is valid
  bool get isValid {
    return docId.isNotEmpty &&
        buyerId.isNotEmpty &&
        vendorId.isNotEmpty &&
        totalPrice > 0;
  }

  // Get order state display text
  String get stateDisplayText {
    switch (state) {
      case '0':
        return 'Unknown';
      case '1':
        return 'Paid';
      case '2':
        return 'Delivered';
      case '3':
        return 'Preparing';
      case '4':
        return 'Running';
      default:
        return 'Unknown';
    }
  }

  // Get formatted total price
  String get formattedTotalPrice {
    return '\$${totalPrice.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, docId: $docId, buyerId: $buyerId, vendorId: $vendorId, totalPrice: $totalPrice, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
