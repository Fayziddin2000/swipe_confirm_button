import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'swipe_button_controller.dart';
import 'swipe_button_theme.dart';

/// Direction the thumb travels to confirm.
enum SwipeDirection {
  /// Drag from the left edge to the right.
  leftToRight,

  /// Drag from the right edge to the left.
  rightToLeft,
}

/// Looping animation played on the idle thumb icon to invite a swipe.
enum SwipeHintAnimation {
  /// No idle animation.
  none,

  /// Slides the icon back and forth along the swipe direction.
  nudge,

  /// Gently scales the icon up and down.
  pulse,

  /// Fades the icon in and out.
  shimmer,

  /// Bobs the icon up and down.
  bounce,

  /// Rocks the icon left and right.
  wiggle,
}

/// Feedback played on the thumb while the user is actively dragging it.
enum SwipeDragEffect {
  /// No drag feedback.
  none,

  /// The thumb scales up.
  grow,

  /// The thumb's shadow deepens, as if it lifted off the track.
  lift,

  /// A soft colored glow radiates from the thumb.
  glow,

  /// Grow and lift combined (a Material-slider-like feel).
  growLift,
}

/// Transition used when the thumb icon swaps between states
/// (idle → loading → success / error).
enum SwipeIconTransition {
  /// The old icon shrinks and fades out while the new one grows and fades in.
  scaleFade,

  /// Scale only.
  scale,

  /// Cross-fade only.
  fade,

  /// A quarter-turn rotation combined with a fade.
  rotate,
}

/// Builds the content shown inside the thumb for the current [status].
typedef SwipeThumbBuilder = Widget Function(
  BuildContext context,
  SwipeButtonStatus status,
);

/// A "slide to confirm" button: the user drags a thumb across the track to
/// trigger an action, the button collapses into a loading circle while the
/// action runs, then shows a success (or error) state.
///
/// It has **zero external dependencies** and is fully themeable (see
/// [SwipeButtonThemeData]). There are two ways to use it:
///
/// **1. Automatic (recommended for most cases).** Return a [Future] from
/// [onSwipe]; the button shows the spinner until it completes, then success.
///
/// ```dart
/// SwipeButton(
///   text: 'Slide to confirm',
///   onSwipe: () async => api.confirmOrder(),
/// )
/// ```
///
/// **2. Manual.** Pass a [SwipeButtonController] and drive the state yourself
/// (e.g. from a BLoC). [onSwipe] becomes a fire-and-forget notification.
///
/// ```dart
/// SwipeButton(
///   controller: controller,
///   text: 'Slide to confirm',
///   onSwipe: () => bloc.add(ConfirmOrder()),
/// )
/// ```
class SwipeButton extends StatefulWidget {
  const SwipeButton({
    super.key,
    this.text,
    this.label,
    this.textStyle,
    this.onSwipe,
    this.onSwipeStart,
    this.onSwipeEnd,
    this.onError,
    this.onStatusChanged,
    this.controller,
    this.height,
    this.width,
    this.borderRadius,
    this.trackPadding = EdgeInsets.zero,
    this.trackColor,
    this.activeTrackColor,
    this.progressColor,
    this.thumbColor,
    this.activeThumbColor,
    this.thumbIconColor,
    this.successColor,
    this.errorColor,
    this.trackGradient,
    this.thumbGradient,
    this.thumbBorder,
    this.thumbPadding = 8,
    this.boxShadow,
    this.trackElevation = 0,
    this.thumbElevation = 0,
    this.idleIcon = Icons.keyboard_double_arrow_right_rounded,
    this.successIcon = Icons.check_rounded,
    this.errorIcon = Icons.close_rounded,
    this.endIcon,
    this.loadingIndicator,
    this.thumbBuilder,
    this.hintAnimation,
    this.hintDuration = const Duration(milliseconds: 900),
    this.iconTransition,
    this.iconSwitchDuration = const Duration(milliseconds: 250),
    this.thumbTransitionBuilder,
    this.dragEffect,
    this.dragEffectDuration = const Duration(milliseconds: 160),
    this.rollIcon = false,
    this.draggableTrack = false,
    this.shakeOnTap = true,
    this.flickToComplete = true,
    this.flickVelocity = 800,
    this.threshold = 0.9,
    this.enableHapticFeedback = true,
    this.collapseOnLoading = true,
    this.resetAfterError = true,
    this.autoResetAfterSuccess,
    this.direction,
    this.animationDuration,
    this.animationCurve,
    this.enabled = true,
  }) : assert(threshold > 0 && threshold <= 1,
            'threshold must be in the (0, 1] range');

