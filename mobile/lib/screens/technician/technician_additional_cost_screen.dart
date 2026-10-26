import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/route_args.dart';
import '../../core/utils/validators.dart';
import '../../repositories/order_repository.dart';

class TechnicianAdditionalCostScreen extends StatefulWidget {
  const TechnicianAdditionalCostScreen({super.key});

  @override
  State<TechnicianAdditionalCostScreen> createState() =>
      _TechnicianAdditionalCostScreenState();
}

class _TechnicianAdditionalCostScreenState
    extends State<TechnicianAdditionalCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _repository = OrderRepository();
  List<Map<String, dynamic>> _addedCosts = [];
  int _orderId = 1;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = RouteArgs.map(context);
    final value = args?['orderId'];
    if (value is int) _orderId = value;
    _loadCosts();
  }

  Future<void> _loadCosts() async {
    final response = await _repository.getAdditionalCosts(_orderId);
    if (!mounted) return;
    final data = response is Map ? response['data'] : null;
    setState(() {
      _addedCosts = data is List
          ? data.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : [];
    });
  }

  Future<void> _addCost() async {
    if (!_formKey.currentState!.validate()) return;
    final itemName = _itemController.text.trim();
    final price = int.parse(_priceController.text.trim());
    await _repository.addAdditionalCost(_orderId, {
      'item_name': itemName,
      'quantity': 1,
      'subtotal': price,
      'status': 'pending',
    });
    _itemController.clear();
    _priceController.clear();
    await _loadCosts();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAdditional = _addedCosts.fold<int>(
        0, (sum, item) => sum + ((item['subtotal'] as num?)?.toInt() ?? 0));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Biaya Tambahan Sparepart',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Tambah Biaya Sparepart',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                          labelText: 'Nama Barang / Sparepart',
                          hintText: 'Contoh: Regulator Gas Meter'),
                      validator: (value) =>
                          Validators.required(value, label: 'Nama barang'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Harga Sparepart (Rp)', hintText: '50000'),
                      validator: (value) =>
                          Validators.positiveNumber(value, label: 'Harga'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addCost,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Tambah ke Daftar'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Daftar Biaya Tambahan',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._addedCosts.map((cost) => _CostRow(cost: cost)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Biaya Tambahan:',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Rp $totalAdditional',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF7A00))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final Map<String, dynamic> cost;
  const _CostRow({required this.cost});

  @override
  Widget build(BuildContext context) {
    final name = cost['item_name'] ?? cost['item'] ?? 'Sparepart';
    final amount = cost['subtotal'] ?? cost['price'] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(name.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          Text('Rp $amount',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: const Color(0xFFFF7A00))),
        ],
      ),
    );
  }
}
