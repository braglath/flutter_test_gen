import 'package:flutter_test_gen_example/repository/user_repository.dart';

class ApiService {
  Future<User> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return User(name: 'John', age: 25);
  }
}
