class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

abstract class UserRepository {
  Future<User> fetchUser(String id);
}
