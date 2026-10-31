// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/constants/app_spacing.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  const CustomerOrderTrackingScreen({super.key});

  @override
  State<CustomerOrderTrackingScreen> createState() =>
      _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState
    extends State<CustomerOrderTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _pollingTimer;

  bool _isLoading = true;
  OrderModel? _realOrder;
  String? _errorMessage;
  bool _initialized = false;
  final _repository = OrderRepository();

  LatLng? get _customerPoint {
    final order = _realOrder;
    final lat = order?.latitude;
    final lng = order?.longitude;
    return lat != null && lng != null ? LatLng(lat, lng) : null;
  }

  LatLng? get _technicianPoint {
    final profile = _realOrder?.technician?.technicianProfile;
    final lat = profile?.currentLatitude;
    final lng = profile?.currentLongitude;
    return lat != null && lng != null ? LatLng(lat, lng) : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initRealTracking();
  }

  void _initRealTracking() async {
    if (_initialized) return;
    _initialized = true;
    final rawArgs = RouteArgs.of<OrderModel>(context) ?? RouteArgs.map(context);
    if (rawArgs is OrderModel) {
      _realOrder = rawArgs;
      _isLoading = false;
      _fetchRealOrderDetails(rawArgs.id);
    } else if (rawArgs is Map<String, dynamic> && rawArgs['id'] != null) {
      final id = int.tryParse(rawArgs['id'].toString()) ?? 1;
      _fetchRealOrderDetails(id);
    } else {
      try {
        final rows = await _repository.getOrders();
        final orders = rows
            .map((r) => OrderModel.fromJson(Map<String, dynamic>.from(r)))
            .toList();
        if (orders.isNotEmpty && mounted) {
          setState(() {
            _realOrder = orders.first;
            _isLoading = false;
          });
          _fetchRealOrderDetails(orders.first.id);
        }
      } catch (_) {}
      if (mounted) setState(() => _isLoading = false);
    }

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final current = _realOrder;
      if (current != null && mounted) {
        _fetchRealOrderDetails(current.id, isBackground: true);
      }
    });
  }

  Future<void> _fetchRealOrderDetails(int orderId,
      {bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final res = await _repository.getOrder(orderId);
      if (res is Map && res['success'] == true && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          _realOrder = OrderModel.fromJson(
              Map<String, dynamic>.from(res['data'] as Map));
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
    final bool hasTechnician =
        technician != null && (technician.name.isNotEmpty);

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
        title: Text(order != null
            ? 'Lacak Pesanan ${order.orderNumber}'
            : 'Lacak Pesanan'),
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : order == null
              ? Center(
                  child: Padding(
                    padding: AppSpacing.allXxl,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            _errorMessage != null
                                ? Icons.error_outline_rounded
                                : Icons.inbox_outlined,
                            size: 48,
                            color: _errorMessage != null
                                ? AppColors.danger
                                : AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage ?? 'Tidak ada data pesanan aktif untuk dilacak.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () {
                              _initialized = false;
                              _initRealTracking();
                            },
                            child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _fetchRealOrderDetails(order.id);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.allLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Zoomable OpenStreetMap Live Map ────────────────────────
                        _buildOpenStreetMapCard(hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Status Banner ──────────────────────────────────────────
                        _buildStatusBanner(
                            activeStep: activeStep,
                            hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Active Servicing Indicator Card (In Progress) ──────────
                        if (statusStr == 'in_progress') ...[
                          Container(
                            padding: AppSpacing.allLg,
                            decoration: BoxDecoration(
                              color: AppColors.paleOrange,
                              borderRadius: AppRadius.large,
                              border: Border.all(
                                  color: AppColors.primary, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.handyman_rounded,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Teknisi Sedang Mengerjakan Servis',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary)),
                                      const SizedBox(height: 2),
                                      Text(
                                          'Kompor gas Anda sedang dalam proses perbaikan di lokasi.',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Timeline ───────────────────────────────────────────────
                        _buildTimeline(
                            activeStep: activeStep,
                            hasTechnician: hasTechnician),
                        const SizedBox(height: 16),

                        // ── Technician Card ────────────────────────────────────────
                        _buildTechnicianCard(
                            technicianName: technician?.name,
                            technicianPhone: technician?.phone,
                            hasTechnician: hasTechnician,
                            context: context),
                        if (!['completed', 'cancelled'].contains(statusStr)) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _cancelOrder(order.id),
                              child: const Text('Batalkan pesanan'),
                            ),
                          ),
                        ],

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
                              icon: const Icon(Icons.star_rounded,
                                  color: Colors.amber),
                              label: Text(
                                'Konfirmasi Selesai & Beri Ulasan Teknisi',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.extraSmall),
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

  Future<void> _cancelOrder(int orderId) async {
    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Batalkan pesanan?',
      message: 'Pesanan akan ditandai sebagai dibatalkan.',
      confirmLabel: 'Batalkan pesanan',
    );
    if (!confirmed || !mounted) return;
    try {
      await _repository.updateStatus(orderId, {'status': 'cancelled'});
      await _fetchRealOrderDetails(orderId);
      if (mounted) AppFeedback.success(context, 'Pesanan berhasil dibatalkan.');
    } catch (error) {
      if (mounted) AppFeedback.error(context, 'Gagal membatalkan pesanan: $error');
    }
  }

  Widget _buildOpenStreetMapCard({required bool hasTechnician}) {
    final customerPoint = _customerPoint;
    final technicianPoint = _technicianPoint;
    final center = customerPoint ?? technicianPoint;
    if (center == null) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.trackingSoft,
          borderRadius: AppRadius.large,
        ),
        child: const Text('Lokasi pesanan belum tersedia'),
      );
    }
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.large,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
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
                if (technicianPoint != null && customerPoint != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [technicianPoint, customerPoint],
                        strokeWidth: 4,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (technicianPoint != null)
                      Marker(
                        point: technicianPoint,
                        width: 48,
                        height: 48,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: Icon(Icons.handyman_rounded,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    if (customerPoint != null)
                      Marker(
                        point: customerPoint,
                        width: 48,
                        height: 48,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                          child: Icon(Icons.person_rounded,
                              color: Colors.white, size: 24),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      technicianPoint != null
                          ? Icons.radar_rounded
                          : Icons.search_rounded,
                      color: technicianPoint != null
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      technicianPoint != null
                          ? 'GPS Live Tracking (Zoom Enabled)'
                          : hasTechnician
                              ? 'Lokasi Teknisi Menunggu Update GPS'
                              : 'Mencari Teknisi Terdekat...',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
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
                      try {
                        final zoom = _mapController.camera.zoom;
                        _mapController.move(
                            _mapController.camera.center, zoom + 1);
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    heroTag: 'zoomOut',
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      try {
                        final zoom = _mapController.camera.zoom;
                        _mapController.move(
                            _mapController.camera.center, zoom - 1);
                      } catch (_) {}
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

  Widget _buildStatusBanner(
      {required int activeStep, required bool hasTechnician}) {
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
      padding: AppSpacing.all18,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasTechnician
              ? [AppColors.primary, AppColors.primaryAccent]
              : [AppColors.trackingOrange, AppColors.trackingOrangeLight],
        ),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[activeStep.clamp(0, titles.length - 1)],
            style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(subtitles[activeStep.clamp(0, subtitles.length - 1)],
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTimeline(
      {required int activeStep, required bool hasTechnician}) {
    final steps = [
      'Mencari Teknisi',
      'Pesanan Diterima',
      'Teknisi Berangkat',
      'Sedang Mengerjakan Servis',
      'Pembayaran Diterima',
      'Servis Selesai',
    ];

    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Pesanan Riil',
              style:
                  AppTextStyles.bodyBold),
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
                        color:
                            isDone ? AppColors.primary : AppColors.chipInactive,
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
                        color: idx < activeStep
                            ? AppColors.primary
                            : AppColors.chipInactive,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
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
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppColors.paleOrange,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.trackingBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.trackingSoft,
              ),
              child: const Icon(Icons.search_rounded,
                  size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mencari Teknisi Terdekat...',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pesanan Anda sedang dihubungkan ke teknisi KlikKompor.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.trackingPale,
            ),
            child: const Icon(Icons.person_rounded,
                size: 30, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technicianName ?? 'Teknisi Resmi',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Teknisi Resmi KlikKompor',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary),
            onPressed: () {
              if (_realOrder != null) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.customerChatDetail,
                  arguments: {
                    'orderId': _realOrder!.id,
                    'technicianName': technicianName ?? 'Teknisi',
                  },
                );
              } else {
                Navigator.pushNamed(context, AppRoutes.customerChat);
              }
            },
            tooltip: 'Chat Teknisi',
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Menghubungi ${technicianPhone ?? "teknisi"}...')),
              );
            },
            tooltip: 'Telepon Teknisi',
          ),
        ],
      ),
    );
  }
}
