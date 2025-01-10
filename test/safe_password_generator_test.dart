import 'package:flutter_test/flutter_test.dart';
import 'package:safe_password_generator/safe_password_generator.dart';

void main() {
  group(
    'SafePasswordGenerator',
    () {
      test(
        'Generate password with a correct length',
        () {
          final password = SafePasswordGenerator.generatePassword(
            length: 12,
            includeUppercase: true,
            includeLowercase: true,
            includeNumbers: true,
            includeSpecialCharacters: true,
          );

          expect(password.length, 12);
        },
      );

      test('returns empty string for zero length', () {
        final password = SafePasswordGenerator.generatePassword(
          length: 0,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSpecialCharacters: true,
        );
        expect(password, '');
      });

      test('includes required character types', () {
        final password = SafePasswordGenerator.generatePassword(
          length: 12,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSpecialCharacters: true,
        );

        expect(password.contains(RegExp(r'[A-Z]')), true);
        expect(password.contains(RegExp(r'[a-z]')), true);
        expect(password.contains(RegExp(r'[0-9]')), true);
        expect(password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')),
            true);
      });
    },
  );
}
