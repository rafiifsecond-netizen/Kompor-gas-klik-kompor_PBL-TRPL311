import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL DATA LAYANAN
// ─────────────────────────────────────────────────────────────────────────────
class ServiceDetailArgs {
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final String estimasi;
  final String hargaMulai;
  final String? bannerAsset;

  const ServiceDetailArgs({
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.estimasi,
    required this.hargaMulai,
    this.bannerAsset,
  });
}

const _grey = Color(0xFF5D5555);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CustomerServiceDetailScreen extends StatelessWidget {
  const CustomerServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    final ServiceDetailArgs args;

    if (raw is ServiceDetailArgs) {
      args = raw;
    } else {
      final m = raw as Map<String, dynamic>? ?? {};
      args = ServiceDetailArgs(
        name: m['name'] as String? ?? 'Service Kompor Gas',
        description: m['description'] as String? ?? '',
        rating: (m['rating'] as num?)?.toDouble() ?? 4.8,
        reviewCount: m['reviewCount'] as int? ?? 9999,
        estimasi: m['estimasi'] as String? ?? '30 - 60 menit',
        hargaMulai: m['hargaMulai'] as String? ?? 'Rp.75.000',
        bannerAsset: m['bannerAsset'] as String?,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),
                  _Banner(assetPath: args.bannerAsset),

                  // ── Konten ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          args.name,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFA500),
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              args.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '(${_formatNumber(args.reviewCount)} ulasan)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Deskripsi
                        Text(
                          args.description.isNotEmpty
                              ? args.description
                              : 'Teknisi berpengalaman kami akan datang ke lokasi Anda untuk menangani masalah kompor gas dengan cepat, aman, dan profesional.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _grey,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 20),

                        // Estimasi Pengerjaan
                        _InfoRow(
                          icon: Icons.access_time_rounded,
                          label: 'Estimasi Pengerjaan',
                          value: args.estimasi,
                        ),

                        const SizedBox(height: 16),

                        // Harga Mulai
                        _InfoRow(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Harga Mulai',
                          value: args.hargaMulai,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Pesan Teknisi ─────────────────────────────
          _PesanButton(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.customerBookingSummary,
              arguments: {
                'name': args.name,
                'hargaMulai': args.hargaMulai,
                'estimasi': args.estimasi,
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 28,
                color: Colors.black,
              ),
            ),
            Text(
              'Detail Layanan',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _Banner extends StatelessWidget {
  final String? assetPath;
  const _Banner({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: assetPath != null
              ? Image.asset(assetPath!, fit: BoxFit.cover)
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF090B27), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.build_circle_rounded,
                      size: 64,
                      color: Color(0xFFFF7A00),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: _grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _grey,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _grey,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOMBOL PESAN TEKNISI
// ─────────────────────────────────────────────────────────────────────────────
class _PesanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PesanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: Text(
              'Pesan Teknisi',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
