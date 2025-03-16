import 'package:flutter/material.dart';
import 'dart:ui';

class ThemeColor {
  final Color background;
  final Color tab;
  final Color text;

  ThemeColor({
    required this.background,
    required this.tab,
    required this.text,
  });

  Color get getBackground => background;
  Color get getTab => tab;
  Color get getText => text;
}

// Dark Theme Variants
class DarkBlue extends ThemeColor {
  DarkBlue()
      : super(
    background: const Color(0xFF12202D),
    tab: const Color(0xFF2594FC),
    text: const Color(0xFFFFFFFF),
  );
}

class DarkGreen extends ThemeColor {
  DarkGreen()
      : super(
    background: const Color(0xFF16271F),
    tab: const Color(0xFF12C372),
    text: const Color(0xFFFFFFFF),
  );
}

class DarkPink extends ThemeColor {
  DarkPink()
      : super(
    background: const Color(0xFF2A1826),
    tab: const Color(0xFFDB52C6),
    text: const Color(0xFFFFFFFF),
  );
}

class DarkOrange extends ThemeColor {
  DarkOrange()
      : super(
    background: const Color(0xFF231814),
    tab: const Color(0xFFFE7747),
    text: const Color(0xFFFFFFFF),
  );
}

class DarkRed extends ThemeColor {
  DarkRed()
      : super(
    background: const Color(0xFF2B181A),
    tab: const Color(0xFFF44F5F),
    text: const Color(0xFFFFFFFF),
  );
}

// Light Theme Variants
class WhiteBlue extends ThemeColor {
  WhiteBlue()
      : super(
    background: const Color(0xFFE2EEFA),
    tab: const Color(0xFF2595FD),
    text: const Color(0xFF000000),
  );
}

class WhiteGreen extends ThemeColor {
  WhiteGreen()
      : super(
    background: const Color(0xFFE2F7EE),
    tab: const Color(0xFF14EB86),
    text: const Color(0xFF000000),
  );
}

class WhitePink extends ThemeColor {
  WhitePink()
      : super(
    background: const Color(0xFFF9E2F6),
    tab: const Color(0xFFED41D3),
    text: const Color(0xFF000000),
  );
}

class WhiteOrange extends ThemeColor {
  WhiteOrange()
      : super(
    background: const Color(0xFFFAE9E2),
    tab: const Color(0xFFFB7746),
    text: const Color(0xFF000000),
  );
}

class WhiteRed extends ThemeColor {
  WhiteRed()
      : super(
    background: const Color(0xFFFAE1E4),
    tab: const Color(0xFFF6606C),
    text: const Color(0xFF000000),
  );
}

// Extra Theme Variants
class S1 extends ThemeColor {
  S1()
      : super(
    background: const Color(0xFFD0EBFC),
    tab: const Color(0xFFA02832),
    text: const Color(0xFF6A6068),
  );
}

class S2 extends ThemeColor {
  S2()
      : super(
    background: const Color(0xFFFBF6D0),
    tab: const Color(0xFF6D521B),
    text: const Color(0xFF6A6068),
  );
}

class S3 extends ThemeColor {
  S3()
      : super(
    background: const Color(0xFFD5DAF8),
    tab: const Color(0xFF000000),
    text: const Color(0xFF6A6068),
  );
}

class S4 extends ThemeColor {
  S4()
      : super(
    background: const Color(0xFFFBF3CF),
    tab: const Color(0xFF942D26),
    text: const Color(0xFF6A6068),
  );
}

class S5 extends ThemeColor {
  S5()
      : super(
    background: const Color(0xFFFBECCD),
    tab: const Color(0xFF9F086F),
    text: const Color(0xFF6A6068),
  );
}

class S6 extends ThemeColor {
  S6()
      : super(
    background: const Color(0xFF2F5830),
    tab: const Color(0xFFF6FB83),
    text: const Color(0xFFA5B7A9),
  );
}
