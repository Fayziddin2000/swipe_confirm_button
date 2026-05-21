import 'package:flutter/foundation.dart';

/// The visual state a [SwipeButton] can be in.
enum SwipeButtonStatus {
  /// Waiting for the user to swipe. The thumb is draggable.
  idle,

  /// An action is in progress. The thumb shows a spinner and the button is
  /// (optionally) collapsed into a circle.
  loading,

  /// The action completed successfully. Shows the success icon.
  success,

  /// The action failed. Shows the error icon.
  error,
}

/// Drives the state of a [SwipeButton] from the outside.
///
/// Provide one when the parent owns the state machine (e.g. a BLoC/Cubit or a
/// `setState`-managed page). When you do **not** pass a controller, the button
/// creates its own and manages the state automatically from the `onSwipe`
/// [Future] — there is always exactly one source of truth, so the UI can never
/// desync.
///
/// ```dart
/// final controller = SwipeButtonController();
/// // later, e.g. in a bloc listener:
/// controller.loading();
/// controller.success();
/// controller.reset();
/// ```
class SwipeButtonController extends ChangeNotifier {
  SwipeButtonStatus _status = SwipeButtonStatus.idle;

  /// The current status. Listeners are notified whenever it changes.
  SwipeButtonStatus get status => _status;

  bool get isIdle => _status == SwipeButtonStatus.idle;
  bool get isLoading => _status == SwipeButtonStatus.loading;
  bool get isSuccess => _status == SwipeButtonStatus.success;
  bool get isError => _status == SwipeButtonStatus.error;

  int _completeRequests = 0;

  /// Increments each time [complete] is called. The button watches this to run
  /// a programmatic confirm.
  int get completeRequests => _completeRequests;

  void _set(SwipeButtonStatus next) {
    if (_status == next) return;
    _status = next;
    notifyListeners();
  }

  /// Programmatically confirm: the button animates the thumb across and fires
  /// `onSwipe`, exactly as a real swipe would. No-op unless currently idle.
  void complete() {
    _completeRequests++;
    notifyListeners();
  }

  /// Move to [SwipeButtonStatus.loading].
  void loading() => _set(SwipeButtonStatus.loading);

  /// Move to [SwipeButtonStatus.success].
  void success() => _set(SwipeButtonStatus.success);

  /// Move to [SwipeButtonStatus.error].
  void error() => _set(SwipeButtonStatus.error);

  /// Return to [SwipeButtonStatus.idle], making the button swipeable again.
  void reset() => _set(SwipeButtonStatus.idle);
}
