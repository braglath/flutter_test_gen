import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_gen_example/repository/user_repository.dart';

import 'api_provider.dart';

final userProvider = FutureProvider<User>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchUser();
});
