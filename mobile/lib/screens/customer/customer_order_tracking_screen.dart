import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../models/order_model.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  const CustomerOrderTrackingScreen({super.key});

  @override
  State<CustomerOrderTrackingScreen> createState() => _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState extends State<CustomerOrderTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _pollingTimer;

  bool _isLoading = true;
  OrderModel? _realOrder;
  String? _errorMessage;

  final LatLng _customerPoint = const LatLng(1.1292, 104.0417);
  final LatLng _technicianPoint = const LatLng(1.1350, 104.0500);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initRealTracking();
  }

  void _initRealTracking() {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs is OrderModel) {
      _realOrder = rawArgs;
      _isLoading = false;
      _fetchRealOrderDetails(rawArgs.id);
    } else if (rawArgs is Map<String, dynamic> && rawArgs['id'] != null) {
      final id = int.tryParse(rawArgs['id'].toString()) ?? 1;
      _fetchRealOrderDetails(id);
    } else {
      setState(() => _isLoading = false);
    }

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_realOrder != null && mounted) {
        _fetchRealOrderDetails(_realOrder!.id, isBackground: true);
      }
    });
  }

  Future<void> _fetchRealOrderDetails(int orderId, {bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final res = await ApiClient().get(ApiEndpoints.orderDetail(orderId));
      if (res is Map && res['success'] == true && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          _realOrder = OrderModel.fromJson(Map<String, dynamic>.from(res['data'] as Map));
          _isLoading = false;
        });
      } else {
        if (!isBackground && mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (!isBackground && mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _realOrder;
    final String statusStr = order?.status ?? 'pending';
    final technician = order?.technician;
    final bool hasTechnician = technician != null && (technician.name.isNotEmpty);

    // Sequence:
    // 0: Mencari Teknisi
    // 1: Pesanan Diterima
    // 2: Teknisi Berangkat (on_the_way)
    // 3: Teknisi Mengerjakan Servis (in_progress)
    // 4: Pembayaran Diterima / Selesai (completed)
    final int activeStep = switch (statusStr) {
      'pending' => hasTechnician ? 1 : 0,
      'accepted' => 1,
      'on_the_way' => 2,
      'in_progress' => 3,
      'completed' => 4,
      _ => 0,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order != null ? 'Lacak Pesanan ${order.orderNumber}' : 'Lacak Pesanan'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (order != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _fetchRealOrderDetails(order.id),
              tooltip: 'Perbarui Status',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null && order == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => _initRealTracking(), child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (order != null) await _fetchRealOrderDetails(order.id);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Zoomable OpenStreetMap Live Map ────────────────────────
                        _buildOpenStreetMapCard(hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Status Banner ──────────────────────────────────────────
                        _buildStatusBanner(activeStep: activeStep, hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Active Servicing Indicator Card (In Progress) ──────────
                        if (statusStr == 'in_progress') ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFF7A00), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(color: Color(0xFFFF7A00), shape: BoxShape.circle),
                                  child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Teknisi Sedang Mengerjakan Servis', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFF7A00))),
                                      const SizedBox(height: 2),
                                      Text('Kompor gas Anda sedang dalam proses perbaikan di lokasi.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Timeline ───────────────────────────────────────────────
                        _buildTimeline(activeStep: activeStep, hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Technician Card ────────────────────────────────────────
                        _buildTechnicianCard(technicianName: technician?.name, technicianPhone: technician?.phone, hasTechnician: hasTechnician, context: context),

                        // ── Button Konfirmasi Selesai & Ulasan ────────────────────
                        if (activeStep >= 3 || statusStr == 'completed') ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.customerReview,
                                  arguments: order,
                                );
                              },
                              icon: const Icon(Icons.star_rounded, color: Colors.amber),
                              label: Text(
                                'Konfirmasi Selesai & Beri Ulasan Teknisi',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7A00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOpenStreetMapCard({required bool hasTechnician}) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _customerPoint,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.klikkompor.mobile',
                ),
                if (hasTechnician)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_technicianPoint, _customerPoint],
                        strokeWidth: 4,
                        color: const Color(0xFFFF7A00),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (hasTechnician)
                      Marker(
                        point: _technicianPoint,
                        width: 48,
                        height: 48,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(color: Color(0xFFFF7A00), shape: BoxShape.circle),
                          child: Icon(Icons.handyman_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    Marker(
                      point: _customerPoint,
                      width: 48,
                      height: 48,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasTechnician ? Icons.radar_rounded : Icons.search_rounded,
                      color: hasTechnician ? Colors.greenAccent : Colors.orangeAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasTechnician ? 'GPS Live Tracking (Zoom Enabled)' : 'Mencari Teknisi Terdekat...',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomIn',
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, zoom + 1);
                    },
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    heroTag: 'zoomOut',
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, zoom - 1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner({required int activeStep, required bool hasTechnician}) {
    final titles = [
      'Mencari Teknisi Terdekat...',
      'Pesanan Diterima Teknisi',
      'Teknisi Sedang Berangkat',
      'Teknisi Sedang Mengerjakan Servis',
      'Pembayaran Diterima (Lunas)',
      'Servis Selesai'
    ];
    final subtitles = [
      'Sistem sedang menghubungkan pesanan Anda ke teknisi terdekat.',
      'Teknisi telah menerima dan mengonfirmasi pesanan Anda.',
      'Teknisi meluncur ke alamat Anda (Est: 15-20 min).',
      'Teknisi sedang melakukan perbaikan / servis kompor gas di lokasi Anda.',
      'Pembayaran Anda telah diterima dan dikonfirmasi lunas oleh teknisi.',
      'Terima kasih telah menggunakan layanan KlikKompor!',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasTechnician
              ? [AppColors.primary, AppColors.primaryAccent]
              : [const Color(0xFFEA580C), const Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[activeStep.clamp(0, titles.length - 1)],
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(subtitles[activeStep.clamp(0, subtitles.length - 1)], style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTimeline({required int activeStep, required bool hasTechnician}) {
    final steps = [
      'Mencari Teknisi',
      'Pesanan Diterima',
      'Teknisi Berangkat',
      'Sedang Mengerjakan Servis',
      'Pembayaran Diterima',
      'Servis Selesai',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Pesanan Riil', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final label = e.value;
            final isDone = idx <= activeStep;
            final isLast = idx == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.primary : AppColors.chipInactive,
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : Icons.circle_outlined,
                        size: 14,
                        color: isDone ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: idx < activeStep ? AppColors.primary : AppColors.chipInactive,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
                      color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard({
    required String? technicianName,
    required String? technicianPhone,
    required bool hasTechnician,
    required BuildContext context,
  }) {
    if (!hasTechnician) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD8A8)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFEAD5),
              ),
              child: const Icon(Icons.search_rounded, size: 28, color: Color(0xFFFF7A00)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mencari Teknisi Terdekat...',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFF7A00)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pesanan Anda sedang dihubungkan ke teknisi KlikKompor.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFEFE2),
            ),
            child: const Icon(Icons.person_rounded, size: 30, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technicianName ?? 'Teknisi Resmi',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Teknisi Resmi KlikKompor', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.customerChat),
            tooltip: 'Chat Teknisi',
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menghubungi ${technicianPhone ?? "teknisi"}...')),
              );
            },
            tooltip: 'Telepon Teknisi',
          ),
        ],
      ),
    );
  }
}
