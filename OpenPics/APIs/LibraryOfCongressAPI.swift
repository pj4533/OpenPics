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

public enum LibraryOfCongressAPI {
    case Search(query: String, page: Int)
}

extension LibraryOfCongressAPI: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://www.loc.gov")! }
    public var path: String {
        switch self {
        case .Search:
            return "/pictures/search"
        }
    }
    public var method: Moya.Method {
        return .GET
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case Search(let query, let page):
            return ["q":query, "sp":page, "fo":"json", "c":100]
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Search(_, _):
            return "{\"login\": \"DERP\", \"id\": 100}".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

public func url(route: TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}


// MARK: - Provider definition

// For now I am only implementing this to get uprezzing on Popular, but eventually this needs a full API implementaiton
public class LOCSource: MoyaProvider<LibraryOfCongressAPI>, Source {
    
    let sourceName = "Library of Congress"
    let sourceShortName = "Library of Congress"
    
    // this was originally meant to work like UIActivityType's, not sure how to do this properly in swift
    static let sourceType = "com.saygoodnight.loc"
    
    // - should the parameters on the completion handler be optional?
    // - how can i specify the name of the variable for the paramters on completion handler?
    func getImagesWithQuery(query: String, pageNumber: Int, completionHandler: ([Image], Bool?) -> Void) {
        self.request(.Search(query: "",page: 1)) { result in
            switch result {
            case let .Success(response):
                
                let json = JSON(data: response.data)
                var images = [Image]()

                for dict in json["results"].arrayValue {
                    if let url = dict["image"]["full"].string {
                        let image = Image(
                            url: "http:\(url)",
                            title: dict["image"]["title"].string,
                            sourceSpecific: dict,
                            sourceType: LOCSource.sourceType)
                        images.append(image)
                    }
                }
                
                completionHandler(images,true)
            case let .Failure(error):
                // Not handling errors here yet
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                print("\(error.description)")
            }
        }
    }
    
    func getHiRezURLForImage(image: Image, completionHandler: (NSURL?) -> Void) {
        
        if let resourceURLString = image.sourceSpecific["links"]["resource"].string {
            
            // this is weird, but apparently there are sometimes spaces in these urls, and alamofire doesn't like that.
            let noSpacesString = resourceURLString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            
            // I don't like calling direct to alamofire here, but to use Moya I'd need to reverse the link in the JSON...seems...meh?
            Alamofire.request(.GET, "http:\(noSpacesString)?fo=json").validate().responseJSON { response in
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

    override init(endpointClosure: EndpointClosure = MoyaProvider.DefaultEndpointMapping,
        requestClosure: RequestClosure = MoyaProvider.DefaultRequestMapping,
        stubClosure: StubClosure = MoyaProvider.NeverStub,
        manager: Manager = Manager.sharedInstance,
        plugins: [PluginType] = []) {
            
            super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins)
    }
}