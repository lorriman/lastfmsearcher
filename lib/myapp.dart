import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'app/home_page.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          // currentFocus.focusedChild?.unfocus();
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
//      debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
