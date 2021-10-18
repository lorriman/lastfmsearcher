import 'package:logger/logger.dart';

enum TestingEnum { none, unit, integration }

TestingEnum global_testing_active = TestingEnum.none;

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    printEmojis: false,
  ),
);
