import 'package:flutter/foundation.dart';
import 'package:jobtest_lastfm/services/repository.dart';

class MusicViewModel extends ChangeNotifier {
  MusicViewModel(this._repository);

  //private

  String _searchString = '';
  bool? _isFirst;

  MusicInfoType _searchType = MusicInfoType.albums;
  final Repository _repository;

  //getters

  String get searchString => _searchString;
  int get totalItems => _repository.totalItems;
  bool get hasItems => totalItems > 0;
  MusicInfoType get searchType => _searchType;
  //various, useful to make UI more readable
  bool get isLoading => _repository.status == RepoStatus.loading;
  bool get notLoading => !isLoading;

  bool get isFirst => _isFirst ?? false;
  bool get notReady => !isReady;
  bool get isReady =>
      (_searchString.trim().length > 2) &&
      (_repository.status != RepoStatus.loading);

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
  void onRadioChange(MusicInfoType? value) {
    assert(value != null);
    if (value != null) searchType = value;
  }

  //methods

  ///fetches data, but does not return it. Data comes async through
  ///the repository streams.
  ///With a calculated delay for UI purposes.
  ///Eg, to guarantee a progress indicator gets a chance to display.
  ///If the fetch is less than 350 milliseconds the repository method
  ///will delay the return of data through the stream by the difference.
  void fetch() {
    if (_isFirst == null) {
      _isFirst = true;
      notifyListeners();
    } else {
      _isFirst = false;
    }
    _repository.next(uiDelayMillisecs: 350);
  }
}
