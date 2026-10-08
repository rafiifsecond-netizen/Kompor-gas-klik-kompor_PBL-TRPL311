import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_fade_slide.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'customer_service_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KONFIGURASI BANNER CAROUSEL
// Tambah / hapus item sesuai kebutuhan.
// Isi assetPath dengan 'assets/images/nama_file.jpg' untuk pakai foto sendiri.
// Biarkan null → tampil gradient sebagai placeholder.
// ─────────────────────────────────────────────────────────────────────────────
const List<_BannerItem> _carouselItems = [
  _BannerItem(
    assetPath: null, // → 'assets/images/banner1.jpg'
    title: 'Promo Servis Kompor',
    subtitle: 'Diskon 20% untuk servis pertama Anda!',
    gradient: [Color(0xFFFA7D10), Color(0xFFE85D04)],
  ),
  _BannerItem(
    assetPath: null, // → 'assets/images/banner2.jpg'
    title: 'Teknisi Berpengalaman',
    subtitle: 'Garansi pengerjaan hingga 30 hari',
    gradient: [Color(0xFF1A1A2E), Color(0xFF2D1515)],
  ),
  _BannerItem(
    assetPath: null, // → 'assets/images/banner3.jpg'
    title: 'Cek Kebocoran Gas',
    subtitle: 'Keamanan rumah Anda prioritas kami',
    gradient: [Color(0xFF0D3B2E), Color(0xFF0A2E20)],
  ),
];

// Banner bawah (single, tidak carousel)
// Ganti null → 'assets/images/banner_bawah.jpg'
const String? _bannerBottomAsset = null;

// ─── Warna & konstanta lokal ──────────────────────────────────────────────────
const _kGrey = Color(0xFF8B8787);
const _kLabelGrey = Color(0xFF5D5555);
const _kBorderGrey = Color(0xFFE0E0E0);
const _kPad = EdgeInsets.symmetric(horizontal: 20);

