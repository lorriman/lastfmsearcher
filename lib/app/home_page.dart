import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/lastfmapi.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import 'package:jobtest_lastfm/services/repository.dart';

import 'models/item.dart';
import 'models/viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //MusicInfoType _radioGroupValue = MusicInfoType.albums;
  late final TextEditingController _textController;

//  final _repository = TestRepository(); //Repository(database: TestDatabase());

  //LastfmDatabase(apiKey: '5b162553274ad0ff3d5a71d798de3f2c'));

  //LastfmDatabase(apiKey: '5b162553274ad0ff3d5a71d798de3f2c'));

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final viewModel = watch(viewModelProvider);
      return GestureDetector(
        //keyboard pop-down, lots of confusion out there on this works
        //onTapDown: (_) =>SystemChannels.textInput.invokeMethod('TextInput.hide'),

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
              Container(
                width: 150,
                child: _searchField(viewModel),
              ),
              IconButton(
                icon: Icon(Icons.search, semanticLabel: 'search button'),
                onPressed: viewModel.notReady ? null : () => viewModel.fetch(),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(height: 40, child: _radioButtons(viewModel)),
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
                    return textPressSearchIcon();

                  return modelsAsyncValue.when(
                    //data isn't livestreamed so this is null
                    //see fetchAndIndicate() in [ListViewMusicInfo.build]
                    loading: () => Center(child: Placeholder()),
                    error: (e, st) => SelectableText(
                      'Error $e ${kDebugMode ? st.toString() : ''}',
                    ),
                    data: (data) {
                      return Expanded(
                          child: ListViewMusicInfo(
                        musicInfoItems: data?.items ?? [],
                        viewModel: viewModel,
                        results: data,
                      ));
                    },
                  );
                },
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _searchField(MusicViewModel viewModel) {
    return Theme(
      data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
      )),
      child: TextField(
        controller: _textController,
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

  Widget _radioButtons(MusicViewModel viewModel) {
    return Row(
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
    );
  }

  //Add an extra element for a loadingIndicator when the user
  // scrolls down to the last element, but not if there are no more items

  Widget textPressSearchIcon() {
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

class ListViewCard extends StatelessWidget {
  const ListViewCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  final MusicInfo item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$index ${item.name}'),
        ));
  }
}

class ListViewMusicInfo extends StatelessWidget {
  const ListViewMusicInfo({
    Key? key,
    required this.musicInfoItems,
    required this.viewModel,
    required this.results,
  }) : super(key: key);

  final List<MusicInfo> musicInfoItems;
  final MusicViewModel viewModel;
  final RepoFetchResult? results;

  @override
  Widget build(BuildContext context) {
    final items = musicInfoItems;
    return ListView.builder(
      itemCount: computeElementCount(),
      itemBuilder: (context, idx) {
        if (results == null) return textPressSearchIcon();
        if (items.isEmpty) return textNoItemsFound();
        //if this element is > items then it's a fetch and circular indicator
        if (idx == items.length) return fetchAndIndicate();
        return ListViewCard(item: items[idx], index: idx);
      },
    );
  }

  //some inline convenience functions
  int computeElementCount() {
    final items = musicInfoItems;
    if (results == null) return 1; //element for a message
    if (items.isEmpty) return 1; //ditto
    if (results!.isLast) return items.length;
    return items.length + 1;
  }

  Widget textPressSearchIcon() {
    return Center(
        heightFactor: 2,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Text('Press search icon'),
          Icon(Icons.search),
          Text('to search'),
        ]));
  }

  Widget textNoItemsFound() {
    return Center(
        heightFactor: 2,
        child: Text(
          'No items found',
          semanticsLabel: 'No items found',
          textScaleFactor: 2,
          style: TextStyle(color: Colors.grey), //grey is darkMode compatible
        ));
  }

  Widget fetchAndIndicate() {
    viewModel.fetch();
    return loadingIndicator(semantics: 'waiting for LastFM');
  }
}
