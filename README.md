
Copyright Greg Lorriman mob: 0044 777520 3753
http://github/lorriman/

Simple project to demonstrate commercial development capabilities.

### It includes :

- MvvM architecture (based on streams and provider)
- abstracted/pluggable backend (eg to allow easier replacement of lastFM API)

### The plumbing includes:

* use of the new Provider library, 'Riverpod'. https://pub.dev/packages/riverpod,  with some rxDart.
* streaming/reactive UI.
* immutable data models.
* accessibility/Semantic widgets
* dependency inversion

### It doesn't include (among other things) :

- unit and integration tests
- internationalisation
- comprehensive documentation
- flavours
- CI/CD
- the polish expected of a fully released app
- adherence to Material design guidelines
- adherence to Apple guidelines

##API info

If you wish to run the code against LastFM create a file called lastfm_api.json in an assets folder
with your own LastFM developer's api key. The file should look like this:

{
   "api_key" : "your key goes here"
}   
