import 'package:flutter/cupertino.dart';

class BottomNavigationProvider extends ChangeNotifier {
  int _index = 0;
  int get currentIndex => _index;

  updatePage(int index) {
    _index = index;
    notifyListeners();
  }
}
