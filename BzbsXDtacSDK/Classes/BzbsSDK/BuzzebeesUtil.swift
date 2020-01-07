//
//  BuzzebeesUtil.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

public class BuzzebeesUtil: BuzzebeesCore {
    public func share(token: String!
        , fbToken: String!
        , postId: String!
        , type: String!
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "post_id": postId,
            "type": type,
            "access_token": fbToken,
        ]
        
        var headers = HTTPHeaders()
        headers["Authorization"] = "token \(String(describing: token))"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/facebook/share"
            , params: params as [String : AnyObject]
            , headers: headers
            , successCallback: { (ao) in
                successCallback("success")
        } , failCallback: failCallback )
    }
}
