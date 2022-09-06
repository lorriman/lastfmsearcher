import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

import '../../services/lastfm_api.dart';

part 'item_model.g.dart';

@CopyWith(constructor: 'named')
class MusicInfo extends Equatable implements IJson {
  MusicInfo(
      this.favourite,
      this.name,
      this.artist,
      this.imageLinkSmall,
      this.imageLinkMedium,
      this.imageLinkLarge,
      this.imageLinkXLarge,
      this.url,
      this.otherData);

  MusicInfo.named(
      {required this.favourite,
      required this.name,
      required this.artist,
      required this.imageLinkSmall,
      required this.imageLinkMedium,
      required this.imageLinkLarge,
      required this.imageLinkXLarge,
      required this.url,
      required this.otherData});

  final bool favourite;
  final String name;
  final String artist;
  final String imageLinkSmall;
  final String imageLinkMedium;
  final String imageLinkLarge;
  final String imageLinkXLarge;
  final String url;
  final Map<String, dynamic> otherData;

  String toJson() {
    final map = <String, dynamic>{};

    map['favourite'] = favourite;
    map['name'] = name;
    map['otherData'] = {'artist': artist};
    map['imageLinkSmall'] = imageLinkSmall;
    map['imageLinkMedium'] = imageLinkMedium;
    map['imageLinkLarge'] = imageLinkLarge;
    map['imageLinkXLarge'] = imageLinkXLarge;
    map['url'] = url;

    return json.encode(map);
  }

  @override
  List<Object> get props => [name, artist];

  @override
  factory MusicInfo.fromJson(final String rawJson) {
    final data = json.decode(rawJson) as Map<String, dynamic>;

    return MusicInfo(
      data['favourite'] ?? false,
      data['name'] ?? '',
      data['otherData']?['artist'] ?? '',
      data['imageLinkSmall'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['imageLinkLarge'] ?? '',
      data['imageLinkXLarge'] ?? '',
      data['url'] ?? '',
      data['otherData'] ?? {},
    );
  }
}

final MusicInfo emptyMusicInfo =
    MusicInfo(false, 'emptyMusicInfo', '', '', '', '', '', '', {});
