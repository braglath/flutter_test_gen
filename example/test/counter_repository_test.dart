import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test_gen_example/counter_repository.dart';


class MockCounterRepository extends Mock implements CounterRepository {}


void main() {

late MockCounterRepository mockCounterRepository;


  group('CounterRepository | lib/counter_repository.dart', () {

    late CounterRepository service;

    setUp(() {

      service = CounterRepository();
    });

    test('getCount', ()  {
      // Arrange

      // Act
      final result = service.getCount();

      // Assert
      expect(result, 1);

    });

  });
  group('CounterViewModel | lib/counter_repository.dart', () {

    late CounterViewModel service;

    setUp(() {
      mockCounterRepository = MockCounterRepository();
      service = CounterViewModel(mockCounterRepository);
    });

    test('getCount', ()  {
      // Arrange
      when(() => mockCounterRepository.getCount()).thenReturn(1);

      // Act
      final result = service.getCount();

      // Assert
      expect(result, 1);
      verify(() => mockCounterRepository.getCount()).called(1);
    });

  });

}
