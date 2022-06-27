import 'package:flutter_test/flutter_test.dart';

//import 'package:mocking/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'viewmodel_test.mocks.dart';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:test/test.dart';
import 'package:jobtest_lastfm/services/repository.dart' as repository;
import 'package:jobtest_lastfm/app/models/items_viewmodel.dart';

@GenerateMocks([repository.Repository])
Future<void> main() async {
  //repo=MockRepository();
  //MusicItemsViewModel()
}

/*
Future<void> main() async {

  Repository? fsdb;
  ModelStream? modelStream;

  final List<Model> expectedModels = [];
  final ids = <String>[];
  final items = <String, ChecklistItem>{};
  DateTime? now;

  group('Test - ViewModel', () {
    setUp(() async {
      //different test data makes it somewhat easier to track issues in
      // mutliple failed tests

    }); //setup

    tearDown(() async {
      items.clear();
      ids.clear();
      expectedModels.clear();
    });

    group('GIVEN the search() is called with text of more than 3 characters', (){
      group('WHEN next() is called', (){
        test('THEN there is stream data', () async {
          expect(modelStream, emits(equals(expectedModels)));
        });
      });
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
