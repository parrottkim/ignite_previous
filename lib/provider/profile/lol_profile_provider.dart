import 'package:flutter/material.dart';
import 'package:ignite/models/profile/lol.dart';
import 'package:ignite/provider/repositories/lol_repository.dart';

class LOLProfileProvider extends ChangeNotifier {
  final LOLRepository _lolRepository = LOLRepository();
  LOLUser? _lolUser;
  LOLUser? get lolUser => _lolUser;

  loadUserProfile(String username) async {
    _lolUser = await _lolRepository.getUserName(username);
    notifyListeners();
  }

  clearUserProfile() {
    _lolUser = null;
  }
}
