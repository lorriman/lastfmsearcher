// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'globals.dart';

//shorthand as there's a lot of this
typedef MapSD = Map<String, dynamic>;

//todo: make custom exceptions work like native exceptions.

class LastFmServerException implements Exception {
  final String cause;
  LastFmServerException(this.cause);
}

class LastFmApiException implements Exception {
  final String cause;
  LastFmApiException(this.cause);
}

class LastFmRateLimitException implements Exception {
  final Duration millisecondsLimit;
  LastFmRateLimitException(this.millisecondsLimit);
  @override
  String toString() {
    return 'Rate limit of ${millisecondsLimit.inMilliseconds} exceeded';
  }
}

class LastFMSearchResult<T> {
  LastFMSearchResult(this.items, this.totalItems, this.currentPage);

  final List<T> items;
  final int totalItems;
  final int currentPage;
}

///for a client to supply a callback to produce the T objects they want
typedef LastFmModelizer<T> = T Function(
  String name,
  String imageLinkSmall,
  String imageLinkMedium,
  String url,
  Map<String, String> otherData,
  MapSD rawData,
);

///Call the search method.
class LastfmApiService<T> {
// The service avoids data state, which should be managed by objects using it.
  final _client = http.Client();
  final String _apiKey;
  Duration rateLimit;
  DateTime? _fetchTime;
 final  LastFmModelizer modelizer;
//  LastFmModelizer modelizer=(_,__,___,____,______,_______){return 'placeholder - see lastfm_api.dart';};

  //retired: for testing purposes, see [DevAPI]
  //LastfmApiService.test(): _apiKey='' , rateLimit=Duration(seconds: 1);

  LastfmApiService({
    required this.rateLimit,
    required String apiKey,
    required this.modelizer,
  })  : _apiKey = apiKey,
        assert(rateLimit.inMilliseconds > -1);

  ///searchType is either 'album', 'track' or 'artist' as String.
  ///LastFM server handles errors.
  ///itemCount is number of items to fetch per page.
  ///fetching beyond the end returns an empty result, not null.
  ///The total potential number of items returnable from
  ///all pages is given in every returned LastFMSearchResult object
  Future<LastFMSearchResult> search(String searchString,
      {required String searchType, int page = 1, int itemCount = 50}) async {
    print('Api search');
    final response = await _networkFetch(searchType, searchString, page);
    final data = decode(response);
    _checkForServiceErrors(data);
    final items = <T>[];
    final totalItems = _jsonToObjects(data, items, searchType);
    return LastFMSearchResult(items, totalItems, page);
  }

  Future<http.Response> _networkFetch(
      String searchType, String searchString, int page) async {
    final link =
        'https://ws.audioscrobbler.com/2.0/?method=$searchType.search&$searchType=$searchString&page=$page&api_key=$_apiKey&format=json';
    final url = Uri.parse(link);
    await _rateExceptionOrLimit(limit: kReleaseMode);
    final response = await _client
        .get(url, headers: {'Accept': 'application/json; charset=UTF-8'});
    if (response.statusCode != 200) {
      throw LastFmServerException('Server: ${response.reasonPhrase}');
    }
    return response;
  }

  MapSD decode(http.Response response) {
    final MapSD data = json.decode(response.body) as MapSD;
    return data;
  }

  void _checkForServiceErrors(MapSD data) {
    if (data['error'] != null) {
      String msg = 'There was an error fetching the data from LastFM';
      switch (data['error']) {
        case '11':
          {
            msg = 'LastFM says the service is offline (maintenance?).';
          }

          break;
        case '29':
          {
            msg = 'LastFM says the app is using the service too much.';
          }
          break;
      }
      logger.e(data['message']);
      throw LastFmApiException('Api: $msg');
    }
  }

  ///extracts meta data, like the total available number of
  ///items if all pages were fetched (totalItems) and
  ///then calls toItemJsonToModel to make objects for
  ///each item.
  int _jsonToObjects(MapSD data, List<T> items, String searchType) {
    late final int totalItems;
    try {
      final info = data['results'] as MapSD;
      final List<dynamic> itemsMatches =
          info['${searchType}matches'][searchType] as List<dynamic>;

      totalItems = int.parse(info['opensearch:totalResults']);

      for (int idx = 0; idx < itemsMatches.length; idx++) {
        final T item = _itemJsonToObject(itemsMatches[idx]);
        items.add(item);
      }
    } catch (e, st) {
      logger.e(e, '', st);
      throw LastFmApiException(
          'App: problem with the data from lastFM - $data');
    }
    return totalItems;
  }

  ///produces a model object (with a callback, modelizer, provided by the
  ///client object)
  T _itemJsonToObject(MapSD itemData) {
    final name = itemData['name'] as String;
    final imageSmall = (itemData['image']?[0]?['#text'] ?? '') as String;
    final imageMedium = (itemData['image']?[1]?['#text'] ?? '') as String;

    final strData = Map.from(itemData);
    //remove non-strings
    strData.removeWhere((dynamic key, dynamic value) => value is! String);
    final other = strData.map<String, String>(
        (dynamic k, dynamic v) => MapEntry(k, v as String));
    other.remove('name');
    final url=other['url'] ?? '';
    //callback, note the cast at the end
    final item = modelizer(name, imageSmall, imageMedium, url, other, itemData) as T;
    return item;
  }

  ///Guard against hammering the lastfM server and getting a ban.
  ///limit==true for release, otherwise throws an exception as
  ///likely a bug.
  Future<void> _rateExceptionOrLimit({required bool limit}) async {
    final now = DateTime.now();
    if (_fetchTime != null) {
      final prev = _fetchTime;
      final diff = now.difference(prev!);
      if (diff.compareTo(rateLimit) < 0) {
        if (limit) {
          await Future.delayed(diff);
        } else {
          throw LastFmRateLimitException(rateLimit);
        }
      }
    }
    _fetchTime = now;
  }

  void close() {
    _client.close();
  }
}
