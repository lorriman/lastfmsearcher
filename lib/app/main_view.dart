// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:package_info_plus/package_info_plus.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import 'models/item_model.dart';
import 'models/items_viewmodel.dart';
import 'list_view.dart';

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
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: NeumorphicButton(
                    padding: EdgeInsets.all(5),

                    //color: Colors.red,
                    //isSelected: true,
                    key: Key('faves_button'),
                    //icon: Icon(Icons.favorite),
                    child: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      ref.read(isFavouritesViewProvider.notifier).state =
                          !ref.read(isFavouritesViewProvider);
                    },
                    style: isFavouritesView
                        ? NeumorphicStyle(
                            color: Colors.purple, depth: -4, intensity: 1)
                        : NeumorphicStyle(
                            color: Colors.purple, depth: 3, intensity: .4),
                    //ButtonStyle(elevation: ButtonStyleButton.allOrNull(20)),
                  ),
                ),
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _header(ref, viewModel, isWideScreen),
              ),
              Consumer(
                builder: (context, ref, _) {
                  late final AsyncValue modelsAsyncValue;
                  final isFavouritesView = ref.watch(isFavouritesViewProvider);
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
                  if (modelsAsyncValue.asData == null) return PressSearchIcon();

                  return modelsAsyncValue.when(
                    //data isn't livestreamed (unlike firestore) so
                    //loading: is never called.
                    //see fetchAndIndicate() in [ListViewMusicInfo.build]
                    //This may change.
                    loading: () =>
                        Center(child: CircularProgressIndicator.adaptive()),
                    error: (e, st) => SelectableText(
                      'Error $e ${kDebugMode ? st.toString() : ''}',
                    ),
                    data: (dynamic data) {
                      print('on data');
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
          ),
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

  /// search total and radio buttons for artist, song, album searches.
  Widget _header(
      WidgetRef ref, MusicItemsViewModel viewModel, bool isWideScreen) {
    final isFavouritesView = ref.read(isFavouritesViewProvider);

    if (isFavouritesView) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(children: [
          if (viewModel.hasSearched && isWideScreen)
            Text('Favourites searched: ${viewModel.totalItems.toThousands()} ',
                textScaleFactor: 1.5)
          else
            Text('Favourites', textScaleFactor: 1.5),
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
          //setState(() {
          viewModel.searchString = value;
          //});
        },
      ),
    );
  }

  //retired
//todo: turn this in to a loop
  Widget _radioButtons(MusicItemsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('albums'),
          Radio<MusicInfoType>(
            value: MusicInfoType.albums,
            groupValue: viewModel.searchType,
            onChanged: viewModel.onSearchTypeChange,
          ),
          Text('songs'),
          Radio<MusicInfoType>(
              value: MusicInfoType.tracks,
              groupValue: viewModel.searchType,
              onChanged: viewModel.onSearchTypeChange),
          Text('artists'),
          Radio<MusicInfoType>(
              value: MusicInfoType.artists,
              groupValue: viewModel.searchType,
              onChanged: viewModel.onSearchTypeChange),
        ],
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
}

/*
class CustomisedCheckboxTile extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool>? onChanged;
  final bool small;

  CustomisedCheckboxTile(
      {this.value = true, this.text = '', this.onChanged, this.small = false});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: small ? 26 : null,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Row(
          children: [
            NeumorphicCheckbox(
              style: NeumorphicCheckboxStyle(
                  selectedColor: primaryColor.withOpacity(.5)),
              value: value,
              isEnabled: onChanged != null,
              onChanged: (val) {
                if (onChanged != null) onChanged!(val);
              },
            ),
            NeumorphicTextCustom(text, fontSize: 30),
          ],
        ),
      ),
    );
  }
}

class NeumorphicTextCustom extends StatelessWidget {

  final String value;
  final double fontSize;
  final Color? color;
  const NeumorphicTextCustom( this.value,{Key? key, this.fontSize=20, this.color=null}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    Color? primaryColor=color;
    if (primaryColor==null) primaryColor=Theme.of(context).colorScheme.primary;
    return NeumorphicText(value,
        style: NeumorphicStyle(color: primaryColor.withOpacity(0.9)),
        textStyle: NeumorphicTextStyle(fontSize: fontSize));

  }
}


 */
