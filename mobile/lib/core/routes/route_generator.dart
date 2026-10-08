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
import '../../screens/technician/technician_incoming_orders_screen.dart';
import '../../screens/technician/technician_update_status_screen.dart';
import '../../screens/technician/technician_additional_cost_screen.dart';
import '../../screens/technician/technician_service_history_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.04);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);

      case AppRoutes.landing:
        return _fadeRoute(const LandingScreen(), settings);

      case AppRoutes.login:
        return _fadeRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _fadeRoute(const RegisterScreen(), settings);

      // Customer
      case AppRoutes.customerHome:
        return _fadeRoute(const CustomerHomeScreen(), settings);

      case AppRoutes.customerCatalog:
        return _fadeRoute(const CustomerCatalogScreen(), settings);

      case AppRoutes.customerServiceDetail:
        return _fadeRoute(const CustomerServiceDetailScreen(), settings);

      case AppRoutes.customerSelectAddress:
        return _fadeRoute(const CustomerSelectAddressScreen(), settings);

      case AppRoutes.customerSelectSchedule:
        return _fadeRoute(const CustomerSelectScheduleScreen(), settings);

      case AppRoutes.customerSelectTechnician:
        return _fadeRoute(const CustomerSelectTechnicianScreen(), settings);

      case AppRoutes.customerBookingSummary:
        return _fadeRoute(const CustomerBookingSummaryScreen(), settings);

      case AppRoutes.customerPayment:
        return _fadeRoute(const CustomerPaymentScreen(), settings);

      case AppRoutes.customerOrderTracking:
        return _fadeRoute(const CustomerOrderTrackingScreen(), settings);

      case AppRoutes.customerOrderHistory:
        return _fadeRoute(const CustomerOrderHistoryScreen(), settings);

      case AppRoutes.customerChat:
        return _fadeRoute(const CustomerChatScreen(), settings);

      case AppRoutes.customerReview:
        return _fadeRoute(const CustomerReviewScreen(), settings);

      case AppRoutes.customerProfile:
        return _fadeRoute(const CustomerProfileScreen(), settings);

      case AppRoutes.customerNotification:
        return _fadeRoute(const CustomerNotificationScreen(), settings);

      case AppRoutes.customerHelpCenter:
        return _fadeRoute(const CustomerHelpCenterScreen(), settings);

      // Technician
      case AppRoutes.technicianDashboard:
        return _fadeRoute(const TechnicianDashboardScreen(), settings);

      case AppRoutes.technicianIncomingOrders:
        return _fadeRoute(const TechnicianIncomingOrdersScreen(), settings);

      case AppRoutes.technicianUpdateStatus:
        return _fadeRoute(const TechnicianUpdateStatusScreen(), settings);

      case AppRoutes.technicianAdditionalCost:
        return _fadeRoute(const TechnicianAdditionalCostScreen(), settings);

      case AppRoutes.technicianServiceHistory:
        return _fadeRoute(const TechnicianServiceHistoryScreen(), settings);

      default:
        return _fadeRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Halaman Sedang Disiapkan')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.construction_rounded,
                        size: 54, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Halaman ${settings.name} sedang dikembangkan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          settings,
        );
    }
  }
}
