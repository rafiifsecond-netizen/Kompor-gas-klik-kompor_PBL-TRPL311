import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class KlikLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const KlikLogoWidget({
    super.key,
    this.size = 90,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFA7D10), Color(0xFFFF9E43)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: size * 0.62,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Klik',
                  style: GoogleFonts.inter(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w800,
                    color: textColor ?? AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Kompor',
                  style: GoogleFonts.inter(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solusi Cepat Servis Kompor Gas',
            style: GoogleFonts.inter(
              fontSize: size * 0.13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
