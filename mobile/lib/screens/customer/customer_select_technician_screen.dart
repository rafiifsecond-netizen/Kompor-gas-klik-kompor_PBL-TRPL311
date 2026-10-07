import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/technician_card_widget.dart';

class CustomerSelectTechnicianScreen extends StatefulWidget {
  const CustomerSelectTechnicianScreen({super.key});
  @override
  State<CustomerSelectTechnicianScreen> createState() => _CustomerSelectTechnicianScreenState();
}

class _CustomerSelectTechnicianScreenState extends State<CustomerSelectTechnicianScreen> {
  int? _selectedTechnicianId;
  final List<Map<String, dynamic>> _technicians = [
    {'id': 1, 'name': 'Ahmad Subagyo', 'rating': 4.9, 'reviewCount': 124, 'distance': '1,2 km', 'experience': '5 Tahun pengalaman'},
    {'id': 2, 'name': 'Budi Wirawan', 'rating': 4.7, 'reviewCount': 89, 'distance': '2,5 km', 'experience': '3 Tahun pengalaman'},
    {'id': 3, 'name': 'Cahyo Pratama', 'rating': 4.8, 'reviewCount': 210, 'distance': '3,1 km', 'experience': '7 Tahun pengalaman'},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pilih Teknisi'), backgroundColor: Colors.white),
      body: Column(children: [
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
            child: ElevatedButton(
              onPressed: _selectedTechnicianId == null ? null : () {
                final sel = _technicians.firstWhere((t) => t['id'] == _selectedTechnicianId);
                final newArgs = Map<String, dynamic>.from(args);
                newArgs['technician'] = sel;
                Navigator.pushNamed(context, AppRoutes.customerBookingSummary, arguments: newArgs);
              },
              child: const Text('Lanjutkan'),
            ),
          ),
        ),
      ]),
    );
  }
}
