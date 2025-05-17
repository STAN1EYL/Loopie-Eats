// lib/Profile_Page/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 如果你还要跳到其它 Tab，请 import 现有的页面
import 'package:flutter_application_2/Home_Page(Navgate_Main)/home_page.dart';
import 'package:flutter_application_2/Recipe_Page/recipe1_page.dart';
import 'package:flutter_application_2/Alerts_Page/alerts_page.dart';
import 'package:flutter_application_2/Share_Page/share_page.dart';
import 'package:flutter_application_2/Profile_Page/profile_page.dart'; // 登录页回退用

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 4; // 一进来就选 Profile
  final TextEditingController _inviteCtrl = TextEditingController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _fridgeStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // 监听所有包含当前用户的 fridge 文档
    _fridgeStream = FirebaseFirestore.instance
        .collection('fridges')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  @override
  void dispose() {
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _inviteMember() async {
    final email = _inviteCtrl.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter an email')));
      return;
    }

    // 在 users 集合查询被邀请者
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }

    final invitedUid = userQuery.docs.first.id;
    final ownerUid = FirebaseAuth.instance.currentUser!.uid;
    final fridgeRef =
        FirebaseFirestore.instance.collection('fridges').doc(ownerUid);

    // 将 owner 与 invitedUid 都加入 members 数组
    await fridgeRef.set({
      'owner': ownerUid,
      'members': FieldValue.arrayUnion([ownerUid, invitedUid]),
    }, SetOptions(merge: true));

  // 4️⃣ 将邀请者和被邀请者个人冰箱 (users/{uid}/ingredients) 里的所有食材
  //    复制到共用冰箱的子集合 sharedIngredients
  final batch = FirebaseFirestore.instance.batch();

  // helper: 把一个用户的 ingredients 全部复制到 fridges/{ownerUid}/sharedIngredients
  Future<void> copyIngredients(String fromUid) async {
    final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(fromUid)
      .collection('ingredients')
      .get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final dest = fridgeRef
        .collection('sharedIngredients')
        .doc(); // 自动生成新 id
      batch.set(dest, {
        ...data,
        'ownerUid': fromUid,      // 标记来源用户
        'sharedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // 把 owner 和 invited 两个用户的数据都 enqueue
  await copyIngredients(ownerUid);
  await copyIngredients(invitedUid);

  // 一次写入
  await batch.commit();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Invite sent!')));
    _inviteCtrl.clear();
  }

  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          children: [
            // ===== Profile Card =====
            Container(
              width: 420,
              color: Colors.white,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 标题 + 登出
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MyHomePage(title: 'Loopie Eats'),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your account information',
                          style: GoogleFonts.quicksand(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF7DA969),
                        child: Text(
                          initial,
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email,
                        style: GoogleFonts.quicksand(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ===== Family Fridge Sharing Card =====
            Container(
              color: Colors.white,
              width: 420,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Fridge Sharing',
                        style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invite family members to share your fridge',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inviteCtrl,
                              decoration: InputDecoration(
                                hintText: 'example@email.com',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _inviteMember,
                            child: const Text('Invite'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7DA969),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Family Members',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 特殊显示 owner，然后其余 members
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _fridgeStream,
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.docs.isEmpty) {
                            return const Text('No family members yet');
                          }
                          final doc = snap.data!.docs.first;
                          final data = doc.data();
                          final ownerUid = data['owner'] as String?;
                          final allMembers =
                              List<String>.from(data['members'] ?? []);
                          final otherMembers =
                              allMembers.where((uid) => uid != ownerUid).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // —— 先显示 Owner —— 
                              if (ownerUid != null) ...[
                                FutureBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(ownerUid)
                                      .get(),
                                  builder: (ctx, ownerSnap) {
                                    if (ownerSnap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Owner: loading...');
                                    }
                                    if (!ownerSnap.hasData ||
                                        !ownerSnap.data!.exists) {
                                      return const Text('Owner: not found');
                                    }
                                    final ownerEmail = ownerSnap
                                            .data!.data()?['email'] ??
                                        '…';
                                    return Text(
                                      'Owner: $ownerEmail',
                                      style: GoogleFonts.quicksand(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                              // —— 再显示其他成员 —— 
                              if (otherMembers.isNotEmpty)
                                ...otherMembers.map(
                                  (uid) => FutureBuilder<
                                      DocumentSnapshot<Map<String,
                                          dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .get(),
                                    builder: (ctx, userSnap) {
                                      if (userSnap.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      }
                                      if (!userSnap.hasData ||
                                          !userSnap.data!.exists) {
                                        return const SizedBox();
                                      }
                                      final memberEmail = userSnap
                                              .data!.data()?['email'] ??
                                          '…';
                                      return Text(
                                        "Member: $memberEmail",
                                        style: GoogleFonts.quicksand(),
                                      );
                                    },
                                  ),
                                ),
                              if (ownerUid == null && otherMembers.isEmpty)
                                const Text('No family members yet'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(onTabSelected: (_) {});
      case 1:
        return RecipePage(
              onShare: (firstMsg, secondMsg) {
                setState(() {
                _selectedIndex = 3;
                });
              },
        );
      case 2:
        return AlertsPage();
      case 3:
        return SharePage(firstText: '', secondText: '');
      case 4:
        return _buildProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset('fonts/home.svg', color: Colors.grey),
            selectedIcon: SvgPicture.asset('fonts/home.svg',
                color: const Color(0xFF7DA969)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('fonts/chefHat.svg', color: Colors.grey),
            selectedIcon: SvgPicture.asset('fonts/chefHat.svg',
                color: const Color(0xFF7DA969)),
            label: 'Recipe',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('fonts/alert.svg', color: Colors.grey),
            selectedIcon: SvgPicture.asset('fonts/alert.svg',
                color: const Color(0xFF7DA969)),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('fonts/upload.svg', color: Colors.grey),
            selectedIcon: SvgPicture.asset('fonts/upload.svg',
                color: const Color(0xFF7DA969)),
            label: 'Share',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('fonts/profile.svg', color: Colors.grey),
            selectedIcon: SvgPicture.asset('fonts/profile.svg',
                color: const Color(0xFF7DA969)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
