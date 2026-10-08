import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TechnicianAdditionalCostScreen extends StatefulWidget {
  const TechnicianAdditionalCostScreen({super.key});

  @override
  State<TechnicianAdditionalCostScreen> createState() => _TechnicianAdditionalCostScreenState();
}

class _TechnicianAdditionalCostScreenState extends State<TechnicianAdditionalCostScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<Map<String, dynamic>> _addedCosts = [
    {'item': 'Penggantian Selang Gas SNI 1.8m', 'price': 45000},
    {'item': 'Klem Selang Stenlis (2 pcs)', 'price': 10000},
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalAdditional = _addedCosts.fold(0, (sum, item) => sum + (item['price'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Biaya Tambahan Sparepart',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Tambah Biaya Sparepart', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                children: [
                  TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(labelText: 'Nama Barang / Sparepart', hintText: 'Contoh: Regulator Gas Meter'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga Sparepart (Rp)', hintText: '50000'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_itemController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                          setState(() {
                            _addedCosts.add({
                              'item': _itemController.text,
                              'price': int.tryParse(_priceController.text) ?? 0,
                            });
                            _itemController.clear();
                            _priceController.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tambah ke Daftar'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Daftar Biaya Tambahan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._addedCosts.map((cost) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cost['item'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      Text('Rp ${cost['price']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFFF7A00))),
                    ],
                  ),
                )),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Biaya Tambahan:', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Rp $totalAdditional', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFFFF7A00))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
