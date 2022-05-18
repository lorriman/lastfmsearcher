// Package imports:
import 'package:logger/logger.dart';

//ignore_for_file: non_constant_identifier_names
//ignore_for_file: constant_identifier_names

enum TestingEnum { none, unit, integrationTestData, integrationRealData }

String global_apiKey = '';

TestingEnum global_testing_active = TestingEnum.none;

const int global_screen_width_breakpoint=360;

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    printEmojis: false,
  ),
);
