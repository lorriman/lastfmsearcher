
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jobtest_lastfm/main.dart' as appmain;
import 'package:jobtest_lastfm/services/dev_api.dart';

void main() {

  testWidgets('Integration search test', (tester) async {
    await appmain.main(args: ['integration_testing']);

    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('search_text_field')), 'pink');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('search_button')));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.byKey(Key('item0')), findsOneWidget);
    for(int i=0;i<5;i++) {
      await tester.flingFrom(Offset(150, 500), Offset(0, -300), 4000);
      await tester.pumpAndSettle();
    }
    final elements=await tester.elementList(find.byType(Card));
    expect(find.byKey(Key('item59')), findsOneWidget);
    expect(find.byKey(Key('item60')), findsNothing);
    //one more scroll, no more widgets should be added
    await tester.flingFrom(Offset(150, 500), Offset(0, -300), 4000);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('item60')), findsNothing);

    return;
    //retired
    //testing framework is not reliable at resetting app, so....
    final finder = find.byKey(Key('testTabItem.binTabButton'));
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(find.byKey(Key('testTabItem.binTabButton')));
      await tester.pumpAndSettle();
    }
  });

}

