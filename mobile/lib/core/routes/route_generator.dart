import 'package:flutter/material.dart';
import '../../screens/auth/landing_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/customer/customer_home_screen.dart';
import '../../screens/customer/customer_catalog_screen.dart';
import '../../screens/customer/customer_service_detail_screen.dart';
import '../../screens/customer/customer_select_address_screen.dart';
import '../../screens/customer/customer_select_schedule_screen.dart';
import '../../screens/customer/customer_select_technician_screen.dart';
import '../../screens/customer/customer_booking_summary_screen.dart';
import '../../screens/customer/customer_payment_screen.dart';
import '../../screens/customer/customer_order_tracking_screen.dart';
import '../../screens/customer/customer_order_history_screen.dart';
import '../../screens/customer/customer_chat_screen.dart';
import '../../screens/customer/customer_review_screen.dart';
import '../../screens/customer/customer_profile_screen.dart';
import '../../screens/customer/customer_notification_screen.dart';
import '../../screens/customer/customer_help_center_screen.dart';
import '../../screens/technician/technician_dashboard_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // Customer
      case AppRoutes.customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());

      case AppRoutes.customerCatalog:
        return MaterialPageRoute(builder: (_) => const CustomerCatalogScreen());

      case AppRoutes.customerServiceDetail:
        return MaterialPageRoute(builder: (_) => const CustomerServiceDetailScreen(), settings: settings);

      case AppRoutes.customerSelectAddress:
        return MaterialPageRoute(builder: (_) => const CustomerSelectAddressScreen(), settings: settings);

      case AppRoutes.customerSelectSchedule:
        return MaterialPageRoute(builder: (_) => const CustomerSelectScheduleScreen(), settings: settings);

      case AppRoutes.customerSelectTechnician:
        return MaterialPageRoute(builder: (_) => const CustomerSelectTechnicianScreen(), settings: settings);

      case AppRoutes.customerBookingSummary:
        return MaterialPageRoute(builder: (_) => const CustomerBookingSummaryScreen(), settings: settings);

      case AppRoutes.customerPayment:
        return MaterialPageRoute(builder: (_) => const CustomerPaymentScreen(), settings: settings);

      case AppRoutes.customerOrderTracking:
        return MaterialPageRoute(builder: (_) => const CustomerOrderTrackingScreen(), settings: settings);

      case AppRoutes.customerOrderHistory:
        return MaterialPageRoute(builder: (_) => const CustomerOrderHistoryScreen());

      case AppRoutes.customerChat:
        return MaterialPageRoute(builder: (_) => const CustomerChatScreen());

      case AppRoutes.customerReview:
        return MaterialPageRoute(builder: (_) => const CustomerReviewScreen());

      case AppRoutes.customerProfile:
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());

      case AppRoutes.customerNotification:
        return MaterialPageRoute(builder: (_) => const CustomerNotificationScreen());

      case AppRoutes.customerHelpCenter:
        return MaterialPageRoute(builder: (_) => const CustomerHelpCenterScreen());

      // Technician
      case AppRoutes.technicianDashboard:
        return MaterialPageRoute(builder: (_) => const TechnicianDashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Halaman Sedang Disiapkan')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.construction_rounded, size: 54, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Halaman ${settings.name} sedang dikembangkan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
