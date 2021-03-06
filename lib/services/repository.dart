// Dart imports:
import 'dart:async';

// Project imports:
import 'package:jobtest_lastfm/app/models/item_model.dart';
import 'lastfm_api.dart';

// here ignore_for_file directive is because we use empty anonymous callbacks
// instead of nulls to avoid testing for null in unused callbacks.
// ignore_for_file: prefer_function_declarations_over_variables

enum FetchPhase { none, fetching, fetched }

enum RepoStatus { none, init, loaded }

enum MusicInfoType { albums, tracks, artists }

const Map<MusicInfoType, String> searchTypeApiStrings = <MusicInfoType, String>{
  MusicInfoType.albums: 'album',
  MusicInfoType.tracks: 'track',
  MusicInfoType.artists: 'artist',
};

const Map<MusicInfoType, String> musicInfoTypeUIStrings = {
  MusicInfoType.albums: 'albums',
  MusicInfoType.tracks: 'tracks',
  MusicInfoType.artists: 'artists',
};

///A single object of this type is the result from a Repository.fetch(), and
///is sent in the streams. They are not returned by any methods.
///Implementation is to use StreamBuilders or streamProviders.
class RepositoryFetchResult<T> {
  RepositoryFetchResult(
    this.infoType,
    this.items,
    this.totalItems,
    // ignore: avoid_positional_boolean_parameters
    this.isFirst,
    this.page,
  );

  final MusicInfoType infoType;
  final List<T> items;
  final int totalItems;
  final int page;
  final bool isFirst;
  bool get isLast {
    return items.length == totalItems;
  }
}

///Implements domain-level methods around a database/API.
///Does not currently implement paging properly (some code, incomplete)
///but this is where the code for paging would go as the Repository
///is where the data is kept for each search.
///This app uses cumulative scrolling, so each fetch of the next page
///is added to a large and larger List.
///The T parameter is the ViewModel's choice for model object and is passed
///through to the API class, and implemented via a call back.
class Repository<T> {
  Repository({required LastfmApiService lastFMapi}) : _lastFMapi = lastFMapi {
    _streamController = StreamController<RepositoryFetchResult<T>?>(
        onListen: () => print('listening'));
    _streamPageController = StreamController<RepositoryFetchResult<T>?>(
        onListen: () => print('pager listening'));
  }

  //private

  final LastfmApiService _lastFMapi;
  //stream are expected to be used by StreamProviders, see the stream getters
  late final StreamController<RepositoryFetchResult<T>?> _streamController;
  late final StreamController<RepositoryFetchResult<T>?> _streamPageController;
  String _searchString = '';
  MusicInfoType _musicInfoType = MusicInfoType.albums;
  final List<T> _items = [];
  int _page = -1;
  int _totalItems = -1;
  FetchPhase _fetchPhase = FetchPhase.none;
  RepoStatus _status = RepoStatus.none;

  //getters

  RepoStatus get status => _status;
  FetchPhase get fetchPhase => _fetchPhase;
  int get totalItems => _totalItems;

  ///Suitable for endless scrolling listviews.
  ///
  ///Stream that is the main source of fetched data. (The next() call
  ///does not return data.) The data added is all items from all pages
  ///that have so far been fetched for the current search string.
  Stream<RepositoryFetchResult<T>?> get stream => _streamController.stream;

  ///Suitable for paged views with next button.
  ///stream that is the main source for fetched data. (The next() call
  ///does not return data.) The data added is a single page of items
  ///that have been fetched on the last next() call.
  Stream<RepositoryFetchResult<T>?> get streamPage =>
      _streamPageController.stream;

  //events/callback

  ///Callback for immediately prior to fetching data in next()
  ///data is existing fetched items. [totalItems] is -1
  ///on the first fetch, and valid after that.
  void Function(List<T> data) beforeFetch = (_) {};

  ///Callback for immediately after fetching data in next(), before
  ///adding data to a stream. [data] is newly fetched items.
  ///[totalItems], the total that can be returned on repeated fetches
  ///is valid.
  void Function(List<T> data) afterFetch = (_) {};

  ///Callback for end of next() function, eg, after data has been added to
  ///a stream. [data] is both existing items and newly fetched items
  ///concatenated.
  void Function(List<T> data) finalizedFetch = (_) {
    print('finalized fetch');
  };

  ///Callback for use in the API, passed in the apiProvider to the api
  ///constructor [rawData] is the source data from the json for any other
  ///info that could be extracted or further processed to add to a [MusicInfo]
  ///with more fields etc.
  static LastFmModelizer modelize = (name, imageLinkSmall, imageLinkMedium,
      imageLinkLarge, imageLinkXLarge, url, otherData, rawData) {
    String newName = name;
    if (name == '(null)') {
      final str = otherData['artist'] ?? '';
      newName = '($str)';
    }

    return MusicInfo(
      newName,
      imageLinkSmall,
      imageLinkMedium,
      imageLinkLarge,
      imageLinkXLarge,
      url,
      otherData,
    );
  };

  ///This is normally called by searchInit(). Unless the repo is already reset
  ///calling this function will send nulls to both streams.
  void reset() {
    assert(_fetchPhase == FetchPhase.none);
    if (_status == RepoStatus.none) return;
    _page = -1;
    _totalItems = -1;
    _fetchPhase = FetchPhase.none;
    _status = RepoStatus.none;
    _items.clear();
    _streamController.add(null);
    _streamPageController.add(null);
  }

  ///Initialise a search, ready for calling next()
  void searchInit(String searchStr, MusicInfoType searchType) {
    assert(_fetchPhase == FetchPhase.none);
    final str = searchStr.trim();
    if (str.isEmpty) reset();
    if (str != _searchString) reset();
    if (str.length > 2) _status = RepoStatus.init;
    _searchString = str;
    _musicInfoType = searchType;
    _page = 0;
  }

  ///Next page of data added to previously fetched items and
  ///added to the stream.
  ///The uiDelayMillisecs is to guarantee that a progress indicator gets to be
  /// seen in case fetching is near instantaneous.
  Future<void> next({int uiDelayMillisecs = 0}) async {
    assert(_page > -1);
    assert(_searchString.length > 2);
    assert(_status != RepoStatus.none);
    final stopWatch = Stopwatch()..start();
    try {
      beforeFetch(_items);
      _fetchPhase = FetchPhase.fetching;
      final results = await _lastFMapi.search(_searchString,
          searchType: searchTypeApiStrings[_musicInfoType]!, page: ++_page);
      _totalItems = results.totalItems;
      _fetchPhase = FetchPhase.fetched;
      _status = RepoStatus.loaded;
      afterFetch(results.items as List<T>);
      //page of results
      final fetchResultPage = RepositoryFetchResult<T>(_musicInfoType,
          results.items as List<T>, results.totalItems, _items.isEmpty, _page);

      _streamPageController.add(fetchResultPage);
      _items.addAll(results.items as List<T>);
      //all results, for infinite scrolling
      final fetchResultAll = RepositoryFetchResult<T>(
        _musicInfoType,
        _items,
        results.totalItems,
        _items.isEmpty,
        _page,
      );
      _fetchPhase = FetchPhase.none;
      _streamController.add(fetchResultAll);
      print('call finalized fetch');
      finalizedFetch(_items);
      print('after finalized fetch');
      final delay = uiDelayMillisecs - stopWatch.elapsed.inMilliseconds;
      await Future.delayed(Duration(milliseconds: delay));
    } finally {
      _fetchPhase = FetchPhase.none;
    }
  }

  void dispose() {
    _streamController.close();
    _streamPageController.close();
  }
}
