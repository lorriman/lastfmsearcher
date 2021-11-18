/*

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:test/test.dart';

//typedef ModelStream = Stream<List<ChecklistItemTileModel>>;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Repository? fsdb;
  ModelStream? modelStream;

  final List<Model> expectedModels = [];
  final ids = <String>[];
  final items = <String, ChecklistItem>{};
  DateTime? now;

  group('Test - View Model', () {
    setUp(() async {
      //different test data makes it somewhat easier to track issues in
      // mutliple failed tests
      uidCount++;
      now = DateTime.now();
      final fakeFirestore = FakeFirebaseFirestore();
      //not used now but maybe in future as some libs call auth
      final fakeAuth = MockFirebaseAuth(signedIn: true);
      final fakeFirestoreService =
          FakeFirestoreService(fakeFirestoreInstance: fakeFirestore);
      final db = Repository(
          uid: uid(), testFirestoreServiceInstance: fakeFirestoreService);
      fsdb = db; //cancel the nullability warnings
      final viewModel = ChecklistItemsViewModel(database: fsdb!);
      modelStream = viewModel.tileModelStream(now!);
      for (int i = 1; i < 3; i++) {
        final id = ChecklistItem.newId();
        ids.add(id);
        final item = ChecklistItem(
          id: id,
          name: 'Item$i',
          description: 'description$i',
          startDate: DateTime.now(),
          ordinal: i,
        );
        items[id] = item;
        await db.setChecklistItem(item);

        //we only want one rating,
        if (i == 1) await db.setRating(i.toDouble(), item, now!);

        final model = ChecklistItemTileModel(
            checklistItem: item,
            database: fsdb,
            id: id,
            titleText: item.name,
            bodyText: item.description,
            //we only want one rating
            rating: i == 1 ? i.toDouble() : 0.0,
            trash: item.trash,
            ordinal: i);
        expectedModels.add(model);
      }
    }); //setup

    tearDown(() async {
      items.clear();
      ids.clear();
      expectedModels.clear();
    });

    test('Checklist view MvvM stream', () async {
      expect(modelStream, emits(equals(expectedModels)));
    });
    test('Checklist item to trash MvvM stream', () async {
      await expectedModels[1].setTrash(trash: true);

      modelStream!
          .listen(expectAsync1<void, List<ChecklistItemTileModel>>((list) {
        expect(
          list.singleWhere((item) => item.trash).id,
          expectedModels[1].id,
        );
      }));
    });
    test('Checklist view change rating to MvvM stream', () async {
      await fsdb!.setRating(5.0, items[ids[0]]!, now!);
      modelStream!
          .listen(expectAsync1<void, List<ChecklistItemTileModel>>((list) {
        expect(
          list.singleWhere((item) => item.rating == 5.0).id,
          expectedModels[0].id,
        );
      }));
    });
  });

}
*/
