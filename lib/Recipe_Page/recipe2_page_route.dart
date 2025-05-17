import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Recipe_data_process/recipe_parser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RecipeGenerateResultRoute extends StatelessWidget {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  final String result;

  //final void Function(String firstText, String secondText) onShare;

  const RecipeGenerateResultRoute({
    super.key,
    required this.result,
    //required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    
    late RecipeData recipe;
    try {
      final jsonMap = jsonDecode(result);
      recipe = RecipeData.fromJson(jsonMap);
    } catch (e) {
      return Scaffold(
        body: Center(child: Text("❌ JSON 解析錯誤：$e")),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 241, 236),
      appBar: AppBar(toolbarHeight: 32, backgroundColor: Color.fromARGB(255, 243, 241, 236),),
      body: Padding(
        padding: EdgeInsets.only(left:243, right: 243),
        
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            
            children: [
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
              SizedBox(height: 30,),
              Container(
                height: 720,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color.fromARGB(255, 177, 177, 177))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${recipe.recipeName}", 
                      style: GoogleFonts.quicksand(
                        fontSize: 25, 
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 139, 110, 78),
                      )
                    ),
                    SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Carbon Rating:",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        buildCarbonRating(recipe.carbonRating)
                      ]
                    ),
                    SizedBox(height: 5,),

                    Text(
                      "${100.0 - recipe.emissionsComparedToAverage}% lower emissions than average recipes",
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 129, 129, 129),
                      ),
                    ),
                    SizedBox(height: 5,),

                    SizedBox(
                      height: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        child: LinearProgressIndicator(
                          backgroundColor: Color.fromARGB(255, 139, 110, 78),
                          valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 123, 163, 111)),
                          value: (100.0 - recipe.emissionsComparedToAverage)/100.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Preparation time: ${recipe.preparationTime} minutes",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color.fromARGB(255, 129, 129, 129),
                          ),
                        ),
                        Text(
                          "Difficulty: ${recipe.difficultyLevel}",
                            style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color.fromARGB(255, 129, 129, 129),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    
                    Text(
                      "Ingredients:",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10,),

                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        itemCount: recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 24,
                            child: 
                              Text("• ${recipe.ingredients[index]}", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold,fontSize: 15))
                          );
                        }
                      ),
                    ), 
                    SizedBox(height: 10,),

                    Divider (height: 2.0, indent: 0.0, color: Color.fromARGB(255, 129, 129, 129),),
                    SizedBox(height: 10,),

                    Text("Instructions:", style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10,),

                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        itemCount: recipe.instructions.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height:24,
                            child: 
                              Text("${recipe.instructions[index]}", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold,fontSize: 15)));
                        },
                      ),
                    ),
                    SizedBox(height: 20,),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(480, 55),
                          side: BorderSide(width: 1.5, color: Color.fromARGB(255, 123, 163, 111),),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          //padding: EdgeInsets.symmetric(horizontal: 140, vertical: 25),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        child: Text(
                          'Creat Another Recipe',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromARGB(255, 123, 163, 111),
                          ),
                        ),
                      ),
                    ),  
                    SizedBox(height: 10,),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(480, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor:Color.fromARGB(255, 123, 163, 111),
                        ),
                        onPressed: () async{
                          // 1. 產生想顯示在 SharePage 的文字
                          final firstText =
                                  "🎉 I cooked ${recipe.recipeName} and saved "
                                  "${100 - recipe.emissionsComparedToAverage}% carbon!";

                          final secondText = 
                                  "Reduced ${recipe.reducedCarbon} kg of carbon emissions";

                          context.go(
                            '/share',
                            extra: {
                              'firstText' : firstText,
                              'secondText' :secondText,
                            }
                          );
                          //onShare(firstText, secondText);

                          Navigator.of(context).popUntil((route) => route.isFirst);

                          final double reduce = double.tryParse(recipe.reducedCarbon) ?? 0.0;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_uid)
                              .collection('stats')
                              .doc('dismissCounter')
                              .update({'totalReduce': FieldValue.increment(reduce),});
                          
                        },
                        child: Text(
                          'Share My Eco Achievement',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildCarbonRating(int Rating) {
  return Row(
    children: List.generate(
        Rating.clamp(0, 10),
        (index) => SvgPicture.asset(
          'assets/fonts/leaf.svg',
          width: 20,
          height: 20,
          color: Color.fromARGB(255, 108, 153, 97), // 葉子綠
        ),
    ),
  );
}
