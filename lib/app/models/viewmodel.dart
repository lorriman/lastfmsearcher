import 'package:flutter/foundation.dart';
import 'package:jobtest_lastfm/app/models/item.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:state_notifier/state_notifier.dart';

class MusicViewModel extends ChangeNotifier {
  MusicViewModel(this._repository);

  //private

  String _searchString = '';
  bool? _isFirst;
  final Repository _repository;
  //FetchType _status = FetchType.none;
  //int _totalResults = -1;

  //getters

  String get searchString => _searchString;
  //FetchType get status => _status;
  //int get totalResults => _totalResults;

  bool get isLoading => _repository.status == RepoStatus.loading;

  bool get isFirst => _isFirst ?? false;

  //setters

  set searchString(String str) {
    if (str != _searchString) _isFirst = null;
    _searchString = str;
    _repository.searchInit(searchString);
    notifyListeners();
  }

  bool get notReady {
    return _searchString.trim().length < 3;
  }

  ///fetches data
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
    _repository.next(UIdelayMillisecs: 350);
  }
}

//debuggin async code
