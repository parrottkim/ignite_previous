import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';
import 'package:ignite/pages/my_pages/registration_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
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
  late AuthProvider _authProvider;
  late PageProvider _pageProvider;

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
    // _pageController = PageController(initialPage: _index);
    // Timer.periodic(const Duration(seconds: 4), (timer) {
    //   if (_index < 2) {
    //     _index++;
    //   } else {
    //     _index = 0;
    //   }

    //   if (_pageController.hasClients) {
    //     _pageController.animateToPage(_index,
    //         duration: const Duration(milliseconds: 200),
    //         curve: Curves.bounceInOut);
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pageProvider = Provider.of<PageProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(size),
      body: _bodyContainer(size),
    );
  }

  AppBar _appBarWidget(Size size) {
    return AppBar(
      title: Text(
        'Hello, ${_authProvider.currentUser!.displayName}!',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
        ),
      ),
      actions: [
        IconButton(
          splashRadius: 28.0,
          onPressed: () {},
          icon: Icon(Icons.notifications_none),
        ),
        FutureBuilder<DocumentSnapshot>(
          future: firestore
              .collection('user')
              .doc(_authProvider.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? IconButton(
                    splashRadius: 28.0,
                    onPressed: () {},
                    icon: CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.data!['avatar'],
                      ),
                    ),
                  )
                : SizedBox();
          },
        ),
        SizedBox(width: 8.0),
      ],
    );
  }

  Widget _bodyContainer(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/main/background.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HomeLogo(size: size),
              SizedBox(height: 20.0),
              FadeAnimation(
                duration: Duration(milliseconds: 500),
                delay: Duration(milliseconds: 1250),
                offset: Offset(0.0, 10.0),
                child: OutlinedButton(
                  onPressed: () {
                    _pageProvider.updatePage(1);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  child: Text('EXPLORE'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _bodyContainer(Size size) {
  //   return SingleChildScrollView(
  //     physics: ClampingScrollPhysics(),
  //     child: Column(
  //       children: [
  //         _mainBanner(size),
  //         SizedBox(height: 10.0),
  //         _updateList(1250),
  //         _proSettings(1500),
  //       ],
  //     ),
  //   );
  // }

  // Widget _mainBanner(Size size) {
  //   return Container(
  //     height: size.height * 0.37,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         fit: BoxFit.cover,
  //         image: AssetImage(
  //           'assets/images/main/background.png',
  //         ),
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: Container(
  //             alignment: Alignment.bottomCenter,
  //             padding: EdgeInsets.only(top: 50.0, left: 20.0),
  //             child: HomeLogo(size: size),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _updateList(int duration) {
  //   List<Widget> swiper = [
  //     Card(
  //       elevation: 4.0,
  //       semanticContainer: true,
  //       clipBehavior: Clip.antiAlias,
  //       child: Stack(
  //         children: [
  //           Image.asset('assets/images/main/temp1.png',
  //               width: double.infinity, height: 240.0, fit: BoxFit.cover),
  //           Positioned(
  //             bottom: 10,
  //             right: 10,
  //             child: Container(
  //               width: 300,
  //               color: Colors.black54,
  //               padding: EdgeInsets.all(10.0),
  //               child: Text(
  //                 'I Like Potatoes And Oranges',
  //                 style: TextStyle(fontSize: 20.0, color: Colors.white),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //     Card(
  //       elevation: 4.0,
  //       semanticContainer: true,
  //       clipBehavior: Clip.antiAlias,
  //       child: Stack(
  //         children: [
  //           Image.asset('assets/images/main/temp2.png',
  //               width: double.infinity, height: 240.0, fit: BoxFit.cover),
  //           Positioned(
  //             bottom: 10,
  //             right: 10,
  //             child: Container(
  //               width: 300,
  //               color: Colors.black54,
  //               padding: EdgeInsets.all(10.0),
  //               child: Text(
  //                 'I Like Potatoes And Oranges',
  //                 style: TextStyle(fontSize: 20.0, color: Colors.white),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //     Card(
  //       elevation: 4.0,
  //       semanticContainer: true,
  //       clipBehavior: Clip.antiAlias,
  //       child: Stack(
  //         children: [
  //           Image.asset('assets/images/main/temp3.png',
  //               width: double.infinity, height: 240.0, fit: BoxFit.cover),
  //           Positioned(
  //             bottom: 10,
  //             right: 10,
  //             child: Container(
  //               width: 300,
  //               color: Colors.black54,
  //               padding: EdgeInsets.all(10.0),
  //               child: Text(
  //                 'I Like Potatoes And Oranges',
  //                 style: TextStyle(fontSize: 20.0, color: Colors.white),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   ];

  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 26.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         FadeAnimation(
  //           duration: Duration(milliseconds: 500),
  //           delay: Duration(milliseconds: duration),
  //           offset: Offset(-10.0, 0.0),
  //           child: Text(
  //             'News',
  //             style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         SizedBox(height: 10.0),
  //         FadeAnimation(
  //           duration: Duration(milliseconds: 500),
  //           delay: Duration(milliseconds: duration),
  //           offset: Offset(-10.0, 0.0),
  //           child: SizedBox(
  //             height: 200,
  //             child: PageView.builder(
  //               itemCount: 3,
  //               controller: _pageController,
  //               onPageChanged: (index) => setState(() => _index = index),
  //               itemBuilder: (context, index) {
  //                 return swiper[index];
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _proSettings(int duration) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 26.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         FadeAnimation(
  //           duration: Duration(milliseconds: 500),
  //           delay: Duration(milliseconds: duration),
  //           offset: Offset(10.0, 0.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'Pro settings',
  //                 style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.push(context, createRoute(ProSettingsPage()));
  //                 },
  //                 child: Padding(
  //                   padding:
  //                       EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
  //                   child: Text(
  //                     'See details >',
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 10.0),
  //         FadeAnimation(
  //           duration: Duration(milliseconds: 500),
  //           delay: Duration(milliseconds: duration),
  //           offset: Offset(10.0, 0.0),
  //           child: Card(
  //             elevation: 4.0,
  //             child: InkWell(
  //               customBorder: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10.0),
  //               ),
  //               child: ListTile(
  //                 onTap: () {},
  //                 minVerticalPadding: 20.0,
  //                 leading: Icon(Icons.person, size: 60.0),
  //                 title: Text(
  //                   'Faker',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 subtitle: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('Monitor   BenQ XL2430T'),
  //                     Text('Mouse     CORSAIR SABRE'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
