//
//  JSONAble.swift
//  OpenPics
//
//  Created by PJ Gray on 1/3/16.
//  Copyright © 2016 Say Goodnight Software. All rights reserved.
//

import Foundation

// This is courtesy of Artsy: https://github.com/artsy/eidolon/blob/master/Kiosk/App/Models/JSONAble.swift
protocol JSONAbleType {
    static func fromJSON(_: [String: AnyObject]) -> Self
}