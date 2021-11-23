// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

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
    return Consumer(builder: (context, watch, _) {
      final viewModel = watch(viewModelProvider);
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
            title: Text(
              'Searcher for LastFM',
              maxLines: 2,
              semanticsLabel: 'app title: LastFM searcher',
            ),
            actions: [
              SizedBox(
                width: 150,
                child: _searchTextField(viewModel),
              ),
              IconButton(
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
                child: _header(viewModel, isWideScreen),
              ),
              Consumer(
                builder: (context, watch, _) {
                  final modelsAsyncValue = watch(musicInfoProvider);

                  //The first loading indicator is done here.
                  //To allow infinite scrolling subsequent loading indicators
                  //are done in the final element of the listview on scrolling
                  //to the end.
                  //see fetchAndIndicate() in [ListViewMusicInfo.build]
                  if (viewModel.isLoading && viewModel.isFirst) {
                    return loadingIndicator(
                        semantics: 'waiting for LastFM', size: 50);
                  }
                  if (modelsAsyncValue.data == null)
                    return PressSearchIcon();

                  return modelsAsyncValue.when(
                    //data isn't livestreamed (unlike firestore) so
                    //loading: is never called.
                    //see fetchAndIndicate() in [ListViewMusicInfo.build]
                    //This may change.
                    loading: () => Center(child: Placeholder()),
                    error: (e, st) => SelectableText(
                      'Error $e ${kDebugMode ? st.toString() : ''}',
                    ),
                    data: (data) {
                      print('on data');
                      return Expanded(
                          child: ListViewMusicInfo(
                        musicInfoItems: data?.items ?? [],
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

  /// search total and radio buttons for artist, song, album searches.
  Widget _header(MusicItemsViewModel viewModel, bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(children: [
        if (viewModel.hasSearched && isWideScreen)
          Text('found: ${viewModel.totalItems.toThousands()} '),
        Expanded(child: Container()),
        _radioButtons(viewModel),
      ]),
    );
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
        autofocus: true,
        focusNode: FocusNode(),
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
        cursorColor: Colors.black,
        showCursor: true,
        onChanged: (value) {
          //setState(() {
          viewModel.searchString = value;
          //});
        },
      ),
    );
  }

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
            onChanged: viewModel.onRadioChange,
          ),
          Text('songs'),
          Radio<MusicInfoType>(
              value: MusicInfoType.tracks,
              groupValue: viewModel.searchType,
              onChanged: viewModel.onRadioChange),
          Text('artists'),
          Radio<MusicInfoType>(
              value: MusicInfoType.artists,
              groupValue: viewModel.searchType,
              onChanged: viewModel.onRadioChange),
        ],
      ),
    );
  }


}


