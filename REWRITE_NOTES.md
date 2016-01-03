# NOTES ON REWRITE

## Changes
### Backend
The backend system is a bit over-engineered.  They are really just providers with some extra functionality, so i think the best thing is to make them another protocol, with just the extra functionality I need (Remote?  Backendable?  RemotelySaved?)

### OPItem
Calling this _Image_ now.

### Providers/Networking
I changed the underlying networking code to use Alamofire & Moya.  Building on top of the Moya provider architecture, I now have APIs that include the Moya code and custom provider class that should do everything the older provider class did (naming etc).

## Before Shipping
* how does the data model transfer between versions?