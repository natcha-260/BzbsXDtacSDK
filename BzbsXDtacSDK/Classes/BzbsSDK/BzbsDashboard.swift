//
//  BzbsDashboard.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsDashboard {
    public var cat: String! = ""
    public var cat_header_en: String! = ""
    public var cat_header_th: String! = ""
    public var menu: String!
    public var type: String!
    public var size: String!
    public var imgType: String!
    public var icon_url: String!
    public var id: String!
    public var ios_schema: String!
    public var imageUrl: String!
    public var line1: String! = ""
    public var line2: String! = ""
    public var line3: String! = ""
    public var line4: String! = ""
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
    
    public var categoryName: String?
    public var subCategoryId = [Int]()
    
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
            if let url = URL(string:icon_url), let host = url.host, host == "buzzebees.blob.core.windows.net"
            {
                let newStrUrl = icon_url.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                if let _ = URL(string: newStrUrl)
                {
                    icon_url = newStrUrl
                }
            }
            
            imageUrl = BuzzebeesConvert.StringFromObject(item["image_url"])
            if let url = URL(string:imageUrl), let host = url.host, host == "buzzebees.blob.core.windows.net"
            {
                let newStrUrl = imageUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                if let _ = URL(string: newStrUrl)
                {
                    imageUrl = newStrUrl
                }
            }
            
            ios_schema = BuzzebeesConvert.StringFromObject(item["ios_schema"])
            line1 = BuzzebeesConvert.StringFromObject(item["line1"])
            line2 = BuzzebeesConvert.StringFromObject(item["line2"])
            line3 = BuzzebeesConvert.StringFromObject(item["line3"])
            line4 = BuzzebeesConvert.StringFromObject(item["line4"])
            name = BuzzebeesConvert.StringOrNull(item["name"])
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
            
            level = BuzzebeesConvert.IntOrNull(item["level"])
            
            categoryName = BuzzebeesConvert.StringOrNull(item["categoryName"])
            
            if let tmpSubCategoryId = item["subCategoryId"] as? [Int] {
                self.subCategoryId = tmpSubCategoryId
            }
        }
    }
    
    open func toCampaign() -> BzbsCampaign {
        let campaign = BzbsCampaign()
        campaign.ID = Int(id)
        campaign.name = line1
        campaign.agencyName = line3
        
        campaign.categoryID = subCategoryId.last ?? 0
        if subCategoryId.count > 1 {
            campaign.parentCampaignId = subCategoryId.first ?? 0
        }
        if LocaleCore.shared.getUserLocale() == 1033
        {
            campaign.name = line2
            campaign.agencyName = line4
        }
        
        campaign.fullImageUrl = imageUrl
        campaign.pointPerUnit = 0
        if let _ = dict,  let pointPerUnit = Convert.IntFromObject(dict!["pointperunit"]) {
            campaign.pointPerUnit = pointPerUnit
        }
        
        
        return campaign
    }
}
