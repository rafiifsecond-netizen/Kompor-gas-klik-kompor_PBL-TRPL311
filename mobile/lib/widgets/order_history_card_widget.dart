import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class OrderHistoryCardWidget extends StatelessWidget {
  final String title;
  final String orderNumber;
  final String date;
  final String price;
  final String status;
  final VoidCallback? onReviewTap;
  final VoidCallback? onReorderTap;
  final VoidCallback? onTap;

  const OrderHistoryCardWidget({
    super.key,
    required this.title,
    required this.orderNumber,
    required this.date,
    required this.price,
    this.status = 'Selesai',
    this.onReviewTap,
    this.onReorderTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB2B2B2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Selesai' ? AppColors.success : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      orderNumber,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF5D5555)),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFFB2B2B2))),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF5D5555)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    Row(
                      children: [
                        if (onReviewTap != null) ...[
                          OutlinedButton(
                            onPressed: onReviewTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFFB2B2B2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              minimumSize: const Size(70, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: Text('Beri ulasan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: onReorderTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            minimumSize: const Size(70, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text('Pesan lagi', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
