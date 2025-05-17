
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:go_router/go_router.dart';


class RecipePage extends StatefulWidget {
  /// 新增这个字段
  //final void Function(String promptResult) result;
  /// 构造函数里接收这个回调
  const RecipePage({
    super.key,
    //required this.result,
  });

  @override
  State<RecipePage> createState() => RecipePageState();
}

class RecipePageState extends State<RecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _preferencesXrestrictions = TextEditingController();
  
    
  bool isLoading = false;

  get crossAxisAlignment => null;

  String? generatedResult;

  Future<void> _generateRecipe() async {
    
    if(!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      generatedResult = null;
    });



/*

*/
    final prompt = '''
      I dont't want flatbread pockets
      if user says make it simple, make it with ingredinets, don't add anything else
      
      You are a professional sustainable‑food chef.
      Your task: create **brand‑new** recipes that are (1) edible, (2) respect user constraints,  
      (3) inspired by a *real, existing* recipe, but (4) noticeably transformed so it does NOT copy.
      Never reuse any recipe you have output in this or any other session.

      Ingredients I have:：${_ingredientController.text}，
      Preferences or restrictions: ${_preferencesXrestrictions.text}。
      Please generate a unique recipe that must include the following:
      {
        "recipe_name": <RecipeName>,
        "carbon_rating":  (1~10) <Number>,
        "emissions_compared_to_average": <Precentage>,
        "preparation_time": <minutes>,
        "difficulty_level": <Hard / Medium / Easy>,
        "Reduced kg of carbon emissions: <string ex:0.8> unique,
        "ingredients": [
          "2 cups leftover cooked potatoes, mashed",
          "1 cup leftover cooked carrots, finely grated",
          "1 small onion, finely chopped",
          "2 cloves garlic, minced",
          "1-2 green chilies, finely chopped (adjust to your spice preference)",
          "1 teaspoon ground cumin",
          "½ teaspoon coriander powder",
          "¼ teaspoon turmeric powder",
          "Salt and pepper to taste",
          "2 whole wheat flatbreads or pita breads",
          "2 tablespoons cooking oil (vegetable or olive oil)",
          "Fresh cilantro, chopped (for garnish)",
          "Plain yogurt or raita, for serving (optional)"
        ],
        "instructions": [
          "1. In a bowl, combine the mashed potatoes, grated carrots, finely chopped onion, minced garlic, and chopped green chilies.",
          "2. Add the ground cumin, coriander powder, and turmeric powder. Season with salt and pepper to taste. Mix well to combine.",
          "3. Heat the cooking oil in a skillet over medium heat.",
          "4. Place one flatbread in the skillet and cook for 1-2 minutes per side until lightly warmed.",
          "5. Spread half of the potato and carrot mixture evenly over one half of the flatbread, leaving a small border.",
          "6. Fold the other half of the flatbread over the filling to create a semi-circle.",
          "7. Gently press down the edges to seal the filling inside.",
          "8. Cook the stuffed flatbread for 3-4 minutes per side, pressing down gently, until it is golden brown and heated through.",
          "9. Remove from the skillet and repeat the process with the remaining flatbread and filling.",
          "10. Garnish with fresh cilantro and serve warm with plain yogurt or raita on the side, if desired."
        ]
      }
      
      Please format clearly. Make sure it looks clean and ready to display directly in the app.
      MUST USE JSON REPLY!
      開頭與結尾不要有```json
      Do not include any code block symbols like ```json or ``` or any explanations.
      回傳結果請務必為「純 JSON」，不要使用 markdown 語法（例如不要包含 ```json ``` 或 ```）。只允許回傳以 { 開始、以 } 結尾的合法 JSON 結構。
    ''';

    try {
      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      if (!mounted) return;

      context.go(
        '/result', 
        extra: {
          'result': response?.output ?? '無回應',
        }
      );
      

} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('錯誤：$e')));
    } finally { 
      setState(() => isLoading = false); //導航過去後 isLoading = false
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32,),
            Text(
              'Cook with Leftovers',
              textAlign: TextAlign.left,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color.fromARGB(255, 139, 110, 78),
              ),
            ),
            SizedBox(height: 5,),

            Text(
              "Enter ingredients you have and we'll create a recipe",
              textAlign: TextAlign.left,
              style: GoogleFonts.quicksand(
                
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20,),
            
            Text(
              'Ingredients you have',
              textAlign: TextAlign.left,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 480,
              child: TextFormField(
                controller: _ingredientController,      //輸入資訊會給到 => 在上面的 _generateRecipe 的 prompt 中
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at lesast one ingredient';
                  }
                  return null;
                },
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 50, top: 35, bottom: 35),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                    color: Color.fromARGB(255, 226, 225, 225)
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                    color: Colors.black
                    )
                  ),
              
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: " e.g., carrots, potatoes, tofu",
                ),
              ),
            ),
            SizedBox(height: 20,),

            Text(
              'Preferences or restrictions',
              textAlign: TextAlign.left,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 480,
              child: TextFormField(
                controller: _preferencesXrestrictions, //輸入資訊會給到 => 在上面的 _generateRecipe 的 prompt 中
                validator: (value) {
                  if(value == null || value.trim().isEmpty) {
                    return 'Please enter preferences or restrictions';
                  }
                  return null;
                },
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 50, top: 35, bottom: 35),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                    color: Color.fromARGB(255, 226, 225, 225)
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                    color: Colors.black
                    )
                  ),
                  
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: " e.g., vegetarian, no nuts, spicy",
                ),
              ),
            ),
            SizedBox(height: 25,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(480, 68),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                //padding: EdgeInsets.symmetric(horizontal: 140, vertical: 25),
                backgroundColor: Color.fromARGB(255, 123, 163, 111),
              ),
              onPressed: isLoading ? null : _generateRecipe, //執行上面的_generateRecipe (已經包含 {_ingredientController}  &  {_preferencesXrestrictions} )
              child: Text(
                isLoading ? 'Generating recipe...' : 'Generate Recipe',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}