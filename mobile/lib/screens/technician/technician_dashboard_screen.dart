import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/order_repository.dart';
import 'technician_chat_screen.dart';
import 'technician_income_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  final MapController _mapController = MapController();
  late Future<List<OrderModel>> _ordersFuture;
  String? _lastMapTarget;
  bool _isOnline = false;
  int _currentIndex = 0;
  final _repository = OrderRepository();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: _currentIndex == 1
          ? const TechnicianIncomeScreen()
          : _currentIndex == 2
              ? TechnicianChatInboxScreen(
                  onBack: () => setState(() => _currentIndex = 0),
                )
              : _currentIndex == 3
                  ? const TechnicianProfileScreen()
                  : _DashboardFuture(
                      future: _ordersFuture,
                      userName: user?.name ?? 'Teknisi',
                      technicianPoint: _validPoint(
                        user?.technicianProfile?.currentLatitude,
                        user?.technicianProfile?.currentLongitude,
                      ),
                      mapController: _mapController,
                      onMapTarget: _syncMapTarget,
                      onProfile: () => Navigator.pushNamed(
                        context,
                        AppRoutes.technicianProfile,
                      ),
                      isOnline: _isOnline,
                      onToggleAvailability: _toggleAvailability,
                      onOpenActiveOrder: _openActiveOrder,
                      onOpenOrders: _openOrders,
                      onShowRoute: _showRoute,
                    ),
      bottomNavigationBar: _DashboardNavigation(
        currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Future<List<OrderModel>> _loadOrders() async {
    try {
      final rows = await _repository.getOrders();
      return rows.map(OrderModel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _toggleAvailability(bool status) async {
    setState(() => _isOnline = status);
    try {
      await _repository.updateTechnicianAvailability(status);
    } catch (_) {}
  }

  void _syncMapTarget(
    String target,
    List<LatLng> points,
  ) {
    if (_lastMapTarget == target) return;
    _lastMapTarget = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || points.isEmpty) return;
      if (points.length == 2) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.fromLTRB(72, 100, 72, 300),
          ),
        );
      } else {
        _mapController.move(points.first, 14);
      }
    });
  }

  void _openActiveOrder(OrderModel? order, LatLng? technicianPoint) {
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada pesanan yang sedang berlangsung.'),
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.technicianOrderDetail,
      arguments: _orderArguments(order, technicianPoint),
    ).then((_) {
      if (mounted) setState(() => _ordersFuture = _loadOrders());
    });
  }

  Map<String, dynamic> _orderArguments(
    OrderModel order,
    LatLng? technicianPoint,
  ) {
    return {
      'orderId': order.id,
      'orderNumber': order.orderNumber,
      'customerName': order.customer?.name ?? 'Pelanggan',
      'serviceName': order.items.isNotEmpty
          ? order.items.first.serviceName ??
              order.items.first.service?.name ??
              'Servis Kompor Gas'
          : 'Servis Kompor Gas',
      'latitude': order.latitude,
      'longitude': order.longitude,
      'technician_latitude': technicianPoint?.latitude,
      'technician_longitude': technicianPoint?.longitude,
      'paymentMethod': order.paymentMethod,
      'address': order.addressText ??
          order.address?.addressLine ??
          'Lokasi pelanggan belum tersedia',
      'amount': order.totalAmount,
      'status': order.status,
    };
  }

  void _openOrders() {
    Navigator.pushNamed(context, AppRoutes.technicianIncomingOrders).then((_) {
      if (mounted) setState(() => _ordersFuture = _loadOrders());
    });
  }

  void _showRoute(LatLng? technicianPoint, List<LatLng> mapPoints) {
    if (mapPoints.length == 2) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(mapPoints),
          padding: const EdgeInsets.all(90),
        ),
      );
    } else if (technicianPoint != null) {
      _mapController.move(technicianPoint, 15);
    }
  }
}

class _DashboardFuture extends StatelessWidget {
  final Future<List<OrderModel>> future;
  final String userName;
  final LatLng? technicianPoint;
  final MapController mapController;
  final void Function(String, List<LatLng>) onMapTarget;
  final VoidCallback onProfile;
  final bool isOnline;
  final ValueChanged<bool> onToggleAvailability;
  final void Function(OrderModel?, LatLng?) onOpenActiveOrder;
  final VoidCallback onOpenOrders;
  final void Function(LatLng?, List<LatLng>) onShowRoute;

