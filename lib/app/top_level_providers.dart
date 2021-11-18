// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/lastfmapi.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'models/item.dart';
import 'models/viewmodel.dart';

/// # Top Level Providers
///
/// ## call order of classes (to explain the providers)
///
/// UI->MusicViewModel.search() and .next()->Repository.search()->LastFMAPI.search()->http calls
///
/// the data returned by the API is put in to model objects which are then pumped in to a stream.
/// The UI is rigged up to a stream provider to listen to that stream.
///
/// ## provider 'flow' :
///
/// databaseProvider(LastFMAPI)->repositoryProvider(Repository)->musicInfoStreamProvider(a stream)
///
/// In this MvvM architecture, a ViewModel calls the repository, not
/// the UI calling the reposiroty. The UI registers with the streamProviders to 
/// recieve data.

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
