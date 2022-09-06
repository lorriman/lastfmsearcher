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
    print('Faves search');
    int totalItems = 0;
    final prefs = await SharedPreferences.getInstance();

    //final test=prefs.getString(_favouritesKey);
    final response = prefs.getStringList(_favouritesKey);

    final items = <T>[];

    if (response != null) {
      for (var rawJson in response) {
        if (rawJson.trim() != '') {
          final item = _jsonToObject(rawJson);
          items.add(item);
        }
      }
      totalItems = items.length; // _jsonToObjects(data, items, searchType);
    }
    return LastFMSearchResult(items, totalItems, page);
  }

/*
  ///extracts meta data, like the total available number of
  ///items if all pages were fetched (totalItems) and
  ///then calls toItemJsonToModel to make objects for
  ///each item.
  int _jsonToObjects(String data, Map<T, T> items, String searchType) {
    late final int totalItems;
    try {
      data.forEach((key, MapSD value) {
        final T item = _itemJsonToObject(value);
        items[item]=item;
      });
    } catch (e, st) {
      logger.e(e, '', st);
      throw LastFmApiException(
          'App: problem with the data returned by SharedPreferences - $data');
    }
    return data.length;
  }
*/

  ///produces a model object (with a callback, modelizer, provided by the
  ///client object)
  /// todo: Is this pointless? Refactor? Tried defining an IJson as a more
  /// elegant solution but doesn't work with dart generics
  T _jsonToObject(String rawJson) {
    final itemData = json.decode(rawJson) as MapSD;

    final favourite = (itemData['favourite'] ?? false) as bool;
    final String name = (itemData['name'] ?? '') as String;
    final String imageSmall = (itemData['imageLinkSmall'] ?? '') as String;
    final String imageMedium = (itemData['imageLinkMedium'] ?? '') as String;
    final String imageLarge = (itemData['imageLinkLarge'] ?? '') as String;
    final String imageXLarge = (itemData['imageLinkXLarge'] ?? '') as String;
    final String url = (itemData['url'] ?? '') as String;
    final other =
        (itemData['otherData'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    //callback, note the cast at the end
    return modelizer(favourite, name, imageSmall, imageMedium, imageLarge,
        imageXLarge, url, other, itemData) as T;
  }

  Future<void> add(T item) async {
    final searchResults = await search('');
    assert(!searchResults.items.contains(item));
    searchResults.items.insert(0, item);
    final newStrings = <String>[];
    for (dynamic itm in searchResults.items) {
      newStrings.add(itm.toJson());
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favouritesKey, newStrings);
  }

  Future<void> delete(T item) async {
    final searchResults = await search('');
    assert(searchResults.items.contains(item));
    searchResults.items.remove(item);
    final newStrings = <String>[];
    for (dynamic itm in searchResults.items) {
      newStrings.add(itm.toJson());
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favouritesKey, newStrings);
    /*
    final searchResults = await search('');
    assert(searchResults.items.contains(item));
    searchResults.items.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _favouritesKey, item.toJson());
  */
  }

  @override
  void close() {}
}
