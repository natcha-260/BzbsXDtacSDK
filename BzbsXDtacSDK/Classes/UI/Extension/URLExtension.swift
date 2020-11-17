//
//  URLExtension.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 13/11/2562 BE.
//

import UIKit

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    public func isDtacDeepLinkPrefix() -> Bool
    {
        let scheme = self.scheme
        let host = self.host
        if  (scheme == "dtacapp" || scheme == "dtac" || scheme == "dtacapp-beta" || scheme == "dtac-beta")
                && (host == "reward")// || host ==  "openweb")
        {
            return true
        }
        return false
    }
}

