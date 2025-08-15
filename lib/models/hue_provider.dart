import 'package:flutter/material.dart';

class HueProvider extends ChangeNotifier {
  double _hueA = 210;
  double _hueB = 150;

  double get hueA => _hueA;

  double get hueB => _hueB;

  double get hueCore {
    double diff = (_hueA - _hueB) % 360;
    if (diff > 180) diff -= 360;
    double center = (_hueB + diff / 2) % 360;
    return center < 0 ? center + 360 : center;
  }

  void setHueA(double newHue) {
    _hueA = (newHue + 360) % 360;
    notifyListeners();
  }

  void setHueB(double newHue) {
    _hueB = (newHue + 360) % 360;
    notifyListeners();
  }
}
