//
//  UserDefaultManage.swift
//  Buzzebees_swift_iOS
//
//  Created by macbookpro on 6/24/2559 BE.
//  Copyright © 2559 buzzebees. All rights reserved.
//

import UIKit


open class UserDefaultManage
{
    // MARK: private Variables For Class
    fileprivate var _defaults = UserDefaults.standard
    
    // MARK: ClearUserDefault When Logout
    func clearUserDefault()
    {
        _defaults.set(false, forKey: "bzbs_login_complete")
        _defaults.set(false, forKey: "device_login")
        _defaults.set(false, forKey: "device_login_with_passcode")
        _defaults.set(false, forKey: "fb_login")
        _defaults.set(nil, forKey: "showWelcome")
        
        // for auto fill in login page
//        _defaults.set("", forKey: "username")
        _defaults.set("", forKey: "password")
        _defaults.set("", forKey: "custom_uuid")
        _defaults.synchronize()
    }
    
    func changeUUID(_ strNewUUID: String)
    {
        _defaults.set(strNewUUID, forKey: "custom_uuid")
    }
    
    // MARK:- User Status
    // MARK:-
    func isDeviceLogin() -> Bool
    {
        if let isDevice = (_defaults.value(forKey: "device_login")) as? Bool
        {
            return isDevice
        }
        
        return false
    }
    
    func isFBLogin() -> Bool
    {
        if let isFacebook = (_defaults.value(forKey: "fb_login")) as? Bool
        {
            return isFacebook
        }
        
        return false
    }
    
    func isUserLogin() -> Bool
    {
        guard let strUsername = (_defaults.value(forKey: "username")) as? String else {
            return false
        }
        
        guard let strPassword = (_defaults.value(forKey: "password")) as? String else {
            return false
        }
        
        if strUsername.count > 0 && strPassword.count > 0
        {
            return true
        }
        
        return false
    }
    
    // MARK:- User & Password
    // MARK:-
    func getUsername() -> String?
    {
        return _defaults.value(forKey: "username") as? String
    }
    
    func changeUsername(_ strUsername: String)
    {
        _defaults.set(strUsername, forKey: "username")
    }
    
    func getPassword() -> String?
    {
        return _defaults.value(forKey: "password") as? String
    }
    
    func changePassword(_ strNewPassword: String)
    {
        _defaults.set(strNewPassword, forKey: "password")
    }
    
    // MARK:- Support Share
    // MARK:-
    func saveKeyShare(_ strCampaignIDUserId: String)
    {
        _defaults.set(strCampaignIDUserId, forKey: "key_share")
    }
    
    func getKeyShare() -> String?
    {
        return _defaults.value(forKey: "key_share") as? String
    }
    
    func saveKey(_ key:String, value:AnyObject)
    {
        _defaults.set(value, forKey: key)
    }
    
    func getValueFromKey(_ key:String) -> AnyObject?
    {
        return _defaults.value(forKey: key) as AnyObject?
    }
}
