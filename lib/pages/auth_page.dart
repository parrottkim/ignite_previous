import 'package:flutter/material.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/pages/get_started_pages/get_started_page.dart';
import 'package:ignite/pages/get_started_pages/intro_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _firstSeen = false;

  _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstSeen = prefs.getBool('first_launch') ?? false;
    });
    await prefs.setBool('first_launch', true);
  }

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, value, widget) {
        if (!_firstSeen && value.currentUser == null) return IntroPage();
        if (value.currentUser == null || !value.currentUser!.emailVerified)
          return GetStartedPage();
        return DashboardPage();
      },
    );
  }
}
