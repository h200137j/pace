import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/services/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the Isar database before anything renders.
  await IsarService.instance.init();

  runApp(
    const ProviderScope(
      child: PaceApp(),
    ),
  );
}
