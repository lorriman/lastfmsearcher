//import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:jobtest_lastfm/app/models/item.dart';
import 'package:jobtest_lastfm/app/models/musicinfoview.dart';

import 'devapi.dart';
import 'lastfmapi.dart';

const Map<MusicInfoType, String> musicInfoTypeStrings = {
  MusicInfoType.albums: 'albums',
  MusicInfoType.tracks: 'tracks',
  MusicInfoType.artists: 'artists',
};

class Repository<T> {
  Repository({required LastfmAPI lastFMapi}) : _lastFMapi = lastFMapi {
    _streamController =
        StreamController<List<T>?>(onListen: () => print('listening'));
    _streamPageController =
        StreamController<List<T>?>(onListen: () => print('pager listening'));
    init();
  }

  final LastfmAPI _lastFMapi;
  late final StreamController<List<T>?> _streamController;
  late final StreamController<List<T>?> _streamPageController;
  String _searchString = '';
  MusicInfoType _searchType = MusicInfoType.albums;
  final List<T> _items = [];
  int _page = -1;
  int _totalItems = -1;

  void init() {
    reset();
  }

  ///stream that is the main source of fetched data. (The next() call
  ///does not return data.) The data added is all items from all pages
  ///that have so far been fetched on a single search string.
  ///Suitable for endless scrolling listviews.
  Stream<List<T>?> get stream => _streamController.stream;
  //stream that is the main source for fetched data. (The next() call
  //does not return data.) The data added is a single page of items
  //that have been fetched on the last next() call.
  //Suitable for paged views with next button.
  Stream<List<T>?> get streamPage => _streamPageController.stream;

  ///totalItems property is the total number of possible items matched
  ///and that would be fetched if all pages are fetched.
  int get totalItems => _totalItems;

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
  static Modelizer modelize = (
    String name,
    String imageLinkSmall,
    String imageLinkMedium,
    Map<String, String> otherData,
    MapStringDynamic rawData,
  ) {
    return MusicInfo(name, imageLinkSmall, imageLinkMedium, otherData);
  };

  void reset() {
    _searchString = '';
    _items.clear();
    _page = 1;
    _totalItems = -1;
    _streamController.add(null);
    _streamPageController.add(null);
  }

  //initialise a search, ready for calling next()
  void searchInit(String searchStr) {
    final str = searchStr.trim();
    if (searchStr != _searchString) {
      reset();
    }
    _searchString = searchStr;
  }

  ///next page of data added to previously fetched items and
  ///added to the stream.
  ///returns true on no new data
  Future<bool> next({int UIdelayMillisecs = 0}) async {
    final stopWatch = Stopwatch();
    stopWatch.start();
    beforeFetch(_items);
    final results = await _lastFMapi.search(_searchString,
        searchType: _searchType, page: _page);
    _totalItems = results.totalItems;
    afterFetch(results.musicInfoList as List<T>);
    _page++;
    _items.addAll(results.musicInfoList as List<T>);
    final delay = UIdelayMillisecs - stopWatch.elapsed.inMilliseconds;
    await Future.delayed(Duration(milliseconds: delay));
    _streamPageController.add(results.musicInfoList as List<T>);
    _streamController.add(_items);
    finalizedFetch(_items);
    final completed = _items.length == _totalItems;
    return completed;
  }

  void dispose() {
    _streamController.close();
    _streamPageController.close();
  }
}

//#######DevTest
class TestRepository {
  TestRepository() {
    streamController = StreamController<List<String>?>(onListen: () {
      print('listening');
    });
    init();
  }

  void init() {
    reset();
  }

  late final StreamController<List<String>?> streamController;

  final r = Random(3);

  String _searchString = '';
  final List<String> _items = [];
  int _page = 1;

  Stream<List<String>?> get stream => streamController.stream;

  void reset() {
    _searchString = '';
    _items.clear();
    _page = 1;
    streamController.add(null);
  }

  void search(String searchStr) {
    if (searchStr != _searchString) {
      reset();
    }
    _searchString = searchStr;
  }

  void next({int UIdelayMillisecs = 0}) async {
    final List<String> viewModels = [];
    await Future.delayed(Duration(milliseconds: UIdelayMillisecs));
    final ss = await Future.value([
      for (var i = _items.length; i < _items.length + 30; i++)
        'string  $i ' + r.nextDouble().toString()
    ]);
    _items.addAll(ss);
    streamController.add(_items);
    return;
  }

  void dispose() {
    streamController.close();
  }
}
