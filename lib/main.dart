import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/auth_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/bottom_navigation_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:ignite/provider/profile/pubg_profile_provider.dart';
import 'package:ignite/provider/profile_page_provider.dart';
import 'package:ignite/provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthenticationProvider(FirebaseAuth.instance)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ProfilePageProvider()),
        ChangeNotifierProvider(create: (_) => LOLProfileProvider()),
        ChangeNotifierProvider(create: (_) => PUBGProfileProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, widget) => MaterialApp(
          // debugShowCheckedModeBanner: false,
          title: 'Ignite',
          themeMode: value.themeMode,
          theme: ThemeData(
            primaryColor: Colors.white,
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.light,
              backgroundColor: Colors.white,
            ).copyWith(
              primary: Colors.redAccent,
              secondary: Color(0xFFFF5454),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              unselectedItemColor: const Color(0xFF8D99AE).withOpacity(0.6),
              selectedItemColor: const Color(0xFFEF233C).withOpacity(0.6),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
              accentColor: Color(0xFFFF5454),
              backgroundColor: Color(0xFF2B2D42),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              unselectedItemColor: const Color(0xFF8D99AE).withOpacity(0.4),
              selectedItemColor: Colors.white,
            ),
          ),
          home: AuthPage(),
        ),
      ),
    );
  }
}