  /// Creates a button that always expands to fill the available width.
  const SwipeButton.expand({
    super.key,
    this.text,
    this.label,
    this.textStyle,
    this.onSwipe,
    this.onSwipeStart,
    this.onSwipeEnd,
    this.onError,
    this.onStatusChanged,
    this.controller,
    this.height,
    this.borderRadius,
    this.trackPadding = EdgeInsets.zero,
    this.trackColor,
    this.activeTrackColor,
    this.progressColor,
    this.thumbColor,
    this.activeThumbColor,
    this.thumbIconColor,
    this.successColor,
    this.errorColor,
    this.trackGradient,
    this.thumbGradient,
    this.thumbBorder,
    this.thumbPadding = 8,
    this.boxShadow,
    this.trackElevation = 0,
    this.thumbElevation = 0,
    this.idleIcon = Icons.keyboard_double_arrow_right_rounded,
    this.successIcon = Icons.check_rounded,
    this.errorIcon = Icons.close_rounded,
    this.endIcon,
    this.loadingIndicator,
    this.thumbBuilder,
    this.hintAnimation,
    this.hintDuration = const Duration(milliseconds: 900),
    this.iconTransition,
    this.iconSwitchDuration = const Duration(milliseconds: 250),
    this.thumbTransitionBuilder,
    this.dragEffect,
    this.dragEffectDuration = const Duration(milliseconds: 160),
    this.rollIcon = false,
    this.draggableTrack = false,
    this.shakeOnTap = true,
    this.flickToComplete = true,
    this.flickVelocity = 800,
    this.threshold = 0.9,
    this.enableHapticFeedback = true,
    this.collapseOnLoading = true,
    this.resetAfterError = true,
    this.autoResetAfterSuccess,
    this.direction,
    this.animationDuration,
    this.animationCurve,
    this.enabled = true,
  })  : width = double.infinity,
        assert(threshold > 0 && threshold <= 1,
            'threshold must be in the (0, 1] range');

  /// Label shown in the center of the track. Ignored if [label] is given.
  final String? text;

  /// Custom label widget. Takes precedence over [text].
  final Widget? label;

  /// Style applied to [text].
  final TextStyle? textStyle;

  /// Called once the thumb is dragged past [threshold] (or flicked, or
  /// confirmed via the controller / assistive technology).
  ///
  /// If it returns a [Future] **and** no [controller] is supplied, the button
  /// manages its own state: spinner while pending, success on completion,
  /// error if it throws.
  final FutureOr<void> Function()? onSwipe;

  /// Called when the user starts dragging the thumb.
  final VoidCallback? onSwipeStart;

  /// Called when the user releases the thumb, regardless of whether the swipe
  /// passed [threshold].
  final VoidCallback? onSwipeEnd;

  /// Invoked when [onSwipe] throws (only in automatic mode).
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Invoked whenever the visual status changes.
  final void Function(SwipeButtonStatus status)? onStatusChanged;

  /// External state owner. When null, the button creates and manages its own.
  final SwipeButtonController? controller;

  /// Track / thumb height. Falls back to the theme, then `64`.
  final double? height;

  /// Fixed width. When null the button expands to its parent's width.
  final double? width;

  /// Corner radius. Falls back to the theme, then a fully-rounded pill.
  final BorderRadiusGeometry? borderRadius;

  /// Inset between the track edge and the thumb's travel area.
  final EdgeInsets trackPadding;

