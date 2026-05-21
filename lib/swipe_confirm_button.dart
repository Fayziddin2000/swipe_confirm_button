/// A universal, zero-dependency "slide to confirm" button for Flutter.
///
/// Import this single file to use [SwipeButton] and [SwipeButtonController].
library;

export 'src/swipe_button.dart'
    show
        SwipeButton,
        SwipeDirection,
        SwipeDragEffect,
        SwipeHintAnimation,
        SwipeIconTransition,
        SwipeThumbBuilder;
export 'src/swipe_button_controller.dart'
    show SwipeButtonController, SwipeButtonStatus;
export 'src/swipe_button_theme.dart'
    show SwipeButtonThemeData, SwipeButtonTheme;
