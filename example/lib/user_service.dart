import 'package:flutter_test_gen_example/user_model.dart';

int globalFunction() => 1;

class UserService {
  int getAge() => 20;

  UserModel getUser(UserModel model) =>
      UserModel(name: "John", age: 30, isActive: true);

  static int add(int a, int b) => a + b;

  int _privateMethod() => 1;
}

mixin LoggerMixin {
  void log(String msg) {}
}

extension StringExt on String {
  int wordCount() => split(" ").length;
}
