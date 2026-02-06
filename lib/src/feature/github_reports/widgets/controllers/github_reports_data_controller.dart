import 'package:flutter/foundation.dart';

class GithubReportsDataController with ChangeNotifier {
  String? _issueTitle;
  String? _issueBody;
  final List<String> _selectedLabels = [];
  bool _isCreatingIssue = false;

  String? get issueTitle => _issueTitle;

  String? get issueBody => _issueBody;

  List<String> get selectedLabels => _selectedLabels;

  bool get isCreatingIssue => _isCreatingIssue;

  set issueTitle(String? title) {
    _issueTitle = title;
    notifyListeners();
  }

  set issueBody(String? body) {
    _issueBody = body;
    notifyListeners();
  }

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

  void setIsCreatingIssue(bool value) {
    _isCreatingIssue = value;
    notifyListeners();
  }

  void clearForm() {
    _issueTitle = null;
    _issueBody = null;
    _selectedLabels.clear();
    notifyListeners();
  }
}
