import 'package:flutter_test_gen_example/repository/user_repository.dart';

class UserService {
  final UserRepository repository;

  UserService(this.repository);

  Future<String> fetchUserName(String id) async {
    final user = await repository.fetchUser(id);
    return user.name;
  }
}
