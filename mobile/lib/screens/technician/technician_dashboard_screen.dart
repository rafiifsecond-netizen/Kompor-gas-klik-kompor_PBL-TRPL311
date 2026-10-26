import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import 'technician_chat_screen.dart';
import 'technician_income_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<OrderModel>> _loadOrders() async {
    final response = await ApiClient().get(ApiEndpoints.orders);
    if (response is! Map) return [];
    final page = response['data'];
    final rows = page is Map ? page['data'] : page;
    if (rows is! List) return [];
    return rows
        .whereType<Map>()
        .map((row) => OrderModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final profile = user?.technicianProfile;
    final technicianPoint = _validPoint(
      profile?.currentLatitude,
      profile?.currentLongitude,
    );

    return Scaffold(
      body: _currentIndex == 1
          ? const TechnicianIncomeScreen()
          : _currentIndex == 2
              ? TechnicianChatInboxScreen(
                  onBack: () => setState(() => _currentIndex = 0),
                )
              : FutureBuilder<List<OrderModel>>(
                  future: _ordersFuture,
                  builder: (context, snapshot) {
                    final orders = snapshot.data ?? const <OrderModel>[];
                    final selectedOrder = _selectOrder(orders);
                    final customerPoint = _validPoint(
                      selectedOrder?.latitude,
                      selectedOrder?.longitude,
                    );
                    final center = _mapCenter(technicianPoint, customerPoint);
                    final mapPoints = [
                      if (technicianPoint != null) technicianPoint,
                      if (customerPoint != null) customerPoint,
                    ];
                    final incomingOrders = orders
                        .where((order) => order.status == 'pending')
                        .length;
                    final mapTarget = [
                      technicianPoint?.latitude,
                      technicianPoint?.longitude,
                      customerPoint?.latitude,
                      customerPoint?.longitude,
                    ].join(':');

                    if (_lastMapTarget != mapTarget) {
                      _lastMapTarget = mapTarget;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || mapPoints.isEmpty) return;
                        if (mapPoints.length == 2) {
                          _mapController.fitCamera(
                            CameraFit.bounds(
                              bounds: LatLngBounds.fromPoints(mapPoints),
                              padding:
                                  const EdgeInsets.fromLTRB(72, 100, 72, 300),
                            ),
                          );
                        } else {
                          _mapController.move(mapPoints.first, 14);
                        }
                      });
                    }

                    return SizedBox.expand(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                  initialCenter: center, initialZoom: 13),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.klikkompor.mobile',
                                ),
                                if (technicianPoint != null &&
                                    customerPoint != null)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: [
                                          technicianPoint,
                                          customerPoint
                                        ],
                                        strokeWidth: 4,
                                        color: const Color(0xFFFA7D10),
                                      ),
                                    ],
                                  ),
                                MarkerLayer(
                                  markers: [
                                    if (technicianPoint != null)
                                      Marker(
                                        point: technicianPoint,
                                        width: 58,
                                        height: 72,
                                        child: const _MapPin(
                                          icon: Icons.handyman_rounded,
                                          color: Color(0xFFFA7D10),
                                          label: 'Teknisi',
                                        ),
                                      ),
                                    if (customerPoint != null)
                                      Marker(
                                        point: customerPoint,
                                        width: 58,
                                        height: 72,
                                        child: const _MapPin(
                                          icon: Icons.person_rounded,
                                          color: Color(0xFF2563EB),
                                          label: 'Pelanggan',
                                        ),
                                      ),
                                  ],
                                ),
                                const RichAttributionWidget(
                                  attributions: [
                                    TextSourceAttribution(
                                        'OpenStreetMap contributors'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 16, 18, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _roundAction(
                                      icon: Icons.person_outline_rounded,
                                      background: const Color(0xFFEADDFF),
                                      foreground: const Color(0xFF4F378A),
                                      tooltip: user?.name ?? 'Profil teknisi',
                                      onTap: () {},
                                    ),
                                    Flexible(
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        elevation: 3,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          onTap: () => setState(
                                              () => _isOnline = !_isOnline),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                            child: Text(
                                              _isOnline
                                                  ? 'Online  >'
                                                  : 'Offline  >',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: _isOnline
                                                    ? const Color(0xFF27834A)
                                                    : const Color(0xFF5D5555),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _roundAction(
                                      icon: Icons.power_settings_new_rounded,
                                      background: _isOnline
                                          ? const Color(0xFF27834A)
                                          : Colors.black,
                                      foreground: Colors.white,
                                      tooltip: _isOnline
                                          ? 'Nonaktifkan status online'
                                          : 'Aktifkan status online',
                                      onTap: () => setState(
                                          () => _isOnline = !_isOnline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 18,
                            bottom: 246,
                            child: Column(
                              children: [
                                _mapControl(Icons.add, 'Perbesar', () {
                                  _mapController.move(
                                      center, _mapController.camera.zoom + 1);
                                }),
                                const SizedBox(height: 8),
                                _mapControl(Icons.remove, 'Perkecil', () {
                                  _mapController.move(
                                      center, _mapController.camera.zoom - 1);
                                }),
                                const SizedBox(height: 8),
                                _mapControl(
                                    Icons.my_location_rounded, 'Lokasi teknisi',
                                    () {
                                  if (technicianPoint != null) {
                                    _mapController.move(technicianPoint, 15);
                                  }
                                }),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: _orderPanel(
                              userName: user?.name ?? 'Teknisi',
                              order: selectedOrder,
                              customerPoint: customerPoint,
                              orderCount: incomingOrders,
                              loading: snapshot.connectionState ==
                                  ConnectionState.waiting,
                              error: snapshot.hasError
                                  ? snapshot.error.toString()
                                  : null,
                              onOpenActiveOrder: () {
                                if (selectedOrder == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Belum ada pesanan yang sedang berlangsung.'),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.technicianOrderDetail,
                                  arguments: {
                                    'orderId': selectedOrder.id,
                                    'orderNumber': selectedOrder.orderNumber,
                                    'customerName':
                                        selectedOrder.customer?.name ??
                                            'Pelanggan',
                                    'serviceName':
                                        selectedOrder.items.isNotEmpty
                                            ? selectedOrder
                                                    .items.first.serviceName ??
                                                selectedOrder.items.first
                                                    .service?.name ??
                                                'Servis Kompor Gas'
                                            : 'Servis Kompor Gas',
                                    'latitude': selectedOrder.latitude,
                                    'longitude': selectedOrder.longitude,
                                    'technician_latitude':
                                        technicianPoint?.latitude,
                                    'technician_longitude':
                                        technicianPoint?.longitude,
                                    'paymentMethod':
                                        selectedOrder.paymentMethod,
                                    'address': selectedOrder.addressText ??
                                        selectedOrder.address?.addressLine ??
                                        'Lokasi pelanggan belum tersedia',
                                    'amount': selectedOrder.totalAmount,
                                    'status': selectedOrder.status,
                                  },
                                ).then((_) {
                                  if (mounted) {
                                    setState(
                                        () => _ordersFuture = _loadOrders());
                                  }
                                });
                              },
                              onOpenOrders: () => Navigator.pushNamed(
                                context,
                                AppRoutes.technicianIncomingOrders,
                              ).then((_) {
                                if (mounted) {
                                  setState(() => _ordersFuture = _loadOrders());
                                }
                              }),
                              onShowRoute: () {
                                if (mapPoints.length == 2) {
                                  final bounds =
                                      LatLngBounds.fromPoints(mapPoints);
                                  _mapController.fitCamera(
                                    CameraFit.bounds(
                                      bounds: bounds,
                                      padding: const EdgeInsets.all(90),
                                    ),
                                  );
                                } else if (technicianPoint != null) {
                                  _mapController.move(technicianPoint, 15);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            setState(() => _currentIndex = 1);
          } else if (index == 2) {
            setState(() => _currentIndex = 2);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.technicianServiceHistory);
          } else {
            setState(() => _currentIndex = 0);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFA7D10),
        unselectedItemColor: const Color(0xFFB5B5B5),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_rounded), label: 'Pendapatan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded), label: 'Pesan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_rounded), label: 'Performa'),
        ],
      ),
    );
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
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
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

  Widget _roundAction({
    required IconData icon,
    required Color background,
    required Color foreground,
    required String tooltip,
    required VoidCallback onTap,
  }) {
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

  Widget _mapControl(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF344054)),
      ),
    );
  }

  Widget _orderPanel({
    required String userName,
    required OrderModel? order,
    required LatLng? customerPoint,
    required int orderCount,
    required bool loading,
    required String? error,
    required VoidCallback onOpenOrders,
    required VoidCallback onOpenActiveOrder,
    required VoidCallback onShowRoute,
  }) {
    final customerName = order?.customer?.name ?? 'Pelanggan';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Column(
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
                            color: Color(0xFF303445),
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: customerPoint == null ? null : onShowRoute,
                      icon: const Icon(Icons.near_me_rounded, size: 18),
                      label: const Text('Lokasi'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFA7D10),
                        backgroundColor: const Color(0xFFF2F4FA),
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
                      child:
                          Icon(Icons.person_rounded, color: Color(0xFF4F378A)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            error != null
                                ? 'Koneksi bermasalah · tekan Pesanan Masuk untuk mencoba lagi'
                                : order == null
                                    ? 'Halo, $userName'
                                    : customerPoint == null
                                        ? 'Koordinat pelanggan belum tersedia'
                                        : 'Lokasi pelanggan ditandai di peta',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777B87),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8EAF0)),
          _panelAction(
            title: 'Pesanan Masuk ($orderCount)',
            onTap: onOpenOrders,
            bottomRadius: true,
          ),
        ],
      ),
    );
  }

  Widget _panelAction({
    required String title,
    required VoidCallback? onTap,
    bool bottomRadius = false,
  }) {
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
                  color: Color(0xFF303445),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 28, color: Color(0xFF303445)),
          ],
        ),
      ),
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
