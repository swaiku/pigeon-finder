import 'package:flutter/material.dart';

/// Share of the avatar's size taken by its initial.
const _initialRatio = .4;

/// A circular avatar showing a single initial, used for users without a
/// profile photo (leaderboard, profile, podium, map header).
class const PfAvatar({
  super.key,
  required final String initial,
  final Color? backgroundColor,
  final Color? foregroundColor,
  final double size = 40,
}) extends StatelessWidget {
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
          fontSize: size * _initialRatio,
        ),
      ),
    );
  }
}
