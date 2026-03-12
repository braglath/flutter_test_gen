import '../models/user_role.dart';

class PermissionService {
  bool canEdit(UserRole role) {
    return role == UserRole.admin;
  }
}
