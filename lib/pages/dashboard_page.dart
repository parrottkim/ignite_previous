import 'package:flutter/material.dart';
import 'package:ignite/pages/chat_pages/chat_page.dart';
import 'package:ignite/pages/home_pages/home_page.dart';
import 'package:ignite/pages/search_pages/search_page.dart';
import 'package:ignite/provider/bottom_navigation_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  final int? index;
  DashboardPage({Key? key, this.index}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late BottomNavigationProvider _bottomNavigationProvider;
  late PageController _pageController;
  late int _currentIndex;

  void onTabNav(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
    _bottomNavigationProvider.updatePage(index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            HomePage(),
            SearchPage(),
            ChatPage(),
          ],
          onPageChanged: (index) {
            _bottomNavigationProvider.updatePage(index);
          },
        ),
        bottomNavigationBar: _bottomNavigationBarWidget(),
      ),
    );
  }

  Widget _bottomNavigationBarWidget() {
    return BottomNavigationBar(
      elevation: 0.0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '메인'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_search), label: '동료 찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: '내 정보'),
      ],
      currentIndex: _bottomNavigationProvider.currentIndex,
      onTap: (index) {
        onTabNav(index);
      },
    );
  }
}
