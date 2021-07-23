//
//  BuzzebeesAuth.swift
//  BuzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

/**
    # All About Authorization
 
    Fill All params of Object for each method to use methods
 */

public class BuzzebeesAuth: BuzzebeesCore {
    
    private static var loginRequest : DataRequest?
    
    // MARK:- Login
    // MARK:-
    /**
     Login to Buzzebees system with Username/Password
     
     - parameter loginParams: Fill BuzzebeesLoginParams all properties
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func login(loginParams: BuzzebeesLoginParams
        , successCallback: @escaping (_ result: BzbsUser) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "username": loginParams.username!,
            "password": loginParams.password!,
            "uuid": loginParams.uuid,
            "app_id": self.appId,
            "os": loginParams.os,
            "platform": loginParams.platform,
            "mac_address": loginParams.mac_address,
            "device_noti_enable": String(loginParams.device_noti_enable),
            "client_version": loginParams.client_version,
            ] as [String : Any?]
        
        if let strDeviceToken = loginParams.device_token {
            params["device_token"] = strDeviceToken;
        }
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/bzbs_login"
            , params: params as [String : AnyObject]?
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsUser(dict: dictJSON))
                        return;
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    /**
     Login with device UUID
     
     - parameter loginParams: Fill DeviceLoginParams all properties
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func login(loginParams: DeviceLoginParams
        , successCallback: @escaping (_ result: BzbsUser, _ dict:Dictionary<String, AnyObject>) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        var locale = 1054
        if let language = loginParams.language?.lowercased()
        {
            if language == "th" {
                locale = 1033
            } else if language == "mm" || language == "my" {
                locale = 1109
            } else {
                locale = 1054
            }
        }
        var params = [
            "uuid": loginParams.uuid as Any,
            "app_id": self.appId as Any,
            "os": loginParams.os as Any,
            "platform": loginParams.platform as Any,
            "mac_address": loginParams.mac_address as Any,
            "device_noti_enable": String(loginParams.device_noti_enable),
            "client_version": loginParams.client_version as Any,
            "info": loginParams.customInfo as Any,
            "locale": locale as Any,
            "device_locale": locale as Any
            ] as [String : Any]
        
        if let strDeviceToken = loginParams.device_token {
            params["device_token"] = strDeviceToken;
        }
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/device_login"
            , params: params as [String : AnyObject]?
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsUser(dict: dictJSON), dictJSON)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    /**
     Login with Facebook access token
     
     
     - parameter loginParams: Fill FacebookLoginParams all properties
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func login(loginParams: FacebookLoginParams
        , successCallback: @escaping (_ result: BzbsUser) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "uuid": loginParams.uuid as Any,
            "app_id": self.appId as Any,
            "os": loginParams.os as Any,
            "platform": loginParams.platform as Any,
            "mac_address": loginParams.mac_address as Any,
            "device_noti_enable": String(loginParams.device_noti_enable),
            "client_version": loginParams.client_version as Any,
            "access_token": loginParams.access_token!,
            ] as [String : Any]
        
        if let strDeviceToken = loginParams.device_token {
            params["device_token"] = strDeviceToken;
        }
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/login"
            , params: params as [String : AnyObject]?
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsUser(dict: dictJSON))
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Logout
    // MARK:-
    /**
     Logout from buzzebees system
     
     - parameter uuid: Unique id of device
     - parameter token: Buzzebees access token
     - parameter fbToken: Facebook access token if user logged in with Facebook, else nil
     - parameter loginParams: Fill FacebookLoginParams all properties
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func logout(uuid: String, token: String, fbToken: String?
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "uuid": uuid,
            ] as [String : Any]
        
        if let accessToken = fbToken {
            params["access_token"] = accessToken
        }
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/logout"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                successCallback("success")
        } , failCallback: failCallback )
    }
    
    // MARK:- Change Mobile Number
    // MARK:-
    
    /**
     Change mobile number
     
     - parameter changeMobileParams: Fill ChangeMobileNumberParams all properties
     - parameter result : ## Not tested yet ???
     - parameter error : BzbsError Object
     */
    public func changeMobileNumber(changeMobileParams: ChangeMobileNumberParams
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "contact_number": changeMobileParams.contact_number,
            "otp": changeMobileParams.otp,
            "refcode": changeMobileParams.refcode,
            "idcard": changeMobileParams.idcard,
            "uuid": changeMobileParams.uuid,
            ]
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(String(describing: changeMobileParams.token))"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/change_authen"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        let bzbsToken = dictJSON["token"] as! String
                        successCallback(bzbsToken)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- One time password
    // MARK:-
    /**
     Get One-time-password to recheck contact numbuer
     
     - parameter contactNumber: contact number 10 digit ex. 0812345679
     - parameter uuid: Unique id of device used for back track if has any problem
     - parameter result : Ref code use with [changeMobileNumber] or [confirmOtp]
     - parameter error : BzbsError Object
     */
    public func otp(contactNumber: String, uuid: String
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "contact_number": contactNumber,
            "uuid": uuid,
            "app_id": self.appId as Any,
            ] as [String : Any]
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/otp"
            , params: params as [String : AnyObject]
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        let refcode = dictJSON["refcode"] as! String
                        successCallback(refcode)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    /**
     Confirm Contact number with One-time-password
     
     - parameter contactNumber: contact number 10 digit ex. 0812345679
     - parameter otp: One-time-password
     - parameter refcode: Reference code from [otp]
     - parameter token: Buzzebees Access token
     - parameter uuid: Unique id of device used for back track if has any problem
     - parameter result : Ref code use with changeMobileNumber
     - parameter error : BzbsError Object
     */
    public func confirmOtp(contactNumber: String, otp: String, refcode: String, token: String
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "contact_number": contactNumber,
            "otp": otp,
            "refcode": refcode,
            ] as [String : Any]
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(token)"
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/bzbs_authen"
            , params: params as [String : AnyObject]
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        let bzbsToken = dictJSON["token"] as! String
                        successCallback(bzbsToken)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Register
    // MARK:-
    /**
     Register for Buzzebees User
     
     - parameter registerParams: Fill all properties to use
     - parameter result : #Not test yet??
     - parameter error : BzbsError Object
    */
    public func register(registerParams: RegisterParams
        , successCallback: @escaping (_ result:AnyObject) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "username": registerParams.username as Any,
            "password": registerParams.password as Any,
            "confirmpassword": registerParams.confirmpassword as Any,
            "app_id": self.appId as Any,
            ] as [String : Any]
        
