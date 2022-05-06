import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/chat_pages/chatgroup_page.dart';
import 'package:ignite/pages/home_pages/home_page.dart';
import 'package:ignite/pages/my_pages/my_page.dart';
import 'package:ignite/pages/search_pages/search_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setupInteractedMessage() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
    );

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'splash',
            ),
          ),
        );
      }
    });

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Provider.of<PageProvider>(context, listen: false).updatePage(2);
    // if (message.data['type'] == 'chat') {
    //   Navigator.push(context, createRoute(ChatPage()));
    // }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setupInteractedMessage();
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
