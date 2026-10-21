import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class TechnicianOrderDetailScreen extends StatefulWidget {
  const TechnicianOrderDetailScreen({super.key});

  @override
  State<TechnicianOrderDetailScreen> createState() =>
      _TechnicianOrderDetailScreenState();
}

class _TechnicianOrderDetailScreenState
    extends State<TechnicianOrderDetailScreen> {
  static const _stages = [
    'Pesanan Diterima',
    'Dalam Perjalanan',
    'Sedang Mengerjakan Servis',
    'Pesanan Selesai',
  ];

  Map<String, dynamic> _order = {};
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _costs = [];
  List<Map<String, dynamic>> _services = [];
  int? _orderId;
  int _stage = 0;
  double _sliderPreview = 0;
  bool _initialized = false;
  bool _loading = false;
  bool _updatingStatus = false;
  bool _updatingService = false;
  String? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    _order = Map<String, dynamic>.from(args);
    _orderId = _asInt(args['orderId']);
    _stage = _stageFor(args['status'] as String?);
    _sliderPreview = _stage.toDouble();
    final initialItems = args['items'];
    if (initialItems is List) {
      _items = initialItems.whereType<Map>().map(_map).toList();
    }
    if (_orderId != null) _loadOrderData();
  }

  int _stageFor(String? status) => switch (status) {
        'on_the_way' => 1,
        'in_progress' => 2,
        'completed' => 3,
        _ => 0,
      };

  Future<void> _loadOrderData() async {
    final id = _orderId;
    if (id == null) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        ApiClient().get(ApiEndpoints.orderDetail(id)),
        ApiClient().get(ApiEndpoints.additionalCosts(id)),
        ApiClient().get(ApiEndpoints.services),
      ]);
      if (!mounted) return;
      final detailResponse = results[0];
      final detail = detailResponse is Map && detailResponse['data'] is Map
          ? _map(detailResponse['data'] as Map)
          : <String, dynamic>{};
      final costsResponse = results[1];
      final servicesResponse = results[2];
      setState(() {
        if (detail.isNotEmpty) {
          _order = {..._order, ...detail};
          final rows = detail['items'];
          if (rows is List) _items = rows.whereType<Map>().map(_map).toList();
          _stage = _stageFor(detail['status'] as String?);
          _sliderPreview = _stage.toDouble();
        }
        final costRows = costsResponse is Map ? costsResponse['data'] : null;
        if (costRows is List) {
          _costs = costRows.whereType<Map>().map(_map).toList();
        }
        final serviceRows =
            servicesResponse is Map ? servicesResponse['data'] : null;
        if (serviceRows is List) {
          _services = serviceRows.whereType<Map>().map(_map).toList();
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = _relationName(_order['customer']) ??
        _order['customer_name'] as String? ??
        _order['customerName'] as String? ??
        'Pelanggan';
    final address = _order['address'] as String? ??
        _order['addressText'] as String? ??
        'Alamat pelanggan belum tersedia';
    final orderNumber = _order['order_number'] as String? ??
        _order['orderNumber'] as String? ??
        '-';
    final customerPoint = _point(_order['latitude'], _order['longitude']);
    final technicianPoint = _point(
      _order['technician_latitude'] ?? _order['technicianLatitude'],
      _order['technician_longitude'] ?? _order['technicianLongitude'],
    );
    final serviceAmount = _serviceAmount;
    final addedCosts = _costs
        .where((cost) => cost['status'] != 'rejected')
        .fold<double>(0, (sum, cost) => sum + _number(cost['subtotal']));
    final transportFee = _number(_order['transport_fee']);
    final platformDeduction = serviceAmount * 0.10;
    final customerTotal =
        serviceAmount + transportFee + addedCosts - platformDeduction;
    final netEarnings = serviceAmount - platformDeduction + addedCosts;
    final serviceLabel = _serviceLabel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: Text(
          'Pesanan',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              _mapCenter(technicianPoint, customerPoint),
                          initialZoom: 13,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.klikkompor.mobile',
                          ),
                          if (technicianPoint != null && customerPoint != null)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [technicianPoint, customerPoint],
                                  strokeWidth: 4,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (customerPoint != null)
                                Marker(
                                  point: customerPoint,
                                  width: 44,
                                  height: 48,
                                  child: const Icon(Icons.location_pin,
                                      color: Color(0xFFE53935), size: 42),
                                ),
                              if (technicianPoint != null)
                                Marker(
                                  point: technicianPoint,
                                  width: 44,
                                  height: 48,
                                  child: const Icon(Icons.handyman_rounded,
                                      color: AppColors.primary, size: 38),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 1,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Lihat Lokasi Pelanggan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 27,
                        backgroundColor: Color(0xFFEADDFF),
                        child: Icon(Icons.person_rounded,
                            color: Color(0xFF4F378A), size: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(orderNumber,
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        tooltip: 'Chat pelanggan',
                        onPressed: _openChat,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Lokasi Servis',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(address,
                      style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
                  const Divider(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _infoColumn(
                          'Jenis Layanan',
                          serviceLabel,
                          'Jarak & Durasi',
                          'Lokasi aktual tersedia di peta',
                          actionLabel: 'Perubahan Layanan',
                          onAction: _updatingService ? null : _chooseService,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _infoColumn(
                          'Tambahan Biaya Lain',
                          _rupiah(addedCosts),
                          'Yang dibayar customer',
                          _rupiah(customerTotal),
                          highlightValue: true,
                          actionLabel: 'Tambah',
                          onAction: _showAddCostDialog,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _infoColumn(
                          'Potongan 10%',
                          _rupiah(platformDeduction),
                          'Biaya Service',
                          _rupiah(serviceAmount),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _infoColumn(
                          'Terima bersih',
                          _rupiah(netEarnings),
                          'Metode Pembayaran',
                          _paymentLabel(_order['payment_method']),
                          highlightValue: true,
                        ),
                      ),
                    ],
                  ),
                  if (transportFee > 0) ...[
                    const SizedBox(height: 14),
                    Text('Biaya transport: ${_rupiah(transportFee)}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  if (_loading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                  if (_loadError != null) ...[
                    const SizedBox(height: 8),
                    Text('Sebagian data gagal dimuat: $_loadError',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.danger)),
                    TextButton.icon(
                      onPressed: _loadOrderData,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _statusSlider(),
        ],
      ),
    );
  }

  Widget _infoColumn(
    String titleOne,
    String valueOne,
    String titleTwo,
    String valueTwo, {
    bool highlightValue = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoPair(titleOne, valueOne, highlight: highlightValue),
        if (actionLabel != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _infoPair(titleTwo, valueTwo, highlight: highlightValue),
      ],
    );
  }

  Widget _infoPair(String title, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.35,
            color: highlight ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _statusSlider() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _stages[_stage],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
                Text('${_stage + 1}/${_stages.length}',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            Slider(
              value: _sliderPreview,
              min: 0,
              max: (_stages.length - 1).toDouble(),
              divisions: _stages.length - 1,
              label: _stages[_stage],
              activeColor: _stage == _stages.length - 1
                  ? const Color(0xFF27834A)
                  : AppColors.primary,
              onChanged: _updatingStatus ||
                      _orderId == null ||
                      _stage == _stages.length - 1
                  ? null
                  : (value) => setState(() => _sliderPreview = value),
              onChangeEnd: _updatingStatus ||
                      _orderId == null ||
                      _stage == _stages.length - 1
                  ? null
                  : (value) {
                      if (value.round() <= _stage) {
                        setState(() => _sliderPreview = _stage.toDouble());
                        return;
                      }
                      final nextStage = _stage + 1;
                      setState(() => _sliderPreview = nextStage.toDouble());
                      _updateStatus(nextStage);
                    },
            ),
            Text(
              _updatingStatus
                  ? 'Memperbarui status pesanan...'
                  : _orderId == null
                      ? 'Detail demo · status tidak disimpan'
                      : 'Geser untuk memperbarui progres pesanan',
              style:
                  GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(int nextStage) async {
    final id = _orderId;
    if (id == null) return;
    final status = switch (nextStage) {
      1 => 'on_the_way',
      2 => 'in_progress',
      _ => 'completed',
    };
    setState(() => _updatingStatus = true);
    try {
      await ApiClient().patch(
        ApiEndpoints.updateOrderStatus(id),
        data: {'status': status},
      );
      if (!mounted) return;
      setState(() {
        _stage = nextStage;
        _sliderPreview = nextStage.toDouble();
        _updatingStatus = false;
        _order['status'] = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status: ${_stages[_stage]}')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sliderPreview = _stage.toDouble();
        _updatingStatus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status gagal diperbarui: $error')),
      );
    }
  }

  Future<void> _chooseService() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katalog layanan belum tersedia.')),
      );
      return;
    }
    final currentIds = _items
        .map((item) => _asInt(item['service_item_id'] ?? item['service_id']))
        .whereType<int>()
        .toSet();
    final selectedIds = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final selected = Set<int>.from(currentIds);
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.76,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Pilih Layanan',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        final id = _asInt(service['id']);
                        return CheckboxListTile(
                          value: id != null && selected.contains(id),
                          activeColor: AppColors.primary,
                          title: Text(service['name'] as String? ?? 'Layanan'),
                          subtitle: Text(
                            '${_rupiah(_number(service['base_price']))} · ${service['estimated_minutes'] ?? 60} menit',
                          ),
                          onChanged: id == null
                              ? null
                              : (value) => setSheetState(() {
                                    if (value == true) {
                                      selected.add(id);
                                    } else {
                                      selected.remove(id);
                                    }
                                  }),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => Navigator.pop(context, selected),
                        child: const Text('Terapkan Layanan'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selectedIds == null ||
        (selectedIds.length == currentIds.length &&
            selectedIds.containsAll(currentIds))) {
      return;
    }
    await _replaceServices(selectedIds.toList());
  }

  Future<void> _replaceServices(List<int> serviceIds) async {
    final id = _orderId;
    if (id == null) return;
    setState(() => _updatingService = true);
    try {
      final response = await ApiClient().patch(
        ApiEndpoints.updateOrderServices(id),
        data: {
          'services': serviceIds
              .map((serviceId) => {'service_item_id': serviceId, 'quantity': 1})
              .toList(),
        },
      );
      if (!mounted) return;
      final data = response is Map && response['data'] is Map
          ? _map(response['data'] as Map)
          : <String, dynamic>{};
      setState(() {
        _order = {..._order, ...data};
        final rows = data['items'];
        if (rows is List) _items = rows.whereType<Map>().map(_map).toList();
        _updatingService = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan order berhasil diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _updatingService = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah layanan: $error')),
      );
    }
  }

  Future<void> _showAddCostDialog() async {
    if (_orderId == null) return;
    final submitted = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddCostDialog(),
    );
    if (submitted == null) return;
    try {
      await ApiClient().post(
        ApiEndpoints.additionalCosts(_orderId!),
        data: {
          ...submitted,
          'quantity': 1,
          'description':
              'Ditambahkan teknisi sesuai kesepakatan dengan pelanggan.',
        },
      );
      await _loadOrderData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biaya tambahan dicatat ke pesanan.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biaya gagal ditambahkan: $error')),
      );
    }
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Siap disambungkan saat halaman chat tersedia.')),
    );
  }

  double get _serviceAmount {
    final itemTotal = _items.fold<double>(
      0,
      (sum, item) => sum + _number(item['total_price'] ?? item['subtotal']),
    );
    if (_items.isNotEmpty) return itemTotal;
    return _number(_order['subtotal']);
  }

  String get _serviceLabel {
    final names = _items
        .map((item) => item['service_name'] ?? item['name'])
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isNotEmpty) return names.join(', ');
    return _order['serviceName'] as String? ?? 'Layanan belum tersedia';
  }

  Map<String, dynamic> _map(Map<dynamic, dynamic> value) =>
      Map<String, dynamic>.from(value);

  String? _relationName(dynamic relation) {
    if (relation is Map) return relation['name'] as String?;
    return null;
  }

  LatLng? _point(dynamic latValue, dynamic lonValue) {
    final lat = _asDoubleNullable(latValue);
    final lon = _asDoubleNullable(lonValue);
    if (lat == null || lon == null) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return LatLng(lat, lon);
  }

  LatLng _mapCenter(LatLng? technician, LatLng? customer) {
    if (technician != null && customer != null) {
      return LatLng(
        (technician.latitude + customer.latitude) / 2,
        (technician.longitude + customer.longitude) / 2,
      );
    }
    return customer ?? technician ?? const LatLng(1.12, 104.04);
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _asDoubleNullable(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _paymentLabel(dynamic value) => switch (value) {
        'qris' => 'QRIS',
        'transfer' => 'Transfer',
        'cash' => 'Tunai',
        _ => 'Tunai',
      };

  String _rupiah(double value) {
    final amount = value.round().toString();
    final formatted = amount.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }
}

class _AddCostDialog extends StatefulWidget {
  const _AddCostDialog();

  @override
  State<_AddCostDialog> createState() => _AddCostDialogState();
}

class _AddCostDialogState extends State<_AddCostDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (name.isEmpty) {
      setState(() => _validationMessage = 'Nama biaya wajib diisi.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _validationMessage = 'Masukkan harga lebih dari nol.');
      return;
    }
    Navigator.of(context).pop<Map<String, dynamic>>({
      'item_name': name,
      'unit_price': price,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Biaya Lain'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                const InputDecoration(labelText: 'Nama biaya/sparepart'),
          ),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Harga (Rp)'),
            onSubmitted: (_) => _submit(),
          ),
          if (_validationMessage != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _validationMessage!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Tambahkan')),
      ],
    );
  }
}
