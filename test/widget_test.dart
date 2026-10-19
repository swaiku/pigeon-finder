import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pigeon_finder/app.dart';
import 'package:pigeon_finder/core/di/injection.dart';
import 'package:pigeon_finder/features/map/domain/repositories/map_repository.dart';
import 'package:pigeon_finder/features/map/presentation/bloc/map_bloc.dart';

import 'support/test_map_repository.dart';

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<MapRepository>(() => testMapRepository());
    sl.registerFactory(() => MapBloc(sl()));
  });

  testWidgets('navigates between tabs and opens the camera page', (
    tester,
  ) async {
    await tester.pumpWidget(const PigeonFinderApp());
    // The map's user dot pulses forever, so pumpAndSettle would never return.
    await tester.pump(const Duration(milliseconds: 100));

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
