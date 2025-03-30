import 'package:flutter/material.dart';

class DateCalculatorProvider extends ChangeNotifier {
  DateTime? _selectedDate;
  bool _showDetailedTime = false;
  bool _isInfoVisible = true;
  double _fontSize = 18.0;
  double _opacity = 0.7;

  DateTime? get selectedDate => _selectedDate;
  bool get showDetailedTime => _showDetailedTime;
  bool get isInfoVisible => _isInfoVisible;
  double get fontSize => _fontSize;
  double get opacity => _opacity;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void toggleDetailedTime() {
    _showDetailedTime = !_showDetailedTime;
    notifyListeners();
  }

  void toggleInfoVisibility() {
    _isInfoVisible = !_isInfoVisible;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value;
    notifyListeners();
  }
} 