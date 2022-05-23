import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/chat_pages/chatgroup_page.dart';
import 'package:ignite/pages/home_pages/home_page.dart';
import 'package:ignite/pages/my_pages/my_page.dart';
import 'package:ignite/pages/search_pages/search_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
import 'package:ignite/services/push_notification.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PushNotification _notification = PushNotification();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _notification.setupInteractedMessage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    if (state == AppLifecycleState.resumed) {
      _firestore.collection('user').doc(currentUser.uid).set({
        'isOnline': true,
      }, SetOptions(merge: true));
    } else {
      _firestore.collection('user').doc(currentUser.uid).set({
        'isOnline': false,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: PageView(
            controller: provider.pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              HomePage(),
              SearchPage(),
              ChatgroupPage(),
              MyPage(),
            ],
          ),
          bottomNavigationBar: _bottomNavigationBarWidget(provider),
        );
      },
    );
  }

  Widget _bottomNavigationBarWidget(PageProvider provider) {
    return BottomNavigationBar(
      elevation: 0.0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '메인'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_search), label: '동료 찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: '내 정보'),
      ],
      currentIndex: provider.currentIndex.toInt(),
      onTap: (index) => provider.updatePage(index.toDouble()),
    );
  }
}
