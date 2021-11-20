// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobtest_lastfm/services/globals.dart';
import 'package:url_launcher/url_launcher.dart';
// Project imports:
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';

import 'models/item.dart';
import 'models/viewmodel.dart';


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
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width >= global_screen_width_breakpoint;
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
                        onTap:  ()=>_launchUrl(item.otherData['url'] ??''),
                        child: Text(
                          item.name,
                          textScaleFactor: 1.5,
                          //maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

              ),
                    ),
                    if (item.otherData['artist']!=null) Padding( padding: const EdgeInsets.only(left: 12.0),
                      child : Text(item.otherData['artist']!),
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
      throw 'Could not launch $url';
    }
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
      itemCount: _computeElementCount(),
      itemBuilder: (_, idx) {
        if (results == null) return _textPressSearchIcon();
        if (items.isEmpty) return _textNoItemsFound();
        //if this element is > items then it's a fetch and circular indicator
        if (idx == items.length) return _fetchAndIndicate();
        return ListViewCard(item: items[idx], index: idx);
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