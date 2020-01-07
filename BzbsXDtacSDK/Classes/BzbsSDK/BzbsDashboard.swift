//
//  BzbsDashboard.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsDashboard {
    public var cat: String!
    public var cat_header_en: String!
    public var cat_header_th: String!
    public var menu: String!
    public var type: String!
    public var size: String!
    public var imgType: String!
    public var icon_url: String!
    public var id: String!
    public var ios_schema: String!
    public var imageUrl: String!
    public var line1: String!
    public var line2: String!
    public var line3: String!
    public var line4: String!
    public var name: String!
    public var subCampaignDetails: [BzbsDashboard]
    public var subCat: String!
    public var url: String!
    public var strGA: String!
    public var hashtag: String!
    public var hashtagListConfig: String!
    public var dict : Dictionary<String, AnyObject>?
    public var config: String!
    public var config_cat: String!
    public var listCampaign: [BzbsCampaign]
    public var random_campaign: Bool!
    public var price: String!
    public var start_time: String!
    public var end_time: String!
    public var start_date: Double!
    public var end_date: Double!
    
    public var level:Int?
    
    init() {
        subCampaignDetails = [BzbsDashboard]()
        listCampaign = [BzbsCampaign]()
    }
    
    init(dict: Dictionary<String, AnyObject>?) {
        subCampaignDetails = [BzbsDashboard]()
        listCampaign = [BzbsCampaign]()
        
        if let item = dict {
            self.dict = dict
            cat = BuzzebeesConvert.StringFromObject(item["cat"])
            cat_header_en = BuzzebeesConvert.StringFromObject(item["cat_header_en"])
            cat_header_th = BuzzebeesConvert.StringFromObject(item["cat_header_th"])
            menu = BuzzebeesConvert.StringFromObject(item["menu"])
            type = BuzzebeesConvert.StringFromObject(item["type"])
            size = BuzzebeesConvert.StringFromObject(item["size"])
            imgType = BuzzebeesConvert.StringFromObject(item["imgtype"])
            id = BuzzebeesConvert.StringFromObject(item["id"])
            icon_url = BuzzebeesConvert.StringFromObject(item["icon_url"])
            imageUrl = BuzzebeesConvert.StringFromObject(item["image_url"])
            ios_schema = BuzzebeesConvert.StringFromObject(item["ios_schema"])
            line1 = BuzzebeesConvert.StringFromObject(item["line1"])
            line2 = BuzzebeesConvert.StringFromObject(item["line2"])
            line3 = BuzzebeesConvert.StringFromObject(item["line3"])
            line4 = BuzzebeesConvert.StringFromObject(item["line4"])
            name = BuzzebeesConvert.StringFromObject(item["name"])
            url = BuzzebeesConvert.StringFromObject(item["url"])
            strGA = BuzzebeesConvert.StringFromObject(item["ga_label"])
            hashtag = BuzzebeesConvert.StringFromObject(item["hashtag"])
            hashtagListConfig = BuzzebeesConvert.StringFromObject(item["hashtag_list_config"])
            config = BuzzebeesConvert.StringFromObject(item["config"])
            config_cat = BuzzebeesConvert.StringFromObject(item["config_cat"])
            subCat = BuzzebeesConvert.StringFromObject(item["subcat"])
            random_campaign = BuzzebeesConvert.BoolFromObject(item["random_campaign"])
            price = BuzzebeesConvert.StringFromObject(item["price"])
            
            subCampaignDetails.removeAll(keepingCapacity: false)
            if let arrItem = item["subcampaigndetails"] as? [Dictionary<String, AnyObject>] {
                for dictItem in arrItem {
                    subCampaignDetails.append(BzbsDashboard(dict: dictItem))
                }
            }
            
            start_time = BuzzebeesConvert.StringFromObject(item["start_time"])
            end_time = BuzzebeesConvert.StringFromObject(item["end_time"])
            start_date = BuzzebeesConvert.DoubleFromObject(item["start_date"])
            end_date = BuzzebeesConvert.DoubleFromObject(item["end_date"])
            
            level = BuzzebeesConvert.IntFromObjectNull(item["level"])
        }
    }
}
