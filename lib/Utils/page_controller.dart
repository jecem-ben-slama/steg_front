import 'package:flutter/foundation.dart';

class PageController extends ChangeNotifier {
  String _currentPage = 'dashboard';

  String get currentPage => _currentPage;

  void setPage(String pageName) {
    if (_currentPage != pageName) {
      _currentPage = pageName;
      debugPrint('PageController: Setting current page to: $pageName');
      notifyListeners();
    }
  }
}
