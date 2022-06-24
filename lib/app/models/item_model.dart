class MusicInfo {
  MusicInfo(this.name, this.imageLinkSmall, this.imageLinkMedium,
      this.imageLinkLarge, this.imageLinkXLarge, this.url, this.otherData);

  final String name;
  final String imageLinkSmall;
  final String imageLinkMedium;
  final String imageLinkLarge;
  final String imageLinkXLarge;
  final String url;
  final Map<String, String> otherData;
}
