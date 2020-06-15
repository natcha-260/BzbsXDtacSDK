//
//  BzbsCoreApi.swift
//  Job_iOS
//
//  Created by macbookpro on 1/19/2560 BE.
//  Copyright © 2560 buzzebees. All rights reserved.
//


import UIKit
import Alamofire

public class BzbsCoreApi: BuzzebeesCore {
    
    public func getGreetingText(_ strBzbsToken:String? ,successCallback: @escaping (_ result: GreetingModel) -> Void,
                                failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var headers = HTTPHeaders()
        if let bzbsToken = strBzbsToken
        {
            headers["Authorization"] = "token \(bzbsToken)"
        }
        let strURL = BuzzebeesCore.apiUrl + "/modules/dtac/main/greeting"
        requestAlamofire(HTTPMethod.get
            , strURL: strURL
            , params: nil
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(GreetingModel(dict: dictJSON))
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    public func getBranch(strBzbsToken: String?, strAgencyId: String?, strCampaignId: String?, strDistance: String?, strMode: String?, strCenter: String?, strSearch: String?, strDeviceLocale: String?, isWithInArea: Bool = false, isRequireCampaign: Bool = false, successCallback: @escaping (_ listPlace: [Branch], _ result: [Dictionary<String, AnyObject>]) -> Void, failCallback: @escaping (_ error: BzbsError) -> Void)
    {
        var params = Dictionary<String, Any>()
        params["within_area"] = isWithInArea
        params["require_campaign"] = isRequireCampaign
        
        if let agencyId = strAgencyId
        {
            params["agencyId"] = agencyId
        }
        
        if let campaignId = strCampaignId
        {
            params["campaignId"] = campaignId
        }
        
        if let mode = strMode
        {
            params["mode"] = mode
        }
        
        if let center = strCenter
        {
            params["center"] = center
        }
        
        if let search = strSearch
        {
            params["q"] = search
        }
        
        if let deviceLocale = strDeviceLocale
        {
            params["device_locale"] = deviceLocale
        }
        
        if let distance = strDistance
        {
            params["distance"] = distance
        }
        
        var headers = HTTPHeaders()
        if let bzbsToken = strBzbsToken
        {
            headers["Authorization"] = "token \(bzbsToken)"
        }
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/place"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>]
                {
                    var list = [Branch]()
                    for i in 0..<arrJSON.count
                    {
                        list.append(Branch(dict: arrJSON[i]))
                    }
                    
                    successCallback(list, arrJSON)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        
        } , failCallback: failCallback )
    }
    
    public func useCampaign(token: String
        , redeemKey: String
        , successCallback: @escaping (_ result: Dictionary<String, AnyObject>) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var headers = HTTPHeaders()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/redeem/" + redeemKey + "/use"
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
    
    public func usedByStaff(_ token :String?, keyId:String, successCallback: @escaping (Dictionary<String, AnyObject>) -> Void,
                                failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let strURL = BuzzebeesCore.apiUrl + "/api/redeem/" + keyId + "/arrange"
        var headers = HTTPHeaders()
        if let bzbsToken = token
        {
            headers["Authorization"] = "token \(bzbsToken)"
        }
        requestAlamofire(HTTPMethod.post
            , strURL: strURL
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
    
    public func searchAutoComplete(_ token :String?, keyword:String, config:String = "campaign_dtac_callcenter", successCallback: @escaping ([String]) -> Void,
                            failCallback: @escaping (_ error: BzbsError) -> Void) {
        let strURL = BuzzebeesCore.apiUrl + "/api/autocomplete/campaign"
        var headers = HTTPHeaders()
        if let bzbsToken = token
        {
            headers["Authorization"] = "token \(bzbsToken)"
        }
        var params = Dictionary<String, Any>()
        params["config"] = config
        params["q"] = keyword
            
        requestAlamofire(HTTPMethod.get
            , strURL: strURL
            , params: params as [String : AnyObject]
            , headers: headers
            , successCallback: { (ao) in
                if let arr = ao as? [String] {
                    successCallback(arr)
                    return
                        
                    }
        } , failCallback: failCallback )
    }

    public func getCampaignStatus(campaignId: Int,
                                  deviceLocale: String,
                                  center: String?,
                                  token: String?,
                                  successCallback: @escaping (_ result: CampaignStatus, Dictionary<String, AnyObject>) -> Void,
                                  failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "device_locale": deviceLocale,
        ]
        
        if let str = center {
            params["center"] = str
        }
        
        var headers: HTTPHeaders?
        if let bzbToken = token {
            headers = HTTPHeaders()
            headers!["Authorization"] = "token \(bzbToken)"
        }
        
        let strURL = BuzzebeesCore.inquiryBaseUrl + "/modules/dtac/campaign/\(campaignId)"
        requestAlamofire(HTTPMethod.get
            , strURL: strURL
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(CampaignStatus(dict: dictJSON), dictJSON)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    public func getMajorInfo(_ hashtag: String,
                             successCallback: ((Dictionary<String,AnyObject>) -> Void)?,
                                  failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "key" : "\(hashtag)"
        ]
        
        let strURL = BuzzebeesCore.apiUrl + "/modules/dtac/main/campaign_group"
        requestAlamofire(HTTPMethod.get
            , strURL: strURL
            , params: params as [String : AnyObject]?
            , headers: nil
            , successCallback: { (ao) in
                if let dict = ao as? Dictionary<String,AnyObject>
                {
                    successCallback?(dict)
                } else {
                    failCallback(
                    BzbsError(strId: "9999", strCode: "9999", strType: "manual", strMessage: "campaign group not found"))
                }
        } , failCallback: failCallback )
    }
    
    public func dtacLog(token: String, ticket:String, sequence:Int,
                        successCallback: (() -> Void)?,
                                  failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "uuid": token ,
            "info" : ticket ,
            "sequence" : "\(sequence)"
        ]
        
        let strURL = BuzzebeesCore.apiUrl + "/modules/dtac/log/segment"
        requestAlamofire(HTTPMethod.post
            , strURL: strURL
            , params: params as [String : AnyObject]?
            , headers: nil
            , successCallback: { (ao) in
                successCallback?()
        } , failCallback: failCallback )
    }
}
