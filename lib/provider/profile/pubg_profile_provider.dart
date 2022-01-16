import 'package:flutter/material.dart';
import 'package:ignite/models/profile/pubg.dart';
import 'package:ignite/provider/repositories/pubg_repository.dart';

class PUBGProfileProvider extends ChangeNotifier {
  final PUBGRepository _pubgRepository = PUBGRepository();
  PUBGUser? _pubgUser;
  PUBGUser? get pubgUser => _pubgUser;

  loadUserProfile(String username, String server) async {
    _pubgUser = await _pubgRepository.getUserName(username, server);
    print(_pubgUser);
    notifyListeners();
  }

  clearUserProfile() {
    _pubgUser = null;
  }
}
