// lib/recipe_data.dart
class RecipeData {
  final String recipeName;
  final int carbonRating;
  final double emissionsComparedToAverage;
  final int preparationTime;
  final String difficultyLevel;
  final String reducedCarbon;
  final List<String> ingredients;
  final List<String> instructions;
  

  RecipeData({
    required this.recipeName,
    required this.carbonRating,
    required this.emissionsComparedToAverage,
    required this.preparationTime,
    required this.difficultyLevel,
    required this.reducedCarbon,
    required this.ingredients,
    required this.instructions,
    
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    // ① 先把整包 JSON 印出來
    print('🔹 Raw JSON ➜ $json');

    final recipe = RecipeData(
      recipeName: json['recipe_name'],
      carbonRating: json['carbon_rating'],
      emissionsComparedToAverage: double.parse(
        (json['emissions_compared_to_average'] as String)
            .replaceAll('-', '')
            .replaceAll('%', ''),
      ),
      preparationTime: json['preparation_time'],
      difficultyLevel: json['difficulty_level'],
      reducedCarbon: (json['Reduced kg of carbon emissions'] ?? json['Reduced kg of carbon emissions:']),
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
    );

    // ② 再把 parse 後的結果印一次
    print('✅ Parsed RecipeData ➜ $recipe');

    return recipe;
  }
}