  /// Background of the track at rest. Falls back to the theme, then
  /// [ColorScheme.inverseSurface].
  final Color? trackColor;

  /// Track color the thumb reaches at full swipe; the track crossfades from
  /// [trackColor] to this as the thumb advances.
  final Color? activeTrackColor;

  /// Fill that follows the thumb. Defaults to the resting thumb color.
  final Color? progressColor;

  /// Thumb color at rest. Falls back to the theme, then [ColorScheme.primary].
  final Color? thumbColor;

  /// Thumb color at full swipe; the thumb crossfades from [thumbColor] to this.
  final Color? activeThumbColor;

  /// Color of the icon/spinner inside the thumb. Defaults to
  /// [ColorScheme.onPrimary].
  final Color? thumbIconColor;

  /// When set, tints the thumb and fill on success. Opt-in.
  final Color? successColor;

  /// When set, tints the thumb and fill on error. Opt-in.
  final Color? errorColor;

  /// Optional gradient for the track (takes precedence over [trackColor]).
  final Gradient? trackGradient;

  /// Optional gradient for the thumb (takes precedence over the thumb color).
  final Gradient? thumbGradient;

  /// Optional border drawn around the thumb.
  final Border? thumbBorder;

  /// Padding between the thumb edge and its icon.
  final double thumbPadding;

  /// Explicit track shadow. Overrides [trackElevation] when set.
  final List<BoxShadow>? boxShadow;

  /// Material-like elevation for the track (ignored when [boxShadow] is set).
  final double trackElevation;

  /// Material-like elevation for the thumb.
  final double thumbElevation;

  /// Icon shown in the thumb while idle.
  final IconData idleIcon;

  /// Icon shown when the action succeeds.
  final IconData successIcon;

  /// Icon shown when the action fails.
  final IconData errorIcon;

  /// Faint hint icon shown at the far (target) end of the track while idle.
  final IconData? endIcon;

  /// Custom loading indicator. Defaults to a small [CircularProgressIndicator].
  final Widget? loadingIndicator;

  /// Fully custom thumb content, built per [SwipeButtonStatus]. When provided it
  /// replaces the default icon/spinner.
  final SwipeThumbBuilder? thumbBuilder;

  /// Looping animation played on the idle (default) icon to invite a swipe.
  /// Falls back to the theme, then [SwipeHintAnimation.nudge]. No effect when
  /// [thumbBuilder] is set or the platform requests reduced motion.
  final SwipeHintAnimation? hintAnimation;

  /// Period of one [hintAnimation] cycle.
  final Duration hintDuration;

  /// How the thumb icon animates when the state changes. Falls back to the
  /// theme, then [SwipeIconTransition.scaleFade].
  final SwipeIconTransition? iconTransition;

  /// Duration of the state-change icon transition.
  final Duration iconSwitchDuration;

  /// Custom transition for the icon swap. Overrides [iconTransition].
  final AnimatedSwitcherTransitionBuilder? thumbTransitionBuilder;

  /// Feedback played on the thumb while it is being dragged. Falls back to the
  /// theme, then [SwipeDragEffect.growLift].
  final SwipeDragEffect? dragEffect;

  /// How quickly the [dragEffect] eases in on grab and out on release.
  final Duration dragEffectDuration;

  /// Spins the default idle icon like a wheel as the thumb travels. Composes
  /// with any [dragEffect]; has no effect when [thumbBuilder] is set.
  final bool rollIcon;

  /// When true the whole track is draggable, not just the thumb.
  final bool draggableTrack;

  /// When true, tapping (instead of swiping) shakes the thumb as a hint.
  final bool shakeOnTap;

  /// When true, a fast flick confirms even if the thumb did not reach
  /// [threshold].
  final bool flickToComplete;

  /// Minimum horizontal velocity (px/s) that counts as a confirming flick.
  final double flickVelocity;

  /// Fraction of the track (0–1) the thumb must pass to confirm.
  final double threshold;

  /// Fire a haptic pulse on confirm.
  final bool enableHapticFeedback;

  /// Collapse the track into a circle when not idle.
  final bool collapseOnLoading;

