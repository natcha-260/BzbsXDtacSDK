//
//  RegisterParams.swift
//  BzbsSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class RegisterParams {
    var username: String!
    var password: String!
    var confirmpassword: String!
    var otp: String?
    var refcode: String?
    var contact_number: String?
    var email: String?
    
    public init(username: String
        , password: String
        , confirmpassword: String
        , otp: String? = nil
        , refcode: String? = nil
        , contactNumber: String? = nil
        , email: String? = nil) {
        self.username = username
        self.password = password
        self.confirmpassword = confirmpassword
        self.otp = otp
        self.refcode = refcode
        self.contact_number = contactNumber
        self.email = email
    }
}
