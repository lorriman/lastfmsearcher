// Dart imports:
import 'dart:async';

// Project imports:
import 'package:jobtest_lastfm/app/models/item_model.dart';
import 'package:jobtest_lastfm/services/utils.dart';
import 'lastfm_api.dart';

// here ignore_for_file directive is because we use empty anonymous callbacks
// instead of nulls to avoid testing for null in unused callbacks.
// ignore_for_file: prefer_function_declarations_over_variables

enum FetchPhase { none, fetching, fetched }

enum RepoStatus { none, init, loaded }

///all is used for favourites
// todo: convert to modern enums
enum MusicInfoType { all, albums, tracks, artists }

const Map<MusicInfoType, String> searchTypeApiStrings = <MusicInfoType, String>{
  MusicInfoType.albums: 'album',
  MusicInfoType.tracks: 'track',
  MusicInfoType.artists: 'artist',
  MusicInfoType.all: 'all',
};

const Map<MusicInfoType, String> musicInfoTypeUIStrings = {
  MusicInfoType.albums: 'albums',
  MusicInfoType.tracks: 'tracks',
  MusicInfoType.artists: 'artists',
  MusicInfoType.all: 'all',
};

///A single object of this type is the result from a Repository.fetch(), and
///is sent in the streams. They are not returned by any methods.
///Implementation is to use StreamBuilders or streamProviders.
//todo: generalise by converting MusicInfoType to a thingy
class RepositoryFetchResult<T> {
  RepositoryFetchResult(
    this.infoType,
    this.items,
    this.totalItems,
    // ignore: avoid_positional_boolean_parameters
    this.isFirst,
    this.page,
  ) {
    debugLog('hashCode: ${this.hashCode} items: ${items.length}',
        'RepositoryFetchResult()');
  }

  factory RepositoryFetchResult.empty() {
    return RepositoryFetchResult(MusicInfoType.all, <T>[], 0, true, 1);
  }

  final MusicInfoType infoType; //this should be an enum
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
  Repository({required ApiService lastFMapi} ) : _lastFMapi = lastFMapi {
    _streamController = StreamController<RepositoryFetchResult<T>?>(
        onListen: () {
          debugLog(debugLabel,'listening');
        },
        onResume: () => print('resuming'));
    _streamPageController = StreamController<RepositoryFetchResult<T>?>(
        onListen: () => print('pager listening'));
  }

  //private

  final ApiService _lastFMapi;

  //stream are expected to be used by StreamProviders, see the stream getters
  late final StreamController<RepositoryFetchResult<T>?> _streamController;
  late final StreamController<RepositoryFetchResult<T>?> _streamPageController;
  String _searchString = '';
  MusicInfoType _musicInfoType = MusicInfoType.albums;
  final List<T> _items = [];
  final Map<String, T> _lookupItems = {};
  int _page = -1;
  int _totalItems = -1;
  FetchPhase _fetchPhase = FetchPhase.none;
  RepoStatus _status = RepoStatus.none;

  //getters

  String get debugLabel =>"repository(${_lastFMapi.runtimeType}) ";

  RepoStatus get status => _status;

  FetchPhase get fetchPhase => _fetchPhase;

  int get totalItems => _totalItems;

  ///Suitable for endless scrolling listviews.
  ///
  ///Stream that is the main source of fetched data. (The next() call
  ///does not return data.) The data added is all items from all pages
  ///that have so far been fetched for the current search string.
  Stream<RepositoryFetchResult<T>?> get stream {
    debugLog(debugLabel,'get stream');
    return _streamController.stream;
  }

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
  static LastFmModelizer modelize = (favourite,
      name,
      imageLinkSmall,
      imageLinkMedium,
      imageLinkLarge,
      imageLinkXLarge,
      url,
      otherData,
      rawData) {
    String newName = name;
    String artist = '';
    artist = (otherData['artist'] ?? '') as String;
    if (name == '(null)') {
      newName = '($artist)';
      artist =
          ''; //blank the artist because it's an entry with no name, so the artist takes its place
    }

    return MusicInfo(
      favourite,
      newName,
      artist,
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
    debugLog(debugLabel, 'reset');
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
    debugLog(debugLabel,'searchInit: $searchStr');
    final str = searchStr.trim();
    if (str.isEmpty) reset();
    if (str != _searchString) reset();
    if (searchType == MusicInfoType.all || str.length > 2)
      _status = RepoStatus.init;
    _searchString = str;
    _musicInfoType = searchType;
    _page = 0;
  }

  ///Next page of data added to previously fetched items and
  ///added to the stream.
  ///The uiDelayMillisecs is to guarantee that a progress indicator gets to be
  /// seen in case fetching is near instantaneous.
  Future<void> next({int uiDelayMillisecs = 0}) async {
    try {
      assert(_page > -1);
      assert(_lastFMapi.runtimeType == LastfmApiService
          ? _searchString.length > 2
          : true);
      assert(_status != RepoStatus.none);
      // assert(_streamController.hasListener ||
      //     _streamPageController.hasListener, 'no stream subscribers');
      debugLog(debugLabel, 'next');
      final stopWatch = Stopwatch()..start();

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

      if (_streamPageController.hasListener) _streamPageController.add(
          fetchResultPage);

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
      if (_streamController.hasListener) _streamController.add(fetchResultAll);
      debugLog(debugLabel,
          'next _streamController.add ${fetchResultAll.items.length} items');
      //print('after finalized fetch');
      final delay = uiDelayMillisecs - stopWatch.elapsed.inMilliseconds;
      await Future.delayed(Duration(milliseconds: delay));
    }on AssertionError catch(e){
      debugLog(debugLabel,e.toString());
    }  on Exception catch( e){
      debugLog(debugLabel,e.toString());
  }finally {
      _fetchPhase = FetchPhase.none;
    }
  }

  ///for example: to add to a favourites list
  Future<void> addItem(T item) async {
    await _lastFMapi.add(item);
  }

  Future<void> removeItem(T item) async {
    await _lastFMapi.delete(item);
  }

  void dispose() {
    debugLog(debugLabel,'dispose');
    _streamController.close();
    _streamPageController.close();
  }
}
