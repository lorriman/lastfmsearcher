import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/list_view.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

final sharedPreferencesServiceProvider =
    Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

class SharedPreferencesService {
  SharedPreferencesService(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';
  static const viewDensityKey = 'viewDensity';

  Future<void> setViewDensity(ViewDensity viewDensity) async {
    await sharedPreferences.setString(viewDensityKey, viewDensity.name);
  }

  ViewDensity getViewDensity() {
    final str = sharedPreferences.getString(viewDensityKey);
    if (str == null) return ViewDensity.large;
    return ViewDensity.values.firstWhere((element) => element.name == str);
  }

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  //Greg Lorriman
  Future<void> resetForTesting() async {
    await sharedPreferences.setBool(onboardingCompleteKey, false);
  }

  bool isOnboardingComplete() =>
      sharedPreferences.getBool(onboardingCompleteKey) ?? false;
}
