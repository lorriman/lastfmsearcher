// Flutter imports:
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:jobtest_lastfm/services/repository.dart';
import 'package:jobtest_lastfm/services/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/item_model.dart';
import 'models/item_viewmodel.dart';
import 'models/items_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

enum ImageSizing { small, medium, large }

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
        return ListViewCard(
            item: MusicInfoViewModel.fromMusicInfo(items[idx]), index: idx);
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
class ListViewCard extends StatefulWidget {
  ListViewCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  final MusicInfoViewModel item;
  final int index;
  static const double lastFmSmallImageSize = 34,
      lastFmMediumImageSize = 60,
      lastFmLargeImageSize = 200;

  @override
  State<ListViewCard> createState() => _ListViewCardState();
}

class _ListViewCardState extends State<ListViewCard>
    with TickerProviderStateMixin {
  final cardKey = GlobalKey();

  //we need this for a faster bottomsheet transition
  late AnimationController animController;

  @override
  initState() {
    super.initState();
    // Initialize AnimationController
    initAnimController();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  void initAnimController() {
    animController = BottomSheet.createAnimationController(this);
    animController.duration = const Duration(milliseconds: 70);
    animController.reverseDuration = const Duration(milliseconds: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        key: widget.index == 0 ? cardKey : null,
        margin: EdgeInsets.all(5),
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  child: Text(
                    '${widget.index + 1}  ',
                    key: Key('item${widget.index}'),
                    textScaleFactor: 0.8,
                  )),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(width: 0, color: Colors.white)),
                onPressed: () async {
                  //_launchUrl(item.url, external: true);
                  //await Share.share(widget.item.url);
                  // Use Builder to get the widget context
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    clipBehavior: Clip.antiAlias,
                    child: Hero(
                        tag: 'image',
                        child: LastFMImage(
                            item: widget.item, sizing: ImageSizing.small))),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => showItemBottomSheet(
                      context, widget.item), //_launchUrl(item.url),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          widget.item.title,

                          textScaleFactor: 1.5,
                          //maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.item.subTitle != '')
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(widget.item.subTitle),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _launchUrl(String url, {bool external = false}) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        //enableDomStorage: true,
        //forceSafariVC: true,
        //forceWebView: !external,
        //enableJavaScript: true,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  void showItemBottomSheet(BuildContext context, MusicInfoViewModel item) {
    showModalBottomSheet<void>(
      context: context,
      transitionAnimationController: animController,
      builder: (BuildContext context) {
        return detailsView(item);
      },
    ).whenComplete(() => initAnimController());
  }

  Widget detailsView(MusicInfoViewModel item) {
    return Container(
      padding: EdgeInsets.all(20),
      //height: 200,
      //color: Colors.amber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: PhysicalModel(
                    color: Colors.white,
                    elevation: 8,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        clipBehavior: Clip.antiAlias,
                        child: Hero(
                            tag: 'image',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      height: 190,
                                      child: LastFMImage(
                                          item: item,
                                          sizing: ImageSizing.large)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    //width: 190,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        item.title,
                                        textScaleFactor: 1.2,
                                        maxLines: 4,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                //SizedBox(height: 10),
                              ],
                            ))),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: SelectableText(
                            item.subTitle,
                            textScaleFactor: 1.5,
                            maxLines: 4,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                child: Icon(Icons.share),
                onPressed: () async {
                  //share_plus docs specify this as needed for IOS
                  final box = context.findRenderObject() as RenderBox?;

                  await Share.share(
                    widget.item.url,
                    subject: 'share',
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  );

                  //await Share.share(widget.item.url);
                },
              ),
              ElevatedButton(
                child: Icon(Icons.open_in_browser),
                onPressed: () {
                  _launchUrl(item.url);
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}

class LastFMImage extends StatelessWidget {
  const LastFMImage({
    Key? key,
    required this.item,
    required this.sizing,
  }) : super(key: key);

  final MusicInfoViewModel item;
  final ImageSizing sizing;

  @override
  Widget build(BuildContext context) {
    late int maxLength;
    late String url;
    switch (sizing) {
      case ImageSizing.small:
        {
          maxLength = ListViewCard.lastFmSmallImageSize.toInt();
          url = item.imageLinkSmall;
        }
        break;
      case ImageSizing.medium:
        {
          maxLength = ListViewCard.lastFmMediumImageSize.toInt();
          url = item.imageLinkMedium;
        }
        break;
      case ImageSizing.large:
        {
          maxLength = ListViewCard.lastFmLargeImageSize.toInt();
          url = item.imageLinkXLarge;
        }
        break;
    }

    return CachedNetworkImage(
      width: maxLength.toDouble(),
      maxHeightDiskCache: maxLength,
      imageUrl: url,
      placeholder: (_, __) => SizedBox(width: maxLength.toDouble()),
      //lots of errors and blanks, so just swallow them

      errorWidget: (_, __, dynamic ___) => SizedBox(
          width: maxLength.toDouble(),
          child: Opacity(
            opacity: 0.1,
            child: Image.asset('assets/icon/icon_small.png',
                cacheWidth: maxLength, filterQuality: FilterQuality.high),
          )),
      fadeInDuration: Duration(milliseconds: 150),
    );
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
