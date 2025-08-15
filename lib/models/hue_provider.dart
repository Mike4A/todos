import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HueProvider extends ChangeNotifier {
  double _hueA = 210;
  double _hueB = 150;

  HueProvider({required double hueA, required double hueB}) : _hueA = hueA, _hueB = hueB;

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

  Map<String, dynamic> toJson() => {'hueA': _hueA, 'hueB': _hueB};

  factory HueProvider.fromJson(Map<String, dynamic> json) =>
      HueProvider(hueA: json['hueA'], hueB: json['hueB']);

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hueValues', jsonEncode(toJson()));
  }

  static Future<HueProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('hueValues');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return HueProvider.fromJson(jsonMap);
    }
    return HueProvider(hueA: 210, hueB: 250);
  }
}
