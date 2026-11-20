import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';

class CustomerSelectScheduleScreen extends StatefulWidget {
  const CustomerSelectScheduleScreen({super.key});
  @override
  State<CustomerSelectScheduleScreen> createState() =>
      _CustomerSelectScheduleScreenState();
}

class _CustomerSelectScheduleScreenState
    extends State<CustomerSelectScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '';
  Timer? _slotTimer;

  List<String> get _timeSlots {
    final now = DateTime.now();
    final start = _selectedDate.year == now.year &&
            _selectedDate.month == now.month &&
            _selectedDate.day == now.day
        ? (now.hour + 1).clamp(8, 20)
        : 8;
    final slots = <String>[];
    var hour = start;
    var minute = 0;
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day &&
        now.minute >= 30) {
      minute = 0;
      hour = now.hour + 1;
    } else if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      minute = now.minute < 30 ? 30 : 0;
    }
    var cursor = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      20,
      30,
    );
    if (cursor.isBefore(now)) {
      cursor = cursor.add(const Duration(minutes: 30));
    }
    while (!cursor.isAfter(end)) {
      slots.add(
        '${cursor.hour.toString().padLeft(2, '0')}:${cursor.minute.toString().padLeft(2, '0')}',
      );
      cursor = cursor.add(const Duration(minutes: 30));
    }
    return slots;
  }

  @override
  void initState() {
    super.initState();
    _selectedTime = '';
    _slotTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_selectedTime.isNotEmpty && !_timeSlots.contains(_selectedTime)) {
          _selectedTime = '';
        }
      });
    });
  }

  @override
  void dispose() {
    _slotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = RouteArgs.map(context) ?? <String, dynamic>{};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Pilih Jadwal'), backgroundColor: Colors.white),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildDatePicker(),
              const SizedBox(height: 24),
              Text('Pilih Jam',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildTimeSlots(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'Teknisi akan tiba dalam 30-60 menit setelah jam yang dipilih.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.primary))),
                ]),
              ),
            ]),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedTime.isEmpty
                  ? null
                  : () {
                      final d = _selectedDate;
                      final newArgs = Map<String, dynamic>.from(args);
                      newArgs['bookingDate'] =
                          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                      newArgs['bookingTime'] = _selectedTime;
                      Navigator.pushNamed(
                          context, AppRoutes.customerSelectTechnician,
                          arguments: newArgs);
                    },
              child: const Text('Lanjutkan'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDatePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pilih Tanggal',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        onDateChanged: (d) => setState(() {
          _selectedDate = d;
          _selectedTime = '';
        }),
      ),
    ]);
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2),
      itemCount: _timeSlots.length,
      itemBuilder: (_, i) {
        final time = _timeSlots[i];
        final isSelected = _selectedTime == time;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = time),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder),
            ),
            child: Center(
                child: Text(time,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.black
                            : AppColors.textPrimary))),
          ),
        );
      },
    );
  }
}
