class CurrencyModel {
  final String? id;
  final String name;
  final String iso;
  final double usdToCoinExchangeRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CurrencyModel({
    this.id,
    required this.name,
    required this.iso,
    required this.usdToCoinExchangeRate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iso': iso,
      'usd_to_coin_exchange_rate': usdToCoinExchangeRate,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map['id'],
      name: map['name'] ?? '',
      iso: map['iso'] ?? '',
      usdToCoinExchangeRate:
          (map['usd_to_coin_exchange_rate'] ?? 0.0).toDouble(),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  CurrencyModel copyWith({
    String? id,
    String? name,
    String? iso,
    double? usdToCoinExchangeRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iso: iso ?? this.iso,
      usdToCoinExchangeRate:
          usdToCoinExchangeRate ?? this.usdToCoinExchangeRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create empty currency
  static CurrencyModel empty() =>
      CurrencyModel(name: '', iso: '', usdToCoinExchangeRate: 0.0);

  // Update timestamp
  CurrencyModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if currency is valid
  bool get isValid {
    return name.isNotEmpty && iso.isNotEmpty && usdToCoinExchangeRate > 0;
  }

  // Convert USD to this currency
  double convertFromUSD(double usdAmount) {
    return usdAmount * usdToCoinExchangeRate;
  }

  // Convert this currency to USD
  double convertToUSD(double currencyAmount) {
    return currencyAmount / usdToCoinExchangeRate;
  }

  // Get formatted exchange rate
  String get formattedExchangeRate {
    return '1 USD = ${usdToCoinExchangeRate.toStringAsFixed(6)} $iso';
  }

  // Get currency symbol (basic implementation)
  String get symbol {
    switch (iso.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'EGP':
        return 'ج.م';
      default:
        return iso;
    }
  }

  // Get formatted amount
  String getFormattedAmount(double amount) {
    return '${amount.toStringAsFixed(2)} $symbol';
  }

  @override
  String toString() {
    return 'CurrencyModel(id: $id, name: $name, iso: $iso, rate: $usdToCoinExchangeRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
