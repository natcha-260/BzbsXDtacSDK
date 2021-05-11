//
//  BzbsCategory.swift
//  BzbsSDK
//
//  Created by macbookpro on 7/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsCategory {
    public var count: Int!
    public var id: Int!
    public var imageUrl: String!
    public var listConfig: String!
    public var mode: String!
    public var name: String!{
        if LocaleCore.shared.getUserLocale() == 1054{
            return nameTh
        }
        return nameEn
    }
    public var nameEn: String!
    public var nameTh: String!
    public var tags: String!
    public var isActive: Bool!
    public var favourite: Bool!
    public var isSelected: Bool!
    
    public var subCat = [BzbsCategory]()
    public var campaigns = [BzbsCampaign]()
    
    init(){
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        count = BuzzebeesConvert.IntFromObject(dict["count"])
        id = BuzzebeesConvert.IntFromObject(dict["id"])
        imageUrl = BuzzebeesConvert.StringFromObject(dict["image_url"])
        if let url = URL(string:imageUrl), let host = url.host, host == "buzzebees.blob.core.windows.net"
        {
            let newStrUrl = imageUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
            if let _ = URL(string: newStrUrl)
            {
                imageUrl = newStrUrl
            }
        }
        listConfig = BuzzebeesConvert.StringFromObject(dict["list_config"])
        mode = BuzzebeesConvert.StringFromObject(dict["mode"])
//        name = BuzzebeesConvert.StringFromObject(dict["name"])
        nameEn = BuzzebeesConvert.StringFromObject(dict["name_en"])
        nameTh = BuzzebeesConvert.StringFromObject(dict["name_th"])
        tags = BuzzebeesConvert.StringFromObject(dict["tags"])
        
        // Api "/api/reservation/" + strLocationId + "/category" ใช้ตัวใหญ่
        if let intId = BuzzebeesConvert.IntFromObject(dict["CategoryId"])
        {
            id = intId
        }
        
//        let strName = BuzzebeesConvert.StringFromObject(dict["Name"])
//        if strName != "" {
//            name = strName
//        }
        
        let strNameEn = BuzzebeesConvert.StringFromObject(dict["NameEn"])
        if strNameEn != "" {
            nameEn = strNameEn
        }
        
        isActive = BuzzebeesConvert.BoolFromObject(dict["active"])
        favourite = BuzzebeesConvert.BoolFromObject(dict["favourite"])
        isSelected = false
        
        getSubCat(arr: dict["subcats"] as? [Dictionary<String, AnyObject>])
        getCampaign(arr: dict["campaigns"] as? [Dictionary<String, AnyObject>])
    }
    
    func getSubCat(arr arrCat: [Dictionary<String, AnyObject>]?) {
        if let arrSubCat = arrCat {
            if(arrSubCat.count == 0) { return }
            
            var listCats = [BzbsCategory]()
            for i in 0..<arrSubCat.count {
                listCats.append(BzbsCategory(dict: arrSubCat[i]))
            }
            
            subCat = listCats
        }
    }
    
    func getCampaign(arr arrCampaign: [Dictionary<String, AnyObject>]?) {
        if let arrItem = arrCampaign {
            if(arrItem.count == 0) { return }
            
            var listCampaigns = [BzbsCampaign]()
            for i in 0..<arrItem.count {
                listCampaigns.append(BzbsCampaign(dict: arrItem[i]))
            }
            
            campaigns = listCampaigns
        }
    }
}
