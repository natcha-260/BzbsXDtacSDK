//
//  BuzzebeesUser.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsUser {
    public var appId: String!
    public var bzbsPoints: Int!
    public var canRedeem: Bool!
    public var isFbUser: Bool!
    public var locale: Int!
    public var platform: String!
    public var sponsorId: Int!
    public var token: String!
    public var userId: String!
    public var userLevel: Int!
    public var uuid: String!
    public var version: BzbsVersion?
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        appId = BuzzebeesConvert.StringFromObject(dict["appId"])
        canRedeem = BuzzebeesConvert.BoolFromObject(dict["canRedeem"])
        isFbUser = BuzzebeesConvert.BoolFromObject(dict["isFbUser"])
        
        let intLocale = BuzzebeesConvert.IntFromObject(dict["locale"])
        if intLocale != 0 {
            locale = intLocale
        }
        platform = BuzzebeesConvert.StringFromObject(dict["platform"])
        sponsorId = BuzzebeesConvert.IntFromObject(dict["sponsorId"])
        token = BuzzebeesConvert.StringFromObject(dict["token"])
        userId = BuzzebeesConvert.StringFromObject(dict["userId"])
        userLevel = BuzzebeesConvert.IntFromObject(dict["userLevel"])
        uuid = BuzzebeesConvert.StringFromObject(dict["uuid"])
        
        getPoint(dict: dict["updated_points"] as? Dictionary<String, AnyObject>)
        getVersion(dict: dict["version"] as? Dictionary<String, AnyObject>)
    }
    
    public func getPoint(dict: Dictionary<String, AnyObject>?) {
        if let item = dict {
            bzbsPoints = BuzzebeesConvert.IntFromObject(item["points"])
        }
    }
    
    public func getVersion(dict: Dictionary<String, AnyObject>?) {
        if let item = dict {
            version = BzbsVersion(dict: item)
        }
    }
    
    public func updateWhenUpdateProfile(dict: Dictionary<String, AnyObject>) {
        if let strToken = dict["Token"] as? String {
            token = strToken
        }
        
        if let strToken = dict["token"] as? String {
            token = strToken
        }
        
        if let intLocale = dict["Locale"] as? Int {
            locale = intLocale
        }
    }
}

public class BzbsVersion {
    public var allow_use: Bool!
    public var has_new_version: Bool!
    public var welcome_page_times: Int!
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        allow_use = BuzzebeesConvert.BoolFromObject(dict["allow_use"])
        has_new_version = BuzzebeesConvert.BoolFromObject(dict["has_new_version"])
        welcome_page_times = BuzzebeesConvert.IntFromObject(dict["welcome_page_times"])
    }
}
