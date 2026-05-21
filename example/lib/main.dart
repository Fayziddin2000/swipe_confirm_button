import 'package:flutter/material.dart';
import 'package:swipe_confirm_button/swipe_confirm_button.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwipeButton Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  // Manual mode: the page owns this controller (mimics a BLoC/Cubit driving it).
  final _manual = SwipeButtonController();
  final _programmatic = SwipeButtonController();

  // Section 6 — interactive animation picker.
  SwipeHintAnimation _hint = SwipeHintAnimation.nudge;
  SwipeIconTransition _transition = SwipeIconTransition.scaleFade;
  SwipeDragEffect _drag = SwipeDragEffect.growLift;
  bool _roll = false;

  @override
  void dispose() {
    _manual.dispose();
    _programmatic.dispose();
    super.dispose();
  }

  Future<void> _fakeRequest() => Future<void>.delayed(const Duration(seconds: 2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwipeButton')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: '1. Automatic (await a Future)',
            child: SwipeButton(
              text: 'Slide to confirm',
              autoResetAfterSuccess: const Duration(seconds: 2),
              onSwipe: _fakeRequest,
            ),
          ),
          _Section(
            title: '2. Manual control (external controller)',
            child: Column(
              children: [
                SwipeButton(
                  controller: _manual,
                  text: 'Buyurtmani yetkazdim',
                  onSwipe: () async {
                    _manual.loading();
                    await _fakeRequest();
                    _manual.success();
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _manual.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          _Section(
            title: '3. Custom style + right-to-left',
            child: SwipeButton(
              text: 'Pull to pay',
              direction: SwipeDirection.rightToLeft,
              height: 56,
              trackColor: const Color(0xFF1B5E20),
              thumbColor: Colors.white,
              thumbIconColor: const Color(0xFF1B5E20),
              progressColor: const Color(0xFF2E7D32),
              idleIcon: Icons.keyboard_double_arrow_left_rounded,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              autoResetAfterSuccess: const Duration(seconds: 2),
              onSwipe: _fakeRequest,
            ),
          ),
          _Section(
            title: '4. Error handling (throws → error → auto reset)',
            child: SwipeButton(
              text: 'Slide (this fails)',
              onSwipe: () async {
                await _fakeRequest();
                throw Exception('Network error');
              },
              onError: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed: $e')),
              ),
            ),
          ),
          _Section(
            title: '5. Elevation, color crossfade, padding & custom thumb',
            child: SwipeButton(
              text: 'Slide to unlock',
              trackColor: const Color(0xFFE0E0E0),
              activeTrackColor: const Color(0xFF6750A4),
              thumbColor: const Color(0xFF6750A4),
              activeThumbColor: const Color(0xFF381E72),
              thumbIconColor: Colors.white,
              textStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              trackPadding: const EdgeInsets.all(6),
              trackElevation: 2,
              thumbElevation: 4,
              borderRadius: BorderRadius.circular(16),
              thumbBuilder: (context, status) => switch (status) {
                SwipeButtonStatus.loading => const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                SwipeButtonStatus.success =>
                  const Icon(Icons.lock_open_rounded, color: Colors.white),
                _ => const Icon(Icons.lock_rounded, color: Colors.white),
              },
              autoResetAfterSuccess: const Duration(seconds: 2),
              onSwipe: _fakeRequest,
            ),
          ),
          _Section(
            title: '6. Pick the animations',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<SwipeHintAnimation>(
                        isExpanded: true,
                        value: _hint,
                        items: [
                          for (final h in SwipeHintAnimation.values)
                            DropdownMenuItem(value: h, child: Text('hint: ${h.name}')),
                        ],
                        onChanged: (v) => setState(() => _hint = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<SwipeIconTransition>(
                        isExpanded: true,
                        value: _transition,
                        items: [
                          for (final t in SwipeIconTransition.values)
                            DropdownMenuItem(value: t, child: Text('swap: ${t.name}')),
                        ],
                        onChanged: (v) => setState(() => _transition = v!),
                      ),
                    ),
                  ],
                ),
                DropdownButton<SwipeDragEffect>(
                  isExpanded: true,
                  value: _drag,
                  items: [
                    for (final d in SwipeDragEffect.values)
                      DropdownMenuItem(value: d, child: Text('drag: ${d.name}')),
                  ],
                  onChanged: (v) => setState(() => _drag = v!),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('rollIcon (spin while swiping)'),
                  value: _roll,
                  onChanged: (v) => setState(() => _roll = v),
                ),
                const SizedBox(height: 12),
                SwipeButton(
                  // A new key rebuilds the button when a setting changes so the
                  // looping animation restarts cleanly.
                  key: ValueKey('$_hint-$_transition-$_drag-$_roll'),
                  text: 'Slide me',
                  hintAnimation: _hint,
                  iconTransition: _transition,
                  dragEffect: _drag,
                  rollIcon: _roll,
                  autoResetAfterSuccess: const Duration(seconds: 2),
                  onSwipe: _fakeRequest,
                ),
              ],
            ),
          ),
          _Section(
            title: '7. Gradient, success/error color, endIcon, draggable track',
            child: SwipeButton(
              text: 'Slide anywhere',
              draggableTrack: true,
              trackGradient: const LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)],
              ),
              thumbColor: Colors.white,
              thumbIconColor: const Color(0xFF5E35B1),
              successColor: const Color(0xFF2E7D32),
              errorColor: const Color(0xFFC62828),
              endIcon: Icons.check_rounded,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              autoResetAfterSuccess: const Duration(seconds: 2),
              onSwipe: _fakeRequest,
            ),
          ),
          _Section(
            title: '8. Programmatic confirm (controller.complete())',
            child: Column(
              children: [
                SwipeButton(
                  controller: _programmatic,
                  text: 'Confirm me from a button',
                  onSwipe: () async {
                    _programmatic.loading();
                    await _fakeRequest();
                    _programmatic.success();
                    await Future<void>.delayed(const Duration(seconds: 1));
                    _programmatic.reset();
                  },
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _programmatic.complete,
                  child: const Text('Trigger programmatically'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
