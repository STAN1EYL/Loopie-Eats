/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient.dart';

class IngredientGrid extends StatefulWidget{
  final List<Ingredient> ingredients;
  final void Function(Ingredient) onDismiss;
  
  const IngredientGrid({
    super.key,
    required this.ingredients,
    required this.onDismiss,
  });
  @override
  State<IngredientGrid> createState() => IngredientGridState();
}

class IngredientGridState extends State<IngredientGrid> {
  



  @override
  Widget build(BuildContext context) {
    
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 3 / 1.8,
      children: widget.ingredients.map((ingredient) {
        final status = _getExpiryStatus(ingredient.expiryDate);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      ingredient.quantity,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                const Spacer(),
                Row(
                  children: [
                    SvgPicture.asset(
                      'fonts/time.svg',
                      width: 14,
                      height: 14,
                      color: status['color'],
                    ),
                    SizedBox(width: 5,),
                    Text(
                      status['label'],
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: status['color'],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        widget.onDismiss(ingredient);
                      });
                    },
                    child: Text("Dismiss",style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black),),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

Map<String, dynamic> _getExpiryStatus(DateTime date) {
  final now = DateTime.now();
  final days = date.difference(DateTime(now.year, now.month, now.day)).inDays;

  String label;
  Color color;

  if(days < 0) {
    label = "Expired ${-days} day${days== -1 ? '' : 's'}ago";
    color = const Color.fromARGB(255, 102, 29, 24);
  } else if (days == 0) {
    label = "Expires today";
    color = Colors.red;
  } else if(days == 1) {
    label = "Expires tomorrow";
    color = Colors.orange;
  } else  {
    label = "Expires in $days day${days == 1 ? '' : 's'}";
    color = Colors.green;
  }

  return {'label' : label, 'color':color};
  
}
*/

// lib/Alerts_Page/ingredient_grid.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient.dart';

/// 把这里的 Ingredient 改成 SharedIngredient
class IngredientGrid extends StatefulWidget {
  final List<SharedIngredient> ingredients;
  final void Function(SharedIngredient) onDismiss;

  const IngredientGrid({
    super.key,
    required this.ingredients,
    required this.onDismiss,
  });
  @override
  State<IngredientGrid> createState() => IngredientGridState();
}

class IngredientGridState extends State<IngredientGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 3 / 1.8,
      children: widget.ingredients.map((ingredient) {
        final status = _getExpiryStatus(ingredient.expiryDate);

        return Container(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 原来名字/数量那一行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ingredient.name,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        ingredient.quantity,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          
                  //const SizedBox(height: 3),
                  // 新增：显示是谁的食材
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(ingredient.ownerUid)
                        .get(),
                    builder: (ctx, snap) {
                      String label;
                      if (snap.connectionState != ConnectionState.done) {
                        label = 'Member: …';
                      } else if (!snap.hasData || snap.data!.data() == null) {
                        label = 'Member: unknown';
                      } else {
                        final data = snap.data!.data()!;
                        label = 'Member: ${data['email'] ?? '…'}';
                      }
                      return Text(
                        label,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  
                  /*Text(
                    'Member: ${ingredient.ownerUid}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),*/
          
                  
                  const SizedBox(height: 2),
                  // 到期状态
                  
                  Row(
                    children: [
                      SvgPicture.asset(
                        'fonts/time.svg',
                        width: 14,
                        height: 14,
                        color: status['color'],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status['label'],
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: status['color'],
                        ),
                      ),
                    ],
                  ),
          
                  const SizedBox(height: 2),
          
                  // Dismiss 按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.onDismiss(ingredient),
                      child: Text(
                        "Dismiss",
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 下面保持不变
Map<String, dynamic> _getExpiryStatus(DateTime date) {
  final now = DateTime.now();
  final days = date.difference(DateTime(now.year, now.month, now.day)).inDays;

  String label;
  Color color;

  if (days < 0) {
    label = "Expired ${-days} day${days == -1 ? '' : 's'} ago";
    color = const Color.fromARGB(255, 102, 29, 24);
  } else if (days == 0) {
    label = "Expires today";
    color = Colors.red;
  } else if (days == 1) {
    label = "Expires tomorrow";
    color = Colors.orange;
  } else {
    label = "Expires in $days day${days == 1 ? '' : 's'}";
    color = Colors.green;
  }

  return {'label': label, 'color': color};
}
