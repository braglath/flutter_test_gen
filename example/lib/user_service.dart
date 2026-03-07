import 'package:flutter_test_gen_example/user_model.dart';

// top level function
int globalFunction() => 1;

class UserService {
  // unit test method
  int getAge() => 20;

  // custom method with parameters
  UserModel getUser(UserModel model) =>
      UserModel(name: "John", age: 30, isActive: true);

  // named parameters
  UserModel updateUser(
    bool isNewUser, {
    required String name,
    required int age,
    bool isActive = true,
    DateTime? createdAt,
  }) =>
      UserModel(
          name: name,
          age: age,
          isActive: isActive,
          createdAt: createdAt ?? DateTime.now());

  // default value test generator
  UserModel updateEmail(String email) =>
      UserModel().copyWith(email: () => email);

  static int add(int a, int b) => a + b;

  // private method (should be ignored)
  int _privateMethod() => 1;
}

// mixin class (should be ignored)
mixin LoggerMixin {
  void log(String msg) {}
}

// extensions (should be ignored)
extension StringExt on String {
  int wordCount() => split(" ").length;
}
