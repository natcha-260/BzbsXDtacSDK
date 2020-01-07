//
//  BuzzebeesDashboard.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

public class BuzzebeesDashboard: BuzzebeesCore {
    // MARK:- Main Dashboard
    // MARK:-
    public func main(appName: String!
        , deviceLocale: String!
        , successCallback: @escaping (_ result: [BzbsDashboard]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "app_name": appName,
            "locale": deviceLocale
            ]
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/main/dashboard"
            , params: params as [String : AnyObject]
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsDashboard]()
                    for i in 0..<arrJSON.count {
                        list.append(BzbsDashboard(dict: arrJSON[i]))
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Sub Dashboard
    // MARK:-
    public func sub(dashboardName: String!
        , deviceLocale: String!
        , successCallback: @escaping (_ result: [BzbsDashboard]) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "locale": deviceLocale
        ]
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/dashboard/" + dashboardName
            , params: params as [String : AnyObject]
            , successCallback: { (ao) in
                if let arrJSON = ao as? [Dictionary<String, AnyObject>] {
                    var list = [BzbsDashboard]()
                    for i in 0..<arrJSON.count {
                        list.append(BzbsDashboard(dict: arrJSON[i]))
                    }
                    
                    successCallback(list)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
}
