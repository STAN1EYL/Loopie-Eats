import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient_dialog.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient_grid.dart';

enum IngredientFilter {
  all,
  todayTomorrow,
  expiringSoon,
  good,
}

class AlertsPage extends StatefulWidget{
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => AlertsPageState();
}

class AlertsPageState extends State<AlertsPage> {
  List<Ingredient> _ingredients = []; //ingredient.dart
  IngredientFilter _currentFilter = IngredientFilter.all;
  String? _fridgeId;

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    // 一定要加，否則 TextEditingController 會漏記憶體
    _noteController.dispose();
    super.dispose();
  }


  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  /*
  void _loadIngredientsFromFirestore() async {
    //final snapshot = await FirebaseFirestore.instance.collection('Ingredient').get();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('ingredients')
        .get();
    
    setState(() {
      _ingredients = snapshot.docs
          .map((doc) => Ingredient.fromJson(doc.data(), doc.id))
          .toList();
    });
  }*/
  void _loadIngredientsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser!;
    final ownerUid = user.uid;

    // 先读当前用户自己的
    final self = await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('ingredients')
        .get();

    // 再去 fridge doc 拿 members 列表
    final fridgeSnap = await FirebaseFirestore.instance
        .collection('fridges')
        .where('members', arrayContains: ownerUid)
        .limit(1)
        .get();
    final fridgeDoc = fridgeSnap.docs.first.data();
    final members = List<String>.from(fridgeDoc['members'] ?? []);

    // 对每个 memberUid 并行读 ingredients
    final futures = members.map((memberUid) async {
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .collection('ingredients')
          .get();
      return qs.docs.map((doc) =>
        SharedIngredient.fromJson(doc.data(), doc.id, memberUid)
      ).toList();
    });

    final lists = await Future.wait(futures);
    final all = lists.expand((l) => l).toList();

    setState(() {
      // _ingredients 改成 List<SharedIngredient>
      _ingredients = all;
    });
  }

  @override
  void initState() {
    _loadFridgeId();
    super.initState();
    _loadIngredientsFromFirestore(); // 初始化讀取 Firestore 資料
  }

  Future<void> _loadFridgeId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
      .collection('fridges')
      .where('members', arrayContains: uid)
      .limit(1)
      .get();
    if (snap.docs.isNotEmpty) {
      setState(() => _fridgeId = snap.docs.first.id);
    }
  }

  Future<void> _addFridgeNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty || _fridgeId == null) return;

    final user = FirebaseAuth.instance.currentUser!;
    final ownerName = user.displayName ?? '匿名';

    await FirebaseFirestore.instance
      .collection('fridges')
      .doc(_fridgeId)
      .collection('notes')
      .add({
        'content': text,
        'ownerUid': user.uid,
        'ownerName': ownerName,
        'timestamp': FieldValue.serverTimestamp(),
      });

    _noteController.clear();
  }



  Future<void> _addIngredient(Ingredient newItem) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // ① 看看有没有共用冰箱
    final fridgeQuery = await FirebaseFirestore.instance
      .collection('fridges')
      .where('members', arrayContains: uid)
      .limit(1)
      .get();

    if (fridgeQuery.docs.isEmpty) {
      // —— 没有共用冰箱，就写个人冰箱 ——
      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ingredients')
        .add(newItem.toJson());

    } else {
      // —— 有共用冰箱，就写 sharedIngredients ——
      final fridgeId = fridgeQuery.docs.first.id;
      await FirebaseFirestore.instance
        .collection('fridges')
        .doc(fridgeId)
        .collection('sharedIngredients')
        .add({
          ...newItem.toJson(),
          'ownerUid': uid,           // 标记是谁添加的
        });
    }

    // 最后再更新本地 state
    setState(() {
      _ingredients.add(newItem);
    });
  }

  
  List<Ingredient> get _filteredIngredients {
    final now = DateTime.now();
    return _ingredients.where((item) {
      final days = item.expiryDate.difference(now).inDays;
      switch (_currentFilter) {
        case IngredientFilter.todayTomorrow:
          return days <= 1;
        case IngredientFilter.expiringSoon:
          return days > 1 && days <= 5;
        case IngredientFilter.good:
          return days > 5;
        case IngredientFilter.all:
          return true;
      }
    }).toList();
  }
  int get countTodayTomorrow => _ingredients.where((i) => i.expiryDate.difference(DateTime.now()).inDays <= 1).length;
  int get countExpiringSoon => _ingredients.where((i) => i.expiryDate.difference(DateTime.now()).inDays > 1 && i.expiryDate.difference(DateTime.now()).inDays <= 5).length;
  int get countGood => _ingredients.where((i) => i.expiryDate.difference(DateTime.now()).inDays > 5).length;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 480,
        height: 865,
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredient Alerts',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color.fromARGB(255, 139, 110, 78),
                  ),
                ),
                //SizedBox(width: 40,),
        
                SizedBox(
                  width: 135,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //padding: EdgeInsets.symmetric(horizontal: 140, vertical: 25),
                      backgroundColor: Color.fromARGB(255, 123, 163, 111),
                    ),
                    onPressed:() {
                      showDialog(
                        context: context,
                        builder: (context) => AddIngredientDialog(onAdd: _addIngredient), //ingredient_dialog.dart
                      );
                    },
                    child: Text(
                      'Add Ingredient',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _categoryButton(
                  svgPath: 'fonts/calendar.svg',
                  color: Colors.red,
                  label: 'Today/Tomorrow',
                  count: countTodayTomorrow,
                  filter: IngredientFilter.todayTomorrow,
                ),
                _categoryButton(
                  svgPath: 'fonts/alert.svg',
                  color: Colors.orange,
                  label: 'Expiring Soon',
                  count: countExpiringSoon,
                  filter: IngredientFilter.expiringSoon,
                ),
                _categoryButton(
                  svgPath: 'fonts/correct.svg',
                  color: Colors.green,
                  label: 'Good',
                  count: countGood,
                  filter: IngredientFilter.good,
                ),
              ],
            ),
            // AlertsPageState.build 中，在 filter Row 之後，加上：

            SizedBox(height: 5),

            // —— Pure UI: Fridge Notes Card —— 
