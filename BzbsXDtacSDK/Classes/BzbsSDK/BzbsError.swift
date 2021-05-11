//
//  BuzzebeesError.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsError {
    public var id: String!
    public var code: String!
    public var type: String!
    public var message: String!
    
    init(){
        id = "-9999"
        code = "-9999"
        type = "Framework"
        message = "Default"
    }
    
    init(strId: String, strCode: String, strType: String, strMessage: String) {
        id = strId
        code = strCode
        type = strType
        message = strMessage
    }
    
    func description() -> String {
        return "BzbsError \n\(String(describing: type))\nid:\(String(describing: id))\ncode:\(String(describing: code))\nmessage:\(String(describing: message))"
    }
}