        if let otp = registerParams.otp {
            params["otp"] = otp
        }
        
        if let refcode = registerParams.refcode {
            params["refcode"] = refcode;
        }
        
        if let contactNumber = registerParams.contact_number {
            params["contact_number"] = contactNumber;
        }
        
        if let email = registerParams.email {
            params["email"] = email
        }
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/register"
            , params: params as [String : AnyObject]?
            , successCallback: successCallback
            , failCallback: failCallback)
    }
    
    // MARK:- Resume
    // MARK:-
    /**
     Renew Token
     
     - parameter updateDeviceParams: Fill all properties to use
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func resume(updateDeviceParams: UpdateDeviceParams
        , successCallback: @escaping (_ result: BzbsUser) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "uuid": updateDeviceParams.uuid as Any,
            "app_id": self.appId as Any,
            "os": updateDeviceParams.os as Any,
            "platform": updateDeviceParams.platform as Any,
            "mac_address": updateDeviceParams.mac_address as Any,
            "device_noti_enable": String(updateDeviceParams.device_noti_enable),
            "client_version": updateDeviceParams.client_version as Any,
            ] as [String : Any]
        
        if let strDeviceToken = updateDeviceParams.device_token {
            params["device_token"] = strDeviceToken;
        }
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(String(describing: updateDeviceParams.token!))";
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/device_resume"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsUser(dict: dictJSON))
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Update Device
    // MARK:-
    /**
     Update deive uuid to get push notification
     
     - parameter updateDeviceParams : Fill all properties to use
     - parameter result : BuzzebeesUser Object, filled with nesessary information that used in other param
     - parameter error : BzbsError Object
     */
    public func updateDevice(updateDeviceParams: UpdateDeviceParams
        , successCallback: @escaping (_ result: String) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var params = [
            "uuid": updateDeviceParams.uuid as Any,
            "app_id": self.appId as Any,
            "os": updateDeviceParams.os as Any,
            "platform": updateDeviceParams.platform as Any,
            "mac_address": updateDeviceParams.mac_address as Any,
            "device_noti_enable": String(updateDeviceParams.device_noti_enable),
            "client_version": updateDeviceParams.client_version as Any,
            ] as [String : Any]
        
        if let strDeviceToken = updateDeviceParams.device_token {
            params["device_token"] = strDeviceToken;
        }
        
        var headers = [String:String]()
        headers["Authorization"] = "token \(String(describing: updateDeviceParams.token!))";
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/update_device"
            , params: params as [String : AnyObject]?
            , headers: headers
            , successCallback: { (ao) in
                if let strResult = ao as? String {
                    successCallback(strResult)
                    return
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
    
    // MARK:- Version
    // MARK:-
    /**
     to check is this client version still available
     
     - parameter clientVersion: app_prefix + version ex. ios_bzbs1.0.0
     - parameter result: Information of client version
     - parameter error : BzbsError Object
     */
    public func version(clientVersion: String
        , successCallback: @escaping (_ result: BzbsVersion) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        let params = [
            "client_version": clientVersion
        ]
        
        requestAlamofire(HTTPMethod.get
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/version"
            , params: params as [String : AnyObject]
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsVersion(dict: dictJSON))
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
}

extension BuzzebeesAuth {
    
    func loginDtac(loginParams: DtacDeviceLoginParams
    , successCallback: @escaping (_ result: BzbsUser, _ dict:Dictionary<String, AnyObject>) -> Void
    , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        var locale = 1054
        if let language = loginParams.language?.lowercased()
        {
            if language == "th" {
                locale = 1054
            } else if language == "mm" || language == "my" {
                locale = 1109
            } else {
                locale = 1033
            }
        }
        //            let loginParams = DtacDeviceLoginParams(uuid: token
        //                , os: "ios " + UIDevice.current.systemVersion
        //                , platform: UIDevice.current.model
        //                , macAddress: UIDevice.current.identifierForVendor!.uuidString
        //                , deviceNotiEnable: false
        //                , clientVersion: strVersion
        //                , deviceToken: token, customInfo: ticket, language:language, DTACSegment: DTACSegment == "" ? "9999" : DTACSegment)
        var appversion = loginParams.DtacAppVersion ?? ""
        if appversion.split(separator: ".").count > 3 {
            let tmp = appversion.split(separator: ".")
            appversion = String(tmp[0]) + "." + String(tmp[1]) + "." + String(tmp[2])
        }
        let info = "{\"ticket\": \"\(loginParams.ticket!)\", \"segment\": \"\(loginParams.DTACSegment!)\", \"teltype\": \"\(loginParams.TelType!)\", \"appversion\": \"\(appversion)\"}"
        
        let params = [
            "uuid": loginParams.token as Any,
            "app_id": self.appId as Any,
            "os": ("ios " + UIDevice.current.systemVersion) as Any,
            "platform": UIDevice.current.model as Any,
            "mac_address": (UIDevice.current.identifierForVendor?.uuidString ?? "") as Any,
            "device_noti_enable": String(false),
            "client_version": loginParams.clientVersion as Any,
            "info": info as Any,
            "locale": locale as Any,
            "device_locale": locale as Any
            ] as [String : Any]
//
//        if let strDeviceToken = loginParams.device_token {
//            params["device_token"] = strDeviceToken
//        }
//
//        if let DTACSegment = loginParams.DTACSegment {
//            params["carrier"] = DTACSegment == "" ? "9999" : DTACSegment
//        }
        
        requestAlamofire(HTTPMethod.post
            , strURL: BuzzebeesCore.apiUrl + "/api/auth/device_login"
            , params: params as [String : AnyObject]?
                         , requestCreated: { (request) in
                            print("loginRequest cancelled")
                            BuzzebeesAuth.loginRequest?.cancel()
                            BuzzebeesAuth.loginRequest = request
                         }
            , successCallback: { (ao) in
                if let dictJSON = ao as? Dictionary<String, AnyObject> {
                    if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                        successCallback(BzbsUser(dict: dictJSON), dictJSON)
                        return
                    }
                }
                
                self.serverSendDataWrongFormat(failCallback: failCallback)
                return
        } , failCallback: failCallback )
    }
}
