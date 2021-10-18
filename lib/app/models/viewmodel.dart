import 'package:jobtest_lastfm/services/repository.dart';
import 'package:state_notifier/state_notifier.dart';

enum FetchType { none, first, subsequent, complete }

class MusicViewModel {
  MusicViewModel(this._repository);

  //private

  String _searchString = '';
  final Repository _repository;
  FetchType _status = FetchType.none;
  int _totalResults = -1;

  //getters

  String get searchString => _searchString;
  FetchType get status => _status;
  int get totalResults => _totalResults;
  bool get hasMoreData {
    return status == FetchType.first || status == FetchType.subsequent;
  }

  //setters

  set searchString(String str) {
    if (str != _searchString) {
      _status = FetchType.none;
      _totalResults = -1;
    }
    _searchString = str;
    _repository.searchInit(searchString);
  }

  bool get notReady {
    return _searchString.length < 3;
  }

  ///fetches data
  ///With a calculated delay for UI purposes.
  ///Eg, to guarantee a progress indicator gets a chance to display.
  ///If the fetch is less than 350 milliseconds the repository method
  ///will delay the return of data through the stream by the difference.
  Future<void> fetch() async {
    switch (status) {
      case FetchType.none:
        _status = FetchType.first;
        break;
      case FetchType.first:
        _status = FetchType.subsequent;
        break;
    }
    final completed = await _repository.next(UIdelayMillisecs: 350);
    _status = completed ? FetchType.complete : status;
  }
}
