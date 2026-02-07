import 'dart:collection';

import 'package:flutter/foundation.dart';

class GithubReportsDataController with ChangeNotifier {
  final List<String> _selectedLabels = [];

  UnmodifiableListView<String> get availableLabels =>
      UnmodifiableListView(['bug', 'enhancement', 'documentation']);

  UnmodifiableListView<String> get selectedLabels => UnmodifiableListView(_selectedLabels);

  void addLabel(String label) {
    if (!_selectedLabels.contains(label)) {
      _selectedLabels.add(label);
      notifyListeners();
    }
  }

  void removeLabel(String label) {
    _selectedLabels.remove(label);
    notifyListeners();
  }

  void clearLabels() {
    _selectedLabels.clear();
    notifyListeners();
  }

  void clearForm() {
    _selectedLabels.clear();
    notifyListeners();
  }
}
