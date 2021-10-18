import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobtest_lastfm/services/globals.dart';

import 'myapp.dart';

Future<void> main({List<String>? args}) async {
  WidgetsFlutterBinding.ensureInitialized();

  args ??= [];
  if (args.contains('integration_testing'))
    global_testing_active = TestingEnum.integration;
  if (args.contains('unit_testing')) global_testing_active = TestingEnum.unit;

  runApp(ProviderScope(child: MyApp()));
}
