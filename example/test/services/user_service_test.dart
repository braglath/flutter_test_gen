import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/repository/user_repository.dart';
import 'package:flutter_test_gen_example/services/user_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  group('UserService (services/user_service.dart)', () {
    late UserService service;

    setUp(() {
      mockRepository = MockUserRepository();

      service = UserService(mockRepository);
    });

    test('returns string when fetchUserName succeeds', () async {
      // Arrange
      const id = 'test';
      when(
        () => mockRepository.fetchUser(id),
      ).thenAnswer((_) async => User(name: 'test', age: 1));

      // Act
      final result = await service.fetchUserName(id);

      // Assert
      expect(result, 'test');

      verify(() => mockRepository.fetchUser(id)).called(1);
    });
  });
}
