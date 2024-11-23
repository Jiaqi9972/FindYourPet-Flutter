import 'package:find_your_pet/models/view_mode.dart';
import 'package:flutter/cupertino.dart';

class ViewModeProvider with ChangeNotifier {
  ViewMode _currentView = ViewMode.list;

  ViewMode get currentView => _currentView;

  void setViewMode(ViewMode mode) {
    _currentView = mode;
    notifyListeners();
  }
}
