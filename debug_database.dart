import 'lib/services/lastfmapi.dart';
import 'lib/services/devapi.dart';

void main() async {
  final api = DevAPI();
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
