import '../localization/app_local.dart';

class LocalService {
  String greeting(AppLocal local) {
    return local.welcome;
  }
}
