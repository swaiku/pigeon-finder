import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A rounded white panel, styled from [CardTheme]. The generic container
/// used everywhere in the design for list rows, stat tiles and panels.
class const PfCard({
  super.key,
  required final Widget child,
  final EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
  final Color? color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
  }
}
