import 'package:flutter/material.dart';

/// Semantic colors that are not part of Flutter's standard [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors(
      {required this.secondaryText,
      required this.success,
      required this.successContainer,
      required this.selectedNavContainer,
      required this.iconTileContainer});

  final Color secondaryText;
  final Color success;
  final Color successContainer;
  final Color selectedNavContainer;
  final Color iconTileContainer;

  static const light = AppColors(
    secondaryText: Color(0xFF6F7077),
    success: Color(0xFF238A50),
    successContainer: Color(0xFFE8F8EE),
    selectedNavContainer: Color(0xFFF1F1F3),
    iconTileContainer: Color(0xFFF8F8FA),
  );

  static const dark = AppColors(
    secondaryText: Color(0xFFB3B4BE),
    success: Color(0xFF62D891),
    successContainer: Color(0xFF183B28),
    selectedNavContainer: Color(0xFF34353D),
    iconTileContainer: Color(0xFF393A42),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith(
          {Color? secondaryText,
          Color? success,
          Color? successContainer,
          Color? selectedNavContainer,
          Color? iconTileContainer}) =>
      AppColors(
        secondaryText: secondaryText ?? this.secondaryText,
        success: success ?? this.success,
        successContainer: successContainer ?? this.successContainer,
        selectedNavContainer: selectedNavContainer ?? this.selectedNavContainer,
        iconTileContainer: iconTileContainer ?? this.iconTileContainer,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      selectedNavContainer: Color.lerp(
        selectedNavContainer,
        other.selectedNavContainer,
        t,
      )!,
      iconTileContainer: Color.lerp(
        iconTileContainer,
        other.iconTileContainer,
        t,
      )!,
    );
  }
}
