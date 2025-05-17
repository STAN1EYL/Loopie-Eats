import 'package:flutter_application_2/Alerts_Page/ingredient.dart';

class DissmissIngredient {
  final String name;
  final String quantity;
  final DateTime expiryDate;
  final String? id;
  
  

  DissmissIngredient({
    required this.name, 
    required this.quantity, 
    required this.expiryDate,
    this.id
  });


    Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(), // 儲存成 ISO 字串
    };
  }

  factory DissmissIngredient.fromIngredient(Ingredient i) =>
        DissmissIngredient(
          name: i.name,
          quantity: i.quantity,
          expiryDate: i.expiryDate,
          id: i.id,
        );
  

}

/*
return Ingredient(
      name: json['name'],
      quantity: json['quantity'],
      expiryDate: DateTime.parse(json['expiryDate']),
      id: id,
    );
*/