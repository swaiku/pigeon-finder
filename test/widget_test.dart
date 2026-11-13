import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pigeon_finder/app.dart';
import 'package:pigeon_finder/core/di/injection.dart';
import 'package:pigeon_finder/features/auth/domain/repositories/auth_repository.dart';
import 'package:pigeon_finder/features/map/data/repositories/location_repository_impl.dart';
import 'package:pigeon_finder/features/map/presentation/bloc/map_bloc.dart';
import 'package:pigeon_finder/features/post/presentation/bloc/post_cubit.dart';
import 'package:pigeon_finder/features/post/presentation/pages/camera_page.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_location_data_source.dart';
import 'support/fake_post_repository.dart';
import 'support/test_map_bloc.dart';

/// Counts the position lookups of the camera page.
class _CountingLocation extends FakeLocationDataSource {
  int lookups = 0;

  @override
  Future<LatLng> getCurrentPosition() {
    lookups++;
    return super.getCurrentPosition();
  }
}

void main() {
  late _CountingLocation postLocation;

  setUp(() async {
    await sl.reset();
    postLocation = _CountingLocation();
    sl.registerFactory<MapBloc>(testMapBloc);
    sl.registerSingleton<AuthRepository>(FakeAuthRepository());
    sl.registerFactory(
      () => PostCubit(
        posts: FakePostRepository(),
        location: LocationRepositoryImpl(postLocation),
      ),
    );
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
    // The route needs one frame to be pushed and a second to build its page.
    await tester.pump();
    // The viewfinder spinner animates while the camera opens (never, without
    // the plugin), so pumpAndSettle would never return.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CameraPage), findsOneWidget);
    expect(find.bySemanticsLabel('Take the photo'), findsOneWidget);
    // The position is looked up while the user frames the shot.
    expect(postLocation.lookups, 1);
  });
}
