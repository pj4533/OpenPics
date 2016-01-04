//
//  LibraryOfCongressAPI.swift
//  OpenPics
//
//  Created by PJ Gray on 1/3/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire

// MARK: - API definition


// MARK: - Provider definition

// For now I am only implementing this to get uprezzing on Popular, but eventually this needs a full API implementaiton
//public class LOCProvider: MoyaProvider<PopularAPI>, ImageProvider {
public class LOCProvider: ImageProvider {
    
    let name = "Library of Congress"
    let shortName = "Library of Congress"
    
    // this was originally meant to work like UIActivityType's, not sure how to do this properly in swift
    let providerType = "com.saygoodnight.loc"
    
    // - should the parameters on the completion handler be optional?
    // - how can i specify the name of the variable for the paramters on completion handler?
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: ([Image], Bool?) -> Void) {
    }
    
    func getHiRezURLForImage(image: Image, completionHandler: (NSURL?) -> Void) {
        
        if let resourceURLString = image.providerSpecific["links"]["resource"].string {
            
            // I don't like calling direct to alamofire here, but to use Moya I'd need to reverse the link in the JSON...seems...meh?
            Alamofire.request(.GET, "http:\(resourceURLString)?fo=json").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let resourceDict = json["resource"].dictionary {
                            let largeSize = resourceDict["large_s"]!.intValue
                            let largerSize = resourceDict["larger_s"]!.intValue
                            let largestSize = resourceDict["largest_s"]!.intValue

                            var urlString = image.url
                            if ((largestSize > 0) && (largestSize < 12582912)) {
                                urlString = resourceDict["largest"]!.stringValue
                            } else if ((largerSize > 0) && (largerSize < 12582912)) {
                                urlString = resourceDict["larger"]!.stringValue
                            } else if ((largeSize > 0) && (largeSize < 12582912)) {
                                urlString = resourceDict["large"]!.stringValue
                            }
                            
                            completionHandler(NSURL(string: "http:\(urlString)"))
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }

    }

//    override init(endpointClosure: EndpointClosure = MoyaProvider.DefaultEndpointMapping,
//        requestClosure: RequestClosure = MoyaProvider.DefaultRequestMapping,
//        stubClosure: StubClosure = MoyaProvider.NeverStub,
//        manager: Manager = Manager.sharedInstance,
//        plugins: [PluginType] = []) {
//            
//            super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins)
//    }
}