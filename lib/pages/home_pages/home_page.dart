import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';
import 'package:ignite/pages/my_pages/registration_page.dart';
import 'package:ignite/provider/theme_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/home_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  PageController _pageController = PageController();

  _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('first_login') ?? false);

    if (!_seen) {
      await prefs.setBool('first_login', true);
      Navigator.pushAndRemoveUntil(
          context, createRoute(RegistrationPage(flag: true)), (_) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
    _pageController = PageController(initialPage: _index);
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_index < 2) {
        _index++;
      } else {
        _index = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(_index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 26.0),
        child: Column(
          children: [
            Container(
              height: size.height * 0.45,
              child: HomeLogo(),
            ),
            _updateList(1250),
          ],
        ),
      ),
    );
  }

  Widget _updateList(int duration) {
    List<Widget> swiper = [
      Card(
        elevation: 1.0,
        semanticContainer: true,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.asset('assets/images/main/temp1.png',
                width: double.infinity, height: 240.0, fit: BoxFit.cover),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 300,
                color: Colors.black54,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'I Like Potatoes And Oranges',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
      Card(
        elevation: 1.0,
        semanticContainer: true,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.asset('assets/images/main/temp2.png',
                width: double.infinity, height: 240.0, fit: BoxFit.cover),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 300,
                color: Colors.black54,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'I Like Potatoes And Oranges',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
      Card(
        elevation: 1.0,
        semanticContainer: true,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.asset('assets/images/main/temp3.png',
                width: double.infinity, height: 240.0, fit: BoxFit.cover),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 300,
                color: Colors.black54,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'I Like Potatoes And Oranges',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: duration),
          offset: Offset(-10.0, 0.0),
          child: Text('업데이트 소식',
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        SizedBox(height: 10.0),
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: duration),
          offset: Offset(-10.0, 0.0),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: 3,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                return swiper[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}
