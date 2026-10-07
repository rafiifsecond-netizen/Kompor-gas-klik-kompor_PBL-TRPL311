import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:klikkompor_mobile/main.dart';
import 'package:klikkompor_mobile/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('KlikKomporApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KlikKomporApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(KlikKomporApp), findsOneWidget);
  });
}

