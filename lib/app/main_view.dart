// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart' hide Builder;
import 'package:package_info_plus/package_info_plus.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import '../services/shared_preferences_service.dart';
import 'models/item_model.dart';
import 'models/items_viewmodel.dart';
import 'list_view.dart';
import 'package:animations/animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void submit(MusicItemsViewModel viewModel) {
    //test isLoading to absorbs an accidental double-tap without
    //having to disable the button
    if (viewModel.isLoading) return;
    viewModel.searchString = _textController.value.text;
    viewModel.fetch();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width >= global_screen_width_breakpoint;
    return Consumer(builder: (context, ref, _) {
      late MusicItemsViewModel viewModel;
      final isFavouritesView = ref.watch(isFavouritesViewProvider);
      if (isFavouritesView) {
        viewModel = ref.watch(favouritesViewModelProvider);
      } else {
        viewModel = ref.watch(viewModelProvider);
      }

      //otherwise the button disappear in to the appbar
      Color color = Theme.of(context).colorScheme.primary;
      final adjust = 200;
      color = Color.fromRGBO(
          color.red + adjust, color.green + adjust, color.blue + adjust, 0.0);
      final buttonColor = color;
      final buttonStyle = TextButton.styleFrom(
        foregroundColor: color,
      );

      return GestureDetector(
        //legacy keyboard pop-down. We might have to resort to this
        //if the other one doesn't work out. See [MyApp.build]->Listener
/*
        FocusManager.instance.primaryFocus?.unfocus(),
        //FocusScope.of(context).requestFocus(new FocusNode()),
*/
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 65,
            title: Column(
              children: [
                GestureDetector(
                  onTap: () => _showAboutDialog(context),
                  child: Text(
                    'Search LastFM',
                    maxLines: 2,
                    semanticsLabel: 'app title: LastFM searcher',
                  ),
                ),
                if (kDebugMode)
                  Align(
                    //alignment: Alignment.centerRight,
                    child: Text(
                      'debug build',
                      textScaleFactor: 0.5,
                    ),
                  )
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FavouritesButton(ref, isFavouritesView, buttonColor),
              ),
              SizedBox(
                width: 150,
                child: _searchTextField(viewModel),
              ),
              IconButton(
                color: Colors.white,
                key: Key('search_button'),
                icon: Icon(Icons.search, semanticLabel: 'search button'),
                //if search string isn't long enough etc disable the button
                onPressed: viewModel.notReady ? null : () => submit(viewModel),
              ),
            ],
          ),
          body: Builder(builder: (context) {
            final body = Column(
              children: [
                Header(ref, viewModel, isWideScreen),
                Consumer(
                  builder: (context, ref, _) {
                    late final AsyncValue modelsAsyncValue;
                    final isFavouritesView =
                        ref.watch(isFavouritesViewProvider);

                    if (isFavouritesView) {
                      modelsAsyncValue =
                          ref.watch(favouritesMusicInfoStreamProvider);
                    } else {
                      modelsAsyncValue = ref.watch(musicInfoStreamProvider);
                    }
                    //The first loading indicator is done here.
                    //To allow infinite scrolling subsequent loading indicators
                    //are done in the final element of the listview on scrolling
                    //to the end.
                    //see fetchAndIndicate() in [ListViewMusicInfo.build]
                    if (viewModel.isLoading && viewModel.isFirst) {
                      return loadingIndicator(
                          semantics: 'waiting for LastFM', size: 50);
                    }
                    if (modelsAsyncValue.asData == null)
                      return PressSearchIcon();

                    return modelsAsyncValue.when(
                      //data isn't livestreamed (unlike firestore) so
                      //loading: is never called.
                      //see fetchAndIndicate() in [ListViewMusicInfo.build]
                      //This may change.
                      loading: () {
                        print(
                            'AsyncValue.loading!! This shouldn\'t be happening');
                        return Center(
                            child: CircularProgressIndicator.adaptive());
                      },
                      error: (e, st) {
                        print('AsyncValue.error');
                        return SelectableText(
                            'Error $e ${kDebugMode ? st.toString() : ''}');
                      },
                      data: (dynamic data) {
                        print('AsyncValue.data');
                        return Expanded(
                            child: ListViewMusicInfo(
                          musicInfoItems:
                              data?.items as List<MusicInfo>? ?? <MusicInfo>[],
                          viewModel: viewModel,
                          results: data,
                        ));
                      },
                    );
                  },
                ),
                if (!isWideScreen && viewModel.hasSearched) _footer(viewModel),
              ],
            );

            final body1 = Container(child: body);
            final body2 = SizedBox(child: body);
            return PageTransitionSwitcher(
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return FadeThroughTransition(
                  //fillColor: isFavouritesView ? Colors.red.shade200: Theme.of(context).canvasColor,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: isFavouritesView ? body1 : body2,
            );
          }),
        ),
      );
    });
  }

  void _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: 'Searcher for LastFM',
      applicationVersion: 'v. ${info.version.toString()} +${info.buildNumber}',
      applicationIcon: Icon(Icons.info_outline),
    );
  }

  /// search total and dropdown for artist, song, album searches.
  Widget _header(
      WidgetRef ref, MusicItemsViewModel viewModel, bool isWideScreen) {
    final isFavouritesView = ref.read(isFavouritesViewProvider);

    if (isFavouritesView) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(children: [
          if (viewModel.hasSearched && isWideScreen)
            Text('Favourites searched: ${viewModel.totalItems.toThousands()} ',
                style: Theme.of(context).textTheme.headlineSmall)
          else
            Text('Favourites',
                style: Theme.of(context).textTheme.headlineMedium),
          Expanded(
              child: Align(
                  child: Icon(Icons.favorite, color: Colors.red),
                  alignment: Alignment.centerRight)),
        ]),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(children: [
          if (viewModel.hasSearched && isWideScreen)
            Text('found ${viewModel.totalItems.toThousands()} ',
                style: Theme.of(context).textTheme.headline6),
          Expanded(child: Container()),
          _compactViewDropDown(),
          _dropDownSearchType(viewModel),
        ]),
      );
    }
  }

  ///search total when screen is narrow
  SizedBox _footer(MusicItemsViewModel viewModel) {
    return SizedBox(
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('total items : ${viewModel.totalItems.toThousands()}'),
          ),
        ]));
  }

  /// text field for search string.
  Widget _searchTextField(MusicItemsViewModel viewModel) {
    return Theme(
      data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
      )),
      child: TextField(
        key: Key('search_text_field'),
        controller: _textController,
        //support enter key for desktop
        onSubmitted: (_) {
          if (viewModel.isReady) submit(viewModel);
        },
        //select
        onTap: () {
          _textController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: viewModel.searchString.length,
          );
        },
        //autofocus: true,
        //focusNode: FocusNode(),
        textAlign: TextAlign.end,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey[300]),
          hintText: 'album, artist or song',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        showCursor: true,
        onChanged: (value) {
          setState(() {
            viewModel.searchString = value;
          });
        },
      ),
    );
  }

  Widget _dropDownSearchType(MusicItemsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<MusicInfoType>(
            style: Theme.of(context).textTheme.headline5,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            value: viewModel.searchType,
            icon: const Icon(Icons.arrow_drop_down_outlined),
            elevation: 16,
            underline: Container(
              height: 0,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: viewModel.onSearchTypeChange,
            items: MusicInfoType.values
                .map<DropdownMenuItem<MusicInfoType>>((MusicInfoType value) {
                  return DropdownMenuItem<MusicInfoType>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(musicInfoTypeUIStrings[value]!,
                          semanticsLabel: 'search type menu'),
                    ),
                  );
                })
                .toList()
                .take(3)
                .toList(), //todo: modify to avoid hard coding
          )
        ],
      ),
    );
  }

  Widget _compactViewDropDown() {
    return Consumer(
      builder: (context, ref, _) {
        final viewDensity = ref.watch(viewDensityProvider);
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<ViewDensity>(
                iconSize: 0,
                style: Theme.of(context).textTheme.headline5,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                value: viewDensity,
                //icon: const Icon(Icons.arrow_drop_down_outlined),
                elevation: 16,
                underline: Container(
                  height: 0,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (value) {
                  setState(() {
                    ref.read(viewDensityProvider.notifier).state = value!;
                    ref
                        .read(sharedPreferencesServiceProvider)
                        .setViewDensity(value);
                  });
                },

                items: ViewDensity.values.reversed
                    .map<DropdownMenuItem<ViewDensity>>((ViewDensity value) {
                  return DropdownMenuItem<ViewDensity>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(value.icon),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.ref, this.viewModel, this.isWideScreen, {Key? key})
      : super(key: key);

  final WidgetRef ref;
  final MusicItemsViewModel viewModel;
  final bool isWideScreen;

  @override
  Widget build(BuildContext context) {
    return Card(
        //surfaceTintColor: Theme.of(context).primaryColor,
        elevation: 5,
        margin: EdgeInsets.fromLTRB(1, 0, 1, 5),
        shadowColor: Colors.grey.shade50,
        child: Builder(builder: (context) {
          final isFavouritesView = ref.read(isFavouritesViewProvider);

          if (isFavouritesView) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(children: [
                if (viewModel.hasSearched && isWideScreen)
                  Text(
                      'Favourites searched: ${viewModel.totalItems.toThousands()} ',
                      style: Theme.of(context).textTheme.headlineSmall)
                else
                  Text('Favourites',
                      style: Theme.of(context).textTheme.headlineMedium),
                Expanded(
                    child: Align(
                        child: Icon(Icons.favorite, color: Colors.red),
                        alignment: Alignment.centerRight)),
              ]),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(children: [
                if (viewModel.hasSearched && isWideScreen)
                  Text('found ${viewModel.totalItems.toThousands()} ',
                      style: Theme.of(context).textTheme.headline6),
                Expanded(child: Container()),
                _compactViewDropDown(),
                _dropDownSearchType(context, viewModel),
              ]),
            );
          }
        }));
  }

  Widget _dropDownSearchType(
      BuildContext context, MusicItemsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<MusicInfoType>(
            style: Theme.of(context).textTheme.headline5,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            value: viewModel.searchType,
            icon: const Icon(Icons.arrow_drop_down_outlined),
            elevation: 16,
            underline: Container(
              height: 0,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: viewModel.onSearchTypeChange,
            items: MusicInfoType.values
                //.all is not supported by LastFM, used for favourites list :
                .skipWhile((value) => value == MusicInfoType.all)
                .map<DropdownMenuItem<MusicInfoType>>((MusicInfoType value) {
              return DropdownMenuItem<MusicInfoType>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(musicInfoTypeUIStrings[value]!,
                      semanticsLabel: 'search type menu'),
                ),
              );
            }).toList(),
            //.takeWhile((value) => value.value!=MusicInfoType.all)
            //.toList(), //todo: modify to avoid hard coding
          )
        ],
      ),
    );
  }

  Widget _compactViewDropDown() {
    return Consumer(
      builder: (context, ref, _) {
        final viewDensity = ref.watch(viewDensityProvider);
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<ViewDensity>(
                iconSize: 0,
                style: Theme.of(context).textTheme.headline5,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                value: viewDensity,
                //icon: const Icon(Icons.arrow_drop_down_outlined),
                elevation: 16,
                underline: Container(
                  height: 0,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (value) {
                  // demoted setState(() {
                  ref.read(viewDensityProvider.notifier).state = value!;
                  ref
                      .read(sharedPreferencesServiceProvider)
                      .setViewDensity(value);
                  //});
                },

                items: ViewDensity.values.reversed
                    .map<DropdownMenuItem<ViewDensity>>((ViewDensity value) {
                  return DropdownMenuItem<ViewDensity>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(value.icon),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}

class FavouritesButton extends StatelessWidget {
  const FavouritesButton(this.ref, this.isFavouritesView, this.buttonColor,
      {Key? key})
      : super(key: key);

  final bool isFavouritesView;
  final Color buttonColor;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Semantics(
        button: true,
        label: 'toggle favourites list',
        child: NeumorphicButton(
          padding: EdgeInsets.all(5),
          key: Key('faves_button'),
          //icon: Icon(Icons.favorite),
          child: Icon(Icons.favorite, color: Colors.red),
          onPressed: () async {
            final isFavesView = ref.read(isFavouritesViewProvider);
            //if not then prep/refresh the faves view
            //todo: refactor in to a refresh method
            if (!isFavesView) {
              final fvm = ref.read(favouritesViewModelProvider);
              //fvm.searchString = '';
              //await fvm.fetch();
            }
            ref.read(isFavouritesViewProvider.notifier).state =
                !ref.read(isFavouritesViewProvider);
          },
          style: isFavouritesView
              ? NeumorphicStyle(color: buttonColor, depth: -4, intensity: 1)
              : NeumorphicStyle(color: buttonColor, depth: 3, intensity: .4),
          //ButtonStyle(elevation: ButtonStyleButton.allOrNull(20)),
        ),
      ),
    );
  }
}
