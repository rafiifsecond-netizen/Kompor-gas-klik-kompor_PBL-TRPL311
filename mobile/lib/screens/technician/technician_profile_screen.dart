// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../repositories/profile_repository.dart';
import '../../core/utils/validators.dart';

class TechnicianProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const TechnicianProfileScreen({super.key, this.showBackButton = false});
  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final _profileRepository = ProfileRepository();
  late UserModel _profileUser;
  late Map<String, dynamic> _profileStatistics;

  @override
  void initState() {
    super.initState();
    final initial = _profileRepository.technicianProfile;
    _profileUser = initial['user'] as UserModel;
    _profileStatistics =
        initial['statistics'] as Map<String, dynamic>;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileRepository.getTechnicianProfile();
    if (!mounted) return;
    setState(() {
      _profileUser = profile['user'] as UserModel;
      _profileStatistics = profile['statistics'] as Map<String, dynamic>;
    });
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileData = <String, dynamic>{
      'statistics': _profileStatistics,
    };
    final user = _profileUser;
    final profile = user.technicianProfile!;

    final double rating = profile.ratingAverage;
    final int completedJobs = profile.totalCompletedOrders;
    final int reviewCount = profile.totalReviews;
    final chatResponseRate =
        profileData['statistics']['chat_response_rate'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil Teknisi',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showEditProfileModal(context, user.name,
                user.phone ?? '', user.address ?? '', user),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allLg,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: AppSpacing.all20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryAccent]),
                borderRadius: AppRadius.extraLarge,
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.substring(0, 2).toUpperCase()
                            : 'TK',
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.small),
                          child: Text('Teknisi Spesialis',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Akumulasi Performa Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Akumulasi Performa Kerja',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.technicianPerformance),
                  child: const Text('Detail'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: 'Rating Rata-rata',
                    value: '$rating ⭐',
                    subtitle: 'Dari $reviewCount ulasan',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.assignment_turned_in_rounded,
                    iconColor: Colors.green,
                    title: 'Order Selesai',
                    value: '$completedJobs Pesanan',
                    subtitle: 'Tepat waktu',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.chat_bubble_rounded,
                    iconColor: AppColors.primary,
                    title: 'Respon Chat',
                    value: chatResponseRate,
                    subtitle: 'Dibalas cepat',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.verified_rounded,
                    iconColor: Colors.blue,
                    title: 'Status Akun',
                    value: profile.isVerified
                        ? 'Terverifikasi'
                        : 'Pending',
                    subtitle: 'Mitra resmi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details Section
            Text('Informasi Akun',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.phone_outlined, 'Nomor Telepon',
                      user.phone ?? ''),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.location_on_outlined, 'Alamat',
                      user.address ?? ''),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.security_outlined, 'Peran Sistem',
                      'Teknisi Lapangan'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                final nav = Navigator.of(context);
                await auth.logout();
                nav.pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text('Keluar Akun',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.danger),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.medium),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<bool> _saveProfile({
    required String name,
    required String phone,
    required String address,
    required UserModel currentUser,
  }) async {
    try {
      final updated = await _profileRepository.updateProfile(
        currentUser: currentUser,
        name: name,
        phone: phone,
        address: address,
      );
      if (mounted) setState(() => _profileUser = updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showEditProfileModal(BuildContext context, String currentName,
      String currentPhone, String currentAddress, UserModel currentUser) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final addressCtrl = TextEditingController(text: currentAddress);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Profil Teknisi',
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    validator: (v) => Validators.required(v, label: 'Nama'),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: const OutlineInputBorder(
                          borderRadius: AppRadius.medium),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    validator: (v) => Validators.required(v, label: 'Nomor telepon'),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: const OutlineInputBorder(
                          borderRadius: AppRadius.medium),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    validator: (v) => Validators.required(v, label: 'Alamat'),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: const OutlineInputBorder(
                          borderRadius: AppRadius.medium),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setStateModal(() => isLoading = true);
                              if (!formKey.currentState!.validate()) {
                                setStateModal(() => isLoading = false);
                                return;
                              }
                              final ok = await _saveProfile(
                                name: nameCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                currentUser: currentUser,
                              );
                              setStateModal(() => isLoading = false);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Profil berhasil diperbarui!'
                                        : 'Gagal memperbarui profil.'),
                                    backgroundColor:
                                        ok ? Colors.green : AppColors.danger,
                                  ),
                                );
                              }

                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Simpan Perubahan',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String value,
      required String subtitle}) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black)),
          const SizedBox(height: 2),
          Text(subtitle,
              style:
                  AppTextStyles.micro.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 14),
          SizedBox(
            width: 120,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
