# swipe_confirm_button

A universal, **zero-dependency** "slide to confirm" button for Flutter — a
themeable, robust reimagining of the classic swipe-to-action pattern.

- **No external packages** — only the Flutter SDK.
- **Two usage modes** — automatic (await a `Future`) or manual (drive it with a
  controller, e.g. from a BLoC).
- **Single source of truth** — the visual status comes from one controller, so
  the UI can never desync.
- **Fully themeable** — colors, height, radius, icons, threshold, direction
  (LTR/RTL), haptics, animations.
- **States**: `idle → loading → success / error`, with a smooth collapse into a
  loading circle.
- **Accessible** — exposes a tap action for screen readers and honors the
  platform's *reduce motion* setting.
- **Rich animations** — idle hint, drag feedback, rolling icon, animated icon
  swaps — all selectable.

## Gallery

| | |
| --- | --- |
| Default | ![Default](doc/images/default.png) |
| Custom colors | ![Styled](doc/images/styled.png) |
| Gradient + trailing hint, draggable track | ![Gradient](doc/images/gradient.png) |
| Rounded, padded track, custom icon | ![Rounded](doc/images/rounded.png) |
| Success state (`successColor`) | ![Success](doc/images/success.png) |

> The button is animated — slide, idle hint, drag feedback, collapse-to-loading
> and the rolling icon are best seen live: `cd example && flutter run`.

## Quick start

```dart
import 'package:swipe_confirm_button/swipe_confirm_button.dart';

// 1. Automatic — show a spinner until the Future completes, then success.
SwipeButton(
  text: 'Slide to confirm',
  autoResetAfterSuccess: const Duration(seconds: 2),
  onSwipe: () async => api.confirmOrder(),
);
```

```dart
// 2. Manual — you own the state (BLoC / Cubit / setState).
final controller = SwipeButtonController();

SwipeButton(
  controller: controller,
  text: 'Buyurtmani yetkazdim',
  onSwipe: () => bloc.add(ConfirmOrder()),
);

// elsewhere, react to your state:
controller.loading();
controller.success(); // or controller.error();
controller.reset();
```

## Customization

| Parameter | Default | Description |
| --- | --- | --- |
| `text` / `label` | — | Center label (string or custom widget). |
| `onSwipe` | — | Called once the thumb passes `threshold`. |
| `onSwipeStart` / `onSwipeEnd` | — | Called when the drag begins / is released. |
| `controller` | internal | External `SwipeButtonController`. Omit for automatic mode. |
| `height` | `64` | Track height / collapsed circle diameter. |
| `width` | full width | Fixed width, or expands to parent. Use `SwipeButton.expand` to always fill. |
| `borderRadius` | `height / 2` | Any `BorderRadiusGeometry`; pill by default. |
| `trackPadding` | `EdgeInsets.zero` | Inset between the track edge and the thumb. |
| `trackColor` / `activeTrackColor` | `inverseSurface` | Track crossfades from rest to active as you swipe. |
| `thumbColor` / `activeThumbColor` | `primary` | Thumb crossfades from rest to active as you swipe. |
| `progressColor` | `thumbColor` | Fill trailing the thumb. |
| `trackElevation` / `thumbElevation` | `0` | Material-like shadows. |
| `boxShadow` | — | Explicit track shadow (overrides `trackElevation`). |
| `idleIcon` / `successIcon` / `errorIcon` | arrows / check / close | Thumb icons. |
| `thumbBuilder` | — | Fully custom thumb content per status. |
| `hintAnimation` | `nudge` | Idle invite loop: `nudge` / `pulse` / `shimmer` / `bounce` / `wiggle` / `none`. |
| `dragEffect` | `growLift` | Feedback while dragging: `grow` / `lift` / `glow` / `growLift` / `none`. |
| `rollIcon` | `false` | Spins the idle icon like a wheel as the thumb travels. |
| `draggableTrack` | `false` | Drag anywhere on the track, not just the thumb. |
| `flickToComplete` / `flickVelocity` | `true` / `800` | A fast flick confirms below threshold. |
| `shakeOnTap` | `true` | Tapping (not swiping) shakes the thumb as a hint. |
| `successColor` / `errorColor` | — | Tint the thumb + fill on success / error. |
| `trackGradient` / `thumbGradient` | — | Gradient fills for track / thumb. |
| `endIcon` | — | Faint hint icon at the target end of the track. |
| `iconTransition` | `scaleFade` | State-change icon swap: `scaleFade` / `scale` / `fade` / `rotate`. |
| `hintDuration` / `iconSwitchDuration` / `dragEffectDuration` | `900ms` / `250ms` / `160ms` | Animation durations. |
| `thumbTransitionBuilder` | — | Fully custom icon-swap transition. |
| `loadingIndicator` | spinner | Custom loading widget. |
| `thumbBorder` / `thumbPadding` | — / `8` | Thumb border and icon padding. |
| `threshold` | `0.9` | Fraction of the track needed to confirm. |
| `direction` | auto | `leftToRight` / `rightToLeft`; follows `Directionality` when null. |
| `collapseOnLoading` | `true` | Collapse into a circle while busy. |
| `enableHapticFeedback` | `true` | Haptic pulse on confirm. |
| `autoResetAfterSuccess` | `null` | Auto-return to idle after success. |
| `resetAfterError` | `true` | Auto-return to idle after an error. |
| `animationDuration` / `animationCurve` | `300ms` / `easeOut` | Snap-back & collapse animation. |
| `enabled` | `true` | Dim and ignore input when false. |

## App-wide theming

Set defaults once via a `ThemeExtension`; per-widget values still win.

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      SwipeButtonThemeData(
        height: 56,
        thumbColor: Colors.indigo,
        dragEffect: SwipeDragEffect.glow,
      ),
    ],
  ),
);
```

## Accessibility

The button exposes a **tap action** so screen-reader users can activate it
without performing a drag, and it honors the platform's **reduce motion**
setting (`MediaQuery.disableAnimations`) by stopping the idle hint loop and
making transitions instant.

## Programmatic confirm

```dart
final controller = SwipeButtonController();
// animates the thumb across and fires onSwipe, just like a real swipe:
controller.complete();
```

## Installation

```yaml
dependencies:
  swipe_confirm_button: ^0.1.0
```

## Demo

`example/lib/main.dart` contains four runnable examples (automatic, manual,
custom-styled RTL, and error handling):

```sh
cd example
flutter run
```

## Tests

```sh
flutter test
```
