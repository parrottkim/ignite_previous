import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

String getDetailDate(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime justNow = now.subtract(Duration(seconds: 30));
  DateTime localDateTime = dateTime.toLocal();
  if (!localDateTime.difference(justNow).isNegative) {
    return 'Just now';
  }
  String roughTimeString = DateFormat('jm').format(dateTime);
  if (localDateTime.day == now.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return roughTimeString;
  }
  DateTime yesterday = now.subtract(Duration(days: 1));
  if (localDateTime.day == yesterday.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'Yesterday, ' + roughTimeString;
  }
  if (now.difference(localDateTime).inDays < 4) {
    String weekday = DateFormat('EEEE').format(localDateTime);
    return '$weekday, $roughTimeString';
  }
  return '${DateFormat('yyyy.MM.dd').format(dateTime)}, $roughTimeString';
}
