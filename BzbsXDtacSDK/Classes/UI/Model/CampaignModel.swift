//
//  CampaignModel.swift
//  BzbsXDtacSDK
//
//  Created by apple on 17/10/2562 BE.
//

import Foundation

public class CampaignStatus: NSObject {
    
    var status: Bool!
    var name: String!
    var desc: String!
    var quantity: Double!
    var remark: String!
    var errorCode : String!
    
    public override init() {
        super.init()
        name = ""
        desc = ""
        status = false
        quantity = 0
        remark = ""
        errorCode = ""
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        super.init()
        
        name = BuzzebeesConvert.StringFromObject(dict["name"])
        desc = BuzzebeesConvert.StringFromObject(dict["description"])
        status = BuzzebeesConvert.BoolFromObject(dict["status"])
        quantity = BuzzebeesConvert.DoubleFromObject(dict["quantity"])
        remark = BuzzebeesConvert.StringFromObject(dict["remark"])
        errorCode = BuzzebeesConvert.StringFromObject(dict["errorcode"]).lowercased()
    }
}
