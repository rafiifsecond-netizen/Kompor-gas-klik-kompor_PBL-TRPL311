import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class NotificationCardWidget extends StatelessWidget {
  final String title;
  final String message;
  final String tag;
  final String time;
  final IconData icon;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    super.key,
    required this.title,
    required this.message,
    required this.tag,
    this.time = 'Hari ini',
    this.icon = Icons.notifications_active_rounded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color tagBg = const Color(0xFFD9D9DD);
    Color tagColor = Colors.black87;
    if (tag == 'Selesai') {
      tagBg = AppColors.success;
      tagColor = Colors.white;
    } else if (tag == 'Status' || tag == 'Order') {
      tagBg = AppColors.primary;
      tagColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2B2B2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(12)),
                      child: Text(tag, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: tagColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF5D5555), height: 1.3),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF767676)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
