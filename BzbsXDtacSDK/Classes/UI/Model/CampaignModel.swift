//
//  CampaignModel.swift
//  BzbsXDtacSDK
//
//  Created by apple on 17/10/2562 BE.
//

import Foundation

public class CampaignStatus: NSObject {
    
    var status: Bool!
    var quantity: Double!
    var remark: String!
    
    public override init() {
        super.init()
        status = false
        quantity = 0
        remark = ""
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        super.init()
        
        status = BuzzebeesConvert.BoolFromObject(dict["status"])
        quantity = BuzzebeesConvert.DoubleFromObject(dict["quantity"])
        remark = BuzzebeesConvert.StringFromObject(dict["remark"])
    }
}
