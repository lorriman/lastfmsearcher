import 'lib/services/lastfmapi.dart';
import 'lib/services/repository.dart';
import 'lib/services/devapi.dart';

void main() async {
  final db = DevAPI();
  final repo = Repository(lastFMapi: db);
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
