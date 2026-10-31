import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../repositories/address_repository.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/constants/app_colors.dart';

class Address {
  final int id;
  final String label, name, phone, detail;
  final String? notes;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const Address(
    this.id,
    this.label,
    this.name,
    this.phone,
    this.detail,
    this.isDefault, {
    this.notes,
    this.latitude,
    this.longitude,
  });

  Address copyWith({
    int? id,
    String? label,
    String? name,
    String? phone,
    String? detail,
    String? notes,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) =>
      Address(
        id ?? this.id,
        label ?? this.label,
        name ?? this.name,
        phone ?? this.phone,
        detail ?? this.detail,
        isDefault ?? this.isDefault,
        notes: notes ?? this.notes,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  Map<String, dynamic> toSelectionPayload() => {
        'id': id,
        'label': label,
        'name': name,
        'phone': phone,
        'address': detail,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class CustomerSelectAddressScreen extends StatefulWidget {
  const CustomerSelectAddressScreen({super.key});

  @override
  State<CustomerSelectAddressScreen> createState() =>
      _CustomerSelectAddressScreenState();
}

class _CustomerSelectAddressScreenState
    extends State<CustomerSelectAddressScreen> {
  final List<Address> _addresses = [];
  final _repository = AddressRepository();
  bool _isLoading = true;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> rows = const [];
    try {
      rows = await _repository.getAddresses();
    } catch (_) {
      rows = const [];
    }
    if (!mounted) return;
    setState(() {
      _addresses
        ..clear()
        ..addAll(rows.map((row) {
          final isDef = row['is_default'] == true ||
              row['is_default'] == 1 ||
              row['is_default'] == '1';
          return Address(
            row['id'] is int
                ? row['id'] as int
                : int.tryParse(row['id']?.toString() ?? '') ?? 0,
            row['label'] as String? ?? 'Rumah',
            row['recipient_name'] as String? ?? '',
            row['phone'] as String? ?? '',
            row['full_address'] as String? ?? '',
            isDef,
            notes: row['notes'] as String?,
            latitude: double.tryParse(row['latitude']?.toString() ?? ''),
            longitude: double.tryParse(row['longitude']?.toString() ?? ''),
          );
        }));

      if (_selectedId == null && _addresses.isNotEmpty) {
        final def = _addresses.firstWhere((a) => a.isDefault,
            orElse: () => _addresses.first);
        _selectedId = def.id;
      }
      _isLoading = false;
    });
  }

  void _navigate(int index) {
    final routes = <int, String>{
      0: AppRoutes.customerHome,
      1: AppRoutes.customerOrderHistory,
      2: AppRoutes.customerChat,
      3: AppRoutes.customerProfile
    };
    final route = routes[index];
    if (route != null && index != 3) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Future<void> _openAddressForm([Address? address]) async {
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressFormSheet(address: address),
    );

    if (result != null && mounted) {
      await _loadAddresses();
      setState(() => _selectedId = result.id);
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Hapus Alamat',
      message: 'Apakah Anda yakin ingin menghapus alamat "${address.label}"?',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !mounted) return;

    try {
      await _repository.delete(address.id);
      await _loadAddresses();
      if (mounted) {
        AppFeedback.success(context, 'Alamat berhasil dihapus.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, 'Gagal menghapus alamat: $e');
      }
    }
  }

  Future<void> _setDefault(int addressId) async {
    try {
      await _repository.setDefault(addressId);
      await _loadAddresses();
      if (mounted) {
        AppFeedback.success(context, 'Alamat utama berhasil diperbarui.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, 'Gagal mengubah alamat utama: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selecting = RouteArgs.of<String>(context) == 'select';

    return Scaffold(
      backgroundColor: AppColors.addressBackground,
      appBar: AppBar(
        title: Text(selecting ? 'Pilih Alamat Layanan' : 'Alamat Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAddresses,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const _InfoBanner(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Alamat',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (_addresses.isNotEmpty)
                    Text(
                      '${_addresses.length} tersimpan',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddressForm(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    'Tambah Alamat Baru',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_addresses.isEmpty)
                _buildEmptyState()
              else
                ..._addresses
                    .map((address) => _addressCard(address, selecting)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: selecting
          ? null
          : CustomBottomNavBar(currentIndex: 3, onTap: _navigate),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.addressBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Alamat Tersimpan',
            style:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik tombol "Tambah Alamat Baru" di atas untuk menambahkan alamat pemesanan servis kompor Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(Address address, bool selecting) {
    final selected = address.id == _selectedId;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: selected ? AppColors.addressSelected : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.addressBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (selecting) {
            Navigator.pop(context, address.toSelectionPayload());
          } else {
            setState(() => _selectedId = address.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    address.label == 'Kantor'
                        ? Icons.business_rounded
                        : address.label == 'Apartemen'
                            ? Icons.apartment_rounded
                            : Icons.home_rounded,
                    color: selected ? AppColors.primary : Colors.black87,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.label,
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (address.isDefault) const _DefaultBadge(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                address.name,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                address.phone,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                address.detail,
                style: GoogleFonts.inter(fontSize: 13, height: 1.4),
              ),
              if (address.notes != null && address.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Catatan: ${address.notes!}',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!address.isDefault)
                    TextButton(
                      onPressed: () => _setDefault(address.id),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Jadikan Alamat Utama',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 19, color: AppColors.primary),
                        tooltip: 'Edit Alamat',
                        onPressed: () => _openAddressForm(address),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 19, color: AppColors.danger),
                        tooltip: 'Hapus Alamat',
                        onPressed: () => _deleteAddress(address),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final Address? address;
  const _AddressFormSheet({this.address});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl, _phoneCtrl, _addressCtrl, _notesCtrl;
  late String _label;
  late bool _isDefault;
  bool _isSaving = false;

  final List<String> _labelOptions = ['Rumah', 'Kantor', 'Apartemen', 'Kos', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _phoneCtrl = TextEditingController(text: a?.phone ?? '');
    _addressCtrl = TextEditingController(text: a?.detail ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _label = a?.label ?? 'Rumah';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        'label': _label,
        'recipient_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'full_address': _addressCtrl.text.trim(),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'is_default': _isDefault,
        'latitude': widget.address?.latitude ?? -6.2088,
        'longitude': widget.address?.longitude ?? 106.8456,
      };

      final res = await AddressRepository().save(
        payload,
        id: widget.address?.id,
      );

      if (!mounted) return;

      final savedId = res['id'] is int
          ? res['id'] as int
          : int.tryParse(res['id']?.toString() ?? '') ?? widget.address?.id ?? 0;

      final savedAddress = Address(
        savedId,
        _label,
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _addressCtrl.text.trim(),
        _isDefault,
        notes: _notesCtrl.text.trim(),
        latitude: widget.address?.latitude ?? -6.2088,
        longitude: widget.address?.longitude ?? 106.8456,
      );

      Navigator.pop(context, savedAddress);
      AppFeedback.success(
        context,
        widget.address == null
            ? 'Alamat berhasil ditambahkan.'
            : 'Alamat berhasil diperbarui.',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppFeedback.error(context, 'Gagal menyimpan alamat: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.address != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Alamat' : 'Tambah Alamat Baru',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Label Alamat',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _labelOptions.map((opt) {
                  final isSelected = _label == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _label = opt);
                    },
                    selectedColor: AppColors.primaryLight,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Penerima',
                  hintText: 'Contoh: Dewi Lestari',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    Validators.required(v, label: 'Nama penerima'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp / HP',
                  hintText: 'Contoh: 081234567890',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    Validators.required(v, label: 'Nomor telepon'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  hintText:
                      'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    Validators.required(v, label: 'Alamat lengkap'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Catatan / Patokan Lokasi (Opsional)',
                  hintText: 'Contoh: Rumah cat putih, pagar hitam',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
                onChanged: (val) => setState(() => _isDefault = val),
                title: Text(
                  'Jadikan Alamat Utama',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Alamat ini akan otomatis dipilih saat melakukan booking servis',
                  style: GoogleFonts.inter(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Simpan Alamat',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressFormScreen extends StatelessWidget {
  final Address? address;
  const AddressFormScreen({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(address == null ? 'Tambah Alamat' : 'Edit Alamat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _AddressFormSheet(address: address),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paleOrange,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kelola alamat Anda untuk mempercepat dan mempermudah proses pemesanan servis kompor gas.',
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.darkText, height: 1.35),
              ),
            ),
          ],
        ),
      );
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: const Text(
          'Utama',
          style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      );
}
