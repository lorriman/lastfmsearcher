import 'dart:convert';

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

  factory MusicInfo.fromJson(final String rawJson) {
    final data = json.decode(rawJson) as Map<String, dynamic>;

    return MusicInfo(
      data['name]'] ?? '',
      data['imageLinkSmall'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['url'] ?? '',
      data['otherData'] ?? {},
    );
  }
}
