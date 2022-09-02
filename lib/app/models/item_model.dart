import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'item_model.g.dart';

@CopyWith(constructor: 'named')
class MusicInfo extends Equatable {
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

  @override
  List<Object> get props => [name, artist];

  factory MusicInfo.fromJson(final String rawJson) {
    final data = json.decode(rawJson) as Map<String, dynamic>;

    return MusicInfo(
      data['favourite'] ?? false,
      data['name]'] ?? '',
      data['otherData']?['artist'] ?? '',
      data['imageLinkSmall'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['imageLinkMedium'] ?? '',
      data['url'] ?? '',
      data['otherData'] ?? {},
    );
  }
}

final MusicInfo emptyMusicInfo =
    MusicInfo(false, '', '', '', '', '', '', '', {});
