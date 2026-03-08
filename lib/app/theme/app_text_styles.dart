import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Headlines - primary font: Poppins
  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        color: AppColors.textDark,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  // Titles - primary font: Poppins
  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  // Body - secondary font: Montserrat
  static TextStyle get bodyLarge => GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  static TextStyle get bodyMedium => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  // Buttons - primary font: Poppins
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      );
}

