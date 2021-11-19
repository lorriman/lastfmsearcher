// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:jobtest_lastfm/app/top_level_providers.dart';
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import 'models/item.dart';
import 'models/viewmodel.dart';

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

  dynamic asThousands(int number) => thousandsFormatter.format(number);

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
                    return textPressSearchIcon();

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
        Text('total items: ${asThousands(viewModel.totalItems)} '),
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
            child: Text('total items : ${asThousands(viewModel.totalItems)}'),
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
  static const double lastFmSmallImageSize = 34;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                  width: 35,
                  child: Text(
                    '${index + 1}  ',
                    textScaleFactor: 0.8,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  maxHeightDiskCache: lastFmSmallImageSize.toInt(),
                  imageUrl: item.imageLinkSmall,
                  placeholder: (_, __) => SizedBox(width: lastFmSmallImageSize),
                  //lots of errors and blanks, so just swallow
                  errorWidget: (_, __, dynamic ___) =>
                      SizedBox(width: lastFmSmallImageSize),
                  fadeInDuration: Duration(milliseconds: 150),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    item.name,
                    textScaleFactor: 1.5,
                    //maxLines: 3,
                    //softWrap: true,
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
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

//retired:
/*
                Image.network(
                  item.imageLinkSmall,
                  errorBuilder: (_, __, ___) => SizedBox(width: 35),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(width: 35);
                  },
                  frameBuilder: (_, child, frame, __) {
                    return AnimatedOpacity(
                      child: child,
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                ),
 */
