import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

enum MusicInfoType { albums, tracks, artists }

const Map<MusicInfoType, String> searchTypeApiKeys = {
  MusicInfoType.albums: 'album',
  MusicInfoType.tracks: 'track',
  MusicInfoType.artists: 'artist',
};

typedef MapStringDynamic = Map<String, dynamic>;

typedef LastFmModelizer<T> = T Function(
  String name,
  String imageLinkSmall,
  String imageLinkMedium,
  Map<String, String> otherData,
  MapStringDynamic rawData,
);

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

class LastfmAPI<T> {
  final _client = http.Client();
  final String _apiKey;
  int _totalItems = -1;
  DateTime? _fetchTime;
  Duration rateLimit;
  final LastFmModelizer modelize;

  //todo: remove my apikey
  LastfmAPI({
    required this.rateLimit,
    required String apiKey,
    required this.modelize,
  })  : _apiKey = apiKey,
        assert(rateLimit.inMilliseconds > -1);

  ///this is the only method that should be called.
  ///Other public methods are for inheritance purposes.
  Future<LastFMSearchResult> search(String searchString,
      {required MusicInfoType searchType,
      int page = 1,
      int itemCount = 50}) async {
    late final List<T> items;
    final response = await networkFetch(searchType, searchString, page);
    final data = decode(response);
    checkForServiceErrors(data);
    items = jsonToOjects(data, searchType);
    return LastFMSearchResult(items, _totalItems, page);
  }

  List<T> jsonToOjects(MapStringDynamic data, MusicInfoType searchType) {
    final items = <T>[];
    try {
      final info = data['results'] as MapStringDynamic;
      final List<dynamic> itemsMatches =
          info['${searchTypeApiKeys[searchType]}matches']
              [searchTypeApiKeys[searchType]] as List<dynamic>;

      _totalItems = int.parse(info['opensearch:totalResults']);

      for (int idx = 0; idx < itemsMatches.length; idx++) {
        final T item = itemJsonToModel(itemsMatches[idx]);
        items.add(item);
      }
    } catch (e, st) {
      logger.e(e, '', st);
      throw LastFmApiException(
          'App: problem with the data from lastFM - $data');
    }
    return items;
  }

  Future<http.Response> networkFetch(
      MusicInfoType searchType, String searchString, int page) async {
    final link =
        'https://ws.audioscrobbler.com/2.0/?method=${searchTypeApiKeys[searchType]}.search&${searchTypeApiKeys[searchType]}=$searchString&page=${page.toString()}&api_key=$_apiKey&format=json';
    final url = Uri.parse(link);
    await _checkRateOrLimit(limit: kReleaseMode);
    final response = await _client
        .get(url, headers: {'Accept': 'application/json; charset=UTF-8'});
    if (response.statusCode != 200) {
      throw LastFmServerException('Server: ${response.reasonPhrase}');
    }
    return response;
  }

  MapStringDynamic decode(http.Response response) {
    final MapStringDynamic data =
        json.decode(response.body) as MapStringDynamic;
    return data;
  }

  void checkForServiceErrors(MapStringDynamic data) {
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

  T itemJsonToModel(MapStringDynamic itemData) {
    final name = itemData['name'] as String;
    final imageSmall = (itemData['image']?[0]?['#text'] ?? '') as String;
    final imageMedium = (itemData['image']?[1]?['#text'] ?? '') as String;
    final strData = Map.from(itemData);
    //remove non-strings
    strData.removeWhere((dynamic key, dynamic value) => value is! String);
    //make a Map(String,String)
    final other = strData.map<String, String>(
        (dynamic k, dynamic v) => MapEntry(k, v as String));
    other.remove('name');
    //callback, note the cast at the end
    final item = modelize(name, imageSmall, imageMedium, other, itemData) as T;
    return item;
  }

  ///guard against hammering the lastfM server and getting a ban
  Future<void> _checkRateOrLimit({required bool limit}) async {
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
