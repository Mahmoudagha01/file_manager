import 'package:flutter/material.dart';

class ThemeConfig {
  //Colors for theme
  static Color primary =  const Color(0xFF8EACCD);
  static Color accent = const Color(0xFFFEF9D9);
  static Color secondary = const Color(0xFF406882);
  static Color accent2 = const Color(0xFF1A374D);
  static Color darkBg = const Color(0xFF222831);
  static Color lightBg = const Color(0xFFD2E0FB);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
   
    primaryColor: primary,
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      elevation: 4,
      color: primary,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: lightBg,
      elevation: 2,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      circularTrackColor: darkBg.withOpacity(0.1),
      color: primary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkBg,
      textStyle: TextStyle(color: lightBg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: primary,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: primary,
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent, //thereby
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    
   
    primaryColor: primary,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      elevation: 4,
      color: primary,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: darkBg,
      elevation: 2,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      circularTrackColor: lightBg.withOpacity(0.8),
      color: primary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: lightBg,
      textStyle: TextStyle(color: darkBg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: primary,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: primary,
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent, //thereby
    ),
  );
}
