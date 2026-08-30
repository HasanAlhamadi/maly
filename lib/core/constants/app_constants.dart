// 📁 lib/core/constants/app_constants.dart
// PURPOSE: Plain app-wide values. Colors live in app_colors.dart only.

class AppConstants {
  AppConstants._();

  /// Currency code shown next to every amount.
  static const String currencySymbol = 'YER';

  static const int maxNameLength = 50;
  static const int maxPhoneLength = 20;
  static const int maxNoteLength = 500;

  /// How many people the home screen previews before "See all".
  static const int homePreviewCount = 5;

  // Shared spacing / shape values so screens stay visually consistent.
  static const double screenPadding = 20;
  static const double cardRadius = 20;
  static const double fieldRadius = 14;
}
