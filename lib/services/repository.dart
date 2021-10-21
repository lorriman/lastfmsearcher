//import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:jobtest_lastfm/app/models/item.dart';
import 'package:jobtest_lastfm/app/models/musicinfoview.dart';

import 'devapi.dart';
import 'lastfmapi.dart';

enum RepoStatus { none, init, loading }

const Map<MusicInfoType, String> musicInfoTypeStrings = {
  MusicInfoType.albums: 'albums',
  MusicInfoType.tracks: 'tracks',
  MusicInfoType.artists: 'artists',
};

class RepoFetchResult<T> {
  RepoFetchResult(
    this.infoType,
    this.items,
    this.totalItems,
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

class Repository<T> {
  Repository({required LastfmAPI lastFMapi}) : _lastFMapi = lastFMapi {
    _streamController = StreamController<RepoFetchResult<T>?>(
        onListen: () => print('listening'));
    _streamPageController = StreamController<RepoFetchResult<T>?>(
        onListen: () => print('pager listening'));
  }

  final LastfmAPI _lastFMapi;
  late final StreamController<RepoFetchResult<T>?> _streamController;
  late final StreamController<RepoFetchResult<T>?> _streamPageController;
  String _searchString = '';
  MusicInfoType _musicInfoType = MusicInfoType.albums;
  final List<T> _items = [];
  int _page = -1;
  int _totalItems = -1;
  RepoStatus _status = RepoStatus.none;

  //gets

  RepoStatus get status => _status;

  ///stream that is the main source of fetched data. (The next() call
  ///does not return data.) The data added is all items from all pages
  ///that have so far been fetched on a single search string.
  ///Suitable for endless scrolling listviews.
  Stream<RepoFetchResult<T>?> get stream => _streamController.stream;
  //stream that is the main source for fetched data. (The next() call
  //does not return data.) The data added is a single page of items
  //that have been fetched on the last next() call.
  //Suitable for paged views with next button.
  Stream<RepoFetchResult<T>?> get streamPage => _streamPageController.stream;

  //events/callback

  ///callback for immediately prior to fetching data in next()
  ///cancel. data is existing fetched items. totalItems is -1
  ///on the first fetch, and valid after that.
  void Function(List<T> data) beforeFetch = (_) {};

  ///callback for immediately after fetching data in next(), before
  ///adding data to a stream. data is newly fetched items.
  ///totalItems, the total that can be returned on repeated fetches
  ///is valid.
  void Function(List<T> data) afterFetch = (_) {};

  ///callback for end of next() function, eg, after data has been added to
  ///a stream. data is both existing items and newly fetched items concatenated.
  void Function(List<T> data) finalizedFetch = (_) {};

  ///callback for use in the API, passed in the apiProvider to the api constructor
  ///rawData is the source data from the json for any other
  ///info that could be extrated or further processed to add to a MusicInfo with
  ///more fields etc.
  // ignore: prefer_function_declarations_over_variables
  static Modelizer modelize =
      (name, imageLinkSmall, imageLinkMedium, otherData, rawData) {
    return MusicInfo(
      name,
      imageLinkSmall,
      imageLinkMedium,
      otherData,
    );
  };

  void reset() {
    _searchString = '';
    _items.clear();
    _page = -1;
    _totalItems = -1;
    _streamController.add(null);
    _streamPageController.add(null);
    _status = RepoStatus.none;
  }

  //initialise a search, ready for calling next()
  void searchInit(String searchStr, MusicInfoType searchType) {
    final str = searchStr.trim();
    if (str.isEmpty) reset();
    if (str.length > 2) _status = RepoStatus.init;
    //preserve whitespace for UI
    _searchString = searchStr;
    _musicInfoType = searchType;
  }

  ///next page of data added to previously fetched items and
  ///added to the stream.
  Future<void> next({int UIdelayMillisecs = 0}) async {
    final stopWatch = Stopwatch();
    stopWatch.start();
    _status = RepoStatus.loading;
    try {
      beforeFetch(_items);
      final results = await _lastFMapi.search(_searchString,
          searchType: _musicInfoType, page: _page);
      _totalItems = results.totalItems;
      afterFetch(results.items as List<T>);
      _page++;
      final fetchResultPage = RepoFetchResult<T>(
          _musicInfoType,
          results.items as List<T>,
          results.totalItems,
          _items.length == 0,
          _page);
      _streamPageController.add(fetchResultPage);
      _items.addAll(results.items as List<T>);
      final fetchResultAll = RepoFetchResult<T>(
        _musicInfoType,
        _items,
        results.totalItems,
        _items.length == 0,
        _page,
      );
      _status = RepoStatus.none;
      print('before stream add');
      _streamController.add(fetchResultAll);
      print('after stream add');
      finalizedFetch(_items);
      //completed = _items.length == _totalItems;
      _status = RepoStatus.none;
      final delay = UIdelayMillisecs - stopWatch.elapsed.inMilliseconds;
      await Future.delayed(Duration(milliseconds: delay));
    } finally {
      _status = RepoStatus.none;
    }
  }

  void dispose() {
    _streamController.close();
    _streamPageController.close();
  }
}
