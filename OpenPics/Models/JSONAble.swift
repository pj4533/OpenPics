//
//  JSONAble.swift
//  OpenPics
//
//  Created by PJ Gray on 1/3/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation
import SwiftyJSON

// This is courtesy of Artsy: https://github.com/artsy/eidolon/blob/master/Kiosk/App/Models/JSONAble.swift
protocol JSONAbleType {
    static func fromJSON(_: [String: AnyObject]) -> Self
    
    // I added this bit, cause i wanted to not have to convert the json blob twice
    // (once on getting request, then to string:any then back to json)
    static func fromJSON(_: SwiftyJSON.JSON) -> Self
}