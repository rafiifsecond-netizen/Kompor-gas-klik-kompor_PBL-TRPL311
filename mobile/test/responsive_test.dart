import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:klikkompor_mobile/core/routes/app_routes.dart';
import 'package:klikkompor_mobile/core/routes/route_generator.dart';
import 'package:klikkompor_mobile/core/theme/app_theme.dart';
import 'package:klikkompor_mobile/providers/auth_provider.dart';
import 'package:klikkompor_mobile/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ResponsiveCase {
  final String label;
  final String route;
  final Object? arguments;

  const _ResponsiveCase(this.label, this.route, {this.arguments});
}

const _sizes = <({String label, Size size})>[
  (label: '360x640', size: Size(360, 640)),
  (label: '411x891', size: Size(411, 891)),
  (label: '800x1280', size: Size(800, 1280)),
];

const _screens = <_ResponsiveCase>[
  _ResponsiveCase('Splash', AppRoutes.splash),
  _ResponsiveCase('Landing', AppRoutes.landing),
  _ResponsiveCase('Login', AppRoutes.login),
  _ResponsiveCase('Register', AppRoutes.register),
  _ResponsiveCase('Home pelanggan', AppRoutes.customerHome),
  _ResponsiveCase('Katalog', AppRoutes.customerCatalog),
  _ResponsiveCase('Detail Layanan', AppRoutes.customerServiceDetail,
      arguments: {'id': 1}),
  _ResponsiveCase('Pilih Teknisi', AppRoutes.customerSelectTechnician),
  _ResponsiveCase('Pilih Alamat', AppRoutes.customerSelectAddress),
  _ResponsiveCase('Form Alamat', AppRoutes.customerEditAddress),
  _ResponsiveCase('Ringkasan Booking', AppRoutes.customerBookingSummary,
      arguments: {
        'service_id': 1,
        'name': 'Servis Kompor Gas',
        'description': 'Servis kompor gas',
        'price': 'Rp 75.000',
        'address': 'Jl. Sei Beduk No. 77, Batam',
      }),
  _ResponsiveCase('Pembayaran', AppRoutes.customerPayment,
      arguments: {
        'service_id': 1,
        'service_name': 'Servis Kompor Gas',
        'address': 'Jl. Sei Beduk No. 77, Batam',
        'date': 'Sen, 27 Oktober 2026',
        'time': '09:00 - 10:00',
        'scheduled_at': '2026-10-27T09:00:00',
        'damageType': 'Kompor tidak menyala',
      }),
  _ResponsiveCase('Riwayat', AppRoutes.customerOrderHistory),
  _ResponsiveCase('Tracking', AppRoutes.customerOrderTracking,
      arguments: {'id': 1}),
  _ResponsiveCase('Notifikasi', AppRoutes.customerNotification),
  _ResponsiveCase('Profil pelanggan', AppRoutes.customerProfile),
  _ResponsiveCase('Dashboard Teknisi', AppRoutes.technicianDashboard),
  _ResponsiveCase('Profil teknisi', AppRoutes.technicianProfile),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views
        .first;
    view.reset();
  });

  for (final screen in _screens) {
    for (final viewport in _sizes) {
      testWidgets(
        '${screen.label} pada ${viewport.label}',
        (tester) async {
          tester.view.physicalSize = viewport.size;
          tester.view.devicePixelRatio = 1.0;
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => AuthProvider()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                onGenerateRoute: RouteGenerator.generateRoute,
                onGenerateInitialRoutes: (_) => [
                  RouteGenerator.generateRoute(RouteSettings(
                    name: screen.route,
                    arguments: screen.arguments ??
                        (screen.route == AppRoutes.customerEditAddress
                            ? null
                            : screen.arguments),
                  )),
                ],
              ),
            ),
          );

          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
