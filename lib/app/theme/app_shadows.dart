import 'package:flutter/material.dart';

/// Shared soft shadows for the app's floating and raised surfaces.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({required this.soft});

  final List<BoxShadow> soft;

  static const light = AppShadows(
    soft: [
      BoxShadow(
        color: Color(0x18000000),
        blurRadius: 26,
        spreadRadius: 1,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const dark = AppShadows(
    soft: [
      BoxShadow(
        color: Color(0x44000000),
        blurRadius: 26,
        spreadRadius: 1,
        offset: Offset(0, 8),
      ),
    ],
  );

  static AppShadows of(BuildContext context) =>
      Theme.of(context).extension<AppShadows>() ?? light;

  @override
  AppShadows copyWith({List<BoxShadow>? soft}) =>
      AppShadows(soft: soft ?? this.soft);

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    final count =
        soft.length < other.soft.length ? soft.length : other.soft.length;
    return AppShadows(
      soft: List.generate(
        count,
        (index) => BoxShadow.lerp(soft[index], other.soft[index], t)!,
      ),
    );
  }
}
