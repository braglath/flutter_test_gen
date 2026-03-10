import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/create_member_form_error_mapper.dart';
import 'package:flutter_test_gen_example/create_member_form_error.dart';



void main() {



  group('CreateMemberFormErrorMapper | example/lib/create_member_form_error_mapper.dart', () {

    late CreateMemberFormErrorMapper service;

    setUp(() {

      service = CreateMemberFormErrorMapper();
    });

    test('mapNameError', ()  {
      // Arrange
      final local = AppLocalizations.values.first;
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.mapNameError(local, error);

      // Assert
      expect(result, 'test');

    });
    test('mapSelectGymError', ()  {
      // Arrange
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.mapSelectGymError(error);

      // Assert
      expect(result, 'test');

    });
    test('mapSelectGenderError', ()  {
      // Arrange
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.mapSelectGenderError(error);

      // Assert
      expect(result, 'test');

    });
    test('mapPhoneError', ()  {
      // Arrange
      final local = AppLocalizations.values.first;
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.mapPhoneError(local, error);

      // Assert
      expect(result, 'test');

    });
    test('verifyPhoneError', ()  {
      // Arrange
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.verifyPhoneError(error);

      // Assert
      expect(result, 'test');

    });
    test('mapWhatsAppError', ()  {
      // Arrange
      final error = CreateMemberFormError.values.first;

      // Act
      final result = CreateMemberFormErrorMapper.mapWhatsAppError(error);

      // Assert
      expect(result, 'test');

    });

  });

}
