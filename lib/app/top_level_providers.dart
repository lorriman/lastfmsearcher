import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/lastfmapi.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'models/item.dart';
import 'models/viewmodel.dart';

/// # Top Level Providers
///
/// ##Data flow
///
/// (not call order)
///
/// http->Database(creates MusicInfo objects)->Repository->
///   MusicViewModel objects->UI
///
/// This is offered by riverpod provider objects:
/// databaseProvider->repositoryProvider->musicInfoStreamProvider(a stream)->
///   musicViewModelStreamProvider(a stream)
///
/// ##initial call
/// To fetch data, from the UI call repository.search().
/// repository.next() gets further pages.
///
/// ## expectation of use
/// The repository receives MusicInfo model objects from the database
/// which it adds as a list to the repository.stream.
/// That stream is offered by musicInfoStreamProvider.
/// The UI watches this stream.
///
//todo: writeup MvvM

final databaseProvider = Provider((ref) {
  return LastfmApiService<MusicInfo>(
    apiKey: global_apiKey,
    modelizer: Repository.modelize,
    rateLimit: Duration(milliseconds: 350),
  );
});

final repositoryProvider = StateProvider<Repository<MusicInfo>>((ref) {
  final database = ref.watch(databaseProvider);

  ref.onDispose(() {});
  return Repository<MusicInfo>(lastFMapi: database);
});

final viewModelProvider = ChangeNotifierProvider<MusicViewModel>((ref) {
  return MusicViewModel(ref.watch(repositoryProvider).state);
});

final musicInfoProvider = StreamProvider<RepoFetchResult<MusicInfo>?>((ref) {
  final repo = ref.watch(repositoryProvider).state;

  return repo.stream;
});
