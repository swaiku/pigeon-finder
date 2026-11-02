import 'dart:async';

import 'package:flutter/material.dart';

/// Rebuilds every second until [until], giving [builder] the time left as
/// `m:ss`, or null once it has passed (or when [until] is null).
class Cooldown extends StatefulWidget {
  const Cooldown({super.key, required this.until, required this.builder});

  final DateTime? until;
  final Widget Function(BuildContext context, String? timeLeft) builder;

  @override
  State<Cooldown> createState() => _CooldownState();
}

class _CooldownState extends State<Cooldown> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.until?.difference(DateTime.now());
    if (left == null || left <= Duration.zero) {
      return widget.builder(context, null);
    }
    final seconds = (left.inMilliseconds / 1000).ceil();
    final text =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return widget.builder(context, text);
  }
}
