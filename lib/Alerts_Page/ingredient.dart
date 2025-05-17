class Ingredient {
  final String name;
  final String quantity;
  final DateTime expiryDate;
  final String? id;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json, String id) {
    return Ingredient(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      id: id,
    );
  }
}

/// 繼承自 Ingredient，多了一個 ownerUid 欄位
class SharedIngredient extends Ingredient {
  final String ownerUid;

  // 選擇性：你也可以額外把 email 存進來，減少 UI 重複查詢
  String? ownerEmail;

  SharedIngredient({
    required this.ownerUid,
    required String id,
    required String name,
    required String quantity,
    required DateTime expiryDate,
    this.ownerEmail,
  }) : super(id: id, name: name, quantity: quantity, expiryDate: expiryDate);

  /// 從 Firestore doc （含 ownerUid 字段）建立
  factory SharedIngredient.fromJson(
    Map<String, dynamic> json,
    String id,
    String ownerUid,
  ) {
    return SharedIngredient(
      ownerUid: ownerUid,
      id: id,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
    );
  }
}
