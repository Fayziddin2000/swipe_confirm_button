import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'swipe_button.dart';

/// App-wide defaults for [SwipeButton], applied through [ThemeData.extensions].
///
/// Any value left null falls back to the widget's own default. A value set on
/// the widget always wins over the theme.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [
///       SwipeButtonThemeData(
///         height: 56,
///         thumbColor: Colors.indigo,
///         dragEffect: SwipeDragEffect.glow,
///       ),
///     ],
///   ),
/// )
/// ```
class SwipeButtonThemeData extends ThemeExtension<SwipeButtonThemeData> {
  const SwipeButtonThemeData({
    this.height,
    this.borderRadius,
    this.trackColor,
    this.activeTrackColor,
    this.progressColor,
    this.thumbColor,
    this.activeThumbColor,
    this.thumbIconColor,
    this.successColor,
    this.errorColor,
    this.hintAnimation,
    this.iconTransition,
    this.dragEffect,
    this.animationDuration,
    this.animationCurve,
  });

  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? trackColor;
  final Color? activeTrackColor;
  final Color? progressColor;
  final Color? thumbColor;
  final Color? activeThumbColor;
  final Color? thumbIconColor;
  final Color? successColor;
  final Color? errorColor;
  final SwipeHintAnimation? hintAnimation;
  final SwipeIconTransition? iconTransition;
  final SwipeDragEffect? dragEffect;
  final Duration? animationDuration;
  final Curve? animationCurve;

  @override
  SwipeButtonThemeData copyWith({
    double? height,
    BorderRadiusGeometry? borderRadius,
    Color? trackColor,
    Color? activeTrackColor,
    Color? progressColor,
    Color? thumbColor,
    Color? activeThumbColor,
    Color? thumbIconColor,
    Color? successColor,
    Color? errorColor,
    SwipeHintAnimation? hintAnimation,
    SwipeIconTransition? iconTransition,
    SwipeDragEffect? dragEffect,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return SwipeButtonThemeData(
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      trackColor: trackColor ?? this.trackColor,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      progressColor: progressColor ?? this.progressColor,
      thumbColor: thumbColor ?? this.thumbColor,
      activeThumbColor: activeThumbColor ?? this.activeThumbColor,
      thumbIconColor: thumbIconColor ?? this.thumbIconColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      hintAnimation: hintAnimation ?? this.hintAnimation,
      iconTransition: iconTransition ?? this.iconTransition,
      dragEffect: dragEffect ?? this.dragEffect,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  SwipeButtonThemeData lerp(
      covariant SwipeButtonThemeData? other, double t) {
    if (other == null) return this;
    return SwipeButtonThemeData(
      height: lerpDouble(height, other.height, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      trackColor: Color.lerp(trackColor, other.trackColor, t),
      activeTrackColor: Color.lerp(activeTrackColor, other.activeTrackColor, t),
      progressColor: Color.lerp(progressColor, other.progressColor, t),
      thumbColor: Color.lerp(thumbColor, other.thumbColor, t),
      activeThumbColor: Color.lerp(activeThumbColor, other.activeThumbColor, t),
      thumbIconColor: Color.lerp(thumbIconColor, other.thumbIconColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      // Discrete settings snap at the midpoint.
      hintAnimation: t < 0.5 ? hintAnimation : other.hintAnimation,
      iconTransition: t < 0.5 ? iconTransition : other.iconTransition,
      dragEffect: t < 0.5 ? dragEffect : other.dragEffect,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
    );
  }
}

/// Convenience accessor for the [SwipeButtonThemeData] in scope.
abstract final class SwipeButtonTheme {
  /// The nearest [SwipeButtonThemeData] from [ThemeData.extensions], or null.
  static SwipeButtonThemeData? maybeOf(BuildContext context) =>
      Theme.of(context).extension<SwipeButtonThemeData>();
}
