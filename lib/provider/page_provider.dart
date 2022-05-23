import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  double _currentIndex = 0;
  double get currentIndex => _currentIndex;

  PageController _pageController = PageController();
  PageController get pageController => _pageController;

  updatePage(double index) {
    _pageController.animateToPage(index.toInt(),
        duration: Duration(milliseconds: 200), curve: Curves.ease);
    _currentIndex = index;
    notifyListeners();
  }

  initialize() {
    _currentIndex = 0;
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
    notifyListeners();
  }
}
