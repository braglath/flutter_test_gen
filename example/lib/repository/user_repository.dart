class User {
  final String name;

  User(this.name);
}

abstract class UserRepository {
  Future<User> fetchUser(String id);
}
