import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/app_routes.dart';
import '../../core/routes/route_args.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../repositories/address_repository.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/constants/app_colors.dart';

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
  int _selectedId = 1;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final rows = await _repository.getAddresses();
    if (!mounted) return;
    setState(() {
      _addresses
        ..clear()
        ..addAll(rows.map((row) => Address(
              row['id'] as int,
              row['label'] as String? ?? 'Rumah',
              row['name'] as String? ?? 'Setiawan Ade',
              row['phone'] as String? ?? '+62 800 0000 0000',
              row['address'] as String? ?? '',
              row['is_default'] == true,
            )));
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

  Future<void> _editAddress([Address? address]) async {
    final result = await Navigator.pushNamed<Address>(
      context,
      AppRoutes.customerEditAddress,
      arguments: address,
    );
    if (!mounted || result == null) return;
    await _repository.saveDummy({
      'id': result.id == 0 ? null : result.id,
      'label': result.label,
      'name': result.name,
      'phone': result.phone,
      'address': result.detail,
      'is_default': result.isDefault,
    });
    await _loadAddresses();
    setState(() {
      final index = _addresses.indexWhere((item) => item.id == result.id);
      if (index == -1) {
        final newId = (_addresses
                .map((item) => item.id)
                .fold(0, (max, id) => id > max ? id : max)) +
            1;
        _addresses.add(result.copyWith(id: newId));
        _selectedId = newId;
      } else {
        _addresses[index] = result;
        _selectedId = result.id;
      }
      if (result.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] =
              _addresses[i].copyWith(isDefault: _addresses[i].id == result.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selecting = RouteArgs.of<String>(context) == 'select';
    return Scaffold(
      backgroundColor: AppColors.addressBackground,
      appBar: AppBar(
          title: const Text('Alamat Saya'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const _InfoBanner(),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daftar Alamat',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _editAddress(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Alamat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._addresses.map((address) => _addressCard(address, selecting)),
          ],
        ),
      ),
      bottomNavigationBar: selecting
          ? null
          : CustomBottomNavBar(currentIndex: 3, onTap: _navigate),
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
              color:
                  selected ? AppColors.addressOrange : AppColors.addressBorder,
              width: selected ? 1.5 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (selecting) {
            Navigator.pop(context, address.detail);
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
                          ? Icons.business
                          : Icons.home_outlined,
                      color:
                          selected ? AppColors.addressOrange : Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(address.label,
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis)),
                  if (address.isDefault) const _DefaultBadge(),
                ],
              ),
              const SizedBox(height: 10),
              Text(address.name,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(address.phone, style: GoogleFonts.inter(fontSize: 13)),
              const SizedBox(height: 6),
              Text(address.detail,
                  style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _editAddress(address),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Address {
  final int id;
  final String label, name, phone, detail;
  final bool isDefault;

  const Address(
      this.id, this.label, this.name, this.phone, this.detail, this.isDefault);

  Address copyWith({int? id, bool? isDefault}) => Address(
      id ?? this.id, label, name, phone, detail, isDefault ?? this.isDefault);
}

class AddressFormScreen extends StatefulWidget {
  final Address? address;
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _phone, _detail;
  late bool _default;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _name = TextEditingController(text: address?.name ?? '');
    _phone = TextEditingController(text: address?.phone ?? '');
    _detail = TextEditingController(text: address?.detail ?? '');
    _default = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim(),
        phone = _phone.text.trim(),
        detail = _detail.text.trim();
    if (name.isEmpty || phone.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nama, nomor HP, dan alamat wajib diisi.')));
      return;
    }
    final saved = await AddressRepository().saveDummy({
      'id': widget.address?.id,
      'label': widget.address?.label ?? 'Rumah',
      'name': name,
      'phone': phone,
      'address': detail,
      'is_default': _default,
    });
    if (!mounted) return;
    Navigator.pop(
        context,
        Address(saved['id'] as int, saved['label'] as String, name, phone,
            detail, saved['is_default'] == true));
    AppFeedback.success(context, 'Alamat berhasil disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.address == null ? 'Tambah Alamat' : 'Edit Alamat'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _field('Nama Penerima', _name, Icons.person_outline,
                  validator: (v) =>
                      Validators.required(v, label: 'Nama penerima')),
              const SizedBox(height: 16),
              _field('Nomor HP', _phone, Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.required(v, label: 'Nomor HP')),
              const SizedBox(height: 16),
              _field('Alamat Lengkap', _detail, Icons.location_on_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      Validators.required(v, label: 'Alamat lengkap')),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _default,
                  activeThumbColor: AppColors.addressOrange,
                  onChanged: (value) => setState(() => _default = value),
                  title: const Text('Jadikan alamat utama')),
              const SizedBox(height: 24),
              SizedBox(
                  height: 52,
                  child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.addressOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text(widget.address == null
                          ? 'Simpan Alamat'
                          : 'Simpan Perubahan'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon,
          {int maxLines = 1,
          TextInputType keyboardType = TextInputType.text,
          String? Function(String?)? validator}) =>
      TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: validator);
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.addressAccent,
          borderRadius: BorderRadius.circular(16)),
      child: const Row(children: [
        Icon(Icons.location_on, color: AppColors.addressOrange, size: 28),
        SizedBox(width: 12),
        Expanded(
            child:
                Text('Kelola alamat Anda untuk mempercepat proses pemesanan.'))
      ]));
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.addressLight,
          borderRadius: BorderRadius.circular(6)),
      child: const Text('Utama',
          style: TextStyle(
              color: AppColors.addressDark,
              fontSize: 11,
              fontWeight: FontWeight.bold)));
}
