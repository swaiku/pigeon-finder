import 'package:material_ui/material_ui.dart';

/// Share of the avatar's size taken by its initial.
const _initialRatio = .4;

/// A circular avatar showing the user's [photoUrl], or a single initial when
/// they have no profile photo (leaderboard, profile, podium, map header).
class const PfAvatar({
  super.key,
  required final String initial,
  final String? photoUrl,
  final Color? backgroundColor,
  final Color? foregroundColor,
  final double size = 40,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = photoUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.tertiary,
        shape: BoxShape.circle,
        image: url == null
            ? null
            : DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
                // A photo that cannot load leaves the plain circle.
                onError: (_, _) {},
              ),
      ),
      alignment: Alignment.center,
      child: url != null
          ? null
          : Text(
              initial,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foregroundColor ?? colorScheme.onTertiary,
                fontSize: size * _initialRatio,
              ),
            ),
    );
  }
}
