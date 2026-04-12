import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/background_worker.dart';
import 'core/services/notification_service.dart';
import 'data/services/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the Isar database before anything renders.
  await IsarService.instance.init();
  
  // Initialize Notification Service
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  
  // Initialize Background Worker
  await BackgroundWorker.instance.init();
  await BackgroundWorker.instance.registerChallengeCheck();

  runApp(
    const ProviderScope(
      child: PaceApp(),
    ),
  );
}
