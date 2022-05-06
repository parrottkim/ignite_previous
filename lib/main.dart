import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ignite/pages/auth_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:ignite/provider/profile/pubg_profile_provider.dart';
import 'package:ignite/provider/profile_page_provider.dart';
import 'package:ignite/provider/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: 'assets/.env');
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
            create: (_) => AuthProvider(FirebaseAuth.instance)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PageProvider()),
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
            primarySwatch: Colors.red,
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
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              unselectedItemColor: const Color(0xFF8D99AE).withOpacity(0.6),
              selectedItemColor: const Color(0xFFEF233C).withOpacity(0.6),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.red,
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
