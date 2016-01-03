//
//  PopularProvider.swift
//  OpenPics
//
//  Created by PJ Gray on 1/2/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import UIKit
import SwiftyJSON

class PopularProvider: Provider {
    let providerName = "Currently Popular Images"
    let providerShortName = "Currently Popular Images"
    let providerType = "com.saygoodnight.Popular"
    
    // - should the parameters on the completion handler be optional?
    // - how can i specify the name of the variable for the paramters on completion handler?
    func getItemsWithQuery(query: String, pageNumber: Int, completionHandler: (NSArray?, Bool?, NSError?) -> Void) {
        
        let urlPath = "http://openpics.herokuapp.com/images"
        
        guard let url = NSURL(string: urlPath) else {
            print("Error creating endpoint");
            return
        }
        
        let request = NSMutableURLRequest(URL:url)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            // I feel like this data unwrapping is wrong...
            let json = JSON(data: data!)
            var images = [Image]()
            for dict in json["data"].arrayValue {
                let image = Image(jsonDictionary: dict.dictionaryObject!)
                images.append(image)
            }
            
            completionHandler(images,true,error)
            
        }.resume()
    }

}
