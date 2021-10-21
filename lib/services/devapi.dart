import 'package:http/src/response.dart';
import 'package:jobtest_lastfm/app/models/item.dart';

import 'lastfmapi.dart';

class DevAPI<T> implements LastfmAPI {
  Future<LastFMSearchResult> search(String searchString,
      {required String searchType, int page = 1, int itemCount = 20}) async {
    final List<MusicInfo> items = [];
    for (var i = 0; i < itemCount; i++) {
      items.add(
          MusicInfo('$searchString${i.toString()}', '', '', {'test': 'test'}));
    }
    await Future.delayed(Duration(milliseconds: 2000));
    if (page > 3) {
      return LastFMSearchResult(<T>[], 3 * itemCount, page);
    }
    return LastFMSearchResult(items, 3 * itemCount, page);
  }

  @override
  Duration rateLimit = Duration.zero;

  @override
  void checkForServiceErrors(MapSD data) {
    // TODO: implement checkForServiceErrors
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  MapSD decode(Response response) {
    // TODO: implement decode
    throw UnimplementedError();
  }

  @override
  T itemJsonToModel(MapSD itemData) {
    // TODO: implement itemJsonToModel
    throw UnimplementedError();
  }

  @override
  int jsonToOjects(MapSD data, List items, String searchType) {
    // TODO: implement jsonToOjects
    throw UnimplementedError();
  }

  @override
  // TODO: implement modelize
  LastFmModelizer get modelizer => throw UnimplementedError();

  @override
  Future<Response> networkFetch(
      String searchType, String searchString, int page) {
    // TODO: implement networkFetch
    throw UnimplementedError();
  }
}
