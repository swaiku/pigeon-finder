import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/injection.dart';
import 'features/detection/domain/repositories/detection_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  await initDependencies();
  // The models take a few seconds (GPU compilation): load them while the
  // user opens the camera. A failure shows when a photo is analysed.
  unawaited(sl<DetectionRepository>().load().catchError((Object _) {}));

  runApp(const PigeonFinderApp());
}
