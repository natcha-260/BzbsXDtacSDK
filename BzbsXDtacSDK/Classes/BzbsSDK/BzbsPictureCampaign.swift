//
//  BzbsPictureCampaign.swift
//  BzbsSDK
//
//  Created by macbookpro on 18/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import UIKit

public class BzbsPictureCampaign {
    public var ID: Int!
    public var campaignID: Int!
    public var caption: String!
    public var sequence: Int!
    public var imageUrl: String!
    public var fullImageUrl: String!
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        ID = BuzzebeesConvert.IntFromObject(dict["ID"])
        campaignID = BuzzebeesConvert.IntFromObject(dict["CampaignID"])
        caption = BuzzebeesConvert.StringFromObject(dict["Caption"])
        sequence = BuzzebeesConvert.IntFromObject(dict["Sequence"])
        imageUrl = BuzzebeesConvert.StringFromObject(dict["ImageUrl"])
        fullImageUrl = BuzzebeesConvert.StringFromObject(dict["FullImageUrl"])
        
        if(fullImageUrl != "") {
            if fullImageUrl.range(of: "-large") == nil{
                var newString = fullImageUrl.replacingOccurrences(of: "?", with: "-large?", options: NSString.CompareOptions.literal, range: nil)
                if let url = URL(string:newString), let host = url.host, host == "buzzebees.blob.core.windows.net"
                {
                    let newStrUrl = newString.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                    if let _ = URL(string: newStrUrl)
                    {
                        newString = newStrUrl
                    }
                }
                fullImageUrl = newString
            }
        }
    }
}
