import 'lib/services/lastfmapi.dart';
import 'lib/services/repository.dart';

void main() async {
  final db = LastfmDatabase(_apiKey: '5b162553274ad0ff3d5a71d798de3f2c');
  final repo = Repository(database: db);
  await repo.search('Black', searchType: MusicInfoType.tracks);

  final items = await repo.next();
  print(items.length);
  for (var item in items) {
    print(item.title);
    for (var key in item.otherData.keys) {
      print('$key:  ${item.otherData[key]}');
    }
  }
}
