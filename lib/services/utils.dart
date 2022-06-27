// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:intl/intl.dart';

const uInt32maxValue = 0xFFFFFFFF;
const uInt32minValue = 0;
const int32maxValue = 0x7FFFFFFF;
const int32minValue = -0x80000000;

//web app javascript can't do these
/*
const Uint64maxValue = 0xFFFFFFFFFFFFFFFF;
const Uint64minValue = 0;
const Int64maxValue = 0x7FFFFFFFFFFFFFFF;
const Int64minValue = -0x8000000000000000;
*/

final dynamic thousandsFormatter = NumberFormat.decimalPattern();
//var thousandsFormatter = NumberFormat('#,##,000');
extension IntUtils on int {

  dynamic toThousands() => thousandsFormatter.format(this);

}

Widget loadingIndicator({String semantics = 'waiting', double size = 50}) {
  return Container(
    //color: Colors.red,
    alignment: Alignment.center,
    child: Center(
      child: SizedBox(
        //color: Colors.blue,
        height: size,
        width: size,
        child: CircularProgressIndicator.adaptive(
          semanticsLabel: semantics,
        ),
      ),
    ),
  );
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool isDayBeforeYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 2));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool isSameDay(final DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(final DateTime other) {
    return year == other.year && month == other.month;
  }

  DateTime dayBefore() {
    return subtract(Duration(days: 1));
  }

  DateTime dayAfter() {
    return add(Duration(days: 1));
  }
}

Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
  final str = await rootBundle.loadString(assetsPath);
  return jsonDecode(str) as Map<String, dynamic>;
}


extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

///Time-based Stateless rate limiter. Pauses for rateLimit duration, and returns
///current time after pausing.
///Return value can help keep track of the previous time, example:
///
///  _fetchTime=await rateLimiter(_fetchTime,_rateLimit);
///  data=await _networkFetch(params);
///
/// This assumes _fetchTime was the time at previous fetch, and that
/// a fetch will occur immediately after the rateLimiter call.
/// Else set a _fetchTime value yourself at a more suitable time.
/// For ease of use, the initial value can be null where there
/// is no previous data, which helps reduce code to one
/// function and no 'if' statements
Future<DateTime> rateLimiter(DateTime? previous, Duration rateLimit) async {
  final now = DateTime.now();
  if (previous != null) {
    final diff = now.difference(previous);
    if (diff.compareTo(rateLimit) < 0) {
      final required = rateLimit - diff;
      print(
          'LastfmApiService rate limiting, requires ${required.inMilliseconds}ms to reach ${rateLimit.inMilliseconds}ms');
      await Future.delayed(required);
    }
  }
  return DateTime.now();
}
