//
//  BuzzebeesCampaign.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

public class BuzzebeesCampaign: BuzzebeesCore {
    // MARK:- List
    // MARK:-
    /**
     Get Campaign List
     Setting from Backoffice
     
     - parameter config: string config from Backoffice
     - parameter skip: get next items from <skip> itmes
     - parameter token: Buzzebee access token
     - parameter search: string search, if don't want to search, keep it ""
     - parameter result: Campaign List from
     - parameter error : BzbsError Object
     */
    public func list(config: String
        , top: Int = 25
        , skip: Int
        , search: String
        , catId: Int?
        , hashTag: String? = nil
        , token: String?
        , center tmpCenter: String? = nil
        , successCallback: @escaping (_ result: [BzbsCampaign]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "byConfig": "true",
            "config": config,
            "$skip": String(skip),
            "top" : String(top)
        ]
        
        if search != "" {
            params["q"] = search
        }
        
        if catId != nil {
            params["cat"] = String(catId!)
        }
        
        if let center = tmpCenter{
            params["mode"] = "nearby"
            params["center"] = center
        }
        
        if let str = hashTag {
            params["tags"] = str
        }
        
        var headers: HTTPHeaders?
        if let bzbToken = token {
            headers = HTTPHeaders()
            headers!["Authorization"] = "token \(bzbToken)"
        }
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/campaign/"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsCampaign]()
                    for i in 0..<arrJSON.count {
                        let itemNoti = BzbsCampaign(dict: arrJSON[i])
                        list.append(itemNoti)
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Detail
    // MARK:-
    /**
     Get Campaign detail
     
     - parameter campaignId: ID of campaign
     - parameter deviceLocale: locale number , will return with language of locale.
     - parameter configRelate: Campaign configuration string, will return related campaign depend on configuration
     - parameter token: Buzzebee access token
     - parameter result: Campaign detail
     - parameter error : BzbsError Object
     */
    public func detail(campaignId: Int
        , deviceLocale: String
        , configRelate: String?
        , center: String?
        , token: String?
        , successCallback: @escaping (_ result: BzbsCampaign) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "device_locale": deviceLocale,
        ]
        
        if configRelate != nil {
            params["relate_config"] = configRelate!
            params["with_relate"] = "true"
        }
        
        if let str = center {
            params["center"] = str
        }
        
        var headers: HTTPHeaders?
        if let bzbToken = token {
            headers = HTTPHeaders()
            headers!["Authorization"] = "token \(bzbToken)"
        }
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/campaign/" + String(campaignId)
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsCampaign(dict: dictJSON))
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    public func favourite(token: String
        , campaignId: Int
        , isFav: Bool
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var headers = HTTPHeaders()
        headers["Authorization"] = "token \(token)"
        var method: HTTPMethod = HTTPMethod.get
        if isFav
        {
            method = HTTPMethod.post
        }else{
            method = HTTPMethod.delete
        }
        
        requestAlamofire(method
            , strURL: BuzzebeesCore.apiUrl + "/api/campaign/" + String(campaignId) + "/favourite"
            , params: nil
            , headers: headers
            , successCallback: { (ao) in
                successCallback("success")
        } , failCallback: failCallback )
    }
    
    public func redeem(token: String
        , campaignId: Int
        , successCallback: @escaping (_ result: Dictionary<String, AnyObject>) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var headers = HTTPHeaders()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.redeemBaseUrl + "/api/campaign/" + String(campaignId) + "/redeem"
            , params: nil
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(dictJSON)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    
    public func favoriteList(token: String?
        , top: Int = 25
        , skip: Int
        , locale: Int?
        , center tmpCenter: String? = nil
        , successCallback: @escaping (_ result: [BzbsCampaign]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "$skip": String(skip),
            "top" : String(top)
        ]
        
        if let center = tmpCenter{
            params["center"] = center
        }
        if let str = locale {
            params["locale"] = "\(str)"
        }
        
        var headers: HTTPHeaders?
        if let bzbToken = token {
            headers = HTTPHeaders()
            headers!["Authorization"] = "token \(bzbToken)"
        }
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/profile/me/favourite_campaign"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsCampaign]()
                    for i in 0..<arrJSON.count {
                        let itemNoti = BzbsCampaign(dict: arrJSON[i])
                        list.append(itemNoti)
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
}
