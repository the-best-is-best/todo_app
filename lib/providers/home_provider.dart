import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  int currentTab = 0;
  ThemeMode themeMode = ThemeMode.system;
  bool isBottomSheetShow = false;

  void goNextTap(int val) {
    currentTab = val;
    notifyListeners();
  }

  void showHideBottomSheet() {
    isBottomSheetShow = !isBottomSheetShow;
    notifyListeners();
  }

  void changeThemeMode(ThemeMode changeTheme) {
    themeMode = changeTheme;
    notifyListeners();
  }
}
