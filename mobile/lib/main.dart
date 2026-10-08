import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KlikKomporApp(),
    ),
  );
}

class KlikKomporApp extends StatelessWidget {
  const KlikKomporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KlikKompor',
      theme: AppTheme.lightTheme,
      // Halaman pertama: Landing Page
      // Alur: Landing → (Mulai) → Login → (Belum punya akun?) → Register
      initialRoute: AppRoutes.landing,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
