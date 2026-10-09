import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pigeon_finder/app.dart';

void main() {
  testWidgets('navigates between tabs and opens the camera page', (
    tester,
  ) async {
    await tester.pumpWidget(const PigeonFinderApp());
    await tester.pumpAndSettle();

    // Starts on the map tab (label in bar + page title).
    expect(find.text('Map'), findsWidgets);

    await tester.tap(find.text('Ranking'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking'), findsNWidgets(3));

    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Camera'), findsWidgets);
  });
}
