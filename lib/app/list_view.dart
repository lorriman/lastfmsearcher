// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Project imports:
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/item_model.dart';
import 'models/item_viewmodel.dart';
import 'models/items_viewmodel.dart';

///Small Utility widget before a search, to indicate to the user
///to type a search string and press the search icon.
class PressSearchIcon extends StatelessWidget {
  const PressSearchIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

///ListView for search results. See [ListViewCard] below
///for individual items
class ListViewMusicInfo extends StatelessWidget {
  const ListViewMusicInfo({
    Key? key,
    required this.musicInfoItems,
    required this.viewModel,
    required this.results,
  }) : super(key: key);

  final List<MusicInfo> musicInfoItems;
  final MusicItemsViewModel viewModel;
  final RepositoryFetchResult? results;

  @override
  Widget build(BuildContext context) {
    final items = musicInfoItems;
    return ListView.builder(
      itemCount: _computeElementCount(),
      itemBuilder: (_, idx) {
        if (results == null) return PressSearchIcon();
        if (items.isEmpty) return _textNoItemsFound();
        //if this element is > items then it's a fetch and circular indicator
        if (idx == items.length) return _fetchAndIndicate();
        return ListViewCard(item: MusicInfoViewModel.fromMusicInfo(items[idx]), index: idx);
      },
    );
  }

  //some inline convenience functions

  int _computeElementCount() {
    final items = musicInfoItems;
    if (results == null) return 1; //element for a message
    if (items.isEmpty) return 1; //ditto
    if (results!.isLast) return items.length;
    return items.length + 1;
  }


  Widget _textNoItemsFound() {
    return Center(
        heightFactor: 2,
        child: Text(
          'No items found',
          semanticsLabel: 'No items found',
          textScaleFactor: 2,
          style: TextStyle(color: Colors.grey), //grey is darkMode compatible
        ));
  }

  Widget _fetchAndIndicate() {
    viewModel.fetch();
    return loadingIndicator(semantics: 'waiting for LastFM');
  }
}

///Card widget for item search result in a ListView
class ListViewCard extends StatelessWidget {
  const ListViewCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  final MusicInfoViewModel item;
  final int index;
  static const double lastFmSmallImageSize = 34;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
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
                  //lots of errors and blanks, so just swallow them
                  errorWidget: (_, __, dynamic ___) =>
                      SizedBox(width: lastFmSmallImageSize),
                  fadeInDuration: Duration(milliseconds: 150),
                ),
              ),
              Expanded(
                child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: InkWell(
                        onTap:  ()=>_launchUrl(item.url),
                        child: Text(
                          item.title,
                          textScaleFactor: 1.5,
                          //maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

              ),
                    ),
                    if (item.subTitle!='') Padding( padding: const EdgeInsets.only(left: 12.0),
                      child : Text(item.subTitle),
                    )

                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }
}


//retired in favour of CachedNetworkImage:
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