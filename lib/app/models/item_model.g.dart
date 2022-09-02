// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MusicInfoCWProxy {
  MusicInfo artist(String artist);

  MusicInfo favourite(bool favourite);

  MusicInfo imageLinkLarge(String imageLinkLarge);

  MusicInfo imageLinkMedium(String imageLinkMedium);

  MusicInfo imageLinkSmall(String imageLinkSmall);

  MusicInfo imageLinkXLarge(String imageLinkXLarge);

  MusicInfo name(String name);

  MusicInfo otherData(Map<String, dynamic> otherData);

  MusicInfo url(String url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MusicInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MusicInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  MusicInfo call({
    String? artist,
    bool? favourite,
    String? imageLinkLarge,
    String? imageLinkMedium,
    String? imageLinkSmall,
    String? imageLinkXLarge,
    String? name,
    Map<String, dynamic>? otherData,
    String? url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMusicInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMusicInfo.copyWith.fieldName(...)`
class _$MusicInfoCWProxyImpl implements _$MusicInfoCWProxy {
  final MusicInfo _value;

  const _$MusicInfoCWProxyImpl(this._value);

  @override
  MusicInfo artist(String artist) => this(artist: artist);

  @override
  MusicInfo favourite(bool favourite) => this(favourite: favourite);

  @override
  MusicInfo imageLinkLarge(String imageLinkLarge) =>
      this(imageLinkLarge: imageLinkLarge);

  @override
  MusicInfo imageLinkMedium(String imageLinkMedium) =>
      this(imageLinkMedium: imageLinkMedium);

  @override
  MusicInfo imageLinkSmall(String imageLinkSmall) =>
      this(imageLinkSmall: imageLinkSmall);

  @override
  MusicInfo imageLinkXLarge(String imageLinkXLarge) =>
      this(imageLinkXLarge: imageLinkXLarge);

  @override
  MusicInfo name(String name) => this(name: name);

  @override
  MusicInfo otherData(Map<String, dynamic> otherData) =>
      this(otherData: otherData);

  @override
  MusicInfo url(String url) => this(url: url);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MusicInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MusicInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  MusicInfo call({
    Object? artist = const $CopyWithPlaceholder(),
    Object? favourite = const $CopyWithPlaceholder(),
    Object? imageLinkLarge = const $CopyWithPlaceholder(),
    Object? imageLinkMedium = const $CopyWithPlaceholder(),
    Object? imageLinkSmall = const $CopyWithPlaceholder(),
    Object? imageLinkXLarge = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? otherData = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return MusicInfo.named(
      artist: artist == const $CopyWithPlaceholder() || artist == null
          ? _value.artist
          // ignore: cast_nullable_to_non_nullable
          : artist as String,
      favourite: favourite == const $CopyWithPlaceholder() || favourite == null
          ? _value.favourite
          // ignore: cast_nullable_to_non_nullable
          : favourite as bool,
      imageLinkLarge: imageLinkLarge == const $CopyWithPlaceholder() ||
              imageLinkLarge == null
          ? _value.imageLinkLarge
          // ignore: cast_nullable_to_non_nullable
          : imageLinkLarge as String,
      imageLinkMedium: imageLinkMedium == const $CopyWithPlaceholder() ||
              imageLinkMedium == null
          ? _value.imageLinkMedium
          // ignore: cast_nullable_to_non_nullable
          : imageLinkMedium as String,
      imageLinkSmall: imageLinkSmall == const $CopyWithPlaceholder() ||
              imageLinkSmall == null
          ? _value.imageLinkSmall
          // ignore: cast_nullable_to_non_nullable
          : imageLinkSmall as String,
      imageLinkXLarge: imageLinkXLarge == const $CopyWithPlaceholder() ||
              imageLinkXLarge == null
          ? _value.imageLinkXLarge
          // ignore: cast_nullable_to_non_nullable
          : imageLinkXLarge as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      otherData: otherData == const $CopyWithPlaceholder() || otherData == null
          ? _value.otherData
          // ignore: cast_nullable_to_non_nullable
          : otherData as Map<String, dynamic>,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
    );
  }
}

extension $MusicInfoCopyWith on MusicInfo {
  /// Returns a callable class that can be used as follows: `instanceOfMusicInfo.copyWith(...)` or like so:`instanceOfMusicInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MusicInfoCWProxy get copyWith => _$MusicInfoCWProxyImpl(this);
}