// 找到這段 Pure UI 的 Card，整段替換成下面這個

            Card(
              color: Color(0xFFFFFBE6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 標題
                    Text(
                      'Fridge Notes',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),

                    // 顯示筆記列表（改成 StreamBuilder）
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow.shade700),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.all(8),
                      child: (_fridgeId == null)
                        ? Center(child: CircularProgressIndicator())
                        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                              .collection('fridges')
                              .doc(_fridgeId)
                              .collection('notes')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return Center(child: CircularProgressIndicator());
                              }
                              final docs = snap.data!.docs;
                              if (docs.isEmpty) {
                                return Text(
                                  'I left some bananas in the fridge!',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                                );
                              }
                              return ListView(
                                children: docs.map((doc) {
                                  final content = doc.data()['content'] as String? ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      content,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                    ),

                    SizedBox(height: 8),
                    Divider(color: Colors.yellow.shade700),

                    // 輸入框 + 送出按鈕（改成呼叫 _addFridgeNote）
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Leave a note for your family…',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: _addFridgeNote,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            // —— 接著就是你原本的 Refrigerator Container ——
            // Container( ... )

            Container(
              width: 480,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Refrigerator',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.black
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Builder(builder: (context) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          return const Center(child: Text('Please log in first'));
                        }
                        final uid = user.uid;

                        return FutureBuilder<QuerySnapshot<Map<String,dynamic>>>(
                          // 先去查有没有任何 fridge 文档把我包含进来
                          future: FirebaseFirestore.instance
                            .collection('fridges')
                            .where('members', arrayContains: uid)
                            .limit(1)
                            .get(),
                          builder: (context, fridgeSnap) {
                            if (!fridgeSnap.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final docs = fridgeSnap.data!.docs;
                            if (docs.isEmpty) {
                              // —— 找不到共用冰箱，显示个人冰箱 ——
                              return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                                stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('ingredients')
                                  .snapshots(),
                                builder: (context, personalSnap) {
                                  if (!personalSnap.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final list = personalSnap.data!.docs.map((doc) {
                                    final d = doc.data();
                                    return SharedIngredient(
                                      id: doc.id,
                                      name: d['name'],
                                      quantity: d['quantity'],
                                      expiryDate: DateTime.parse(d['expiryDate']),
                                      ownerUid: uid,  // 自己的食材
                                    );
                                  }).toList();

                                  return IngredientGrid(
                                    ingredients: list,
                                    onDismiss: (sharedIng) {
                                      // 这里把 SharedIngredient 转回 Ingredient，并删除 users/{uid}/ingredients/{id}
                                      FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .collection('ingredients')
                                        .doc(sharedIng.id)
                                        .delete();

                                      FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .collection('stats')
                                        .doc('dismissCounter')
                                        .set({'total': FieldValue.increment(1)}, SetOptions(merge: true));
                                    },
                                  );
                                },
                              );
                            } else {
                              // —— 找到了共用冰箱，显示 sharedIngredients ——
                              final fridgeId = docs.first.id;
                              return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                                stream: FirebaseFirestore.instance
                                  .collection('fridges')
                                  .doc(fridgeId)
                                  .collection('sharedIngredients')
                                  .snapshots(),
                                builder: (context, sharedSnap) {
                                  if (!sharedSnap.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final list = sharedSnap.data!.docs.map((doc) {
                                    final d = doc.data();
                                    return SharedIngredient(
                                      id: doc.id,
                                      name: d['name'],
                                      quantity: d['quantity'],
                                      expiryDate: DateTime.parse(d['expiryDate']),
                                      ownerUid: d['ownerUid'], // 原作者 UID
                                    );
                                  }).toList();

                                  return IngredientGrid(
                                    ingredients: list,
                                    onDismiss: (sharedIng) {
                                      // 从共用冰箱里删除
                                      FirebaseFirestore.instance
                                        .collection('fridges')
                                        .doc(fridgeId)
                                        .collection('sharedIngredients')
                                        .doc(sharedIng.id)
                                        .delete();

                                      FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .collection('stats')
                                        .doc('dismissCounter')
                                        .set({'total': FieldValue.increment(1)}, SetOptions(merge: true));

                                    },
                                  );
                                },
                              );
                            }
                          },
                        );
                      }),
                    ),

                    
                    /*Expanded(
                      child: IngredientGrid(
                        ingredients: _filteredIngredients.map((ing) {
                          // 假设当前用户是 fridge 的 owner
                          final owner = FirebaseAuth.instance.currentUser!.uid;
                          return SharedIngredient(
                            id: ing.id!,
                            name: ing.name,
                            quantity: ing.quantity,
                            expiryDate: ing.expiryDate,
                            ownerUid: owner,
                          );
                        }).toList(),
                        onDismiss: (sharedIng) {
                          // 这里你可以把 SharedIngredient 还原成 Ingredient 继续用原逻辑
                          final orig = Ingredient(
                            id: sharedIng.id,
                            name: sharedIng.name,
                            quantity: sharedIng.quantity,
                            expiryDate: sharedIng.expiryDate,
                          );
                          _removeIngredient(orig);
                        },
                      ),
                    ),*/

                    /*
                    Expanded(
                      child: IngredientGrid( //在ingredient_grid.dart裡
                        ingredients: _filteredIngredients,
                        onDismiss: (ingredient) {
                          _removeIngredient(ingredient);
                        }
                      )
                    ),*/
                  ],
                )
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _categoryButton({
    required String svgPath,
    required Color color,
    required String label,
    required int count,
    required IngredientFilter filter,
  }) {
    final isSelected = _currentFilter == filter;
    return SizedBox(
      width: 155,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: isSelected ? Colors.orange.shade50 : Colors.white,
        ),
        onPressed: () {
          setState(() {
            if(_currentFilter == filter) {
              _currentFilter = IngredientFilter.all;
            } else {
              _currentFilter = filter;
            }
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            SvgPicture.asset(svgPath, width: 18, height: 18, color: color),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
            const SizedBox(height: 2),
            Text('$count', style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  
}