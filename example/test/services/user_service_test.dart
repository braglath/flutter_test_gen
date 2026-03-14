import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test_gen_example/services/user_service.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  group('UserService | example/lib/services/user_service.dart', () {
    late UserService service;

    setUp(() {
      mockRepository = MockUserRepository();

      service = UserService(mockRepository);
    });

    test('fetchUserName', () async {
      // Arrange
      final id = 'test';
      when(() => mockRepository.fetchUser(id)).thenAnswer((_) async => 'test');

      // Act
      final result = await service.fetchUserName(id);

      // Assert
      expect(result, isA<Future<String>>());
      verify(() => mockRepository.fetchUser(id)).called(1);
    });
  });
}
