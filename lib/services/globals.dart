// Package imports:
import 'package:logger/logger.dart';

//ignore_for_file: non_constant_identifier_names

enum TestingEnum { none, unit, integration }

String global_apiKey = '';

TestingEnum global_testing_active = TestingEnum.none;

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    printEmojis: false,
  ),
);
