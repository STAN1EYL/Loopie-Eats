import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Profile_Page/auth_service.dart';
import 'package:flutter/services.dart'; // ← 新增
import 'package:flutter_application_2/Profile_Page/dashboard_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final void Function(int) onTabSelected;
  const ProfilePage({super.key, required this.onTabSelected,});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> 
  with SingleTickerProviderStateMixin{
  
  String? _loginError;  
  final _auth = AuthService();
  late final TabController _tabController;
  final loginEmail = TextEditingController();
  final loginPwd = TextEditingController();

  final signName = TextEditingController();
  final signEmail = TextEditingController();
  final signPwd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _tabController.dispose();
    loginEmail.dispose();
    loginPwd.dispose();
    signName.dispose();
    signEmail.dispose();
    signPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext content) {
    return Scaffold(
      body: Center(
        
        //padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            Container(
              width: 480,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding:  EdgeInsets.only(left:20, bottom: 20, right: 20, top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Loopie Eats',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Color.fromARGB(255, 139, 110, 78),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Center(
                      child: Text(
                        'Login or create an account',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                        TabBar.secondary(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorPadding: const EdgeInsets.all(6),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: const <Widget>[Tab(text: 'Login'), Tab(text: 'Sign Up')],
                        ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          Card(
                            elevation: 0,
                            color: Color.fromARGB(255, 255, 255, 255),
                            margin: const EdgeInsets.all(16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email', style: GoogleFonts.quicksand(fontSize:18, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10,),
        
                                  TextField(
                                    controller: loginEmail,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                    ),
                                  ),
                                  SizedBox(height: 25,),
        
                                  Text('Password', style: GoogleFonts.quicksand(fontSize:18, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10,),
        
                                  TextField(
                                    controller: loginPwd,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                    ),
                                  ),
                                  SizedBox(height: 35),
        
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7DA969),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        FocusScope.of(context).unfocus();
                                        HardwareKeyboard.instance.clearState();
                                        // ② 再呼叫你的登入邏輯
                                        _login();
                                      },
                                      icon: const Icon(Icons.login_rounded, size: 18),
                                      label: Text('Sign In', style: GoogleFonts.quicksand(fontSize: 16)),
                                    ),
                                  ),
                                  SizedBox(height: 20),
        
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7DA969),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        FocusScope.of(context).unfocus();
                                        HardwareKeyboard.instance.clearState();
                                        await _auth.signout();
                                        widget.onTabSelected(0);
                                      },
                                      icon: const Icon(Icons.logout_outlined, size: 18),
                                      label: Text('Sign Out', style: GoogleFonts.quicksand(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: Color.fromARGB(255, 255, 255, 255),
                            margin: const EdgeInsets.all(16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Usernane', style: GoogleFonts.quicksand(fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10,),
        
                                  TextField(
                                    controller: signName,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your usernane',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
        
                                  Text('Email', style: GoogleFonts.quicksand(fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10,),
        
                                  TextField(
                                    controller: signEmail,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
        
                                  Text('Password', style: GoogleFonts.quicksand(fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10,),
        
                                  TextField(
                                    controller: signPwd,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                    ),
                                  ),
                                  SizedBox(height: 24),
        
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7DA969),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed:(){
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        FocusScope.of(context).unfocus();
                                        HardwareKeyboard.instance.clearState();
                                        _signup();
                                      },
                                      icon: SvgPicture.asset(
                                        'fonts/profileadd.svg',
                                        width: 18,
                                        height: 18,
                                        color: Colors.white,
                                      ),
                                      label: Text('Create Account', style: GoogleFonts.quicksand(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  _signup() async {
    final user =
        await _auth.createUserWithEmailAndPassword(signEmail.text, signPwd.text);
    if (user != null) {

      // 1) 在 users 集合存下 email+displayName
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'email': signEmail.text.trim().toLowerCase(),
                'displayName': signName.text.trim(),});
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stats')
        .doc('dismissCounter')
        .set({'total': 0, 'totalReduce': 0}, SetOptions(merge: true));

      // 2) 在 fridges 集合为这个新用户创建冰箱
      /*await FirebaseFirestore.instance
        .collection('fridges')
        .doc(user.uid)
        .set({'owner': user.uid,'members': [user.uid],});*/
      
                
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      log("User Created Succesfully");
      widget.onTabSelected(0);
    }
  }

  _login() async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        loginEmail.text.trim(),
        loginPwd.text.trim(),
      );
      if (user != null) {
        // ——— 新增：如果 users/{uid} 不存在，就创建一条
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await userDoc.get();
        if (!docSnap.exists) {
          await userDoc.set({
            'email': user.email,
            'displayName': user.email?.split('@').first ?? '',
          });
        }
        // ——— 原有逻辑：提示登录成功并切到 Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You're now logged in!")),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect email or password')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login error')),
      );
    }
  }


}