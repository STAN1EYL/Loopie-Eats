import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';              
import 'package:path_provider/path_provider.dart';        


class SharePage extends StatefulWidget{
  final String firstText;
  final String secondText;
  
  

  const SharePage({super.key, required this.firstText, required this.secondText});

  @override
  State<SharePage> createState() => SharePageState();
}

class SharePageState extends State<SharePage> {
  
  final int savedgoalCount  = 15;   // 達標門檻

  final double savedCarbonGoal  = 25.0;   // 達標門檻
  

  final ImagePicker _picker = ImagePicker();
  XFile? _photo;                               

  Future<void> _pickImage() async {            
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() => _photo = picked);
  }

  Future<void> _downloadImage() async{
    if(_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select image first')),
      );
      return;
    }
    // 1-a 申請權限（官方 README 寫法）
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('沒有儲存權限')),
      );
      return;
    }
    // 1-b 取得路徑（官方 path_provider 範例）
    final dir = await getApplicationDocumentsDirectory(); // 也可用 getDownloadsDirectory()
    final fileName =
        'eco_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savePath = '${dir.path}/$fileName';

    // 1-c 寫檔
    await File(_photo!.path).copy(savePath);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("it's downloaded to：$savePath")),
    );
  }

  Future<void> _shareImage([String? target]) async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇圖片')),
      );
      return;
    }

    if (kIsWeb) {
      // Web 只能分享純文字
      await Share.share(widget.firstText);
    } else {
      await Share.shareXFiles(
        [_photo!],
        text: widget.firstText,
      );
    }
  }
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // 如果 user == null，就只显示「请登录」提示
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              Text(
                'Share Achievement',
                textAlign: TextAlign.left,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 139, 110, 78),
                ),
              ),
              SizedBox(height: 30,),
              
              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'My Low‑Carbon Cooking\nAchievement!',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 139, 110, 78),
                      ),
                    ),
                    const SizedBox(height: 12),
              
                    // ===== 主要敘述（來自上一頁傳入的 message）=====
                    Text(
                      widget.firstText,
                      style: GoogleFonts.quicksand(
                        fontSize: 17,
                        color: Colors.black87,
                        //fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
              
                    // ===== 強調文字（示範寫死；可依需要抽成參數）=====
                    Text(
                      widget.secondText,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        color: const Color(0xFF3A7530),
                      ),
                    ),
                    const SizedBox(height: 16),
              
                    // ===== 圖片區 =====
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _photo != null
                            ? (kIsWeb
                                ? Image.network(_photo!.path,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover)
                                : Image.file(File(_photo!.path),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover))
                            : Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey.shade300,
                                child:
                                    const Center(child: Icon(Icons.add_a_photo, size: 48)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
              
                    // ===== Hashtags =====
                    Text(
                      '#LoopieEats #SustainableDiet\n#LowCarbonCooking',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10,),
              ElevatedButton.icon(
                onPressed: _downloadImage,
                icon: Icon(Icons.download),
                label: 
                  Text(
                    'Download Image',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 123, 163, 111),
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 新增 Instagram 按鈕
              OutlinedButton.icon(
                onPressed: () => _shareImage('instagram'),
                icon: SvgPicture.asset(
                  'fonts/instagram.svg',
                  width: 18,
                  height: 18,
                  color: Colors.black,
                ),
                label: 
                  Text('Share to Instagram',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),
                  ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 新增 Facebook 按鈕
              OutlinedButton.icon(
                onPressed: () => _shareImage('facebook'),
                icon: Icon(Icons.facebook_outlined, color: Colors.black,),
                label: 
                  Text(
                    'Share to Facebook',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),
                  ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'My Sustainability Achievements',
                textAlign: TextAlign.left,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 139, 110, 78),
                ),
              ),

              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'Food Waste Hero',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Saved $savedgoalCount ingredients from expiring',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color(0xFFEFF6EE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('🏆', style: TextStyle(fontSize: 28))),
                        ),
                        SizedBox(width: 16),
                        // 進度 + 百分比
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            /*
                            stream: FirebaseFirestore.instance
                                .doc('stats/dismissCounter')
                                .snapshots(),
                              */
                            stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_uid)
                                    .collection('stats')
                                    .doc('dismissCounter')
                                    .snapshots(),
                            builder: (context, snap) {
                              final int total = (snap.data?.data()?['total'] ?? 0) as int;
                              final double progress = total / savedgoalCount;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    color: const Color(0xFF7DA969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('$total / $savedgoalCount',
                                      style: GoogleFonts.quicksand(fontSize: 12)),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),

              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 247, 247, 247),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'Carbon Master',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Reduced $savedCarbonGoal kg of carbon emissions',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color(0xFFEFF6EE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('🌱', style: TextStyle(fontSize: 28))),
                        ),
                        SizedBox(width: 16),


                        Expanded(
                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            /*
                            stream: FirebaseFirestore.instance
                                .doc('stats/dismissCounter')
                                .snapshots(),*/
                            stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_uid)
                                    .collection('stats')
                                    .doc('dismissCounter')
                                    .snapshots(),
                            builder: (context, snap) {
                              final  total = (snap.data?.data()?['totalReduce'] ?? 0) as double;
                              final double progress = total / savedCarbonGoal;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    color: const Color(0xFF7DA969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('$total / $savedCarbonGoal',
                                      style: GoogleFonts.quicksand(fontSize: 12)),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );


        /*
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              Text(
                'Share Achievement',
                textAlign: TextAlign.left,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 139, 110, 78),
                ),
              ),
              SizedBox(height: 30,),
              
              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F9F7),
                      Color(0xFFEFF6EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'Please sign in to share achievement!',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 139, 110, 78),
                      ),
                    ),
                  ]
                )
              )
            ]
          )
        );
        */
      }
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              Text(
                'Share Achievement',
                textAlign: TextAlign.left,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 139, 110, 78),
                ),
              ),
              SizedBox(height: 30,),
              
              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'My Low‑Carbon Cooking\nAchievement!',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 139, 110, 78),
                      ),
                    ),
                    const SizedBox(height: 12),
              
                    // ===== 主要敘述（來自上一頁傳入的 message）=====
                    Text(
                      widget.firstText,
                      style: GoogleFonts.quicksand(
                        fontSize: 17,
                        color: Colors.black87,
                        //fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
              
                    // ===== 強調文字（示範寫死；可依需要抽成參數）=====
                    Text(
                      widget.secondText,
                      
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        color: const Color(0xFF3A7530),
                      ),
                    ),
                    const SizedBox(height: 16),
              
                    // ===== 圖片區 =====
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _photo != null
                            ? (kIsWeb
                                ? Image.network(_photo!.path,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover)
                                : Image.file(File(_photo!.path),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover))
                            : Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey.shade300,
                                child:
                                    const Center(child: Icon(Icons.add_a_photo, size: 48)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
              
                    // ===== Hashtags =====
                    Text(
                      '#LoopieEats #SustainableDiet\n#LowCarbonCooking',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10,),
              ElevatedButton.icon(
                onPressed: _downloadImage,
                icon: Icon(Icons.download),
                label: 
                  Text(
                    'Download Image',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 123, 163, 111),
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 新增 Instagram 按鈕
              OutlinedButton.icon(
                onPressed: () => _shareImage('instagram'),
                icon: SvgPicture.asset(
                  'fonts/instagram.svg',
                  width: 18,
                  height: 18,
                  color: Colors.black,
                ),
                label: 
                  Text('Share to Instagram',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),
                  ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 新增 Facebook 按鈕
              OutlinedButton.icon(
                onPressed: () => _shareImage('facebook'),
                icon: Icon(Icons.facebook_outlined, color: Colors.black,),
                label: 
                  Text(
                    'Share to Facebook',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),
                  ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(428, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'My Sustainability Achievements',
                textAlign: TextAlign.left,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 139, 110, 78),
                ),
              ),

              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'Food Waste Hero',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Saved $savedgoalCount ingredients from expiring',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color(0xFFEFF6EE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('🏆', style: TextStyle(fontSize: 28))),
                        ),
                        SizedBox(width: 16),
                        // 進度 + 百分比
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            /*
                            stream: FirebaseFirestore.instance
                                .doc('stats/dismissCounter')
                                .snapshots(),
                              */
                            stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_uid)
                                    .collection('stats')
                                    .doc('dismissCounter')
                                    .snapshots(),
                            builder: (context, snap) {
                              final int total = (snap.data?.data()?['total'] ?? 0) as int;
                              final double progress = total / savedgoalCount;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    color: const Color(0xFF7DA969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('$total / $savedgoalCount',
                                      style: GoogleFonts.quicksand(fontSize: 12)),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),

              Container(
                width: 420,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // 右下 ↘️ 漸層淡綠
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 247, 247, 247),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 標題 =====
                    Text(
                      'Carbon Master',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Reduced $savedCarbonGoal kg of carbon emissions',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color(0xFFEFF6EE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('🌱', style: TextStyle(fontSize: 28))),
                        ),
                        SizedBox(width: 16),


                        Expanded(
                          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            /*
                            stream: FirebaseFirestore.instance
                                .doc('stats/dismissCounter')
                                .snapshots(),*/
                            stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_uid)
                                    .collection('stats')
                                    .doc('dismissCounter')
                                    .snapshots(),
                            builder: (context, snap) {
                              final  total = (snap.data?.data()?['totalReduce'] ?? 0) as double;
                              final double progress = total / savedCarbonGoal;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    color: const Color(0xFF7DA969),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('$total / $savedCarbonGoal',
                                      style: GoogleFonts.quicksand(fontSize: 12)),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
}
