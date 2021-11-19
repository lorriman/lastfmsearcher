// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import 'models/viewmodel.dart';
import 'musicinfo_listview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //todo: shoft the controller in to the ViewModel
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void submit(MusicViewModel viewModel) {
    //test isLoading to absorbs an accidental double-tap without
    //having to disable the button
    if (viewModel.isLoading) return;
    viewModel.searchString = _textController.value.text;
    viewModel.fetch();
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width >= 400;
    return Consumer(builder: (context, watch, _) {
      final viewModel = watch(viewModelProvider);
      return GestureDetector(
        //legacy keyboard pop-down. We might have to resort to this
        //if the other one doesn't work out. See [MyApp.build]->Listener

        //FocusManager.instance.primaryFocus?.unfocus(),
        //FocusScope.of(context).requestFocus(new FocusNode()),
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
                //not enough text etc so disable the button
                onPressed: viewModel.notReady ? null : () => submit(viewModel),
              ),
            ],
          ),
          body: Column(
            children: [
              _header(viewModel, isWideScreen),
              Consumer(
                builder: (context, watch, _) {
                  final modelsAsyncValue = watch(musicInfoProvider);

                  //first loading indicator is done here. Subsequently,
                  //to allow infinite scrolling, loading indicators
                  //are done at final element of the listview on scrolling
                  //to the end.
                  //see fetchAndIndicate() in [ListViewMusicInfo.build]
                  if (viewModel.isLoading && viewModel.isFirst) {
                    return loadingIndicator(
                        semantics: 'waiting for LastFM', size: 100);
                  }
                  if (modelsAsyncValue.data == null)
                    return _textPressSearchIcon();

                  return modelsAsyncValue.when(
                    //data isn't livestreamed (unlike firestore) so
                    //loading: is never called.
                    //see fetchAndIndicate() in [ListViewMusicInfo.build]
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

  Row _header(MusicViewModel viewModel, bool isWideScreen) {
    return Row(children: [
      if (viewModel.hasSearched && isWideScreen)
        Text('total items: ${viewModel.totalItems.toThousands()} '),
      Expanded(child: Container()),
      _radioButtons(viewModel),
    ]);
  }

  SizedBox _footer(MusicViewModel viewModel) {
    return SizedBox(
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('total items : ${viewModel.totalItems.toThousands()}'),
          ),
        ]));
  }

  Widget _searchTextField(MusicViewModel viewModel) {
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
  Widget _radioButtons(MusicViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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

  //Add an extra element for a loadingIndicator when the user
  // scrolls down to the last element, but not if there are no more items

  Widget _textPressSearchIcon() {
    return Center(
        heightFactor: 2,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Text('Press search icon'),
          Icon(Icons.search),
          Text('to search'),
        ]));
  }
}


