class Account {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String accountType;
  final String currency;
  final String icon;
  final bool isDefault;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.accountType,
    required this.currency,
    required this.icon,
    required this.isDefault,
  });

  // ✅ Ensure balance is always a double
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'],
      balance: double.tryParse(json['balance'].toString()) ?? 0.0, // ✅ FIX: Ensure double conversion
      accountType: json['account_type'],
      currency: json['currency'],
      icon: json['icon'] ?? "default_icon",
      isDefault: json['is_default'] == true || json['is_default'] == 1, // ✅ Convert '1' or 'true' to boolean
    );
  }

  // ✅ Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "name": name,
      "balance": balance,
      "account_type": accountType,
      "currency": currency,
      "icon": icon,
      "is_default": isDefault ? 1 : 0, // ✅ Store boolean as 1/0 for database
    };
  }
}
