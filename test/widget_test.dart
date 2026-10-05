import 'package:flutter_test/flutter_test.dart';

import 'package:pigeon_finder/app.dart';

void main() {
  testWidgets('shows the app title and tagline', (WidgetTester tester) async {
    await tester.pumpWidget(const PigeonFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('Pigeon Finder'), findsOneWidget);
    expect(find.text('Spot it. Snap it. Score it.'), findsOneWidget);
  });
}
