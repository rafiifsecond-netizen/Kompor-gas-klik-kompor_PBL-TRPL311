import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';

class CustomerBookingSummaryScreen extends StatefulWidget {
  const CustomerBookingSummaryScreen({super.key});

  @override
  State<CustomerBookingSummaryScreen> createState() => _CustomerBookingSummaryScreenState();
}

class _CustomerBookingSummaryScreenState extends State<CustomerBookingSummaryScreen> {
  String _selectedDate = 'Sab, 16 September 2026';
  String _selectedTime = '09:00 - 12:00';
  String? _selectedDamageType;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _damageTypes = [
    'Api Merah / Kompor Berkerak',
    'Kebocoran Gas / Bau Gas Menyengat',
    'Pemantik Api Tidak Berfungsi',
    'Kompor Gas Mati Total',
    'Lainnya',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 28, color: Colors.black),
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
              const Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7A00),
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
                      'Jl. Raplesia No. 10, Kel. Patriot\nKec. Lubuk Baja, Kepulauan Riau',
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
              ),
              child: Column(
                children: [
                  // Row Tanggal
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 24, color: Colors.black),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _selectedDate,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
                  // Row Waktu
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 24, color: Colors.black),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _selectedTime,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black),
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
                border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDamageType,
                  hint: Text(
                    'Pilih jenis kerusakan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: Colors.black),
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
                border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Tulis catatan tambahan...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9E9E9E),
                  ),
                  contentPadding: const EdgeInsets.all(16),
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
              'Rp 75.000 - Rp 150.000',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    AppRoutes.customerPayment,
                    arguments: {
                      'address': 'Jl. Raplesia No. 10, Kel. Patriot Kec. Lubuk Baja, Kepulauan Riau',
                      'date': _selectedDate,
                      'time': _selectedTime,
                      'damageType': _selectedDamageType!,
                      'notes': _notesController.text,
                      'priceRange': 'Rp 75.000 - Rp 150.000',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = '${_getDayName(picked.weekday)}, ${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final times = ['08:00 - 10:00', '09:00 - 12:00', '13:00 - 15:00', '15:00 - 18:00'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Waktu Kedatangan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...times.map((t) => ListTile(
                    title: Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    onTap: () => Navigator.pop(ctx, t),
                  )),
            ],
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

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return '';
    }
  }
}
