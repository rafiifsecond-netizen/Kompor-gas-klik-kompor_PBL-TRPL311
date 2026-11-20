import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';
import '../../models/service_model.dart';
import '../../repositories/service_repository.dart';
import '../../repositories/order_repository.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_fade_slide.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../models/banner_model.dart';
import '../../repositories/banner_repository.dart';
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
    gradient: [AppColors.primary, AppColors.bannerOrange],
  ),
  _BannerItem(
    assetPath: null, // → 'assets/images/banner2.jpg'
    title: 'Teknisi Berpengalaman',
    subtitle: 'Garansi pengerjaan hingga 30 hari',
    gradient: [AppColors.bannerNavy, AppColors.bannerBrown],
  ),
  _BannerItem(
    assetPath: null, // → 'assets/images/banner3.jpg'
    title: 'Cek Kebocoran Gas',
    subtitle: 'Keamanan rumah Anda prioritas kami',
    gradient: [AppColors.bannerGreen, AppColors.bannerDarkGreen],
  ),
];

// Banner bawah (single, tidak carousel)
// Ganti null → 'assets/images/banner_bawah.jpg'
const String? _bannerBottomAsset = null;

// ─── Warna & konstanta lokal ──────────────────────────────────────────────────
const _kGrey = AppColors.mutedGrey;
const _kLabelGrey = Color(0xFF5D5555);
const _kBorderGrey = AppColors.lightGrey;
const _kPad = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

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
  late final Future<Map<String, dynamic>?> _latestCompletedOrder;
  late final Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _latestCompletedOrder = _loadLatestCompletedOrder();
    _bannersFuture = BannerRepository().getBanners();
  }

  Future<Map<String, dynamic>?> _loadLatestCompletedOrder() async {
    final orders = await OrderRepository().getOrders();
    final completed = orders
        .where((order) => order['status'] == 'completed')
        .toList()
      ..sort((a, b) => (b['completed_at'] ?? b['booking_date'] ?? '')
          .toString()
          .compareTo(
              (a['completed_at'] ?? a['booking_date'] ?? '').toString()));
    return completed.isEmpty ? null : completed.first;
  }

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
                const Padding(
                  padding: _kPad,
                  child: _SearchBar(),
                ),

                const SizedBox(height: 16),

                // ── Carousel banner (auto-scroll & dinamis dari database) ──
                Padding(
                  padding: _kPad,
                  child: FutureBuilder<List<BannerModel>>(
                    future: _bannersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 195,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final banners = snapshot.data ?? [];
                      if (banners.isNotEmpty) {
                        return _BannerCarousel(dynamicBanners: banners);
                      }
                      return const _BannerCarousel(items: _carouselItems);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                _HomeServicesSection(
                  onSeeAll: () =>
                      Navigator.pushNamed(context, AppRoutes.customerCatalog),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: _kPad,
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _latestCompletedOrder,
                    builder: (context, snapshot) => _ServiceReminderCard(
                      completedOrder: snapshot.data,
                      onBook: () => Navigator.pushNamed(
                          context, AppRoutes.customerCatalog),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Banner bawah
                const Padding(
                  padding: _kPad,
                  child: _PhotoBanner(
                    assetPath: _bannerBottomAsset,
                    height: 155,
                    borderRadius: 12,
                    fallbackGradient: [Color(0xFF0D0D1A), Color(0xFF1A1A3E)],
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

class _HomeServicesSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _HomeServicesSection({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: _kPad,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Layanan Kami',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('Layanan Lainnya'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _RealServiceGrid(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ServiceReminderCard extends StatelessWidget {
  final Map<String, dynamic>? completedOrder;
  final VoidCallback onBook;

  const _ServiceReminderCard({
    required this.completedOrder,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final completedDate = DateTime.tryParse(
        completedOrder?['completed_at']?.toString() ??
            completedOrder?['booking_date']?.toString() ??
            '');
    final nextDate = completedDate?.add(const Duration(days: 182));
    final message = nextDate == null
        ? 'Belum ada riwayat servis. Pesan servis pertama Anda sekarang.'
        : 'Jadwalkan pemeriksaan berikutnya sekitar '
            '${nextDate.day.toString().padLeft(2, '0')}/'
            '${nextDate.month.toString().padLeft(2, '0')}/'
            '${nextDate.year}.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paleBackground,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded,
              color: AppColors.primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pengingat Servis Berkala',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton(onPressed: onBook, child: const Text('Pesan')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER CAROUSEL — auto-scroll 3 detik, swipe manual, dot indicator
// ─────────────────────────────────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  final List<_BannerItem>? items;
  final List<BannerModel>? dynamicBanners;

  const _BannerCarousel({this.items, this.dynamicBanners});

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
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
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
    final hasDynamic =
        widget.dynamicBanners != null && widget.dynamicBanners!.isNotEmpty;
    final count = hasDynamic
        ? widget.dynamicBanners!.length
        : (widget.items?.length ?? 0);

    if (count == 0) return const SizedBox.shrink();

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
                if (hasDynamic) {
                  final banner = widget.dynamicBanners![index % count];
                  return _BannerSlide(dynamicBanner: banner);
                }
                final item = widget.items![index % count];
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
  final _BannerItem? item;
  final BannerModel? dynamicBanner;

  const _BannerSlide({this.item, this.dynamicBanner});

  @override
  Widget build(BuildContext context) {
    if (dynamicBanner != null) {
      final banner = dynamicBanner!;
      return Stack(
        fit: StackFit.expand,
        children: [
          // Background network image
          Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.bannerOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image_outlined,
                      color: Colors.white70, size: 48),
                ),
              );
            },
          ),

          // Gradient overlay for readability
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xAA000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Badge
          if (banner.badgeText != null && banner.badgeText!.isNotEmpty)
            Positioned(
              top: 14,
              left: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  banner.badgeText!,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Text Content
          Positioned(
            left: 18,
            right: 24,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  banner.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (banner.description != null &&
                    banner.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    banner.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Fallback item
    final fallbackItem = item!;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: gambar atau gradient
        if (fallbackItem.assetPath != null)
          Image.asset(fallbackItem.assetPath!, fit: BoxFit.cover)
        else
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: fallbackItem.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

        // Decorative circles (hanya pada fallback)
        if (fallbackItem.assetPath == null) ...[
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
                fallbackItem.title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fallbackItem.subtitle,
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
      borderRadius: AppRadius.small,
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
              const Icon(Icons.search, size: 20, color: AppColors.textHint),
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
// ignore: unused_element
class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  static final _defs = <_ServiceDef>[
    const _ServiceDef(
      label: 'Service\nKompor',
      icon: _WhiteIcon(Icons.settings_rounded),
      args: ServiceDetailArgs(
        name: 'Service Kompor Gas',
        description:
            'Perbaikan berbagai masalah pada kompor gas, seperti api kecil, kompor tidak menyala, hingga kebocoran gas.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp 75.000',
      ),
    ),
    const _ServiceDef(
      label: 'Instalasi\nRegulator',
      icon: _RegulatorIcon(),
      args: ServiceDetailArgs(
        name: 'Instalasi Regulator',
        description:
            'Layanan pemasangan regulator gas yang cepat, aman, dan dikerjakan oleh teknisi profesional. Memastikan sambungan terpasang dengan benar sehingga meminimalkan risiko kebocoran.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp 75.000',
      ),
    ),
    const _ServiceDef(
      label: 'Cek\nKebocoran',
      icon: _WhiteIcon(Icons.propane_tank_rounded),
      args: ServiceDetailArgs(
        name: 'Cek Kebocoran Gas',
        description:
            'Deteksi kebocoran dengan cepat dan akurat. Teknisi kami akan memeriksa seluruh sambungan gas untuk mencegah risiko kebakaran dan kecelakaan.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 60 menit',
        hargaMulai: 'Rp 75.000',
      ),
    ),
    const _ServiceDef(
      label: 'Lainnya',
      icon: _WhiteIcon(Icons.more_horiz_rounded),
      args: ServiceDetailArgs(
        name: 'Layanan Lainnya',
        description:
            'Berbagai layanan perawatan dan perbaikan kompor gas lainnya oleh teknisi profesional berpengalaman.',
        rating: 4.8,
        reviewCount: 9999,
        estimasi: '30 - 90 menit',
        hargaMulai: 'Rp 75.000',
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

class _RealServiceGrid extends StatefulWidget {
  const _RealServiceGrid();
  @override
  State<_RealServiceGrid> createState() => _RealServiceGridState();
}

class _RealServiceGridState extends State<_RealServiceGrid> {
  final _repository = ServiceRepository();
  List<ServiceModel> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repository.getServices();
      if (mounted) {
        setState(
            () => _services = rows.map(ServiceModel.fromJson).take(4).toList());
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _services = [];
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
          height: 120, child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Layanan gagal dimuat'),
              TextButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    if (_services.isEmpty) {
      return const SizedBox(
          height: 120,
          child: Center(child: Text('Belum ada layanan tersedia')));
    }
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 12,
      runSpacing: 16,
      children: _services
          .map((service) => _ServiceTile(
                label: service.name,
                icon: const _WhiteIcon(Icons.build_rounded),
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.customerServiceDetail,
                    arguments: {
                      'id': service.id,
                      'name': service.name,
                      'description': service.description ?? '',
                      'hargaMulai': AppConstants.formatCurrency(service.price),
                      'estimasi': '${service.estimatedDurationMinutes} menit',
                    }),
              ))
          .toList(),
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