  const _DashboardFuture({
    required this.future,
    required this.userName,
    required this.technicianPoint,
    required this.mapController,
    required this.onMapTarget,
    required this.onProfile,
    required this.isOnline,
    required this.onToggleAvailability,
    required this.onOpenActiveOrder,
    required this.onOpenOrders,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: future,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const <OrderModel>[];
        final selectedOrder = _selectOrder(orders);
        final customerPoint = _validPoint(
          selectedOrder?.latitude,
          selectedOrder?.longitude,
        );
        final center = _mapCenter(technicianPoint, customerPoint);
        final mapPoints = [
          if (technicianPoint != null) technicianPoint!,
          if (customerPoint != null) customerPoint,
        ];
        final target = [
          technicianPoint?.latitude,
          technicianPoint?.longitude,
          customerPoint?.latitude,
          customerPoint?.longitude,
        ].join(':');
        onMapTarget(target, mapPoints);
        return _DashboardMap(
          center: center,
          mapPoints: mapPoints,
          technicianPoint: technicianPoint,
          customerPoint: customerPoint,
          mapController: mapController,
          userName: userName,
          order: selectedOrder,
          orderCount: orders.where((o) => o.status == 'pending').length,
          loading: snapshot.connectionState == ConnectionState.waiting,
          error: snapshot.hasError ? snapshot.error.toString() : null,
          isOnline: isOnline,
          onProfile: onProfile,
          onToggleAvailability: onToggleAvailability,
          onOpenActiveOrder: () =>
              onOpenActiveOrder(selectedOrder, technicianPoint),
          onOpenOrders: onOpenOrders,
          onShowRoute: () => onShowRoute(technicianPoint, mapPoints),
        );
      },
    );
  }
}

OrderModel? _selectOrder(List<OrderModel> orders) {
  for (final status in ['on_the_way', 'accepted', 'in_progress']) {
    for (final order in orders) {
      if (order.status == status) return order;
    }
  }
  return null;
}

LatLng? _validPoint(double? latitude, double? longitude) {
  if (latitude == null || longitude == null) return null;
  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return null;
  }
  return LatLng(latitude, longitude);
}

LatLng _mapCenter(LatLng? technician, LatLng? customer) {
  if (technician != null && customer != null) {
    return LatLng(
      (technician.latitude + customer.latitude) / 2,
      (technician.longitude + customer.longitude) / 2,
    );
  }
  return technician ?? customer ?? const LatLng(1.12, 104.04);
}

class _DashboardMap extends StatelessWidget {
  final LatLng center;
  final List<LatLng> mapPoints;
  final LatLng? technicianPoint;
  final LatLng? customerPoint;
  final MapController mapController;
  final String userName;
  final OrderModel? order;
  final int orderCount;
  final bool loading;
  final String? error;
  final bool isOnline;
  final VoidCallback onProfile;
  final ValueChanged<bool> onToggleAvailability;
  final VoidCallback onOpenActiveOrder;
  final VoidCallback onOpenOrders;
  final VoidCallback onShowRoute;

