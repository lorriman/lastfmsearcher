// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'app/main_view.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      //keyboard popdown, see HomePage for a disabled alternative
      onPointerDown: (_) {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          SystemChannels.textInput.invokeMethod<dynamic>('TextInput.hide');
        }
      },
      child: MaterialApp(
        theme: ThemeData(
          visualDensity: VisualDensity.standard,
          primarySwatch: Colors.lightGreen,
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: Colors.transparent),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.lightGreen,
          brightness: Brightness.dark,
        ),
        home: HomePage(),
      ),
    );
  }
}
