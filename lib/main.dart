

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/App_Router/app_router.dart';
import 'package:flutter_application_2/consts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: ApiKey,
        authDomain: AuthDomain,
        projectId: ProjectId,
        storageBucket: StorageBucket,
        messagingSenderId: MessagingSenderId,
        appId: AppId,
        measurementId: MeasurementId,
      )
    );
  } else {
    await Firebase.initializeApp();
  }
  
  Gemini.init(apiKey: GEMINI_API_KEY,);
  
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,

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
    );
  }
}
//
