
# OpenPics [![Build Status](https://travis-ci.org/pj4533/OpenPics.png?branch=master)](https://travis-ci.org/pj4533/OpenPics?branch=master)

An open source iOS application for viewing images from multiple remote sources. Get it on the [app store](https://itunes.apple.com/us/app/openpics/id633423505?ls=1&mt=8).

Public usage stats for the app store version are available [here](https://www.stathat.com/cards/R4S4y3DM6EyP).

![Screenshot](Screenshots/openpics.png "Screenshot")

## Goals

* Always use the latest iOS technology.  (Target only latest OS version)
* Keep all image source knowledge inside corresponding 'Provider' class
* Make it flippin sweet with awesome animations and stuff.

## Providers

Each remote image source gets a OPProvider class.  Providers can be easily added provided they conform to the OPProvider base class.  Currently supported providers:

* Currently Popular - Recently favorited images (Using OPBackend)
* Your favorites - Images you have marked as favorites (Using local Keyed Archiver)
* Library of Congress (http://www.loc.gov/pictures/api)
* New York Public Library (http://api.repo.nypl.org)
* California Digital Library - XTF (http://www.cdlib.org/services/publishing/tools/xtf/)
* Digital Public Library of America (https://github.com/dpla/platform)
* Europeana (http://www.europeana.eu/portal/api-introduction.html)
* LIFE Magazine (http://images.google.com/hosted/life)
* National Library of Australia - Trove (http://trove.nla.gov.au/general/api)
* Flickr Commons Project (http://www.flickr.com/commons)

For APIs like NYPL, which require a token, it should go into the file OPProviderTokens.h as a define.   For example:

``` objective-c
#define kOPPROVIDERTOKEN_NYPL @"<your token here>"
```

This header file is in the .gitignore, so as to not add tokens to the GitHub repository.  When an OPProvider is added to the OPProviderController, it is checked to see if it is configured properly with a token.  If not, it isn't added and can't be used.  If you wish to use these token based providers, go to the corresponding website, create a token and add it to the above file in your local repository.   If anyone has a better way of managing this, I am all ears!

## Backend

Popular images (recently favorited) are stored using a flexible backend based on the OPBackend class.  The current implementation uses a simple Ruby Sinatra app running on Heroku with a PostgresSQL store.  Keeping in the spirit of this being an Open Source project, you can add your own backend using any system that conforms to the OPBackend base class.   Similar to OPProvider and OPActivities, there is an OPBackendTokens.h file in the .gitignore, to hold private tokens for backend services.

## Sharing

Sharing (Twitter & Facebook) uses UIActivitys from iOS6.

## Dependencies

* AFNetworking
* CocoaPods
* Heavy use of UICollectionView (currently using my flow layout subclass: [SGSStaggeredFlowLayout](https://github.com/pj4533/SGSStaggeredFlowLayout) )

## How To Run

1. Clone the repo:    git clone git@github.com:pj4533/OpenPics.git
2. Init CocoaPods:    pod install
3. Open OpenPics.xcworkspace
4. Run in simulator:  CMD-R
5. Search for sweet old timey pics.

## Contribute

If you wish to contribute, send some pull requests!  I'll update the app in the App Store whenever we get awesome pull requests merged in.

## Contact

PJ Gray

- http://github.com/pj4533
- http://twitter.com/pj4533
- pj@pj4533.com

## License

OpenPics is available under the GPLv3 license.  You can modify it and release it, but its gotta be free.

See the LICENSE file for more info.

![OSI](OpenPics/Images/OSI/OSI-logo-100x117.png "OSI")
