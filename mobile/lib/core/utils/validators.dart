class Validators {
  Validators._();

  static String? required(String? value, {String label = 'Field'}) {
    return value == null || value.trim().isEmpty ? '$label wajib diisi' : null;
  }

  static String? email(String? value) {
    final requiredError = required(value, label: 'Email');
    if (requiredError != null) return requiredError;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : 'Format email tidak valid';
  }

  static String? password(String? value) {
    final requiredError = required(value, label: 'Kata sandi');
    if (requiredError != null) return requiredError;
    return value!.length < 8 ? 'Kata sandi minimal 8 karakter' : null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = required(value, label: 'Konfirmasi kata sandi');
    if (requiredError != null) return requiredError;
    return value != password ? 'Kata sandi tidak cocok' : null;
  }

  static String? positiveNumber(String? value, {String label = 'Harga'}) {
    final requiredError = required(value, label: label);
    if (requiredError != null) return requiredError;
    final amount = num.tryParse(value!.trim());
    return amount == null || amount <= 0
        ? '$label harus berupa angka positif'
        : null;
  }
}
