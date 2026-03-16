import 'package:flutter_test_gen_example/localization/app_locale.dart';

class LocalService {
  String greeting(AppLocal local) {
    return local.welcome;
  }
}
