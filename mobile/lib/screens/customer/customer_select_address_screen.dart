import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerSelectAddressScreen extends StatefulWidget {
  const CustomerSelectAddressScreen({super.key});

  @override
  State<CustomerSelectAddressScreen> createState() => _CustomerSelectAddressScreenState();
}

class _CustomerSelectAddressScreenState extends State<CustomerSelectAddressScreen> {
  int _selectedAddressId = 1;

  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 1,
      'label': 'Rumah',
      'recipientName': 'Budi Santoso',
      'recipientPhone': '08123456789',
      'addressLine': 'Jl. Merdeka No. 12, RT 03/RW 05',
      'city': 'Jakarta Selatan',
      'isDefault': true,
    },
    {
      'id': 2,
      'label': 'Kantor',
      'recipientName': 'Budi Santoso',
      'recipientPhone': '08123456789',
      'addressLine': 'Jl. Sudirman Kav. 52, Lantai 8',
      'city': 'Jakarta Pusat',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pilih Alamat'), backgroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Alamat Tersimpan',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ..._addresses.map((addr) => _buildAddressCard(addr)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Tambah Alamat Baru'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  final selected = _addresses.firstWhere((a) => a['id'] == _selectedAddressId);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.customerSelectSchedule,
                    arguments: {'service': service, 'address': selected},
                  );
                },
                child: const Text('Gunakan Alamat Ini'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final isSelected = _selectedAddressId == addr['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = addr['id'] as int),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder, width: 2),
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
                child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.chipInactive,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          addr['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (addr['isDefault'] == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            'Utama',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    addr['recipientName'] as String,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    addr['recipientPhone'] as String,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${addr['addressLine']}, ${addr['city']}',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}