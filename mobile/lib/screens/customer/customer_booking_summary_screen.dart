import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../repositories/service_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class CustomerBookingSummaryScreen extends StatefulWidget {
  const CustomerBookingSummaryScreen({super.key});

  @override
  State<CustomerBookingSummaryScreen> createState() =>
      _CustomerBookingSummaryScreenState();
}

class _BookingSummaryView extends StatelessWidget {
  final _CustomerBookingSummaryScreenState screen;

  const _BookingSummaryView({required this.screen});

  @override
  Widget build(BuildContext context) => screen._buildView(context);
}

class _CustomerBookingSummaryScreenState
    extends State<CustomerBookingSummaryScreen> {
  String _selectedDate = '';
  String _selectedTime = '';
  late DateTime _selectedDateValue;
  String? _selectedDamageType;
  Map<String, dynamic> _bookingArgs = {};
  bool _argsInitialized = false;
  final _serviceRepository = ServiceRepository();
  List<String> _damageTypes = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateValue = now;
    _selectedDate =
        '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}';
    _selectedTime = _availableTimes(now).first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BookingSummaryView(screen: this);
  }

  Widget _buildView(BuildContext context) {
    final raw = RouteArgs.map(context);
    if (!_argsInitialized && raw != null) {
      _bookingArgs = Map<String, dynamic>.from(raw);
      _argsInitialized = true;
      _loadDamageTypes();
    }

    final serviceName = _bookingArgs['name'] as String? ?? 'Layanan dipilih';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 28, color: Colors.black),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Booking',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.lightGreyBorder, height: 1, thickness: 1),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Alamat ───────────────────────────────────────────
            Text(
              'Alamat',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final selected = await Navigator.pushNamed(
                    context, AppRoutes.customerSelectAddress,
                    arguments: 'select');
                if (selected is String && mounted) {
                  setState(() =>
                      _bookingArgs = {..._bookingArgs, 'address': selected});
                }

              },
              child: Container(
                width: double.infinity,
                padding: AppSpacing.allLg,
                decoration: const BoxDecoration(
                    color: AppColors.lightGreyBorder,
                    borderRadius: AppRadius.large),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        (_bookingArgs['address'] as String?)?.isNotEmpty == true
                            ? _bookingArgs['address'] as String
                            : 'Pilih alamat utama',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('Layanan',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: AppSpacing.allLg,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16)),
              child: Text(serviceName,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),

            // ── Section 2: Tanggal & Waktu ─────────────────────────────────
            Text(
              'Tanggal & Waktu',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                border: Border.all(color: AppColors.paleBorder, width: 1.2),
              ),
              child: Column(
                children: [
                  // Row Tanggal
                  InkWell(
                    onTap: _pickDate,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 24, color: Colors.black),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _selectedDate,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                      color: AppColors.mediumGrey, height: 1, thickness: 1),
                  // Row Waktu
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 24, color: Colors.black),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _selectedTime,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 3: Jenis Kerusakan ──────────────────────────────────
            Text(
              'Jenis Kerusakan',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.paleBorder, width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDamageType,
                  hint: Text(
                    'Pilih jenis kerusakan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 28, color: Colors.black),
                  isExpanded: true,
                  items: _damageTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDamageType = val;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 4: Catatan (opsional) ───────────────────────────────
            Text(
              'Catatan (opsional)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.paleBorder, width: 1.2),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Tulis catatan tambahan...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
                  ),
                  contentPadding: AppSpacing.allLg,
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Section 5: Estimasi Harga ──────────────────────────────────
            Text(
              'Estimasi Harga',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _bookingArgs['price']?.toString() ?? 'Harga mengikuti layanan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 36),

            // ── Section 6: Tombol Lanjut ke Pembayaran ──────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDamageType == null ||
                      _selectedDamageType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Harap pilih jenis kerusakan terlebih dahulu!',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    AppRoutes.customerPayment,
                    arguments: {
                      'service_id': _bookingArgs['service_id'],
                      'service_name': serviceName,
                      'address': _bookingArgs['address'] ?? '',
                      'date': _selectedDate,
                      'time': _selectedTime,
                      'scheduled_at': _scheduledAt(),
                      'damageType': _selectedDamageType!,
                      'notes': _notesController.text,
                      'priceRange': _bookingArgs['price'] ?? '',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                  ),
                ),
                child: Text(
                  'Lanjut ke Pembayaran',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDamageTypes() async {
    final types = await _serviceRepository
        .getDamageTypes(_bookingArgs['name']?.toString() ?? '');
    if (mounted) setState(() => _damageTypes = types);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateValue = picked;
        _selectedDate =
            '${_getDayName(picked.weekday)}, ${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _scheduledAt() {
    final now = DateTime.now();
    final hour = _selectedDateValue.year == now.year &&
            _selectedDateValue.month == now.month &&
            _selectedDateValue.day == now.day
        ? now.hour + 1
        : 8;
    return DateTime(_selectedDateValue.year, _selectedDateValue.month,
            _selectedDateValue.day, hour)
        .toIso8601String();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final times = _availableTimes(now);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Waktu Kedatangan',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: times
                          .map((t) => ListTile(
                                title: Text(t,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                onTap: () => Navigator.pop(ctx, t),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _selectedTime = selected;
      });
    }
  }

  List<String> _availableTimes(DateTime date) {
    final now = DateTime.now();
    final start =
        date.year == now.year && date.month == now.month && date.day == now.day
            ? (now.hour + 1).clamp(8, 20)
            : 8;
    return [
      for (var hour = start; hour <= 20; hour++)
        '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00'
    ];
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }
}
