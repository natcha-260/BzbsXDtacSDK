//
//  BuzzebeesHistory.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

public class BuzzebeesHistory: BuzzebeesCore {
    public func list(config: String
        , token: String
        , skip: Int
        , successCallback: @escaping (_ result: [BzbsHistory]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "byConfig": "true",
            "config": config,
            "skip": skip,
            ] as [String : Any]
        
        var headers = HTTPHeaders()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/redeem/"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsHistory]()
                    for i in 0..<arrJSON.count {
                        let itemNoti = BzbsHistory(dict: arrJSON[i])
                        list.append(itemNoti)
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    public func use(token: String
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
}
