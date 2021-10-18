/*
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:insomnia_checklist/myapp.dart' as

void main() {

  testWidgets('Integration search test', (tester) async {
    await appmain.main(args: ['integration_testing']);

    await tester.pumpAndSettle();
    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());

    //testing framework is not reliable at resetting app, so....
    final finder = find.byKey(Key(Keys.testOnBoardingOnGetStartedButton));
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(find.byKey(Key(Keys.testOnBoardingOnGetStartedButton)));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(Key('checklistItem-0')), findsNothing);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key(Keys.testEditItemTextName)), 'Item1');

    await tester.pump();

    await tester.enterText(
      find.byKey(Key(Keys.testEditItemTextDescription)),
      'Description1',
    );
    await tester.drag(
        find.byKey(Key('dismissable_checklistItem-0')), Offset(2000, 0));

    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.byKey(Key('dismissable_checklistItem-0')), findsNothing);
    await tester.tap(find.byKey(Key('testTabItem.binTabButton')));
  });

}
*/
