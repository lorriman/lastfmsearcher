
Copyright Greg Lorriman mob: 0044 777520 3753
http://github/lorriman/

(To compile, into Android or Linux Desktop, see 'building' below about recreating an api key file,
 not supplied.)

# LastFm demonstrator 

## What is this?

A simple app that has been over-engineered to demonstrate commercial development capabilities
of Greg Lorriman in Google's Flutter/Dart.

### It includes :

- MvvM architecture (based on streams and provider)
- abstracted/pluggable backend (eg to allow easy replacement of lastFM API to adapt
the app for other search purposes.)

### The plumbing includes:

* use of the new Provider library, 'Riverpod'. https://pub.dev/packages/riverpod.
* streaming
* accessibility/Semantic widgets
* integration test

### It doesn't include (among other things) :

- unit tests
- fully immutable data models
- internationalisation
- comprehensive documentation
- flavours
- CI/CD
- the polish expected of a fully released app (The UI is basic)
- adherence to Material design guidelines
- adherence to Apple guidelines
- logging

### Issues:

~~backspace key doesn't work in some desktop environments~~

### building

<!-- To view an android debug build download and install the apk from here: [android build](https://drive.google.com/file/d/1X-ATwzBrcpBNuzcHxroXucsH-vYbdyzl/view?usp=sharing). -->

The app has only been compiled in Android and Linux desktop versions.

I don't include my developer's LastFM api key, nor required image assets.
It would be a little work to compile this on your own computer.

The file should look like this:

{
   "api_key" : "your key goes here"
}