  /// In automatic mode, return to idle a moment after an error.
  final bool resetAfterError;

  /// In automatic mode, return to idle this long after success. When null the
  /// button stays in the success state (one-shot confirm).
  final Duration? autoResetAfterSuccess;

  /// Swipe direction. When null it follows the ambient [Directionality]
  /// (RTL locales swipe right-to-left).
  final SwipeDirection? direction;

  /// Duration of the snap-back / collapse animations. Falls back to the theme,
  /// then 300ms.
  final Duration? animationDuration;

  /// Curve of the snap-back / collapse animations. Falls back to the theme,
  /// then [Curves.easeOut].
  final Curve? animationCurve;

  /// When false the button is dimmed and ignores input.
  final bool enabled;

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with TickerProviderStateMixin {
  /// Normalized thumb progress, 0 (start) .. 1 (fully swiped).
  late final AnimationController _progress;

  /// Collapse amount, 0 (full-width track) .. 1 (circle). Driven on the same
  /// ticker as [_progress] so the shrink and the thumb return stay in lockstep.
  late final AnimationController _collapse;

  /// Looping driver for the idle hint animation.
  late final AnimationController _hint;

  /// Press feedback amount, 0 (released) .. 1 (grabbed).
  late final AnimationController _press;

  /// One-shot shake when the button is tapped instead of swiped.
  late final AnimationController _shake;

  bool _dragging = false;

  late SwipeButtonController _controller;
  bool _ownsController = false;
  int _seenCompleteRequests = 0;

  bool _locked = false;
  bool _reduceMotion = false;
  SwipeButtonThemeData? _theme;

  // Geometry captured during build, used by drag handlers.
  double _maxDrag = 0;
  double _maxWidth = 0;
  bool _reverse = false;

  // ---- Resolved settings (widget ?? theme ?? hardcoded default) ----
  double get _heightR => widget.height ?? _theme?.height ?? 64;
  Duration get _animDurR =>
      widget.animationDuration ??
      _theme?.animationDuration ??
      const Duration(milliseconds: 300);
  Duration get _effAnimDur => _reduceMotion ? Duration.zero : _animDurR;
  Curve get _animCurveR =>
      widget.animationCurve ?? _theme?.animationCurve ?? Curves.easeOut;
  SwipeHintAnimation get _hintAnimR =>
      widget.hintAnimation ?? _theme?.hintAnimation ?? SwipeHintAnimation.nudge;
  SwipeIconTransition get _iconTransR =>
      widget.iconTransition ??
      _theme?.iconTransition ??
      SwipeIconTransition.scaleFade;
  SwipeDragEffect get _dragEffectR =>
      widget.dragEffect ?? _theme?.dragEffect ?? SwipeDragEffect.growLift;
  SwipeDirection get _directionR {
    if (widget.direction != null) return widget.direction!;
    return Directionality.of(context) == TextDirection.rtl
        ? SwipeDirection.rightToLeft
        : SwipeDirection.leftToRight;
  }

  double get _thumbSize =>
      (_heightR - widget.trackPadding.vertical).clamp(0.0, _heightR);

  @override
  void initState() {
    super.initState();
    const fallback = Duration(milliseconds: 300);
    final dur = widget.animationDuration ?? fallback;
    _progress = AnimationController(
      vsync: this,
      duration: dur,
      lowerBound: 0,
      upperBound: 1,
    )..addListener(_onTick);
    _collapse = AnimationController(
      vsync: this,
      duration: dur,
      lowerBound: 0,
      upperBound: 1,
    )..addListener(_onTick);
    _hint = AnimationController(vsync: this, duration: widget.hintDuration);
    _press = AnimationController(vsync: this, duration: widget.dragEffectDuration)
      ..addListener(_onTick);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(_onTick);
    _attachController(widget.controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = SwipeButtonTheme.maybeOf(context);
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _progress.duration = _effAnimDur;
    _collapse.duration = _effAnimDur;
    _hint.duration = widget.hintDuration;
    _press.duration = widget.dragEffectDuration;
    _updateHint();
  }

  @override
  void didUpdateWidget(covariant SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController(widget.controller);
    }
    _progress.duration = _effAnimDur;
    _collapse.duration = _effAnimDur;
    _hint.duration = widget.hintDuration;
    _press.duration = widget.dragEffectDuration;
    _updateHint();
  }

  @override
  void dispose() {
    _detachController();
    _progress.dispose();
    _collapse.dispose();
    _hint.dispose();
    _press.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _attachController(SwipeButtonController? external) {
    _controller = external ?? SwipeButtonController();
    _ownsController = external == null;
    _seenCompleteRequests = _controller.completeRequests;
    _controller.addListener(_onControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _updateHint() {
    final shouldRun = widget.enabled &&
        !_reduceMotion &&
        _hintAnimR != SwipeHintAnimation.none &&
        widget.thumbBuilder == null &&
        _controller.isIdle &&
        !_dragging &&
        _progress.value < 0.02;
    if (shouldRun) {
      if (!_hint.isAnimating) _hint.repeat(reverse: true);
    } else if (_hint.isAnimating) {
      _hint.stop();
      _hint.value = 0;
    }
  }

  void _onControllerChanged() {
    // Programmatic confirm requested via SwipeButtonController.complete().
    if (_controller.completeRequests != _seenCompleteRequests) {
      _seenCompleteRequests = _controller.completeRequests;
      if (_controller.isIdle) {
        _programmaticComplete();
        return;
      }
    }
    final status = _controller.status;
    widget.onStatusChanged?.call(status);
    if (status == SwipeButtonStatus.idle) {
      _locked = false;
      _animateTo(0);
      _animateCollapse(0);
    } else if (widget.collapseOnLoading) {
      // The thumb returns to the start (_progress: 1 -> 0) and the track shrinks
      // into a centered circle (_collapse: 0 -> 1). Both run on the same ticker
      // with the same duration/curve, so `_progress == 1 - _collapse` every
      // frame and the shrink can never lag behind the return.
      _animateTo(0);
      _animateCollapse(1);
    } else {
      _animateTo(1);
      _animateCollapse(0);
    }
    _updateHint();
    if (mounted) setState(() {});
  }

  void _animateTo(double target) {
    _progress.animateTo(target.clamp(0.0, 1.0),
        duration: _effAnimDur, curve: _animCurveR);
  }

  void _animateCollapse(double target) {
    _collapse.animateTo(target.clamp(0.0, 1.0),
        duration: _effAnimDur, curve: _animCurveR);
  }

  bool get _interactive =>
      widget.enabled && _controller.isIdle && !_locked && _maxDrag > 0;

  void _beginDrag() {
    _dragging = true;
    _pressIn();
    _updateHint();
    widget.onSwipeStart?.call();
  }

  // --- Thumb dragging (delta based) ---
  void _onThumbDragStart(DragStartDetails details) {
    if (!_interactive) return;
    _beginDrag();
  }

  void _onThumbDragUpdate(DragUpdateDetails details) {
    if (!_interactive) return;
    _progress.stop();
    final dx = _reverse ? -details.delta.dx : details.delta.dx;
    final next = (_progress.value * _maxDrag + dx).clamp(0.0, _maxDrag);
    _progress.value = next / _maxDrag;
  }

  // --- Track dragging (absolute position based) ---
  void _onTrackDragStart(DragStartDetails details) {
    if (!_interactive) return;
    _beginDrag();
    _setProgressFromLocal(details.localPosition.dx);
  }

  void _onTrackDragUpdate(DragUpdateDetails details) {
    if (!_interactive) return;
    _progress.stop();
    _setProgressFromLocal(details.localPosition.dx);
  }

  void _setProgressFromLocal(double localX) {
    if (_maxDrag <= 0) return;
    final pad = widget.trackPadding;
    final travel = _reverse
        ? (_maxWidth - pad.right - localX) - _thumbSize / 2
        : localX - pad.left - _thumbSize / 2;
    _progress.value = (travel / _maxDrag).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    _pressOut();
    widget.onSwipeEnd?.call();
    final v = details.velocity.pixelsPerSecond.dx;
    final flicked = widget.flickToComplete &&
        _progress.value > 0.35 &&
        (_reverse ? v < -widget.flickVelocity : v > widget.flickVelocity);
    if (_progress.value >= widget.threshold || flicked) {
      _complete();
    } else {
      _animateTo(0);
    }
  }

  void _onTap() {
    if (!widget.shakeOnTap || !_interactive) return;
    if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
    _shake.forward(from: 0);
  }

  void _pressIn() {
    if (_dragEffectR == SwipeDragEffect.none) return;
    _press.animateTo(1, curve: Curves.easeOut);
  }

  void _pressOut() {
    if (_press.value == 0) return;
    _press.animateTo(0, curve: Curves.easeOut);
  }

  /// Animates the thumb across, then confirms — used by the controller and by
  /// assistive technology (Semantics tap).
  void _programmaticComplete() {
    if (!_interactive) return;
    widget.onSwipeStart?.call();
    _progress
        .animateTo(1, duration: _effAnimDur, curve: _animCurveR)
        .whenComplete(() {
      if (mounted) _complete();
    });
  }

  void _complete() {
    if (_locked) return;
    _locked = true;
    if (widget.enableHapticFeedback) HapticFeedback.mediumImpact();
    // Snap the thumb flush to the end so the collapse starts from a fully filled
    // track (no leftover sliver) and `_progress` lines up with `_collapse`.
    _progress.value = 1;

    if (_ownsController) {
      _runManaged();
    } else {
      final result = widget.onSwipe?.call();
      if (result is Future) {
        result.catchError((Object e, StackTrace s) {
          widget.onError?.call(e, s);
        });
      }
    }
  }

  Future<void> _runManaged() async {
    _controller.loading();
    try {
      final result = widget.onSwipe?.call();
      if (result is Future) await result;
      if (!mounted) return;
      _controller.success();
      final hold = widget.autoResetAfterSuccess;
      if (hold != null) {
        await Future<void>.delayed(hold);
        if (mounted) _controller.reset();
      }
    } catch (e, s) {
      widget.onError?.call(e, s);
      if (!mounted) return;
      _controller.error();
      if (widget.resetAfterError) {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (mounted) _controller.reset();
      }
    }
  }

  /// Material-like layered shadow derived from an [elevation] value.
  List<BoxShadow>? _shadowFor(double elevation) {
    if (elevation <= 0) return null;
    return [
      BoxShadow(
        color: const Color(0x33000000),
        blurRadius: elevation * 2.2,
        spreadRadius: elevation * 0.1,
        offset: Offset(0, elevation * 0.7),
      ),
      BoxShadow(
        color: const Color(0x1F000000),
        blurRadius: elevation,
        offset: Offset(0, elevation * 0.3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = _progress.value;
    final status = _controller.status;
    _reverse = _directionR == SwipeDirection.rightToLeft;

    final inactiveTrack =
        widget.trackColor ?? _theme?.trackColor ?? scheme.inverseSurface;
    final trackColor = Color.lerp(inactiveTrack,
        widget.activeTrackColor ?? _theme?.activeTrackColor ?? inactiveTrack, t)!;

    final inactiveThumb =
        widget.thumbColor ?? _theme?.thumbColor ?? scheme.primary;
    var thumbColor = Color.lerp(inactiveThumb,
        widget.activeThumbColor ?? _theme?.activeThumbColor ?? inactiveThumb, t)!;
    var progressColor =
        widget.progressColor ?? _theme?.progressColor ?? inactiveThumb;
    final iconColor =
        widget.thumbIconColor ?? _theme?.thumbIconColor ?? scheme.onPrimary;

    // Success / error tinting of the (collapsed) thumb + fill.
    final stateColor = switch (status) {
      SwipeButtonStatus.success =>
        widget.successColor ?? _theme?.successColor,
      SwipeButtonStatus.error => widget.errorColor ?? _theme?.errorColor,
      _ => null,
    };
    if (stateColor != null) {
      thumbColor = stateColor;
      progressColor = stateColor;
    }

    final height = _heightR;
    final pad = widget.trackPadding;
    final thumbSize = _thumbSize;
    final defaultRadius = BorderRadius.circular(height / 2);
    final collapseT = widget.collapseOnLoading ? _collapse.value : 0.0;
    final effectiveRadius = BorderRadiusGeometry.lerp(
      widget.borderRadius ?? _theme?.borderRadius ?? defaultRadius,
      defaultRadius,
      collapseT,
    )!;
    final collapsedWidth = thumbSize + pad.horizontal;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.text,
      onTap: widget.enabled ? _programmaticComplete : null,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: SizedBox(
          height: height,
          width: widget.width ?? double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _maxWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final innerWidth = _maxWidth - pad.horizontal;
              _maxDrag = (innerWidth - thumbSize).clamp(0.0, double.infinity);
              final thumbTravel = (t * _maxDrag).clamp(0.0, _maxDrag);
              final trackWidth =
                  _maxWidth + (collapsedWidth - _maxWidth) * collapseT;

              Widget content = Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: trackWidth,
                  height: height,
                  // Unclipped so the thumb's press effect can spill past the edge.
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: widget.trackGradient == null ? trackColor : null,
                            gradient: widget.trackGradient,
                            borderRadius: effectiveRadius,
                            boxShadow: widget.boxShadow ??
                                _shadowFor(widget.trackElevation),
                          ),
                          child: Padding(
                            padding: pad,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: (1 - collapseT).clamp(0.0, 1.0),
                                  child: IgnorePointer(
                                    child: widget.label ??
                                        Text(
                                          widget.text ?? '',
                                          style: widget.textStyle ??
                                              TextStyle(
                                                color: scheme.onInverseSurface,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                  ),
                                ),
                                if (widget.endIcon != null)
                                  Positioned(
                                    left: _reverse ? 4 : null,
                                    right: _reverse ? null : 4,
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: ((1 - t) * (1 - collapseT) * 0.45)
                                            .clamp(0.0, 1.0),
                                        child: Icon(widget.endIcon,
                                            color: scheme.onInverseSurface),
                                      ),
                                    ),
                                  ),
                                // Progress fill that trails the thumb.
                                Positioned(
                                  left: _reverse ? null : 0,
                                  right: _reverse ? 0 : null,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: (thumbTravel + thumbSize)
                                        .clamp(thumbSize, double.infinity),
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      borderRadius:
                                          BorderRadius.circular(thumbSize / 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // The thumb, on top and unclipped.
                      Positioned(
                        left: _reverse ? null : pad.left + thumbTravel,
                        right: _reverse ? pad.right + thumbTravel : null,
                        top: pad.top,
                        bottom: pad.bottom,
                        child: _wrapThumbGestures(
                          _buildThumb(
                              thumbSize, thumbColor, iconColor, status, height),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (widget.draggableTrack) {
                content = GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onHorizontalDragStart: _onTrackDragStart,
                  onHorizontalDragUpdate: _onTrackDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  onTap: _onTap,
                  child: content,
                );
              }
              return content;
            },
          ),
        ),
      ),
    );
  }

  /// The thumb only carries its own gesture detector when the whole track is
  /// not draggable (otherwise the outer detector owns the gesture).
  Widget _wrapThumbGestures(Widget thumb) {
    if (widget.draggableTrack) return thumb;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onHorizontalDragStart: _onThumbDragStart,
      onHorizontalDragUpdate: _onThumbDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _onTap,
      child: thumb,
    );
  }

  Widget _buildThumb(
    double size,
    Color thumbColor,
    Color iconColor,
    SwipeButtonStatus status,
    double height,
  ) {
    final p = Curves.easeOut.transform(_press.value);
    final effect = _dragEffectR;
    final grows =
        effect == SwipeDragEffect.grow || effect == SwipeDragEffect.growLift;
    final lifts =
        effect == SwipeDragEffect.lift || effect == SwipeDragEffect.growLift;
    final glows = effect == SwipeDragEffect.glow;

    final scale = grows ? 1 + p * 0.12 : 1.0;
    final shadow = <BoxShadow>[
      ...?_shadowFor(widget.thumbElevation + (lifts ? p * 8 : 0)),
      if (glows && p > 0)
        BoxShadow(
          color: thumbColor.withAlpha((p * 150).round()),
          blurRadius: 8 + p * 18,
          spreadRadius: p * 3,
        ),
    ];

    // Damped one-shot shake on tap.
    final sv = _shake.value;
    final shakeDx =
        sv == 0 ? 0.0 : math.sin(sv * math.pi * 4) * 6 * (1 - sv);

    return Transform.translate(
      offset: Offset(shakeDx, 0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(widget.thumbPadding),
          decoration: BoxDecoration(
            color: widget.thumbGradient == null ? thumbColor : null,
            gradient: widget.thumbGradient,
            shape: BoxShape.circle,
            border: widget.thumbBorder,
            boxShadow: shadow.isEmpty ? null : shadow,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: _reduceMotion ? Duration.zero : widget.iconSwitchDuration,
              transitionBuilder:
                  widget.thumbTransitionBuilder ?? _iconTransitionBuilder,
              child: widget.thumbBuilder?.call(context, status) ??
                  _defaultThumbContent(status, iconColor, size),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconTransitionBuilder(Widget child, Animation<double> animation) {
    switch (_iconTransR) {
      case SwipeIconTransition.fade:
        return FadeTransition(opacity: animation, child: child);
      case SwipeIconTransition.scale:
        return ScaleTransition(scale: animation, child: child);
      case SwipeIconTransition.scaleFade:
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      case SwipeIconTransition.rotate:
        return RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
    }
  }

  Widget _defaultThumbContent(
      SwipeButtonStatus status, Color iconColor, double size) {
    switch (status) {
      case SwipeButtonStatus.loading:
        return widget.loadingIndicator ??
            SizedBox(
              key: const ValueKey('loading'),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            );
      case SwipeButtonStatus.success:
        return Icon(widget.successIcon,
            key: const ValueKey('success'), color: iconColor);
      case SwipeButtonStatus.error:
        return Icon(widget.errorIcon,
            key: const ValueKey('error'), color: iconColor);
      case SwipeButtonStatus.idle:
        Widget icon = Icon(widget.idleIcon, color: iconColor);
        if (widget.rollIcon && _maxDrag > 0 && size > 0) {
          // Wheel physics: rotation = distance travelled / radius.
          final dir = _reverse ? -1.0 : 1.0;
          final angle = dir * (_progress.value * _maxDrag) / (size / 2);
          icon = Transform.rotate(angle: angle, child: icon);
        }
        if (_hintAnimR == SwipeHintAnimation.none) {
          return KeyedSubtree(key: const ValueKey('idle'), child: icon);
        }
        // Only the icon rebuilds on each hint frame, never the whole button.
        return AnimatedBuilder(
          key: const ValueKey('idle'),
          animation: _hint,
          builder: (context, child) => _applyHint(child!, _hint.value),
          child: icon,
        );
    }
  }

  Widget _applyHint(Widget child, double v) {
    final dir = _reverse ? -1.0 : 1.0;
    final e = Curves.easeInOut.transform(v);
    switch (_hintAnimR) {
      case SwipeHintAnimation.none:
        return child;
      case SwipeHintAnimation.nudge:
        return Transform.translate(
            offset: Offset(dir * (e - 0.5) * 8, 0), child: child);
      case SwipeHintAnimation.pulse:
        return Transform.scale(scale: 1 + e * 0.18, child: child);
      case SwipeHintAnimation.shimmer:
        return Opacity(opacity: 0.4 + e * 0.6, child: child);
      case SwipeHintAnimation.bounce:
        return Transform.translate(offset: Offset(0, -e * 5), child: child);
      case SwipeHintAnimation.wiggle:
        return Transform.rotate(angle: (e - 0.5) * 0.5, child: child);
    }
  }
}
