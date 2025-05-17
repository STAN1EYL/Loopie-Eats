

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/consts.dart';
import 'package:flutter_application_2/Home_Page(Navgate_Main)/home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyArYiYo8U2dg5tcw2A4fsMwTk8MDJCMsx8",
        authDomain: "greenheart-aecb6.firebaseapp.com",
        projectId: "greenheart-aecb6",
        storageBucket: "greenheart-aecb6.firebasestorage.app",
        messagingSenderId: "916232851118",
        appId: "1:916232851118:web:0f44c80003123b544da73f",
        measurementId: "G-8KZ017NYMG",
      )
    );
  } else {
    await Firebase.initializeApp();
  }
  
  Gemini.init(apiKey: GEMINI_API_KEY,);
  
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  static final homeKey = GlobalKey<MyHomePageState>();
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 243, 241, 236),
        ).copyWith(
          primary: Color(0xFFFFF6E6),            // ← 你要的精準顏色
          primaryContainer: Color.fromARGB(255, 243, 241, 236),   // ← 也可以套用在 container
          onPrimary: Colors.black,              // 與背景搭配用黑色字
          surface: Color(0xFFFFFBF8),         // 可自訂其他色
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // ok , cancel    buttons
            ),
        ),
      ),

      home: const MyHomePage(title: 'Home Page'),
    );
  }
}
//
