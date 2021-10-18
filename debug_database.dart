import 'lib/services/lastfmapi.dart';

void main() async {
  final api = LastfmAPI(apiKey: '5b162553274ad0ff3d5a71d798de3f2c');
  final result = await api.search('Black', searchType: MusicInfoType.albums);
  final items = result.musicInfoList;
  print('items returned: $items.length');
  for (var item in items) {
    print(item.name);
    for (var key in item.otherData.keys) {
      print('$key:  ${item.otherData[key]}');
    }
  }
}
