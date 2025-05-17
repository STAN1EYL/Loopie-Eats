import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_2/AppAssets/AppAssetsPath.dart';
//import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/Recipe_Page/recipe1_page.dart';
import 'package:flutter_application_2/Profile_Page/profile_page.dart';
import 'package:flutter_application_2/Alerts_Page/alerts_page.dart';
import 'package:flutter_application_2/Share_Page/share_page.dart';
import 'package:google_fonts/google_fonts.dart';

//C:\Users\stanl\Desktop\flutter_app_dev\flutter_application_2\lib\Alerts_Page\alerts_page.dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState(); //go to ==> Home_Page/home_page.dart
}

class HomePage extends StatefulWidget {
  final void Function(int) onTabSelected;
  const HomePage({super.key, required this.onTabSelected});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<Offset> _iconOffset;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _iconOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.10),
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          SlideTransition(
            position: _iconOffset,
            child: Image.asset(
              AppAssetsPath.iconHome,
              cacheHeight: 128,
              cacheWidth: 128,
            ),
          ),
          SizedBox(height: 15),

          Text(
            'Welcome to Loopie Eats!',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Color.fromARGB(255, 139, 110, 78),
            ),
          ),
          SizedBox(height: 5,),
          Text(
            "What's in your fridge? 🍳 Let's cook!",
            style: GoogleFonts.quicksand(
              fontSize: 18,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          
          SizedBox(height: 25,),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(480, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              //padding: EdgeInsets.symmetric(horizontal: 140, vertical: 25),
              backgroundColor: Color.fromARGB(255, 123, 163, 111),
            ),
            onPressed:() {
              widget.onTabSelected(1); // 切換到 RecipePage（index 1）
            },
            icon: SvgPicture.asset(
              'fonts/chefHat.svg',
              width: 15,
              height: 15,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            label: Text(
              ' Cook with Leftovers',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              )
            ),
          ),
          SizedBox(height: 15,),
          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(480, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              //padding: EdgeInsets.symmetric(horizontal: 120, vertical: 25),
              backgroundColor: Color.fromARGB(255, 123, 163, 111),
            ),
            onPressed:() {
              widget.onTabSelected(2);
            },
            icon: SvgPicture.asset(
              'fonts/alert.svg',
              width: 15,
              height: 15,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            label: Text(
              ' Ingredient Alerts',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              )
            ),
          ),
          SizedBox(height: 15,),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(480, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              //padding: EdgeInsets.symmetric(horizontal: 120, vertical: 25),
              backgroundColor: Color.fromARGB(255, 123, 163, 111),
            ),
            onPressed:() {
              widget.onTabSelected(3);
            },
            icon: SvgPicture.asset(
              'fonts/upload.svg',
              width: 16,
              height: 16,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            label: Text(
              ' Share Achievement',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              )
            ),
          ),
          SizedBox(height: 15,),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(480, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              //padding: EdgeInsets.symmetric(horizontal: 120, vertical: 25),
              backgroundColor: Color.fromARGB(255, 123, 163, 111),
            ),
            onPressed:() {
              widget.onTabSelected(4);
            },
            icon: SvgPicture.asset(
              'fonts/profile.svg',
              width: 16,
              height: 16,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            label: Text(
              ' Profile',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              )
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  String firstMessage = "Nothing yet!";
  String scondMessage = "";
  @override
  Widget build(BuildContext context) {
    
    Widget page;
    switch(selectedIndex) {
      case 0:
        page = HomePage(
          onTabSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        );
        break;
      case 1:
        page = RecipePage(
          onShare: (msg, secmsg) {
            log("🔥 MyHomePageState.onShare 被调用，msg=$msg");
            setState(() {
              firstMessage = msg;
              scondMessage = secmsg;
              selectedIndex = 3; // 切到「分享」页
            });
          },
        );
        break;
      case 2:
        page = AlertsPage();
        break;
      case 3:
       page = SharePage(firstText: firstMessage, secondText: scondMessage);
       break;
      case 4:
        page = ProfilePage(
          onTabSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        //indicatorColor: Colors.amber,
        selectedIndex: selectedIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: SvgPicture.asset(
              'fonts/home.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 123, 163, 111),
            ),
            icon: SvgPicture.asset(
              'fonts/home.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 107, 105, 105),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: SvgPicture.asset(
              'fonts/chefHat.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 123, 163, 111),
            ),
            icon: SvgPicture.asset(
              'fonts/chefHat.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 107, 105, 105),
            ),
            label: 'Recipe',
          ),
          NavigationDestination(
            selectedIcon: SvgPicture.asset(
              'fonts/alert.svg',
              width: 25,
              height: 25,
              color: Color.fromARGB(255, 123, 163, 111),
            ),
            icon: SvgPicture.asset(
              'fonts/alert.svg',
              width: 25,
              height: 25,
              color: Color.fromARGB(255, 107, 105, 105),
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            selectedIcon: SvgPicture.asset(
              'fonts/upload.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 123, 163, 111),
            ),
            icon: SvgPicture.asset(
              'fonts/upload.svg',
              width: 30,
              height: 30,
              color: Color.fromARGB(255, 107, 105, 105),
            ),
            label: 'Share',
          ),
          NavigationDestination(
            selectedIcon: SvgPicture.asset(
              'fonts/profile.svg',
              width: 25,
              height: 25,
              color: Color.fromARGB(255, 123, 163, 111),
            ),
            icon: SvgPicture.asset(
              'fonts/profile.svg',
              width: 25,
              height: 25,
              color: Color.fromARGB(255, 107, 105, 105),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}