import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CustomerReviewScreen extends StatefulWidget {
  const CustomerReviewScreen({super.key});
  @override
  State<CustomerReviewScreen> createState() => _CustomerReviewScreenState();
}

class _CustomerReviewScreenState extends State<CustomerReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Beri Ulasan'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 12),
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFEFE2)),
            child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text('Bagaimana pelayanan teknisi?', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Beri rating dan ulasan Anda', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(i < _rating ? Icons.star_rounded : Icons.star_border_rounded, size: 44, color: AppColors.star),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text(_ratingLabel(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.star)),
          const SizedBox(height: 24),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalaman Anda (opsional)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              filled: true, fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (_rating == 0 || _isSubmitting) ? null : () async {
              setState(() => _isSubmitting = true);
              await Future.delayed(const Duration(seconds: 1));
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ulasan berhasil dikirim! Terima kasih.'), backgroundColor: AppColors.success),
              );
              // ignore: use_build_context_synchronously
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (r) => false);
            },
            child: _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('Kirim Ulasan'),
          ),
        ]),
      ),
    );
  }

  String _ratingLabel() {
    switch (_rating) {
      case 1: return 'Sangat Buruk';
      case 2: return 'Buruk';
      case 3: return 'Cukup';
      case 4: return 'Baik';
      case 5: return 'Sangat Baik';
      default: return 'Pilih rating';
    }
  }
}
