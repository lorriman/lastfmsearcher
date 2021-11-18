// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_size/window_size.dart';

// Project imports:
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/utils.dart';
import 'myapp.dart';

Future<void> main({List<String>? args}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && (Platform.isWindows || Platform.isLinux) ) {
    setWindowMaxSize(const Size(384, 600));
    setWindowMinSize(const Size(384, 600));
  }

  final apikeys = await parseJsonFromAssets('assets/lastfm_api.json');
  global_apiKey = apikeys['api_key'] as String;

  args ??= [];
  if (args.contains('integration_testing'))
    global_testing_active = TestingEnum.integration;
  if (args.contains('unit_testing')) global_testing_active = TestingEnum.unit;

  runApp(ProviderScope(child: MyApp()));
}
