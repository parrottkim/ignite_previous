import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';
import 'package:ignite/pages/my_pages/registration_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/theme_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/home_logo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthenticationProvider _authenticationProvider;

  final firestore = FirebaseFirestore.instance;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10.0),
          ),
        ),
        title:
            Text('Hello, ${_authenticationProvider.currentUser!.displayName}!'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          FutureBuilder(
              future: firestore
                  .collection('user')
                  .doc(_authenticationProvider.currentUser!.uid)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 4.0,
                          color: Colors.black,
                          spreadRadius: 0.4)
                    ],
                  ),
                  child: snapshot.hasData
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!['avatar']))
                      : Container(),
                );
              }),
          SizedBox(width: 14.0),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.26),
          child: Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
              child: HomeLogo(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 26.0),
        child: Column(
          children: [
            _updateList(1250),
            SizedBox(height: 30.0),
            _proSettings(1500),
          ],
        ),
      ),
    );
  }

  Widget _updateList(int duration) {
    List<Widget> swiper = [
      Card(
        elevation: 4.0,
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
        elevation: 4.0,
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
        elevation: 4.0,
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
          child: Text(
            'News',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.0),
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: duration),
          offset: Offset(-10.0, 0.0),
          child: SizedBox(
            height: 200,
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

  Widget _proSettings(int duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: duration),
          offset: Offset(10.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pro settings',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Text(
                    'see details >',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: duration),
          offset: Offset(10.0, 0.0),
          child: Card(
            elevation: 4.0,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                onTap: () {},
                minVerticalPadding: 20.0,
                leading: Icon(Icons.person, size: 60.0),
                title: Text(
                  'Faker',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monitor   BenQ XL2430T'),
                    Text('Mouse     CORSAIR SABRE'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
