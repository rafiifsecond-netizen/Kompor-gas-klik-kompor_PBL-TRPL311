import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../widgets/technician_card_widget.dart';
import '../../repositories/technician_repository.dart';
import '../../widgets/empty_state_widget.dart';

class CustomerSelectTechnicianScreen extends StatefulWidget {
  const CustomerSelectTechnicianScreen({super.key});
  @override
  State<CustomerSelectTechnicianScreen> createState() =>
      _CustomerSelectTechnicianScreenState();
}

class _CustomerSelectTechnicianScreenState
    extends State<CustomerSelectTechnicianScreen> {
  final _repository = TechnicianRepository();
  int? _selectedTechnicianId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _technicians = [];
  String? _errorMessage;
  String _query = '';
  List<String> _sorts = ['nearest'];

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
      final list = await _repository.getTechnicians();
      if (mounted) {
        setState(() {
          _technicians = list.map((item) {
            final map = Map<String, dynamic>.from(item);
            // Backend /technicians returns users with a nested
            // technician_profile object, not a flat profile row.
            final profile = map['technician_profile'] is Map
                ? Map<String, dynamic>.from(map['technician_profile'] as Map)
                : map;
            final userId = map['id'] is int
                ? map['id'] as int
                : int.tryParse(map['id']?.toString() ?? '') ??
                    int.tryParse(profile['user_id']?.toString() ?? '') ??
                    0;
            return {
              'id': profile['id'] ?? userId,
              'user_id': userId,
              'name': map['name'] ?? profile['name'] ?? 'Teknisi Resmi',
              'phone': map['phone'] ?? profile['phone'] ?? '',
              'rating': double.tryParse(
                      (profile['rating_avg'] ?? profile['rating_average'])
                              ?.toString() ??
                          '') ??
                  0.0,
              'reviewCount':
                  int.tryParse((profile['reviews_count'] ??
                              profile['total_reviews'])
                          ?.toString() ??
                      '') ??
                      0,
              'distance': map['distance_km'] == null
                  ? '-'
                  : '${map['distance_km']} km',
              'distance_km': (map['distance_km'] as num?)?.toDouble(),
              'price': (profile['price'] as num?)?.toDouble() ?? 0,
              'specialization': profile['specialization'] ??
                  profile['bio'] ??
                  '',
              'experience': '${profile['jobs_completed_count'] ?? profile['total_completed_orders'] ?? 0} Servis Selesai',
              'is_available': profile['is_available'] == true ||
                  profile['is_available'] == 1,
            };
          }).toList();
          _isLoading = false;
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
    final args = RouteArgs.map(context) ?? <String, dynamic>{};
    final visibleTechnicians = _filteredTechnicians();

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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _fetchRealTechnicians,
                            child: const Text('Coba Lagi')),
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
                              decoration: const BoxDecoration(
                                  color: Color(0xFFFFF0E6),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.build_circle_outlined,
                                  size: 42, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text('Belum Ada Teknisi Online',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 8),
                            Text(
                                'Maaf, saat ini belum ada teknisi yang online/tersedia. Anda tetap dapat melanjutkan pemesanan dan sistem akan mencarikan teknisi terdekat begitu ada yang aktif.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                final newArgs = Map<String, dynamic>.from(args);
                                newArgs['technician'] =
                                    null; // Auto-assign later
                                Navigator.pushNamed(
                                    context, AppRoutes.customerSelectSchedule,
                                    arguments: newArgs);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Lanjutkan Tanpa Pilih Teknisi',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Cari nama atau spesialisasi...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: const [
                                    _SortChip(
                                        value: 'nearest', label: 'Terdekat'),
                                    _SortChip(
                                        value: 'rating',
                                        label: 'Rating tertinggi'),
                                    _SortChip(
                                        value: 'price_low',
                                        label: 'Harga termurah'),
                                    _SortChip(
                                        value: 'price_high',
                                        label: 'Harga termahal'),
                                  ]
                                      .map((chip) => FilterChip(
                                            label: chip.labelWidget,
                                            selected:
                                                _sorts.contains(chip.value),
                                            onSelected: (_) =>
                                                _toggleSort(chip.value),
                                          ))
                                      .toList(),
                                ),
                              ),
                              TextButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        ),
                        if (visibleTechnicians.isEmpty)
                          Expanded(
                            child: EmptyStateWidget(
                              icon: Icons.search_off,
                              title: 'Teknisi tidak ditemukan',
                              message: 'Coba ubah pencarian atau reset filter.',
                              buttonText: 'Reset filter',
                              onButtonPressed: _resetFilters,
                            ),
                          )
                        else
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: visibleTechnicians
                                  .map((t) => TechnicianCardWidget(
                                        name: t['name'] as String,
                                        rating: (t['rating'] as num).toDouble(),
                                        reviewCount: t['reviewCount'] as int,
                                        distance: t['distance'] as String,
                                        experience: t['experience'] as String,
                                        isSelected:
                                            _selectedTechnicianId == t['id'],
                                        onTap: () => setState(() =>
                                            _selectedTechnicianId =
                                                t['id'] as int),
                                      ))
                                  .toList(),
                            ),
                          ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _selectedTechnicianId == null
                                    ? null
                                    : () {
                                        final sel = _technicians.firstWhere(
                                            (t) =>
                                                t['id'] ==
                                                _selectedTechnicianId);
                                        final newArgs =
                                            Map<String, dynamic>.from(args);
                                        newArgs['technician'] = sel;
                                        newArgs['technician_id'] =
                                            sel['user_id'];
                                        Navigator.pushNamed(context,
                                            AppRoutes.customerSelectSchedule,
                                            arguments: newArgs);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Pilih Teknisi Ini',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  List<Map<String, dynamic>> _filteredTechnicians() {
    final query = _query.trim().toLowerCase();
    final result = _technicians.where((technician) {
      final name = technician['name'].toString().toLowerCase();
      final specialization =
          technician['specialization'].toString().toLowerCase();
      return query.isEmpty ||
          name.contains(query) ||
          specialization.contains(query);
    }).toList();
    return sortTechnicians(result, _sorts);
  }

  void _toggleSort(String value) {
    setState(() {
      if (_sorts.contains(value)) {
        _sorts.remove(value);
      } else {
        _sorts.add(value);
      }
      if (_sorts.isEmpty) _sorts = ['nearest'];
    });
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _sorts = ['nearest'];
    });
  }
}

class _SortChip {
  final String value;
  final String label;
  const _SortChip({required this.value, required this.label});
  Widget get labelWidget => Text(label);
}

List<Map<String, dynamic>> sortTechnicians(
    List<Map<String, dynamic>> technicians, List<String> criteria) {
  num distanceOf(Map<String, dynamic> row) =>
      (row['distance_km'] as num?) ?? double.infinity;
  num ratingOf(Map<String, dynamic> row) => (row['rating'] as num?) ?? 0;
  num priceOf(Map<String, dynamic> row) => (row['price'] as num?) ?? 0;

  final result = List<Map<String, dynamic>>.from(technicians);
  result.sort((a, b) {
    for (final criterion in criteria) {
      final comparison = switch (criterion) {
        'rating' => ratingOf(b).compareTo(ratingOf(a)),
        'price_low' => priceOf(a).compareTo(priceOf(b)),
        'price_high' => priceOf(b).compareTo(priceOf(a)),
        _ => distanceOf(a).compareTo(distanceOf(b)),
      };
      if (comparison != 0) return comparison;
    }
    return 0;
  });
  return result;
}
