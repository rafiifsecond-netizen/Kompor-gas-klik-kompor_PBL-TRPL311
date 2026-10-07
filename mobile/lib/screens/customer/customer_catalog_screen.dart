import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerCatalogScreen extends StatefulWidget {
  const CustomerCatalogScreen({super.key});

  @override
  State<CustomerCatalogScreen> createState() => _CustomerCatalogScreenState();
}

class _CustomerCatalogScreenState extends State<CustomerCatalogScreen> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'Semua'},
    {'id': 1, 'name': 'Kompor Gas'},
    {'id': 2, 'name': 'Regulator'},
    {'id': 3, 'name': 'Selang Gas'},
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Service Kompor Gas 1 Tungku',
      'category': 'Kompor Gas',
      'price': 75000,
      'duration': 60,
      'description': 'Perawatan dan perbaikan kompor gas 1 tungku termasuk bersihkan burner dan cek regulator.',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'id': 2,
      'name': 'Service Kompor Gas 2 Tungku',
      'category': 'Kompor Gas',
      'price': 100000,
      'duration': 90,
      'description': 'Perawatan dan perbaikan kompor gas 2 tungku termasuk bersihkan semua burner.',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'id': 3,
      'name': 'Ganti Selang Gas',
      'category': 'Selang Gas',
      'price': 50000,
      'duration': 30,
      'description': 'Penggantian selang gas yang bocor atau rusak dengan selang gas berkualitas.',
      'icon': Icons.swap_horiz_rounded,
    },
    {
      'id': 4,
      'name': 'Ganti Regulator Gas',
      'category': 'Regulator',
      'price': 80000,
      'duration': 45,
      'description': 'Penggantian regulator gas yang bermasalah atau rusak.',
      'icon': Icons.settings_rounded,
    },
    {
      'id': 5,
      'name': 'Pembersihan Kompor Menyeluruh',
      'category': 'Kompor Gas',
      'price': 150000,
      'duration': 120,
      'description': 'Pembersihan total kompor gas termasuk bagian dalam dan luar, semua burner.',
      'icon': Icons.cleaning_services_rounded,
    },
    {
      'id': 6,
      'name': 'Cek & Instalasi Kompor Baru',
      'category': 'Kompor Gas',
      'price': 120000,
      'duration': 90,
      'description': 'Pemeriksaan dan instalasi kompor gas baru termasuk tes keamanan.',
      'icon': Icons.handyman_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    final query = _searchController.text.toLowerCase();
    return _services.where((s) {
      final matchCategory = _selectedCategory == 0 || s['category'] == _categories[_selectedCategory]['name'];
      final matchSearch = query.isEmpty || (s['name'] as String).toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog Layanan'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildServiceList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Cari layanan...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.chipInactive,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[i]['name'] as String,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceList() {
    final filtered = _filteredServices;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Layanan tidak ditemukan',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildServiceCard(filtered[i]),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.customerServiceDetail,
            arguments: service,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(service['icon'] as IconData, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] as String,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['category'] as String,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Rp ${(service['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            '${service['duration']} mnt',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}