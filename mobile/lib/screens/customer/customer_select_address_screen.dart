import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

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
      'recipientName': 'Setiawan Ade',
      'recipientPhone': '+62 800 0000 0000',
      'addressLine': 'Jl. Ahmad Yani No. 12, RT 03/RW 05, Kel. Tanjung Uncang, Kec. Batu Aji, Kota Batam, Kepulauan Riau 29422',
      'province': 'Kepulauan Riau',
      'city': 'Kota Batam',
      'district': 'Batu Aji',
      'subDistrict': 'Tanjung Uncang',
      'rt': '03',
      'rw': '05',
      'isDefault': true,
    },
    {
      'id': 2,
      'label': 'Kantor',
      'recipientName': 'Setiawan Ade',
      'recipientPhone': '+62 800 0000 0000',
      'addressLine': 'Jl. Sei Beduk No 77, Kel. Baloi Indah, Kec. Lubuk Baja, Kota Batam, Kepulauan Riau',
      'province': 'Kepulauan Riau',
      'city': 'Kota Batam',
      'district': 'Lubuk Baja',
      'subDistrict': 'Baloi Indah',
      'rt': '01',
      'rw': '02',
      'isDefault': false,
    },
  ];

  void _onNavTap(int index) {
    final route = switch (index) {
      0 => AppRoutes.customerHome,
      1 => AppRoutes.customerOrderHistory,
      2 => AppRoutes.customerChat,
      3 => AppRoutes.customerProfile,
      _ => null,
    };
    if (route != null) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _openEditAddressForm({Map<String, dynamic>? initialData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _EditAddressScreen(
          initialData: initialData,
          onSave: (newData) {
            setState(() {
              if (initialData != null) {
                final idx = _addresses.indexWhere((a) => a['id'] == initialData['id']);
                if (idx != -1) {
                  _addresses[idx] = newData;
                }
              } else {
                final newId = _addresses.length + 1;
                newData['id'] = newId;
                _addresses.add(newData);
                _selectedAddressId = newId;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(initialData != null ? 'Alamat berhasil diperbarui!' : 'Alamat baru berhasil ditambahkan!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Text(
                  'Alamat saya',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Banner Info ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1A8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFFF7A00),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atur alamat Anda',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kelola alamat pengiriman Anda untuk mempermudah proses pemesanan.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Section: Daftar Alamat + Button Tambah Alamat ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Alamat',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openEditAddressForm(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'Tambah Alamat',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Address Cards List ──────────────────────────────────────────
            ..._addresses.map((addr) => _buildAddressCard(addr)),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final id = addr['id'] as int;
    final isSelected = _selectedAddressId == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE8D6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF666666),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      addr['label'] == 'Kantor' ? Icons.apartment_rounded : Icons.home_outlined,
                      size: 26,
                      color: isSelected ? const Color(0xFFFF7A00) : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      addr['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
                  onPressed: () => _openEditAddressForm(initialData: addr),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              addr['recipientName'] as String,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              addr['recipientPhone'] as String,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    addr['addressLine'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT / TAMBAH ALAMAT SCREEN (Matching Reference Screenshot & GPS Locator)
// ─────────────────────────────────────────────────────────────────────────────
class _EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _EditAddressScreen({
    this.initialData,
    required this.onSave,
  });

  @override
  State<_EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<_EditAddressScreen> {
  String _selectedLabel = 'Rumah'; // 'Rumah', 'Kantor', 'Lainnya'
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _rtController;
  late final TextEditingController _rwController;

  String _province = 'Kepulauan Riau';
  String _city = 'Kota Batam';
  String _district = 'Batu Aji';
  String _subDistrict = 'Tanjung Uncang';
  bool _isDefault = true;
  bool _isLocatingGPS = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _selectedLabel = d?['label'] as String? ?? 'Rumah';
    _nameController = TextEditingController(text: d?['recipientName'] as String? ?? 'Setiawan Ade');
    _phoneController = TextEditingController(text: d?['recipientPhone'] as String? ?? '+62 800 0000 0000');
    _addressController = TextEditingController(
      text: d?['addressLine'] as String? ?? 'Jl. Ahmad Yani No. 12, RT 03/RW 05, Kel. Tanjung Uncang, Kec. Batu Aji, Kota Batam, Kepulauan Riau 29422',
    );
    _rtController = TextEditingController(text: d?['rt'] as String? ?? '03');
    _rwController = TextEditingController(text: d?['rw'] as String? ?? '05');
    _isDefault = d?['isDefault'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocatingGPS = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _isLocatingGPS = false;
      _addressController.text = 'Jl. Ahmad Yani No. 12, RT 03/RW 05, Kel. Tanjung Uncang, Kec. Batu Aji, Kota Batam, Kepulauan Riau 29422';
      _province = 'Kepulauan Riau';
      _city = 'Kota Batam';
      _district = 'Batu Aji';
      _subDistrict = 'Tanjung Uncang';
      _rtController.text = '03';
      _rwController.text = '05';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi terkini berhasil terdeteksi via GPS!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.initialData != null ? 'Edit Alamat' : 'Tambah Alamat',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tombol Pilih Lokasi Terkini ──────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: OutlinedButton.icon(
                onPressed: _isLocatingGPS ? null : _getCurrentLocation,
                icon: _isLocatingGPS
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF7A00)))
                    : const Icon(Icons.my_location_rounded, color: Color(0xFFFF7A00), size: 20),
                label: Text(
                  _isLocatingGPS ? 'Mendeteksi Lokasi GPS...' : 'Gunakan Lokasi Saat Ini (GPS)',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFF7A00)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFF7A00), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0xFFFFF7F0),
                ),
              ),
            ),

            // ── Section 1: Jenis Alamat ─────────────────────────────────────
            Text(
              'Jenis Alamat',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAddressTypeTile(
                      label: 'Rumah',
                      icon: Icons.home_rounded,
                      isSelected: _selectedLabel == 'Rumah',
                      onTap: () => setState(() => _selectedLabel = 'Rumah'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildAddressTypeTile(
                      label: 'Kantor',
                      icon: Icons.apartment_rounded,
                      isSelected: _selectedLabel == 'Kantor',
                      onTap: () => setState(() => _selectedLabel = 'Kantor'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildAddressTypeTile(
                      label: 'Lainnya',
                      icon: Icons.location_on_rounded,
                      isSelected: _selectedLabel == 'Lainnya',
                      onTap: () => setState(() => _selectedLabel = 'Lainnya'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section 2: Nama Penerima ────────────────────────────────────
            Text(
              'Nama Penerima',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 8),
            _buildInputField(controller: _nameController, hint: 'Nama Penerima'),

            const SizedBox(height: 20),

            // ── Section 3: Nomor HP ─────────────────────────────────────────
            Text(
              'Nomor HP',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 8),
            _buildInputField(controller: _phoneController, hint: '+62 800 0000 0000', keyboardType: TextInputType.phone),

            const SizedBox(height: 20),

            // ── Section 4: Alamat Lengkap ───────────────────────────────────
            Text(
              'Alamat Lengkap',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(height: 8),
            _buildInputField(controller: _addressController, hint: 'Tulis alamat lengkap...', maxLines: 3),

            const SizedBox(height: 20),

            // ── Section 5: Provinsi & Kota/Kabupaten ────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Provinsi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _province,
                        items: ['Kepulauan Riau', 'Riau', 'DKI Jakarta', 'Jawa Barat'],
                        onChanged: (v) => setState(() => _province = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kota/Kabupaten', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _city,
                        items: ['Kota Batam', 'Kota Tanjungpinang', 'Kabupaten Bintan'],
                        onChanged: (v) => setState(() => _city = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section 6: Kecamatan & Kelurahan ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kecamatan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _district,
                        items: ['Batu Aji', 'Lubuk Baja', 'Batam Kota', 'Sekupang'],
                        onChanged: (v) => setState(() => _district = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kelurahan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _subDistrict,
                        items: ['Tanjung Uncang', 'Baloi Indah', 'Belian', 'Batu Besar'],
                        onChanged: (v) => setState(() => _subDistrict = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section 7: RT & RW ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RT', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildInputField(controller: _rtController, hint: '03'),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RW', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildInputField(controller: _rwController, hint: '05'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Section 8: Jadikan Sebagai Alamat Utama Card ───────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadikan sebagai alamat utama',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alamat ini akan digunakan sebagai alamat default untuk pengiriman.',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isDefault,
                    activeThumbColor: const Color(0xFFFF7A00),
                    onChanged: (val) => setState(() => _isDefault = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Section 9: Simpan Perubahan Button ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave({
                    'id': widget.initialData?['id'] ?? 1,
                    'label': _selectedLabel,
                    'recipientName': _nameController.text.trim(),
                    'recipientPhone': _phoneController.text.trim(),
                    'addressLine': _addressController.text.trim(),
                    'province': _province,
                    'city': _city,
                    'district': _district,
                    'subDistrict': _subDistrict,
                    'rt': _rtController.text.trim(),
                    'rw': _rwController.text.trim(),
                    'isDefault': _isDefault,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTypeTile({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0E6) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFD0D0D0),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: isSelected ? const Color(0xFFFF7A00) : Colors.black87, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7A00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
