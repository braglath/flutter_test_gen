import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter_provider.dart';

final greetingProvider = Provider<String>((ref) {
  final count = ref.watch(counterProvider);
  return "Count is $count";
});
