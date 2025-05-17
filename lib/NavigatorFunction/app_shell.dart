import 'package:flutter/material.dart';
import 'package:flutter_application_2/Profile_Page/dashboard_page.dart';
import 'package:flutter_application_2/Recipe_Page/recipe2_page_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// 引入你的各頁面
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/Home_Page(Navgate_Main)/home_page.dart';
import 'package:flutter_application_2/Recipe_Page/recipe1_page.dart';
import 'package:flutter_application_2/Profile_Page/profile_page.dart';
import 'package:flutter_application_2/Alerts_Page/alerts_page.dart';
import 'package:flutter_application_2/Share_Page/share_page.dart';

/// AppShell：整個 App 的外殼，管理底部 NavBar + 分頁邏輯
class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  /// 讓子 Widget 可以透過 context 找到這個 State
  static AppShellState? of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<AppShellState>();

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  String _firstText = "Nothing yet!", _secondText = "";
  String _recipe = "";
  /// 切換到指定 tab
  void switchTab(int index) {
    setState(() => _selectedIndex = index);
  }

  /// 專門用來處理生成的食譜，並跳到 RecipeGenerateResultRoute
  void generateRecipe(String recipe) {
      setState(() {
      _recipe = recipe;
      switchTab(11);
    });
  }
  
  /// 專門用來處理分享，並跳到 SharePage
  void share(String first, String second) {
    setState(() {
      _firstText = first;
      _secondText = second;
      switchTab(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = HomePage(onTabSelected: switchTab,);
        break;
      case 1:
        page = RecipePage(result: generateRecipe);
        break;
      case 11:
        page = RecipeGenerateResultRoute(onShare: share, result: _recipe,);
        break;
      case 2:
        page = AlertsPage();
        break;
      case 3:
        page = SharePage(firstText: _firstText, secondText: _secondText);
        break;
      case 4:
        page = ProfilePage(onTabSelected: switchTab);
        break;
      case 5:
        page = DashboardPage(onTabSelected: switchTab);
      default:
        page = Center(child: Text("Unknown tab"));
    }

    final navDestinations = <NavigationDestination> [
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
    ];

    if(_selectedIndex < navDestinations.length + 1) {
      return Scaffold(
        body: page,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: switchTab,
          destinations: navDestinations,
        ),
      );
    }
    return Scaffold(
      body: page,
    );

  }
}
