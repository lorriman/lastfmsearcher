import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'lastfm_api.dart';

///Call the search method.
class FavouritesApiService<T> extends ApiService<T> {
  static const _favouritesKey = 'favourites_v1';

  FavouritesApiService({
    required LastFmModelizer modelizer,
  }) {
    this.modelizer = modelizer;
  }

  @override
  Future<LastFMSearchResult> search(String searchString,
      {String searchType = '', int page = 1, int itemCount = 50}) async {
    print('Api search');
    int totalItems = 0;
    final prefs = await SharedPreferences.getInstance();

    final response = prefs.getString(_favouritesKey);
    final items = <T>[];

    if (response != null) {
      final data = json.decode(response) as MapSD;

      totalItems = _jsonToObjects(data, items, searchType);
    }
    return LastFMSearchResult(items, totalItems, page);
  }

  ///extracts meta data, like the total available number of
  ///items if all pages were fetched (totalItems) and
  ///then calls toItemJsonToModel to make objects for
  ///each item.
  int _jsonToObjects(MapSD data, List<T> items, String searchType) {
    late final int totalItems;
    try {
      for (int idx = 0; idx < data.length; idx++) {
        final T item = _itemJsonToObject(data[idx]);
        items.add(item);
      }
    } catch (e, st) {
      logger.e(e, '', st);
      throw LastFmApiException(
          'App: problem with the data returned by SharedPreferences - $data');
    }
    return data.length;
  }

  ///produces a model object (with a callback, modelizer, provided by the
  ///client object)
  T _itemJsonToObject(MapSD itemData) {
    final favourite = (itemData['favourite'] ?? false) as bool;
    final String name = (itemData['name'] ?? '') as String;
    final String imageSmall = (itemData['nameimageLinkSmall'] ?? '') as String;
    final String imageMedium = (itemData['imageLinkMedium'] ?? '') as String;
    final String imageLarge = (itemData['imageLinkLarge'] ?? '') as String;
    final String imageXLarge = (itemData['imageLinkXLarge'] ?? '') as String;
    final String url = (itemData['url'] ?? '') as String;
    final other = (itemData['other'] ?? {}) as Map<String, dynamic>;

    //callback, note the cast at the end
    final item = modelizer(favourite, name, imageSmall, imageMedium, imageLarge,
        imageXLarge, url, other, itemData) as T;
    return item;
  }

  Future<void> add(T item) async {
    final searchResults = await search('');
    searchResults.items.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _favouritesKey, searchResults.items as List<String>);
  }

  Future<void> delete(T item) async {
    final searchResults = await search('');
    searchResults.items.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _favouritesKey, searchResults.items as List<String>);
  }

  @override
  void close() {}
}
