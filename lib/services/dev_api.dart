// Package imports:
import 'package:http/http.dart';

// Project imports:
import 'package:jobtest_lastfm/app/models/item_model.dart';
import 'lastfm_api.dart';

const int dev_api_page_length=20;

//For debugging and perhaps testing.
class DevAPI<T> implements LastfmApiService<T> {

  //DevAPI.test(): super.test();

  @override
  Future<LastFMSearchResult> search(String searchString,
      {required String searchType, int page = 1, int itemCount = dev_api_page_length}) async {
    final List<MusicInfo> items = [];
    for (var i = 0; i < itemCount; i++) {
      items.add(
          MusicInfo('$searchString${i.toString()}', '', '','', {'test': 'test'}));
    }
    await Future.delayed(Duration(milliseconds: 350));
    if (page > 3) {
      return LastFMSearchResult(<T>[], 3 * itemCount, page);
    }
    return LastFMSearchResult(items, 3 * itemCount, page);
  }

  @override
  Duration rateLimit = Duration.zero;

  @override
  MapSD decode(Response response)=> throw UnimplementedError();


  @override
  LastFmModelizer get modelizer => throw UnimplementedError();


  @override
  void close() {
  }
}
