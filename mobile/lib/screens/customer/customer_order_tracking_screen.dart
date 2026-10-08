import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerOrderTrackingScreen extends StatefulWidget {
  const CustomerOrderTrackingScreen({super.key});

  @override
  State<CustomerOrderTrackingScreen> createState() => _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState extends State<CustomerOrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 2; // 0: Dibuat, 1: Bayar, 2: Berangkat, 3: Tiba, 4: Selesai
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final technician = args['technician'] as Map<String, dynamic>? ?? {'name': 'Ahmad Subagyo', 'phone': '081234567890'};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lacak Pesanan (Live Tracking)'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Simulated Gojek-style Live Map / Radar View ──
            _buildLiveMapCard(),
            const SizedBox(height: 16),

            // ── Status Banner ──
            _buildStatusBanner(),
            const SizedBox(height: 16),

            // ── Interactive Timeline ──
            _buildTimeline(),
            const SizedBox(height: 16),

            // ── Technician Card ──
            _buildTechnicianCard(technician, context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2229),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated Grid / Map Lines
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          // Pulsing Radar Effect (Gojek style)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 100 + (_pulseController.value * 80),
                height: 100 + (_pulseController.value * 80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                ),
              );
            },
          ),
          // Technician Pin
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bike_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Teknisi (1.2 km)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 36),
            ],
          ),
          // Floating Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, color: Colors.greenAccent, size: 14),
                  const SizedBox(width: 6),
                  Text('GPS Live Tracking', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final titles = ['Pesanan Dibuat', 'Pembayaran Diterima', 'Teknisi Sedang Berangkat', 'Teknisi Tiba di Lokasi', 'Servis Selesai'];
    final subtitles = [
      'Menunggu konfirmasi teknisi terdekat.',
      'Pembayaran Anda telah terverifikasi.',
      'Teknisi meluncur ke alamat Anda (Est: 15-20 min).',
      'Teknisi siap melakukan pemeriksaan kompor.',
      'Terima kasih telah menggunakan layanan KlikKompor!'
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(titles[_currentStep], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              // Simulation stepper button for testing
              GestureDetector(
                onTap: () => setState(() => _currentStep = (_currentStep + 1) % 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text('Next Step 🔄', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitles[_currentStep], style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      'Pesanan Dibuat',
      'Pembayaran Diterima',
      'Teknisi Berangkat',
      'Teknisi Tiba',
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
          Text('Status Pesanan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final label = e.value;
            final isDone = idx <= _currentStep;
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
                        color: idx < _currentStep ? AppColors.primary : AppColors.chipInactive,
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

  Widget _buildTechnicianCard(Map<String, dynamic> technician, BuildContext context) {
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
                  technician['name'] as String? ?? 'Ahmad Subagyo',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Teknisi Profesional KlikKompor', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Chat Button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.customerChat),
            tooltip: 'Chat Teknisi',
          ),
          // Call Button
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menghubungi teknisi...')),
              );
            },
            tooltip: 'Telepon Teknisi',
          ),
        ],
      ),
    );
  }
}

// Background Grid Painter for simulated map
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
