import 'package:client/design/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
   brightness: Brightness.dark,
   appBarTheme: AppBarTheme(
     backgroundColor: AppColors.scaffoldBgColor,
     elevation: 0,
   ),
   scaffoldBackgroundColor: AppColors.scaffoldBgColor,
  );
}