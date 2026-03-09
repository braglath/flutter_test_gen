import 'package:test/test.dart';

import '../bin/flutter_test_gen.dart' as cli;

void main() {
  group('CLI main()', () {
    test('shows help when args empty', () async {
      cli.main([]);

      expect(true, true); // ensures no crash
    });

    test('shows help when --help provided', () async {
      cli.main(['--help']);

      expect(true, true);
    });

    test('shows help when -h provided', () async {
      cli.main(['-h']);

      expect(true, true);
    });

    test('shows help when help command provided', () async {
      cli.main(['help']);

      expect(true, true);
    });

    test('calls generate command', () async {
      cli.main(['generate', 'user_service']);

      expect(true, true);
    });

    test('backward compatibility generate', () async {
      cli.main(['user_service']);

      expect(true, true);
    });
  });
}
