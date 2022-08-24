import 'item_model.dart';

class MusicInfoViewModel{

  final bool favourite;
  final String title;
  late final String subTitle;
  final String imageLinkSmall;
  final String imageLinkMedium;
  final String imageLinkLarge;
  final String imageLinkXLarge;
  late final MusicInfo musicInfo;
  final String url;


  MusicInfoViewModel

  (

  this

      .

  favourite

  ,

  this

      .

  title

  ,

  String subTitle

  ,

  this

      .

  imageLinkSmall

  ,

  this

      .

  imageLinkMedium

  ,

  this

      .

  imageLinkLarge

  ,

  this

      .

  imageLinkXLarge

  ,

  this

      .

  url

  ,

  MusicInfo? musicInfo = null

  ) {
  if( musicInfo==null) {
  this.musicInfo=emptyMusicInfo;

  } else this.musicInfo=musicInfo;

  }

  factory MusicInfoViewModel.fromMusicInfo(MusicInfo item) {
    return MusicInfoViewModel(
        item.favourite,
        item.name,
        item.artist,
        item.imageLinkSmall,
        item.imageLinkMedium,
        item.imageLinkLarge,
        item.imageLinkXLarge,
        item.url,
        item);
  }

  MusicInfo toMusicInfo() {
    final data = <String, String>{'artist': subTitle};
    return MusicInfo(
        favourite,
        title,
        subTitle,
        imageLinkSmall,
        imageLinkMedium,
        imageLinkLarge,
        imageLinkXLarge,
        url,
        data);
  }
}