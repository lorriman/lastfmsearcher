#Job/Contract test project for unknown company

written by Greg Lorriman greg@lorriman.com mob: 0044 777520 3753
http://github/lorriman/

### It includes :

- MvvM architecture (based on streams and provider)

- Abstracted/pluggable backend (eg to allow easier replacement of lastFM API)

- basic Unit and integration tests (see /test and /integration_test)


### The plumbing includes:

* Use of the new Provider library, 'Riverpod'. https://pub.dev/packages/riverpod,  with some rxDart.
* streaming/reactive UI.
* Immutable data models.
* accessibility/Semantic widgets
* dependency injection


### It doesn't include (among other things) :

- internationalisation
- comprehensive documentation
- comprehensive unit and integration tests
- flavours
- CI/CD
- the polish expected of a fully released app
- testing on anything except android and Firebase emulator
- adherence to Material design guidelines
- adherence to Apple guidelines


# Test brief (as supplied by recruitment company):

-	Search – using the API pick from EITHER, Album, Song or Artist
-	Results – Display the results with minimal detail
-	Detail – On selecting an item from the result – the Detail view is presented, this should contain the basic information about from the result, you don’t need to include a everything from the returned values, but enough to show an expanded amount of info compared to the results view.

## Specs:

-	UI/ UX -  Don’t stress about designs for this project, we are not looking to asses the results on your skills in photoshop. Stock OS library components are fine.
-	Architecture – go with what ever pattern you feel works best for your app
-	Use Git for version control
-	You can use any open source libraries or frameworks you desire

##API info

You will need to create an account at lastFM and generate an API key:

-	Signup	http://last.fm
-	Create API key https://www.last.fm/api/account/create
-	API Docs http://www.last.fm/api/show/album.search

