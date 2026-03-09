import 'package:flutter/material.dart';

class UserModel {
  final String? name;
  final String? email;
  final int? age;
  final bool? isActive;
  final DateTime? createdAt;

  UserModel({this.name, this.email, this.age, this.isActive, this.createdAt});

  UserModel copyWith(
          {ValueGetter<String?>? name,
          ValueGetter<String?>? email,
          ValueGetter<int?>? age,
          ValueGetter<bool?>? isActive,
          ValueGetter<DateTime?>? createdAt}) =>
      UserModel(
          name: name != null ? name() : this.name,
          email: email != null ? email() : this.email,
          age: age != null ? age() : this.age,
          isActive: isActive != null ? isActive() : this.isActive,
          createdAt: createdAt != null ? createdAt() : this.createdAt);
}
