import 'package:flutter_test_gen_example/localization/app_locale.dart';

import '../errors/user_error.dart';

class ErrorMapper {
  final UserError error;

  ErrorMapper(this.error);

  String map(AppLocal local) {
    return switch (error) {
      UserNotFound() => local.invalidUser,
      UserBlocked() => "User blocked",
    };
  }
}
