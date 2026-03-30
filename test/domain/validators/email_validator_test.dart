// test/domain/validators/email_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/domain/validators/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('should validate correct email', () {
      expect(EmailValidator.validate('test@example.com'), true);
      expect(EmailValidator.validate('user.name+tag@example.co.uk'), true);
      expect(EmailValidator.validate('simple@domain.io'), true);
    });

    test('should invalidate incorrect email', () {
      expect(EmailValidator.validate('notanemail'), false);
      expect(EmailValidator.validate('missing@domain'), false);
      expect(EmailValidator.validate('@domain.com'), false);
      expect(EmailValidator.validate('user@'), false);
      expect(EmailValidator.validate(''), false);
      expect(EmailValidator.validate('user @domain.com'), false);
    });

    test('should validate edge cases', () {
      expect(EmailValidator.validate('a@b.co'), true);
      expect(EmailValidator.validate('test..test@domain.com'), false);
    });
  });
}
