import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/profile_pages/lol_profile_page.dart';
import 'package:ignite/pages/profile_pages/pubg_profile_page.dart';

class ProfilePageProvider extends ChangeNotifier {
  getPage(String gameName) {
    switch (gameName) {
      case 'League of Legends':
        return LOLProfilePage();
      case 'Playerunknown\'s Battlegrounds':
        return PUBGProfilePage();
      default:
        return Scaffold(body: Center(child: Text(gameName)));
    }
  }
}
