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

  Stream<RepositoryFetchResult<MusicInfo>?> itemsStream() {
    print('itemsStream:entered');
    //return _repository.stream;

    return CombineLatestStream.combine2(
      Stream.value(RepositoryFetchResult<MusicInfo>.empty()),
      _repository.stream,
      _itemsCombiner,
    );
    /*
    return _repository.stream.map((repositoryFetchResult) {
      print('itemsStream:_repository.stream.map');
      if (repositoryFetchResult == null) return null;
      final items = repositoryFetchResult.items;
      if (items.isEmpty) return repositoryFetchResult;
      print('itemsStream:pre _faveRepository');
      if (_favesRepository == null) return repositoryFetchResult;

      if (_favesRepository != null) {
        _favesRepository!.reset();
        _favesRepository!.searchInit('', MusicInfoType.all);
        _favesRepository!.next();
        print('itemsStream:pre next()');
          _favesRepository!.stream.map((faveRepositoryFetchResult) {
          print('itemsStream:_favesRepository!.stream.map');
          if (faveRepositoryFetchResult == null) return repositoryFetchResult;
          if (faveRepositoryFetchResult.items.isEmpty)
            return repositoryFetchResult;

          final newItems =
              _itemsCombiner(faveRepositoryFetchResult.items, items);
          print('itemsStream:pre next() type: ${newItems.runtimeType}');
          return RepositoryFetchResult<MusicInfo>(
            repositoryFetchResult.infoType,
            newItems,
            repositoryFetchResult.totalItems,
            repositoryFetchResult.isFirst,
            repositoryFetchResult.page,
          );
        });
      }
    });

     */
    print('itemsStream:Stream.value(null)');
    return Stream.value(null);
    return Stream.value(RepositoryFetchResult(
        MusicInfoType.all, <MusicInfo>[emptyMusicInfo], 1, true, 1));
  }

  static RepositoryFetchResult<MusicInfo>? _itemsCombiner(
      RepositoryFetchResult<MusicInfo>? faveItems,
      RepositoryFetchResult<MusicInfo>? items) {
    final List<MusicInfo> combo = [];
    final faveItemsMap = Map<MusicInfo, MusicInfo>.fromIterable(faveItems);
    for (final item in items) {
      final faveItem = faveItemsMap[item];
      if (faveItem != null) {
        combo.add(faveItem);
      } else {
        combo.add(item);
      }
    }
    return combo;
  }

/*
  Stream<List<RatingChecklistItem>> _checklistitemsTrashItemsStream() {
    //reusing some of the infrastructure of the main Checklist tab, so we need
    //an empty stream since we're not reading any ratings for the trash tab.

    return CombineLatestStream.combine2(
      Stream<Map<String, Rating>>.value({}),
      repository.checklistItemsTrashStream(),
      _ratingsChecklistItemsCombiner,
    );
  }

  static List<RatingChecklistItem> _ratingsChecklistItemsCombiner(
      Map<String, Rating>? ratings, List<ChecklistItem> checklistItems) {
    final List<RatingChecklistItem> combo = [];
    for (final checklistItem in checklistItems) {
      final Rating? rating = ratings?[checklistItem.id];
      combo.add(RatingChecklistItem(rating, checklistItem));
    }
    return combo;
  }
  */
  /// Output stream
// Stream<List<ChecklistItemTileModel>> tileModelStream(DateTime day) =>
//     _checklistitemsRatingitemsStream(day).map(_createModels);
}
