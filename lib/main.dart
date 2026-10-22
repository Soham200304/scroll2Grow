import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrool2grow/app/app.dart';
import 'package:scrool2grow/features/notifications/services/NotificationService.dart';
import 'package:scrool2grow/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: Scrool2GrowApp(),
    ),
  );
}