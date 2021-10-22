import 'package:jobtest_lastfm/app/models/item.dart';

import 'lastfmapi.dart';

class DevAPI<T> implements LastfmApiService {
  @override
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
  MapSD decode(Response response) {
    // TODO: implement decode
    throw UnimplementedError();
  }

  @override
  // TODO: implement modelize
  LastFmModelizer get modelizer => throw UnimplementedError();

  @override
  void close() {
    // TODO: implement close
  }
}
