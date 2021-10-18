import 'package:http/src/response.dart';
import 'package:jobtest_lastfm/app/models/item.dart';
import 'package:jobtest_lastfm/services/repository.dart';

import 'lastfmapi.dart';

class DevDatabase<T> implements LastfmAPI {
  Future<SearchResult> search(String searchString,
      {required MusicInfoType searchType,
      int page = 1,
      int itemCount = 20}) async {
    final List<MusicInfo> items = [];
    for (var i = 0; i < itemCount; i++) {
      items.add(
          MusicInfo('$searchString${i.toString()}', '', '', {'test': 'test'}));
    }
    await Future.delayed(Duration(milliseconds: 500));
    if (page > 3) {
      return SearchResult(<T>[], 3 * itemCount, page);
    }
    return SearchResult(items, 3 * itemCount, page);
  }

  @override
  Duration rateLimit = Duration.zero;

  @override
  void checkForServiceErrors(MapStringDynamic data) {
    // TODO: implement checkForServiceErrors
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  MapStringDynamic decode(Response response) {
    // TODO: implement decode
    throw UnimplementedError();
  }

  @override
  T itemJsonToModel(MapStringDynamic itemData) {
    // TODO: implement itemJsonToModel
    throw UnimplementedError();
  }

  @override
  List<T> jsonToOjects(MapStringDynamic data, MusicInfoType searchType) {
    // TODO: implement jsonToOjects
    throw UnimplementedError();
  }

  @override
  // TODO: implement modelize
  Modelizer get modelize => throw UnimplementedError();

  @override
  Future<Response> networkFetch(
      MusicInfoType searchType, String searchString, int page) {
    // TODO: implement networkFetch
    throw UnimplementedError();
  }
}