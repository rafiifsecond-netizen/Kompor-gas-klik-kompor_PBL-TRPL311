import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class TechnicianPendingScreen extends StatefulWidget {
  const TechnicianPendingScreen({super.key});

  @override
  State<TechnicianPendingScreen> createState() => _TechnicianPendingScreenState();
}

class _TechnicianPendingScreenState extends State<TechnicianPendingScreen> {
  bool _isChecking = false;
  String _status = 'pending';
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final response = await ApiClient().get(ApiEndpoints.technicianRegistrationStatus);
      if (response is Map && response['data'] is Map) {
        final data = response['data'] as Map;
        final newStatus = data['status']?.toString() ?? 'pending';
        final isVerified = data['is_verified'] == true;
        final reason = data['rejection_reason']?.toString();

        setState(() {
          _status = newStatus;
          _rejectionReason = reason;
        });

        if (newStatus == 'approved' || isVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selamat! Akun Anda telah disetujui.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.technicianDashboard,
              (r) => false,
            );
          }
        }
      }
    } catch (_) {
      // Keep current state
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRejected = _status == 'rejected';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Status Pendaftaran Teknisi',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Status Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isRejected
                      ? Colors.red.shade50
                      : Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isRejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_rounded,
                    size: 50,
                    color: isRejected ? Colors.red.shade600 : Colors.amber.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                isRejected
                    ? 'Pendaftaran Belum Disetujui'
                    : 'Pendaftaran Sedang Ditinjau',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isRejected ? Colors.red.shade900 : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle / Body
              Text(
                isRejected
                    ? 'Mohon maaf, pendaftaran akun teknisi Anda ditolak oleh Admin KlikKompor.'
                    : 'Terima kasih telah mendaftar sebagai mitra teknisi KlikKompor. Berkas pendaftaran dan dokumen Anda saat ini sedang dalam proses peninjauan oleh tim Admin kami.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              if (isRejected && _rejectionReason != null && _rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Penolakan:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _rejectionReason!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Refresh Status Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    _isChecking ? 'Memeriksa...' : 'Periksa Status Terbaru',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Keluar ke Halaman Login',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
