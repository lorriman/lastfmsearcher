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

//todo: over-complicated rate limiter converting from python
/*sleep() to limit the rate according to a minimum time between calls
    (float in seconds).
    limit() checks for elapsed time and
    calls sleep(secs) for the difference if too fast.
    eg rl=RateLimiter(.5) will sleep on calls to .limit() if
    the time elapsed since the previous call is less than
    500 milliseconds.
    The first call to limit() starts the clock but does not
    rate limit unless the object was initialised with a
    start_time, which avoids haivng to write awkward flow-control loops.
    */
/*
class RateLimiter{

  RateLimiter({required this.minimum, this.start_time=0.0}) {
    reset(start_time);
  }

 double minimum;
  double start_time;



//call limit to start the clock, and each time we want some limiting/sleeping
//ie before calls to BGG since it's rate limited to 2 calls a sec
void limit()  async {
//sleep if elapsed time less than minimum'''
  final time_taken = DateTime.now - _prev_time;
  __prev_time = Datetime.now();
  if time_taken < _minimum:
  final s=_minimum-time_taken;
  _counter+=s;
  await Future.delayed(Duration(seconds : s));
  //read timer again since sleep may be longer than requested
  _prev_time = Datetime.now();
}


def reset(self,start_time=0.0):
'''re-initialize but keep the minimum'''
self.__prev_time=start_time
self.__counter=0.0

def count(self):
'''Give cumulative amount of limiting, which maybe zero if
        operations are slower than the rate limit'''
return self.__counter


*/
