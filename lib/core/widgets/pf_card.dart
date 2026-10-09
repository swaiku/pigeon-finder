import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A rounded white panel, styled from [CardTheme]. The generic container
/// used everywhere in the design for list rows, stat tiles and panels.
class PfCard extends StatelessWidget {
  const PfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
  }
}
