import 'dart:math';

import 'package:safe_password_generator/src/utils/constants.dart';

class SafePasswordGenerator {
  ///Generate a password based on specified criteria
  static String generatePassword({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSpecialCharacters,
  }) {
    if (length <= 0) return '';

    String characterPool = '';
    if (includeUppercase) characterPool += Constants.uppercase;
    if (includeLowercase) characterPool += Constants.lowercase;
    if (includeNumbers) characterPool += Constants.numbers;
    if (includeSpecialCharacters) characterPool += Constants.specialCharacters;

    final random = Random.secure();
    String password;

    /// First executes the code in the do block
    /// Then checks the condition
    /// If the condition is true, it repeats
    /// Keeps repeating until the condition becomes false
    do {
      password = List.generate(
        length,
        (index) => characterPool[random.nextInt(characterPool.length)],
      ).join();
    } while (!_validatePassword(
      password: password,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSpecialCharacters: includeSpecialCharacters,
    ));

    return password;
  }

  /// Validates that the password contains at least one character of each selected type.
  static bool _validatePassword({
    required String password,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSpecialCharacters,
  }) {
    if (includeUppercase && !RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (includeLowercase && !RegExp(r'[a-z]').hasMatch(password)) return false;
    if (includeNumbers && !RegExp(r'[0-9]').hasMatch(password)) return false;
    if (includeSpecialCharacters &&
        !RegExp(r'[!@#\$%^&*()_+\[\]{}|\\<>?]').hasMatch(password)) {
      return false;
    }
    return true;
  }

  /// Calculates the strength of a password on a scale of 0 to 100.
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    // Calculate entropy
    double entropy = _calculatePasswordEntropy(password);

    // Penalize weak patterns
    double penalty = _calculatePenalty(password);

    // Final strength (entropy - penalty, capped at 100)
    double strength = max(0, entropy - penalty);
    return min(strength, 100);
  }

  /// Calculates the entropy of a password.
  static double _calculatePasswordEntropy(String password) {
    // Determine the size of the character pool
    int poolSize = 0;
    if (password.contains(RegExp(r'[A-Z]'))) {
      poolSize += 26; // Uppercase letters
    }
    if (password.contains(RegExp(r'[a-z]'))) {
      poolSize += 26; // Lowercase letters
    }
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10; // Numbers
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      poolSize += 32;
    }

    /// Calculate entropy: log2(poolSize^password.length)
    /// This is the general formula for calculating a password's entropy
    if (poolSize == 0) return 0;
    return password.length * log(poolSize) / log(2);
  }

  /// Calculates penalties for weak patterns in the password.
  static double _calculatePenalty(String password) {
    double penalty = 0;

    // Penalize common weak patterns
    if (_isCommonPassword(password)) {
      penalty += 50; // Heavy penalty for common passwords
    }

    // Penalize sequential characters (e.g., "1234", "abcd")
    if (_hasSequentialCharacters(password)) {
      penalty += 20;
    }

    // Penalize repeated characters (e.g., "aaaaaa")
    if (_hasRepeatedCharacters(password)) {
      penalty += 15;
    }

    return penalty;
  }

  /// Checks if the password is a common weak password.
  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'abc123',
      '1234',
      '1234567890'
          'iloveyou',
      'password1',
      'monkey',
    ];
    return commonPasswords.contains(password.toLowerCase());
  }

  /// Checks if the password contains sequential characters.
  static bool _hasSequentialCharacters(String password) {
    // Check for sequential characters (e.g., "1234", "abcd")
    for (int i = 0; i < password.length - 2; i++) {
      int currentChar = password.codeUnitAt(i);
      int nextChar = password.codeUnitAt(i + 1);
      if (nextChar == currentChar + 1) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the password contains repeated characters.
  static bool _hasRepeatedCharacters(String password) {
    // Check for repeated characters (e.g., "aaaaaa")
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  static String getStrengthLabel(double strength) {
    if (strength >= 80) return 'Very Strong';
    if (strength >= 60) return 'Strong';
    if (strength >= 40) return 'Moderate';
    if (strength >= 20) return 'Weak';
    return 'Very Weak';
  }

}
