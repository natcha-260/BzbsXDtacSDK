//
//  LoginParams.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import UIKit

/**
 DeviceLoginParams require all properties to login with device
 */
public class DeviceLoginParams {
    /**
     Unique id of device
     */
    var uuid: String!
    /**
     Operating system
     */
    var os: String!
    /**
     Platform
     */
    var platform: String!
    /**
     Mac address
     */
    var mac_address: String!
    /**
     Device push notification enable
     */
    var device_noti_enable: Bool! = false
    /**
     Client version
     */
    var client_version: String!
    /**
     Device token
     */
    var device_token: String?
    /**
     Custom info
     */
    var customInfo: String?
    /**
     language  => "en" or "th"
     */
    var language: String?
    

    
    
    /**
     Initial object
     - parameter uuid: Unique id of device
     - parameter os: Operating system
     - parameter platform: Platform
     - parameter macAddress: Mac address ps. Same with uuid
     - parameter deviceNotiEnable: Device push notification enable
     - parameter clientVersion: Client version
     - parameter deviceToken: Device token
     */
    public init(uuid: String, os: String, platform: String, macAddress: String, deviceNotiEnable: Bool, clientVersion: String, deviceToken: String?, customInfo:String?, language:String?) {
        self.uuid = uuid
        self.os = os
        self.platform = platform
        self.mac_address = macAddress
        self.device_noti_enable = deviceNotiEnable
        self.client_version = clientVersion
        self.device_token = deviceToken
        self.customInfo = customInfo
        self.language = language
    }
}

public class BuzzebeesLoginParams: DeviceLoginParams {
    /**
     Username
     */
    public var username: String!
    /**
     Password
     */
    public var password: String!
    
    public init(username: String, password: String, uuid: String, appId: Int, deviceAppId: Int, os: String, platform: String, macAddress: String, deviceNotiEnable: Bool, clientVersion: String, deviceToken: String?,customInfo: String?, language:String?) {
        
        super.init(uuid: uuid, os: os, platform: platform, macAddress: macAddress, deviceNotiEnable: deviceNotiEnable, clientVersion: clientVersion, deviceToken: deviceToken, customInfo: customInfo, language:language)
        
        self.username = username
        self.password = password
    }
}

public class FacebookLoginParams: DeviceLoginParams {
    /**
     Access token
     */
    public var access_token: String!
    
    public init(fbToken: String, uuid: String, appId: Int, deviceAppId: Int, os: String, platform: String, macAddress: String, deviceNotiEnable: Bool, clientVersion: String, deviceToken: String?, language:String?) {
        
        super.init(uuid: uuid, os: os, platform: platform, macAddress: macAddress, deviceNotiEnable: deviceNotiEnable, clientVersion: clientVersion, deviceToken: deviceToken, customInfo: nil, language:language)
        
        self.access_token = fbToken
    }
}

public class UpdateDeviceParams: DeviceLoginParams {
    /**
     Buzzebees Token
    */
    public var token: String!
    
    public init(token: String, uuid: String, os: String, platform: String, macAddress: String, deviceNotiEnable: Bool, clientVersion: String, deviceToken: String?, language:String?) {
        
        super.init(uuid: uuid, os: os, platform: platform, macAddress: macAddress, deviceNotiEnable: deviceNotiEnable, clientVersion: clientVersion, deviceToken: deviceToken, customInfo: nil, language:language)
        
        self.token = token
    }
}
