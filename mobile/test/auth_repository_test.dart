import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/repositories/auth_repository.dart';
import 'package:klikkompor_mobile/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('dummy customer login succeeds', () async {
    final user = await AuthRepository().login(email: 'dewi@example.com', password: 'password123');
    expect(user.role, 'customer');
  });

  test('dummy invalid login fails', () async {
    expect(() => AuthRepository().login(email: 'wrong@example.com', password: 'wrongpass'), throwsException);
  });
}