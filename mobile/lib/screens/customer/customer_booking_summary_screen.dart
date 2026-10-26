import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../core/theme/app_text_styles.dart';
import '../../repositories/service_repository.dart';

class CustomerBookingSummaryScreen extends StatefulWidget {
  const CustomerBookingSummaryScreen({super.key});

  @override
  State<CustomerBookingSummaryScreen> createState() =>
      _CustomerBookingSummaryScreenState();
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
    final raw = RouteArgs.map(context);
    if (!_argsInitialized && raw != null) {
      _bookingArgs = Map<String, dynamic>.from(raw);
      _argsInitialized = true;
      _loadDamageTypes();
    }

    final serviceName = _bookingArgs['name'] as String? ?? 'Layanan dipilih';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: _BookingHeader(),
      ),
      body: _BookingForm(
        address: _bookingArgs['address'] as String?,
        serviceName: serviceName,
        selectedDate: _selectedDate,
        selectedTime: _selectedTime,
        damageTypes: _damageTypes,
        selectedDamageType: _selectedDamageType,
        price: _bookingArgs['price']?.toString(),
        notesController: _notesController,
        onAddressTap: () => _selectAddress(context),
        onDateTap: _pickDate,
        onTimeTap: _pickTime,
        onDamageTypeChanged: (value) =>
            setState(() => _selectedDamageType = value),
        onContinue: () => _continueToPayment(context, serviceName),
      ),
    );
  }

  Future<void> _selectAddress(BuildContext context) async {
    final selected = await Navigator.pushNamed(
      context,
      AppRoutes.customerSelectAddress,
      arguments: 'select',
    );
    if (selected is String && mounted) {
      setState(() => _bookingArgs = {..._bookingArgs, 'address': selected});
    }
  }

  void _continueToPayment(BuildContext context, String serviceName) {
    if (_selectedDamageType == null || _selectedDamageType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Harap pilih jenis kerusakan terlebih dahulu!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TimePickerSheet(
        times: _availableTimes(now),
        onSelected: (time) => Navigator.pop(ctx, time),
      ),
    );
    if (selected != null) setState(() => _selectedTime = selected);
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
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return day >= 1 && day <= names.length ? names[day - 1] : '';
  }

  String _getMonthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return month >= 1 && month <= names.length ? names[month - 1] : '';
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text('Booking',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
              ],
            ),
          ),
          const Divider(
              color: AppColors.lightGreyBorder, height: 1, thickness: 1),
        ],
      ),
    );
  }
}

class _BookingForm extends StatelessWidget {
  final String? address;
  final String serviceName;
  final String selectedDate;
  final String selectedTime;
  final List<String> damageTypes;
  final String? selectedDamageType;
  final String? price;
  final TextEditingController notesController;
  final VoidCallback onAddressTap;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final ValueChanged<String?> onDamageTypeChanged;
  final VoidCallback onContinue;

  const _BookingForm({
    required this.address,
    required this.serviceName,
    required this.selectedDate,
    required this.selectedTime,
    required this.damageTypes,
    required this.selectedDamageType,
    required this.price,
    required this.notesController,
    required this.onAddressTap,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onDamageTypeChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BookingSectionTitle('Alamat'),
          const SizedBox(height: 12),
          _AddressCard(address: address, onTap: onAddressTap),
          const SizedBox(height: 24),
          const _BookingSectionTitle('Layanan'),
          const SizedBox(height: 12),
          _ServiceCard(serviceName),
          const SizedBox(height: 24),
          const _BookingSectionTitle('Tanggal & Waktu'),
          const SizedBox(height: 12),
          _ScheduleCard(
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            onDateTap: onDateTap,
            onTimeTap: onTimeTap,
          ),
          const SizedBox(height: 24),
          const _BookingSectionTitle('Jenis Kerusakan'),
          const SizedBox(height: 12),
          _DamageTypeField(
            damageTypes: damageTypes,
            selectedDamageType: selectedDamageType,
            onChanged: onDamageTypeChanged,
          ),
          const SizedBox(height: 24),
          const _BookingSectionTitle('Catatan (opsional)'),
          const SizedBox(height: 12),
          _NotesField(controller: notesController),
          const SizedBox(height: 28),
          _PriceAndAction(
            price: price,
            onContinue: onContinue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BookingSectionTitle extends StatelessWidget {
  final String title;

  const _BookingSectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      );
}

class _AddressCard extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;

  const _AddressCard({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final value = address?.isNotEmpty == true ? address! : 'Pilih alamat utama';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: AppSpacing.allLg,
        decoration: const BoxDecoration(
          color: AppColors.lightGreyBorder,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
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
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String serviceName;

  const _ServiceCard(this.serviceName);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(serviceName,
            style:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
      );
}

class _ScheduleCard extends StatelessWidget {
  final String selectedDate;
  final String selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _ScheduleCard({
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.paleBorder, width: 1.2),
        ),
        child: Column(
          children: [
            _ScheduleRow(
              icon: Icons.calendar_today_outlined,
              value: selectedDate,
              top: true,
              onTap: onDateTap,
            ),
            const Divider(color: AppColors.mediumGrey, height: 1, thickness: 1),
            _ScheduleRow(
              icon: Icons.access_time,
              value: selectedTime,
              bottom: true,
              onTap: onTimeTap,
            ),
          ],
        ),
      );
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool top;
  final bool bottom;
  final VoidCallback onTap;

  const _ScheduleRow({
    required this.icon,
    required this.value,
    this.top = false,
    this.bottom = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: top ? const Radius.circular(18) : Radius.zero,
          bottom: bottom ? const Radius.circular(18) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(width: 14),
              Expanded(
                child: Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint)),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.black),
            ],
          ),
        ),
      );
}

class _DamageTypeField extends StatelessWidget {
  final List<String> damageTypes;
  final String? selectedDamageType;
  final ValueChanged<String?> onChanged;

  const _DamageTypeField({
    required this.damageTypes,
    required this.selectedDamageType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.paleBorder, width: 1.2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedDamageType,
            hint: Text('Pilih jenis kerusakan',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint)),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 28, color: Colors.black),
            isExpanded: true,
            items: damageTypes
                .map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;

  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.paleBorder, width: 1.2),
        ),
        child: TextField(
          controller: controller,
          maxLines: 4,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Tulis catatan tambahan...',
            hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint),
            contentPadding: AppSpacing.allLg,
            border: InputBorder.none,
          ),
        ),
      );
}

class _PriceAndAction extends StatelessWidget {
  final String? price;
  final VoidCallback onContinue;

  const _PriceAndAction({required this.price, required this.onContinue});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimasi Harga',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 6),
          Text(price ?? 'Harga mengikuti layanan',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black)),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
              child: Text('Lanjut ke Pembayaran',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      );
}

class _TimePickerSheet extends StatelessWidget {
  final List<String> times;
  final ValueChanged<String> onSelected;

  const _TimePickerSheet({required this.times, required this.onSelected});

  @override
  Widget build(BuildContext context) => Container(
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
                        .map((time) => ListTile(
                              title: Text(time,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              onTap: () => onSelected(time),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
