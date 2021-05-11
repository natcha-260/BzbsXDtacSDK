//
//  NotiParams.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class NotiParams {
    var token: String!
    var mode: String?
    var type: String?
    var sortby: String?
    
    public init(token: String
        , mode: String? = nil
        , type: String? = nil
        , sortBy: String? = nil) {
        self.token = token
        self.mode = mode
        self.type = type
        self.sortby = sortBy
    }
}
