import 'dart:io';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/detection_result.dart';

/// Display name of a manifest class (`classes` of the release).
String speciesName(AppLocalizations l10n, String species) => switch (species) {
  'feral pigeon' => l10n.speciesFeralPigeon,
  'wood pigeon' => l10n.speciesWoodPigeon,
  'collared dove' => l10n.speciesCollaredDove,
  'other' => l10n.speciesOther,
  _ => species, // a class added by a later release
};

/// Name shown for one bird: uncertain when the classifier abstained.
String birdName(AppLocalizations l10n, DetectedBird bird) =>
    bird.abstained ? l10n.speciesUncertain : speciesName(l10n, bird.species);

/// The photo, cropped to fill like the review page, with a box and a tag per
/// bird when [result] is given (green, or amber when uncertain).
class const DetectionPhoto({
  super.key,
  required final String path,
  final DetectionResult? result,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final result = this.result;
    final image = Image.file(File(path), fit: BoxFit.cover);
    if (result == null || result.count == 0) return image;
    // Drawn in photo pixels, then scaled with the photo: boxes stay on birds.
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: result.photoWidth.toDouble(),
        height: result.photoHeight.toDouble(),
        child: CustomPaint(
          foregroundPainter: _BoxesPainter(result, [
            for (final b in result.birds)
              AppLocalizations.of(context)!.analysisConfidence(
                birdName(AppLocalizations.of(context)!, b),
                (b.confidence * 100).round(),
              ),
          ]),
          child: Image.file(File(path), fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class _BoxesPainter extends CustomPainter {
  _BoxesPainter(this.result, this.labels);

  final DetectionResult result;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    // About 3 px and 11 px on a phone screen, whatever the photo size.
    final unit = math.max(size.width, size.height) / 360;
    for (final (i, bird) in result.birds.indexed) {
      final color = bird.abstained ? AppColors.grain : AppColors.iridescent;
      final box = Rect.fromLTRB(bird.left, bird.top, bird.right, bird.bottom);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(4 * unit)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * unit
          ..color = color,
      );
      final text = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontFamily: AppTypography.body,
            fontWeight: FontWeight.w800,
            fontSize: 5.5 * unit,
            color: bird.abstained ? AppColors.night : Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pad = 2.5 * unit;
      final tag = Rect.fromLTWH(
        box.left,
        math.max(0, box.top - text.height - 2 * pad - unit),
        text.width + 2 * pad,
        text.height + pad,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tag, Radius.circular(3 * unit)),
        Paint()..color = color,
      );
      text.paint(canvas, tag.topLeft + Offset(pad, pad / 2));
    }
  }

  @override
  bool shouldRepaint(_BoxesPainter old) =>
      old.result != result || old.labels != labels;
}
