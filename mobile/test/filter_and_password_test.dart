import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/screens/customer/customer_select_technician_screen.dart';

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
}
