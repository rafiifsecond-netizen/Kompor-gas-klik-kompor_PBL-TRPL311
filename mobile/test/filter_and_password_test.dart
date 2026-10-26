import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/screens/customer/customer_select_technician_screen.dart';
import 'package:klikkompor_mobile/services/auth_service.dart';
import 'package:klikkompor_mobile/services/storage_service.dart';
import 'package:klikkompor_mobile/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('technician filters can be combined with priority order', () {
    final technicians = [
      {'name': 'A', 'distance_km': 1.0, 'rating': 4.5, 'price': 50000},
      {'name': 'B', 'distance_km': 3.0, 'rating': 5.0, 'price': 50000},
      {'name': 'C', 'distance_km': 2.0, 'rating': 5.0, 'price': 75000},
    ];

    final sorted = sortTechnicians(technicians, ['rating', 'price_low']);
    expect(sorted.map((item) => item['name']), ['B', 'C', 'A']);
  });

  test('dummy password change rejects an incorrect old password', () async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await AuthRepository()
        .login(email: 'dewi@example.com', password: 'password123');

    final response = await AuthService().changePassword(
      currentPassword: 'wrong-password',
      newPassword: 'newpassword123',
      newPasswordConfirmation: 'newpassword123',
    );

    expect(response.success, isFalse);
    expect(response.message, 'Kata sandi lama tidak sesuai.');

    final changed = await AuthService().changePassword(
      currentPassword: 'password123',
      newPassword: 'newpassword123',
      newPasswordConfirmation: 'newpassword123',
    );
    expect(changed.success, isTrue);
  });
}