  const _DashboardMap({
    required this.center,
    required this.mapPoints,
    required this.technicianPoint,
    required this.customerPoint,
    required this.mapController,
    required this.userName,
    required this.order,
    required this.orderCount,
    required this.loading,
    required this.error,
    required this.isOnline,
    required this.onProfile,
    required this.onToggleAvailability,
    required this.onOpenActiveOrder,
    required this.onOpenOrders,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _DashboardMapLayer(
            center: center,
            mapController: mapController,
            technicianPoint: technicianPoint,
            customerPoint: customerPoint,
          ),
          _DashboardTopBar(
            userName: userName,
            isOnline: isOnline,
            onProfile: onProfile,
            onToggleAvailability: onToggleAvailability,
          ),
          _DashboardMapControls(
            center: center,
            technicianPoint: technicianPoint,
            mapController: mapController,
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _OrderPanel(
              userName: userName,
              order: order,
              customerPoint: customerPoint,
              orderCount: orderCount,
              loading: loading,
              error: error,
              onOpenActiveOrder: onOpenActiveOrder,
              onOpenOrders: onOpenOrders,
              onShowRoute: onShowRoute,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMapLayer extends StatelessWidget {
  final LatLng center;
  final MapController mapController;
  final LatLng? technicianPoint;
  final LatLng? customerPoint;

  const _DashboardMapLayer({
    required this.center,
    required this.mapController,
    required this.technicianPoint,
    required this.customerPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: center, initialZoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.klikkompor.mobile',
          ),
          if (technicianPoint != null && customerPoint != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [technicianPoint!, customerPoint!],
                  strokeWidth: 4,
                  color: AppColors.primary,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (technicianPoint != null)
                Marker(
                  point: technicianPoint!,
                  width: 58,
                  height: 72,
                  child: const _MapPin(
                    icon: Icons.handyman_rounded,
                    color: AppColors.primary,
                    label: 'Teknisi',
                  ),
                ),
              if (customerPoint != null)
                Marker(
                  point: customerPoint!,
                  width: 58,
                  height: 72,
                  child: const _MapPin(
                    icon: Icons.person_rounded,
                    color: AppColors.secondary,
                    label: 'Pelanggan',
                  ),
                ),
            ],
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  final String userName;
  final bool isOnline;
  final VoidCallback onProfile;
  final ValueChanged<bool> onToggleAvailability;

  const _DashboardTopBar({
    required this.userName,
    required this.isOnline,
    required this.onProfile,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoundAction(
                icon: Icons.person_outline_rounded,
                background: const Color(0xFFEADDFF),
                foreground: AppColors.purpleText,
                tooltip: userName,
                onTap: onProfile,
              ),
              Flexible(
                child: _AvailabilityButton(
                  isOnline: isOnline,
                  onTap: () => onToggleAvailability(!isOnline),
                ),
              ),
              _RoundAction(
                icon: Icons.power_settings_new_rounded,
                background: isOnline ? const Color(0xFF27834A) : Colors.black,
                foreground: Colors.white,
                tooltip: isOnline
                    ? 'Nonaktifkan status online'
                    : 'Aktifkan status online',
                onTap: () => onToggleAvailability(!isOnline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityButton extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onTap;

  const _AvailabilityButton({required this.isOnline, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(40),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Text(
            isOnline ? 'Online  >' : 'Offline  >',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  isOnline ? const Color(0xFF27834A) : const Color(0xFF5D5555),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardMapControls extends StatelessWidget {
  final LatLng center;
  final LatLng? technicianPoint;
  final MapController mapController;

  const _DashboardMapControls({
    required this.center,
    required this.technicianPoint,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 18,
      bottom: 246,
      child: Column(
        children: [
          _MapControl(
            icon: Icons.add,
            tooltip: 'Perbesar',
            onTap: () => mapController.move(
              center,
              mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 8),
          _MapControl(
            icon: Icons.remove,
            tooltip: 'Perkecil',
            onTap: () => mapController.move(
              center,
              mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: 8),
          _MapControl(
            icon: Icons.my_location_rounded,
            tooltip: 'Lokasi teknisi',
            onTap: technicianPoint == null
                ? () {}
                : () => mapController.move(technicianPoint!, 15),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundAction({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 54,
            height: 54,
            child: Icon(icon, color: foreground, size: 28),
          ),
        ),
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.darkText),
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  final String userName;
  final OrderModel? order;
  final LatLng? customerPoint;
  final int orderCount;
  final bool loading;
  final String? error;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenActiveOrder;
  final VoidCallback onShowRoute;

  const _OrderPanel({
    required this.userName,
    required this.order,
    required this.customerPoint,
    required this.orderCount,
    required this.loading,
    required this.error,
    required this.onOpenOrders,
    required this.onOpenActiveOrder,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    final customerName = order?.customer?.name ?? 'Pelanggan';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          elevation: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
                child: _OrderPanelHeader(
                  customerName: customerName,
                  userName: userName,
                  customerPoint: customerPoint,
                  order: order,
                  error: error,
                  onOpenActiveOrder: onOpenActiveOrder,
                  onShowRoute: onShowRoute,
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8EAF0)),
              _PanelAction(
                title: 'Pesanan Masuk ($orderCount)',
                onTap: onOpenOrders,
                bottomRadius: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderPanelHeader extends StatelessWidget {
  final String customerName;
  final String userName;
  final LatLng? customerPoint;
  final OrderModel? order;
  final String? error;
  final VoidCallback onOpenActiveOrder;
  final VoidCallback onShowRoute;

  const _OrderPanelHeader({
    required this.customerName,
    required this.userName,
    required this.customerPoint,
    required this.order,
    required this.error,
    required this.onOpenActiveOrder,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = error != null
        ? 'Koneksi bermasalah · tekan Pesanan Masuk untuk mencoba lagi'
        : order == null
            ? 'Halo, $userName'
            : customerPoint == null
                ? 'Koordinat pelanggan belum tersedia'
                : 'Lokasi pelanggan ditandai di peta';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onOpenActiveOrder,
                child: const Text(
                  'Pesanan Berlangsung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: customerPoint == null ? null : onShowRoute,
              icon: const Icon(Icons.near_me_rounded, size: 18),
              label: const Text('Lokasi'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.paleBackground,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFEADDFF),
              child: Icon(Icons.person_rounded, color: AppColors.purpleText),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Color(0xFF777B87), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PanelAction extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool bottomRadius;

  const _PanelAction({
    required this.title,
    required this.onTap,
    this.bottomRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: bottomRadius
          ? const BorderRadius.vertical(bottom: Radius.circular(24))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 18, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 28, color: AppColors.darkText),
          ],
        ),
      ),
    );
  }
}

class _DashboardNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DashboardNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFFB5B5B5),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.work_rounded), label: 'Pendapatan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded), label: 'Pesan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Profil'),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapPin({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 3),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ],
    );
  }
}
