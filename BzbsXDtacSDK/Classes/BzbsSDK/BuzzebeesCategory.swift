//
//  BuzzebeesCategory.swift
//  BzbsSDK
//
//  Created by macbookpro on 7/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

public class BuzzebeesCategory: BuzzebeesCore {
    // MARK:- List
    // MARK:-
    public func list(config: String
        , token: String?
        , haveCampaign: Bool = false
        , top: Int = 0
        , successCallback: @escaping (_ result: [BzbsCategory]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "byConfig": "true",
            "config": config
        ]
        
        params["top"] = String(top)
        
        var headers: [String:String]?
        if let bzbsToken = token {
            headers = [String:String]()
            headers!["Authorization"] = "token \(bzbsToken)"
        }
        
        var strUrl = BuzzebeesCore.apiUrl + "/api/campaigncat/menu"
        if haveCampaign {
            strUrl = BuzzebeesCore.apiUrl + "/api/campaigncat/menu_campaigns"
        }
        
        requestAlamofire(HTTPMethod.get
            , strURL: strUrl
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsCategory]()
                    for i in 0..<arrJSON.count {
                        list.append(BzbsCategory(dict: arrJSON[i]))
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Favourite List
    // MARK:-
    public func favourite(token: String
        , successCallback: @escaping (_ result: [BzbsCategory]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "sponsor": true,
            ]
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/campaigncat/favourite"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsCategory]()
                    for i in 0..<arrJSON.count {
                        list.append(BzbsCategory(dict: arrJSON[i]))
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Favourite List With Group
    // MARK:-
    public func favourite(groupId: String
        , successCallback: @escaping (_ result: [BzbsCategory]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "sponsor": true,
            "groupId": groupId,
            ] as [String : Any]
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/campaigncat/list"
            , params: params as [String : AnyObject]?
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsCategory]()
                    for i in 0..<arrJSON.count {
                        list.append(BzbsCategory(dict: arrJSON[i]))
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Post Favourite
    // MARK:-
    public func createFavourite(token: String
        , ids: String
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "ids[]": ids,
            "sponsor": true,
            ] as [String : Any]
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/campaigncat/favourite"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                successCallback("success")
        } , failCallback: failCallback )
    }
}

