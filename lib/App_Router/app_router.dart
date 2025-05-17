// lib/app_router.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Alerts_Page/alerts_page.dart';
import 'package:flutter_application_2/Home_Page(Navgate_Main)/home_page.dart';
import 'package:flutter_application_2/Profile_Page/dashboard_page.dart';
import 'package:flutter_application_2/Profile_Page/profile_page.dart';
import 'package:flutter_application_2/Recipe_Page/recipe1_page.dart';
import 'package:flutter_application_2/Recipe_Page/recipe2_page_route.dart';
import 'package:flutter_application_2/Share_Page/share_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';



/// 全域共用的 GoRouter 實例，放在這裡管理
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // ShellRoute：封裝五個主 Tab
    ShellRoute(
      builder: (ctx, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _locationToTabIndex(state.uri.toString()),
          onDestinationSelected: (i) => _goToTab(i, ctx),
          destinations: [
            NavigationDestination(
              selectedIcon: SvgPicture.asset(
                'fonts/home.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 123, 163, 111),
              ),
              icon: SvgPicture.asset(
                'fonts/home.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 107, 105, 105),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: SvgPicture.asset(
                'fonts/chefHat.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 123, 163, 111),
              ),
              icon: SvgPicture.asset(
                'fonts/chefHat.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 107, 105, 105),
              ),
              label: 'Recipe',
            ),
            NavigationDestination(
              selectedIcon: SvgPicture.asset(
                'fonts/alert.svg',
                width: 25, height: 25,
                color: Color.fromARGB(255, 123, 163, 111),
              ),
              icon: SvgPicture.asset(
                'fonts/alert.svg',
                width: 25, height: 25,
                color: Color.fromARGB(255, 107, 105, 105),
              ),
              label: 'Alerts',
            ),
            NavigationDestination(
              selectedIcon: SvgPicture.asset(
                'fonts/upload.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 123, 163, 111),
              ),
              icon: SvgPicture.asset(
                'fonts/upload.svg',
                width: 30, height: 30,
                color: Color.fromARGB(255, 107, 105, 105),
              ),
              label: 'Share',
            ),
            NavigationDestination(
              selectedIcon: SvgPicture.asset(
                'fonts/profile.svg',
                width: 25, height: 25,
                color: Color.fromARGB(255, 123, 163, 111),
              ),
              icon: SvgPicture.asset(
                'fonts/profile.svg',
                width: 25, height: 25,
                color: Color.fromARGB(255, 107, 105, 105),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      /*
      builder: (ctx, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _locationToTabIndex(state.uri.toString()),
          onTap: (i) => _goToTab(i, ctx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home),    label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recipe'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.share),   label: 'Share'),
            BottomNavigationBarItem(icon: Icon(Icons.person),  label: 'Profile'),
          ],
        ),
      ),
      */

      routes: [
        GoRoute(path: '/home',    builder: (_, __) => HomePage()),
        GoRoute(path: '/recipe',  builder: (_, __) => RecipePage()),
        GoRoute(path: '/alerts',  builder: (_, __) => AlertsPage()),

        GoRoute(path: '/share',   builder: (ctx, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return SharePage(
            firstText: data['firstText'] ?? '',
            secondText: data['secondText'] ?? '',
          );
        }),

        GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),

            // 細節頁：獨立全螢幕
        GoRoute(path: '/result',   builder: (ctx, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return RecipeGenerateResultRoute(
            result: data['result'] ?? '',
          );
        }),

        GoRoute(path: '/dashboard',builder: (_, __) => DashboardPage()),

      ],
    ),




  ],
);

/// Helper：URL location → BottomNav index
int _locationToTabIndex(String loc) {
  if (loc.startsWith('/recipe') || loc.startsWith('/result')) return 1;
  if (loc.startsWith('/alerts')) return 2;
  if (loc.startsWith('/share'))  return 3;
  if (loc.startsWith('/profile') || loc.startsWith('/dashboard'))return 4;
  return 0;
}

/// Helper：點 BottomNav → 導航
void _goToTab(int i, BuildContext ctx) {
  switch (i) {
    case 0: ctx.go('/home');    break;
    case 1: ctx.go('/recipe');  break;
    case 2: ctx.go('/alerts');  break;
    case 3: ctx.go('/share');   break;
    case 4:
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 已登入就留在 Dashboard
        ctx.go('/dashboard');
      } else {
        // 未登入就進 Profile 登入
        ctx.go('/profile');
      }
      break;
    //case 4: ctx.go('/profile'); break;
  }
}
