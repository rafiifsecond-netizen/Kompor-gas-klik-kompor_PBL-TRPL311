import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/core/utils/validators.dart';

void main() {
  test('valid and invalid email', () {
    expect(Validators.email('user@example.com'), isNull);
    expect(Validators.email('not-an-email'), isNotNull);
  });

  test('password requires at least 8 characters', () {
    expect(Validators.password('1234567'), isNotNull);
    expect(Validators.password('12345678'), isNull);
  });

  test('confirmation must match password', () {
    expect(Validators.confirmPassword('different', 'password'), isNotNull);
    expect(Validators.confirmPassword('password', 'password'), isNull);
  });

  test('required rejects empty fields', () {
    expect(Validators.required(''), isNotNull);
    expect(Validators.required('   '), isNotNull);
    expect(Validators.required('value'), isNull);
  });
}
