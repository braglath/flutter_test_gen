import '../errors/user_error.dart';
import '../localization/app_local.dart';

class ErrorMapper {
  final UserError error;

  ErrorMapper(this.error);

  String map(AppLocal local) {
    return switch (error) {
      UserNotFound() => local.invalidUser,
      UserBlocked() => "User blocked",
      _ => "Unknown error",
    };
  }
}
