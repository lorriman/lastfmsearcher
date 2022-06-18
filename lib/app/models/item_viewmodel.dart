import 'item_model.dart';

class MusicInfoViewModel{

  final String title;
  late final String subTitle;
  final String imageLinkSmall;
  final String imageLinkMedium;
  final String imageLinkLarge;
  final String imageLinkXLarge;

  final String url;
  late final Map<String, String> _otherData;

  MusicInfoViewModel(
      this.title,
      this.imageLinkSmall,
      this.imageLinkMedium,
      this.imageLinkLarge,
      this.imageLinkXLarge,
      this.url,
      Map<String, String> otherData) {
    _otherData = otherData;
    subTitle = _otherData['artist'] ?? '';
  }

  factory MusicInfoViewModel.fromMusicInfo(MusicInfo item) {
    return MusicInfoViewModel(
        item.name,
        item.imageLinkSmall,
        item.imageLinkMedium,
        item.imageLinkLarge,
        item.imageLinkXLarge,
        item.url,
        item.otherData);
  }

}