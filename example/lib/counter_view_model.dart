import 'package:flutter/material.dart';
import 'package:flutter_test_gen_example/app_enum.dart';

class CounterViewModel extends ChangeNotifier {
  int _counter = 0;
  UserGender _gender = UserGender.male;

  int get counter => _counter;
  UserGender get gender => _gender;

  void increment() {
    _counter++;
    notifyListeners();
  }

  void decrement() {
    _counter--;
    notifyListeners();
  }

  void reset() {
    _counter = 0;
    notifyListeners();
  }

  void updateGender(UserGender userGender) {
    _gender = userGender;
    notifyListeners();
  }

  int addAge(int a, int b) => a + b;
}
