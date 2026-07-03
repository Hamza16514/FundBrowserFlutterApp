import 'dart:async';
import 'package:flutter/material.dart';

/// Manages user session idle timeout.
/// 
/// Wrap any screen that requires authentication with [SessionTimeoutWrapper].
/// Any pointer interaction on the screen resets the idle timer.
/// After [timeoutDuration] of inactivity the [onTimeout] callback is invoked.
class SessionManager {
  static const Duration _defaultTimeout = Duration(minutes: 5);

  Timer? _idleTimer;
  final Duration timeoutDuration;
  final VoidCallback onTimeout;

  SessionManager({
    Duration? timeoutDuration,
    required this.onTimeout,
  }) : timeoutDuration = timeoutDuration ?? _defaultTimeout;

  /// Call this whenever user activity is detected (touch, scroll, tap, etc.).
  void resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(timeoutDuration, onTimeout);
  }

  /// Starts the idle timer. Call once the authenticated screen is entered.
  void start() {
    resetTimer();
  }

  /// Permanently stops the timer. Call when leaving the authenticated screen.
  void dispose() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }
}

/// A widget that wraps its [child] with pointer-event detection.
/// 
/// Any touch event inside the widget tree resets the session idle timer.
/// When the timer expires, [onTimeout] is called (e.g. to navigate to login).
class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;
  final VoidCallback onTimeout;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 5),
    required this.onTimeout,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  late final SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionManager = SessionManager(
      timeoutDuration: widget.timeoutDuration,
      onTimeout: widget.onTimeout,
    );
    _sessionManager.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user comes back to app, reset the timer
    if (state == AppLifecycleState.resumed) {
      _sessionManager.resetTimer();
    }
    // Optionally pause when backgrounded (we do not pause so the
    // timer still fires when the user is gone for > 5 min)
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _sessionManager.resetTimer(),
      onPointerMove: (_) => _sessionManager.resetTimer(),
      child: widget.child,
    );
  }
}
