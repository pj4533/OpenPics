//
//  PopularProvider.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit
import SwiftyJSON

class PopularProvider: NSObject, Provider {
    let providerName = "Currently Popular Images"
    let providerShortName = "Currently Popular Images"
    let providerType = "com.saygoodnight.Popular"
    
    func getItemsWithQuery(query: String, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        let urlPath = "http://openpics.herokuapp.com/images"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            // I feel like this data unwrapping is wrong...
            let json = JSON(data: data!)
            
            print("\(json)")
        }.resume()
    }

}
