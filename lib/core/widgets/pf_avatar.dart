import 'package:flutter/material.dart';

/// A circular avatar showing a single initial, used for users without a
/// profile photo (leaderboard, profile, podium, map header).
class PfAvatar extends StatelessWidget {
  const PfAvatar({
    super.key,
    required this.initial,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 40,
  });

  final String initial;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.tertiary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: foregroundColor ?? colorScheme.onTertiary,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
