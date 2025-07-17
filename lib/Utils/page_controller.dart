// lib/controllers/page_controller.dart (Create this new file)
import 'package:flutter/foundation.dart';

class PageController extends ChangeNotifier {
  String _currentPage = 'dashboard'; // Initial page

  String get currentPage => _currentPage;

  void setPage(String pageName) {
    if (_currentPage != pageName) {
      _currentPage = pageName;
      debugPrint('PageController: Setting current page to: $pageName');
      notifyListeners();
    }
  }
}
