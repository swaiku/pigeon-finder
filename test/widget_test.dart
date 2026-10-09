import 'package:flutter_test/flutter_test.dart';

import 'package:pigeon_finder/app.dart';

void main() {
  testWidgets('shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const PigeonFinderApp());
    await tester.pumpAndSettle();

    // Tests run in debug mode, so the design system showcase is displayed
    // and repeats the title in several text styles.
    expect(find.text('Pigeon Finder'), findsWidgets);
  });
}
