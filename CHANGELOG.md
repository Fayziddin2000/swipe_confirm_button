## 0.1.0

Initial release.

- `SwipeButton` — themeable slide-to-confirm button with zero external
  dependencies.
- `SwipeButtonController` / `SwipeButtonStatus` for manual state control.
- Automatic mode: drives loading/success/error from the `onSwipe` `Future`.
- Customizable colors, height, radius, icons, threshold, haptics and
  animations.
- Left-to-right and right-to-left (RTL) swipe directions.
- Collapse-into-a-circle loading animation.
- `onSwipeStart` / `onSwipeEnd` drag callbacks.
- `SwipeButton.expand` constructor.
- `activeTrackColor` / `activeThumbColor` crossfade as the thumb advances.
- `trackElevation` / `thumbElevation` Material-like shadows.
- `trackPadding` to inset the thumb within the track.
- `borderRadius` accepts any `BorderRadiusGeometry`.
- `thumbBuilder` for fully custom, status-aware thumb content.
- `iconTransition` — animated icon swap on state change (`scaleFade` shrinks the
  old icon out and grows the new one in), plus `scale` / `fade` / `rotate` and a
  fully custom `thumbTransitionBuilder`.
- `hintAnimation` — looping idle invitation on the thumb icon (`nudge` / `pulse`
  / `shimmer` / `bounce` / `wiggle` / `none`); only the icon repaints per frame.
- `dragEffect` — feedback while the thumb is grabbed (`grow` / `lift` / `glow` /
  `growLift` / `none`); the thumb is drawn in an unclipped layer so it can spill
  past the track edge.
- `rollIcon` — spins the idle icon like a wheel (rotation proportional to the
  distance swiped); composes with any `dragEffect`.
- `hintDuration` / `iconSwitchDuration` / `dragEffectDuration` tuning.
- Accessibility: exposes a Semantics tap action to confirm, and honors
  `MediaQuery.disableAnimations` (reduce motion).
- `SwipeButtonThemeData` / `SwipeButtonTheme` — app-wide defaults via
  `ThemeData.extensions`.
- `SwipeButtonController.complete()` — confirm programmatically with animation.
- `flickToComplete` / `flickVelocity` — a fast flick confirms below threshold.
- `draggableTrack` — drag anywhere on the track, not only the thumb.
- `shakeOnTap` — tapping (not swiping) shakes the thumb as a hint.
- `successColor` / `errorColor` — tint the thumb + fill per state.
- `trackGradient` / `thumbGradient` and a faint trailing `endIcon`.
- `direction` now follows the ambient `Directionality` when left null (auto-RTL).