// ─────────────────────────────────────────────────────────────────────────────
// MODEL BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _BannerItem {
  final String? assetPath;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _BannerItem({
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  static const int _homeIndex = 0;

  void _onNavTap(int index) {
    final route = switch (index) {
      0 => AppRoutes.customerHome,
      1 => AppRoutes.customerOrderHistory,
      2 => AppRoutes.customerChat,
      3 => AppRoutes.customerProfile,
      _ => null,
    };
    if (route != null && index != _homeIndex) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.name.split(' ').first ?? 'Pengguna';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimatedFadeSlide(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child:
                      _Header(firstName: firstName, avatarUrl: user?.avatarUrl),
                ),

                const SizedBox(height: 18),

                // Search bar
                Padding(
                  padding: _kPad,
                  child: _SearchBar(),
                ),

                const SizedBox(height: 16),

                // ── Carousel banner (auto-scroll) ──────────────
                Padding(
                  padding: _kPad,
                  child: _BannerCarousel(items: _carouselItems),
                ),

                const SizedBox(height: 24),

                // Layanan Kami
                Padding(
                  padding: _kPad,
                  child: Text(
                    'Layanan Kami',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4 ikon layanan
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _ServiceGrid(),
                ),

                const SizedBox(height: 24),

                // Banner bawah
                Padding(
                  padding: _kPad,
                  child: _PhotoBanner(
                    assetPath: _bannerBottomAsset,
                    height: 155,
                    borderRadius: 12,
                    fallbackGradient: const [
                      Color(0xFF0D0D1A),
                      Color(0xFF1A1A3E)
                    ],
                    fallbackIcon: Icons.local_fire_department_rounded,
                    fallbackLabel: 'Kompor Gas Bersih & Efisien',
                    overlayDim: 0.18,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _homeIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER CAROUSEL — auto-scroll 3 detik, swipe manual, dot indicator
// ─────────────────────────────────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  final List<_BannerItem> items;
  const _BannerCarousel({required this.items});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _ctrl;
  late int _current;
  Timer? _timer;

  // Mulai dari tengah virtual list agar bisa scroll tak terbatas ke dua arah
  static const int _virtualBase = 10000;

  @override
  void initState() {
    super.initState();
    _current = 0;
    _ctrl = PageController(initialPage: _virtualBase);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;

    return Column(
      children: [
        // Slider
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 195,
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (page) => setState(() => _current = page % count),
              itemBuilder: (_, index) {
                final item = widget.items[index % count];
                return _BannerSlide(item: item);
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Satu slide banner
class _BannerSlide extends StatelessWidget {
  final _BannerItem item;
  const _BannerSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: gambar atau gradient
        if (item.assetPath != null)
          Image.asset(item.assetPath!, fit: BoxFit.cover)
        else
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

        // Decorative circles (hanya pada fallback)
        if (item.assetPath == null) ...[
          Positioned(
            right: -20,
            top: -20,
            child: _circle(120, 0.06),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: _circle(80, 0.04),
          ),
        ],

        // Gradasi bawah agar teks terbaca
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x99000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Teks
        Positioned(
          left: 18,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String firstName;
  final String? avatarUrl;
  const _Header({required this.firstName, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Butuh service kompor gas?\nKami siap membantu!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _kGrey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.customerNotification),
          icon: const Icon(Icons.notifications_outlined, size: 26),
          color: Colors.black87,
          tooltip: 'Notifikasi',
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.customerProfile),
          child: _ProfileAvatar(avatarUrl: avatarUrl),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.pushNamed(context, AppRoutes.customerCatalog),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorderGrey),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 10),
              Text(
                'Cari layanan...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE AVATAR
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  const _ProfileAvatar({required this.avatarUrl});

  static const _ph =
      Icon(Icons.person_rounded, size: 28, color: Color(0xFF4F378A));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEADDFF),
        border: Border.all(color: _kBorderGrey, width: 2),
      ),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? Image.network(avatarUrl!,
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph)
          : _ph,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE GRID
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  static final _defs = <_ServiceDef>[
    _ServiceDef(
      label: 'Service\nKompor',
      icon: const _WhiteIcon(Icons.settings_rounded),
      args: const ServiceDetailArgs(
        name: 'Service Kompor Gas',
        description:
            'Perbaikan berbagai masalah pada kompor gas, seperti api kecil, kompor tidak menyala, hingga kebocoran gas.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp.75.000',
      ),
    ),
    _ServiceDef(
      label: 'Instalasi\nRegulator',
      icon: const _RegulatorIcon(),
      args: const ServiceDetailArgs(
        name: 'Instalasi Regulator',
        description:
            'Layanan pemasangan regulator gas yang cepat, aman, dan dikerjakan oleh teknisi profesional. Memastikan sambungan terpasang dengan benar sehingga meminimalkan risiko kebocoran.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp.75.000',
      ),
    ),
    _ServiceDef(
      label: 'Cek\nKebocoran',
      icon: const _WhiteIcon(Icons.propane_tank_rounded),
      args: const ServiceDetailArgs(
        name: 'Cek Kebocoran Gas',
        description:
            'Deteksi kebocoran dengan cepat dan akurat. Teknisi kami akan memeriksa seluruh sambungan gas untuk mencegah risiko kebakaran dan kecelakaan.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp.75.000',
      ),
    ),
    _ServiceDef(
      label: 'Lainnya',
      icon: const _WhiteIcon(Icons.more_horiz_rounded),
      args: const ServiceDetailArgs(
        name: 'Layanan Lainnya',
        description:
            'Berbagai layanan perawatan dan perbaikan kompor gas lainnya oleh teknisi profesional berpengalaman.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 90 menit',
        hargaMulai: 'Rp.75.000',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in _defs)
          _ServiceTile(
            label: d.label,
            icon: d.icon,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.customerServiceDetail,
              arguments: d.args,
            ),
          ),
      ],
    );
  }
}

class _ServiceDef {
  final String label;
  final Widget icon;
  final ServiceDetailArgs args;
  const _ServiceDef(
      {required this.label, required this.icon, required this.args});
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kLabelGrey,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteIcon extends StatelessWidget {
  final IconData icon;
  const _WhiteIcon(this.icon);

  @override
  Widget build(BuildContext context) =>
      Icon(icon, color: Colors.white, size: 30);
}

class _RegulatorIcon extends StatelessWidget {
  const _RegulatorIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _RegulatorPainter()),
    );
  }
}

class _RegulatorPainter extends CustomPainter {
  const _RegulatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.65),
        Radius.circular(w * 0.1),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.1, w * 0.4, h * 0.18),
        Radius.circular(w * 0.06),
      ),
      p,
    );
    canvas.drawLine(
      Offset(w * 0.28, h * 0.58),
      Offset(w * 0.72, h * 0.58),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO BANNER (single, tidak carousel)
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoBanner extends StatelessWidget {
  final String? assetPath;
  final double height;
  final double borderRadius;
  final List<Color> fallbackGradient;
  final IconData fallbackIcon;
  final String fallbackLabel;
  final double overlayDim;

  const _PhotoBanner({
    required this.assetPath,
    required this.height,
    required this.borderRadius,
    required this.fallbackGradient,
    required this.fallbackIcon,
    required this.fallbackLabel,
    this.overlayDim = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: assetPath != null
            ? Stack(fit: StackFit.expand, children: [
                Image.asset(assetPath!, fit: BoxFit.cover),
                if (overlayDim > 0)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: overlayDim),
                  ),
              ])
            : _FallbackBanner(
                gradient: fallbackGradient,
                icon: fallbackIcon,
                label: fallbackLabel,
              ),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final String label;

  const _FallbackBanner({
    required this.gradient,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: _decor(120, 0.05)),
          Positioned(right: 30, bottom: -30, child: _decor(90, 0.04)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 48, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ganti assetPath di konfigurasi bagian atas',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decor(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}
