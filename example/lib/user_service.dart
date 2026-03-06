int globalFunction() => 1;

class UserService {
  int getAge() => 20;

  static int add(int a, int b) => a + b;

  int _privateMethod() => 1;
}

mixin LoggerMixin {
  void log(String msg) {}
}

extension StringExt on String {
  int wordCount() => split(" ").length;
}
