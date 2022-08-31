// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_generator/material_color_generator.dart';

// Project imports:
import 'app/main_view.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool favouritesView = false;

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;
    return Listener(
      //keyboard popdown, see HomePage for a disabled alternative
      onPointerDown: (_) {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          SystemChannels.textInput.invokeMethod<dynamic>('TextInput.hide');
        }
      },
      child: MaterialApp(
        //gets in the way of the button
        debugShowCheckedModeBanner : false,
        theme: ThemeData(
          visualDensity: VisualDensity.compact,
          primarySwatch: generateMaterialColor(
              color: HSLColor.fromColor(Colors.purple)
                  .withLightness(.6)
                  .toColor()),
          // https://www.reddit.com/r/web_design/comments/skkr9k/whats_your_favorite_google_font_typeface/
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: Colors.transparent),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.lightGreen,
          brightness: Brightness.dark,
        ),
        home: Consumer(
          builder: (context, ref, _) {
            return HomePage();
          },
        ),
      ),
    );
  }
}
