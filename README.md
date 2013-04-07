# OpenPics

An open source iOS application for viewing images from multiple remote sources.

![Screenshot](Screenshots/openpics.png "Screenshot")

## Goals

* Always use the latest iOS technology.  (Target only latest OS version)
* Keep all image source knowledge inside corresponding 'Provider' class
* Make it flippin sweet with awesome animations and stuff.

## Providers

Each remote image source gets a OPProvider class.  Providers can be easily added provided they conform to the OPProvider base class.  Currently supported providers:

* Library of Congress (http://www.loc.gov/pictures/api)
* New York Public Library (http://api.repo.nypl.org)

For APIs like NYPL, which require a token, it should go into the file OPProviderTokens.h as a define.   For example:

``` objective-c
#define kOPPROVIDERTOKEN_NYPL @"<your token here>"
```

This header file is in the .gitignore, so as to not add tokens to the GitHub repository.  So either only use non-token providers (like Library of Congress), or create the above file in your local repository.   If anyone has a better way of managing this, I am all ears!

## Dependencies

* AFNetworking
* CocoaPods
* Heavy use of UICollectionView (currently using unmodified UICollectionViewFlowLayout)

## To do

* Make Icon!
* Make Default screen
* Submit v1 to App Store
* Support showing more metadata (Title, notes, etc)
* Support showing information about results (current page, total pages)
* Support iPad portait orientation
* Support iPhone
* Support sharing (have a nice class for Tumblr, need to add it)
* Support loading higher res images, if the Provider supports it

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

