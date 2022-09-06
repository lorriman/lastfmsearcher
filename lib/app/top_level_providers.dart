// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/lastfm_api.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/faves-api.dart';
import '../services/shared_preferences_service.dart';
import 'list_view.dart';
import 'models/item_model.dart';
import 'models/items_viewmodel.dart';


/// ## call order of classes (to explain the providers)
///
/// UI->MusicViewModel.search() and ..next()->Repository.search()->LastFMAPI.search()->http calls
///
/// the data returned by the API is put in to model objects which are then pumped in to a stream.
/// The UI is rigged up to a stream provider to listen to that stream.
///
/// ## provider 'flow' :
///
/// databaseProvider(LastFMAPI)->repositoryProvider(Repository)->musicInfoStreamProvider(a stream)
///
/// In this MvvM architecture, a ViewModel calls the repository, not
/// the UI calling the repository. The UI registers with the streamProviders to
/// recieve data.

//todo: writeup MvvM

class FavouritesViewNotifier extends StateNotifier<bool> {
  bool isFavouritesView = false;

  FavouritesViewNotifier(super.state);
}

final isFavouritesViewProvider =
    StateNotifierProvider<FavouritesViewNotifier, bool>((ref) {
  return FavouritesViewNotifier(false);
});

class ViewDensityNotifier extends StateNotifier<ViewDensity> {
  ViewDensity viewDensity = ViewDensity.large;

  ViewDensityNotifier(super.state);
}

final viewDensityProvider =
    StateNotifierProvider<ViewDensityNotifier, ViewDensity>((ref) {
  final vd = ref.read(sharedPreferencesServiceProvider).getViewDensity();
  return ViewDensityNotifier(vd);
});

final databaseProvider = Provider<LastfmApiService<MusicInfo>>((ref) {
  return LastfmApiService<MusicInfo>(
    apiKey: global_apiKey,
    modelizer: Repository.modelize,
    rateLimit: Duration(milliseconds: 350),
  );
});

final repositoryProvider =
    StateProvider.autoDispose<Repository<MusicInfo>>((ref) {
  final database = ref.watch(databaseProvider);

  ref.onDispose(() {});
  return Repository<MusicInfo>(lastFMapi: database);
});

final viewModelProvider =
    ChangeNotifierProvider<MusicItemsViewModel>((ref) {
  return MusicItemsViewModel(
    ref.read(repositoryProvider),
    Repository<MusicInfo>(lastFMapi: ref.read(favouritesDatabaseProvider)),
  );
});

final musicInfoStreamProvider =
StreamProvider<RepositoryFetchResult<MusicInfo>?>((ref) {
  print('calling musicInfoStreamProvider');
  ref.onDispose(() {
    print('disposing musicInfoStreamProvider ');
  });
  final vm = ref.read(viewModelProvider);
  return vm.itemsStream();
});

final favouritesDatabaseProvider =
    Provider<FavouritesApiService<MusicInfo>>((ref) {
  return FavouritesApiService<MusicInfo>(
    modelizer: Repository.modelize,
  );
});

final favouritesRepositoryProvider =
    StateProvider<Repository<MusicInfo>>((ref) {
      final database = ref.watch(favouritesDatabaseProvider);

  ref.onDispose(() {});
  return Repository<MusicInfo>(lastFMapi: database);
});

final favouritesViewModelProvider =
    ChangeNotifierProvider<MusicItemsViewModel>((ref) {
  return MusicItemsViewModel(ref.watch(favouritesRepositoryProvider));
});

final favouritesMusicInfoStreamProvider =
    StreamProvider<RepositoryFetchResult<MusicInfo>?>((ref) {
      final repo = ref.read(favouritesRepositoryProvider);
  return repo.stream;
});

