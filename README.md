# OpenPics [![Build Status](https://travis-ci.org/pj4533/OpenPics.png?branch=master)](https://travis-ci.org/pj4533/OpenPics?branch=master)

An open source iOS application for viewing images from multiple remote sources. Get it on the [app store](https://itunes.apple.com/us/app/openpics/id633423505?ls=1&mt=8).


# THIS BRANCH IS NOT SHIPPED YET

This is the in-progress swift rewrite. The shipped version (in all its old & busted glory) is on the [latest_shipped](https://github.com/pj4533/OpenPics/tree/latest_shipped) branch.

![](openpics.gif)

## Changes
### Backend
The backend system is a bit over-engineered.  They are really just providers with some extra functionality, so i think the best thing is to make them another protocol, with just the extra functionality I need (Remote?  Backendable?  RemotelySaved?)

### OPItem
Calling this _Image_ now.

### Providers/Networking
I changed the underlying networking code to use Alamofire & Moya.  Building on top of the Moya provider architecture, I now have APIs that include the Moya code and custom provider class that should do everything the older provider class did (naming etc).  However, in order to not confuse naming, now the OpenPics specific functionality will be in a protocol called _Source_, not Provider.

### TODO

- [x] Basic collectionview
- [x] Simple source working
- [x] Sources table view
- [ ] Get fastlane (re)setup, use version v3.0.0
- [ ] Set collectionview
- [x] Search
- [x] Basic Paging
- [ ] iPad layout
- [ ] All image sources from old version (break out to list if necessary)
- [ ] Favoriting (local storage)
- [ ] Hi-rez downloading (**new**)
- [ ] NYPL allows hi rez now, verify using it.

## Before Shipping
* how does the data model transfer between versions?

## Contact

PJ Gray

- http://github.com/pj4533
- http://twitter.com/pj4533
- pj@pj4533.com

## License

OpenPics is available under the GPLv3 license.  You can modify it and release it, but its gotta be free.

See the LICENSE file for more info.
