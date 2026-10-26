import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/technician_card_widget.dart';

class CustomerSelectTechnicianScreen extends StatefulWidget {
  const CustomerSelectTechnicianScreen({super.key});
  @override
  State<CustomerSelectTechnicianScreen> createState() => _CustomerSelectTechnicianScreenState();
}

class _CustomerSelectTechnicianScreenState extends State<CustomerSelectTechnicianScreen> {
  int? _selectedTechnicianId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _technicians = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRealTechnicians();
  }

  Future<void> _fetchRealTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient().get(ApiEndpoints.technicians);
      if (res is Map && res['success'] == true) {
        final data = res['data'];
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);

        setState(() {
          _technicians = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final userMap = map['user'] is Map ? Map<String, dynamic>.from(map['user'] as Map) : {};
            return {
              'id': map['id'] ?? userMap['id'] ?? 1,
              'user_id': userMap['id'] ?? map['user_id'] ?? 1,
              'name': userMap['name'] ?? map['name'] ?? 'Teknisi Resmi',
              'phone': userMap['phone'] ?? map['phone'] ?? '08123456789',
              'rating': double.tryParse(map['rating_avg']?.toString() ?? '5.0') ?? 5.0,
              'reviewCount': map['reviews_count'] ?? 12,
              'distance': '1,2 km',
              'experience': '${map['jobs_completed_count'] ?? 5} Servis Selesai',
              'is_available': map['is_available'] ?? true,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _technicians = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args = rawArgs is Map<String, dynamic> ? rawArgs : {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Teknisi Resmi'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchRealTechnicians,
            tooltip: 'Muat Ulang Teknisi',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
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
                        ElevatedButton(onPressed: _fetchRealTechnicians, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : _technicians.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(color: Color(0xFFFFF0E6), shape: BoxShape.circle),
                              child: const Icon(Icons.build_circle_outlined, size: 42, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text('Belum Ada Teknisi Online', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 8),
                            Text('Maaf, saat ini belum ada teknisi yang online/tersedia. Anda tetap dapat melanjutkan pemesanan dan sistem akan mencarikan teknisi terdekat begitu ada yang aktif.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                final newArgs = Map<String, dynamic>.from(args);
                                newArgs['technician'] = null; // Auto-assign later
                                Navigator.pushNamed(context, AppRoutes.customerSelectSchedule, arguments: newArgs);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Lanjutkan Tanpa Pilih Teknisi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: _technicians.map((t) => TechnicianCardWidget(
                              name: t['name'] as String,
                              rating: (t['rating'] as num).toDouble(),
                              reviewCount: t['reviewCount'] as int,
                              distance: t['distance'] as String,
                              experience: t['experience'] as String,
                              isSelected: _selectedTechnicianId == t['id'],
                              onTap: () => setState(() => _selectedTechnicianId = t['id'] as int),
                            )).toList(),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _selectedTechnicianId == null ? null : () {
                                  final sel = _technicians.firstWhere((t) => t['id'] == _selectedTechnicianId);
                                  final newArgs = Map<String, dynamic>.from(args);
                                  newArgs['technician'] = sel;
                                  newArgs['technician_id'] = sel['user_id'];
                                  Navigator.pushNamed(context, AppRoutes.customerSelectSchedule, arguments: newArgs);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Pilih Teknisi Ini', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
