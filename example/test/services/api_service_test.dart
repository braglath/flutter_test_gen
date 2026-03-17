import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/repository/user_repository.dart';
import 'package:flutter_test_gen_example/services/api_service.dart';

void main() {
  group('ApiService (services/api_service.dart)', () {
    late ApiService service;

    setUp(() {
      service = ApiService();
    });

    test('fetchUser', () async {
      // Act
      final result = await service.fetchUser();

      // Assert
      expect(result, isA<User>());
    });
  });
}
