// test/domain/validators/password_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/domain/validators/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('should validate strong password', () {
      expect(PasswordValidator.validate('SecurePass123'), true);
      expect(PasswordValidator.validate('MyPassword@456'), true);
      expect(PasswordValidator.validate('Tr0pic@lThunder'), true);
    });

    test('should reject password shorter than 8 characters', () {
      expect(PasswordValidator.validate('Pass12'), false);
      expect(PasswordValidator.validate('Short1!'), false);
    });

    test('should reject password without uppercase letter', () {
      expect(PasswordValidator.validate('password123'), false);
      expect(PasswordValidator.validate('pass@word123'), false);
    });

    test('should reject password without numeric character', () {
      expect(PasswordValidator.validate('PasswordNoNum'), false);
      expect(PasswordValidator.validate('Password!'), false);
    });

    test('should reject empty password', () {
      expect(PasswordValidator.validate(''), false);
    });

    test('should validate passwords with special characters', () {
      expect(PasswordValidator.validate('Pass@word123'), true);
      expect(PasswordValidator.validate('Secure#Pass2'), true);
    });

    test('should require at least one uppercase and one number', () {
      // Has uppercase but no number
      expect(PasswordValidator.validate('Nosixnumber'), false);
      // Has number but no uppercase
      expect(PasswordValidator.validate('no123numbers'), false);
      // Has both - valid
      expect(PasswordValidator.validate('Has1Number'), true);
    });
  });
}
