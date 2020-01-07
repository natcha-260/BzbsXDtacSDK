//
//  ChangeMobileNumberParams.swift
//  BzbsSDK
//
//  Created by macbookpro on 4/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import UIKit

public class ChangeMobileNumberParams {
    var contact_number: String!
    var otp: String!
    var refcode: String!
    var idcard: String!
    var uuid: String!
    var token: String!
    
    public init(contactNumber: String, otp: String, refcode: String, idCard: String, uuid: String, token: String){
        self.contact_number = contactNumber
        self.otp = otp
        self.refcode = refcode
        self.idcard = idCard
        self.uuid = uuid
        self.token = token
    }
}
