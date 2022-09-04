// Flutter imports:
import 'package:flutter/foundation.dart';

import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:jobtest_lastfm/services/repository.dart';

import 'item_model.dart';

///A number of properties are provided to reduce UI clutter as well as serve
///specific UI requirements.
class MusicItemsViewModel extends ChangeNotifier {
  MusicItemsViewModel(this._repository, [this._favesRepository = null]);

  //private

  final Repository<MusicInfo> _repository;
  final Repository<MusicInfo>? _favesRepository;

  String _searchString = '';
  bool? _isFirst;
  MusicInfoType _searchType = MusicInfoType.albums;

  //getters

  String get searchString => _searchString;

  int get totalItems => _repository.totalItems;

  bool get hasSearched => _repository.status == RepoStatus.loaded;

  MusicInfoType get searchType => _searchType;

  //useful to make UI more readable and less cluttered
  bool get isLoading => _repository.fetchPhase == FetchPhase.fetching;

  bool get notLoading => !isLoading;

  //replicated by [RepoFetchResult.isFirst] but needed in the loading phase
  //prior to a RepoFetchResult coming through in the streams.
  bool get isFirst => _isFirst ?? false;

  bool get isReady =>
      (_searchString.trim().length > 2) &&
      (_repository.fetchPhase != FetchPhase.fetching);

  bool get notReady => !isReady;

  //setters

  set searchString(String str) {
    if (str != _searchString) _isFirst = null;
    _searchString = str;
    _repository.searchInit(searchString, _searchType);
    notifyListeners();
  }

  set searchType(MusicInfoType searchType) {
    _searchType = searchType;
    _repository.reset();
    notifyListeners();
  }

  //events/callbacks

  ///callback to support state for radio buttons
  ///Uses nullable type as legacy of pre-nullable Flutter
  void onSearchTypeChange(MusicInfoType? value) {
    assert(value != null);
    if (value != null) searchType = value;
  }

  //methods

  ///fetches data, but does not return it. Data comes through
  ///the repository streams.
  ///With a calculated delay for UI purposes. Eg, to guarantee a
  ///circular progress indicator gets a chance to display.
  ///If the fetch is less than 350 milliseconds the repository method
  ///will delay the return of data through the stream by the difference.
  ///
  ///isFirst=true on the first fetch and listeners notified to allow a
  ///loading indicator for the first fetch. This is because the API
  ///is not live streamed and when.loading: is not triggered.
  Future<void> fetch() async {
    if (_isFirst == null) {
      _isFirst = true;
    } else {
      _isFirst = false;
    }
    await _repository.next(uiDelayMillisecs: 350);
    notifyListeners();
  }

  //stream for the UI to hook into with an AsyncValue
  //If _favesRepository is configured reconciled with main stream
  //to supply favourited items.
  Stream<RepositoryFetchResult<MusicInfo>?> itemsStream() {
    print('itemsStream:entered');

    if (_favesRepository == null) return _repository.stream;
    final favsRepo = _favesRepository;
    favsRepo!.reset();
    favsRepo!.searchInit('', MusicInfoType.all);
    favsRepo!.next();

    return CombineLatestStream.combine2(
      //Stream.value(RepositoryFetchResult<MusicInfo>.empty()),//fallback for testing
      _favesRepository!.stream,
      _repository.stream,
      _itemsCombiner,
    );
  }

  static RepositoryFetchResult<MusicInfo>? _itemsCombiner(
      RepositoryFetchResult<MusicInfo>? faveRepFetchResult,
      RepositoryFetchResult<MusicInfo>? repFetchResult) {
    print('items combiner');
    if (repFetchResult == null) return null;
    if (faveRepFetchResult == null) return repFetchResult;

    final List<MusicInfo> newItems = [];
    final items = repFetchResult.items;
    final faveItemsMap =
        Map<MusicInfo, MusicInfo>.fromIterable(faveRepFetchResult.items);
    for (final item in items) {
      final faveItem = faveItemsMap[item];
      if (faveItem != null) {
        newItems.add(faveItem);
      } else {
        newItems.add(item);
      }
    }

    return RepositoryFetchResult<MusicInfo>(
      repFetchResult.infoType,
      newItems,
      repFetchResult.totalItems,
      repFetchResult.isFirst,
      repFetchResult.page,
    );
  }

  Future<void> toggleFavourite(MusicInfo item) async {
    if (item.favourite) {
      await _favesRepository?.removeItem(item);
    } else {
      await _favesRepository?.addItem(item);
    }
    notifyListeners();
  }
}