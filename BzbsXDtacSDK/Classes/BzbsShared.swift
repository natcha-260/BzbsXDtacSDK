//
//  BzbsShared.swift
//  iOS_Dtac_Rewards
//
//  Created by Buzzebees iMac on 12/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

// Bundle
// Dtac : th.co.dtac.beta
// Bzbs : com.buzzebees.xDtac

import UIKit

struct DtacLoginParams {
    var token:String?
    var ticket :String?
    var language :String?
    var DTACSegment : String?
}

@objc public protocol BzbsDelegate {
    func clickMessage()
    func suspend()
    func reLogin()
    func reTokenTicket()
    func analyticsScreen(screenName: String)
    func analyticsEvent(event: String, category: String, action: String, label: String)
    func analyticsEventEcommerce(eventName:String, params:[String:AnyObject])
}

@objc public class Bzbs: NSObject {
    @objc public static var shared = Bzbs()
    
    var dtacLoginParams = DtacLoginParams()
    @objc public var delegate: BzbsDelegate?
    @objc public var isHasNewMessage :Bool = false{
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
        }
    }
    
    var apiPrefix:String?// = "https://dev.buzzebees.com"
    private var webMiscUrl:String?{
        BuzzebeesCore.miscUrl
    }
    var blobUrl:String?{
        BuzzebeesCore.blobUrl
    }
    private let pathUrlMemberLevel = "/misc/levelinfo"
    private let pathUrlFAQ = "/misc/faq"
    private let pathUrlAbout = "/misc/about"
    
    @objc public var versionString :String = "0.0.4"
    let agencyID = "110807"
    let prefixApp = "ios_dtw"
    
    @objc public var isDebugMode = false
    var userLogin: BzbsUser?
    var arrCategory :[BzbsCategory]?
    var blueCategory : BzbsCategory?
    var deepLinkUrl : URL?
    var isRetriedGetSegment = false
    
    var currentBundle : Bundle {
        let bundle = Bundle(for: BzbsMainViewController.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("BzbsXDtacSDK.bundle"),
            let resourceBundle = Bundle(url: bundleURL)
            else {
                return Bundle.main
        }
        
        return resourceBundle
    }
    
    func getCacheLoginParams(loginCacheSelector: ((DtacLoginParams?) -> Void))
    {
        CacheCore.shared.loadCacheData(key: BBCache.keys.loginparam, successCallback: { (ao) in
            if let dict = ao as? Dictionary<String, String>
            {
                var loginParams = DtacLoginParams()
                loginParams.token = dict["token"]
                loginParams.ticket = dict["ticket"]
                loginParams.DTACSegment = dict["DTACSegment"]
                loginCacheSelector(loginParams)
            } else {
                loginCacheSelector(nil)
            }
        }) {
            loginCacheSelector(nil)
        }
    }
    
    @objc public func setup(token:String, ticket:String, language:String, DTACSegment:String ,delegate:BzbsDelegate? = nil, isHasNewMessage:Bool = false){
        var loginParams = DtacLoginParams()
        if token == "" || ticket == "" || DTACSegment == ""
        {
            getCacheLoginParams { (loginParamsCache) in
                if loginParamsCache != nil {
                    loginParams = loginParamsCache!
                    loginParams.language = language
                    self.dtacLoginParams = loginParams
                }
                self.relogin()
                self.isHasNewMessage = isHasNewMessage
                if delegate != nil {
                    self.delegate = delegate
                }
            }
        } else {
            loginParams.token = token
            loginParams.ticket = ticket
            loginParams.language = language
            loginParams.DTACSegment = DTACSegment
            var dict = Dictionary<String, String>()
            dict["token"] = token
            dict["ticket"] = ticket
            dict["DTACSegment"] = DTACSegment
            CacheCore.shared.saveCacheData(dict as AnyObject, key: BBCache.keys.loginparam, lifetime: BuzzebeesCore.cacheTimeSegment)
            self.dtacLoginParams = loginParams
            relogin()
            self.isHasNewMessage = isHasNewMessage
            if delegate != nil {
                self.delegate = delegate
            }
        }
    }
    
    @objc public func isLoggedIn() -> Bool {
        if let userLogin = Bzbs.shared.userLogin
        {
            if userLogin.token != nil && userLogin.dtacLevel != .no_level
            {
                return true
            }
        }
        return false
    }
    
    var isCallingLogin = false
    
    @objc public func login(token:String, ticket:String, language:String, DTACSegment:String)
    {
        login(token: token, ticket: ticket, language: language, DTACSegment:DTACSegment, completionHandler: nil, failureHandler: nil)
    }
    
    func relogin(completionHandler:(() -> Void)? = nil, failureHandler:((BzbsError) -> Void)? = nil)
    {
        let token = dtacLoginParams.token
        let ticket = dtacLoginParams.ticket
        let language = dtacLoginParams.language ?? "th"
        let DTACSegment = dtacLoginParams.DTACSegment ?? ""
        login(token: token, ticket: ticket, language: language, DTACSegment:DTACSegment, completionHandler: completionHandler, failureHandler: failureHandler)
    }
    
    func login(token:String?, ticket:String?, language:String, DTACSegment: String, completionHandler:(() -> Void)? = nil, failureHandler:((BzbsError) -> Void)? = nil)
    {
        if isCallingLogin { return }
        isCallingLogin = true
        if !BuzzebeesCore.isSetEndpoint
        {
            BuzzebeesCore.apiSetupPrefix(successCallback: {
                self.isCallingLogin = false
                self.login(token:token, ticket:ticket, language:language, DTACSegment:DTACSegment, completionHandler: completionHandler, failureHandler: failureHandler)
            }) {
                self.isCallingLogin = false
                self.login(token:token, ticket:ticket, language:language, DTACSegment:DTACSegment, completionHandler: completionHandler, failureHandler: failureHandler)
            }
            return
        }
        
        Bzbs.shared.dtacLoginParams = DtacLoginParams(token: token, ticket: ticket, language: language, DTACSegment:DTACSegment)
        
        if let token = dtacLoginParams.token, token != "",
            let ticket = dtacLoginParams.ticket, ticket != "",
            let language = dtacLoginParams.language,
            let DTACSegment = dtacLoginParams.DTACSegment
        {
            if DTACSegment == "" && !isRetriedGetSegment
            {
                delegate?.reLogin()
                isRetriedGetSegment = true
                Bzbs.shared.userLogin = nil
                self.isCallingLogin = false
                NotificationCenter.default.post(name: Notification.Name.BzbsApiReset, object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
                BzbsCoreApi().dtacLog(token: token, ticket: ticket, sequence: 2, successCallback: nil) { (error) in  }
                return
                
            }
            let version = Bzbs.shared.versionString
            let strVersion = Bzbs.shared.prefixApp + version
            let loginParams = DtacDeviceLoginParams(uuid: token
                , os: "ios " + UIDevice.current.systemVersion
                , platform: UIDevice.current.model
                , macAddress: UIDevice.current.identifierForVendor!.uuidString
                , deviceNotiEnable: false
                , clientVersion: strVersion
                , deviceToken: token, customInfo: ticket, language:language, DTACSegment: DTACSegment == "" ? "9999" : DTACSegment)
            
            BuzzebeesAuth().loginDtac(loginParams: loginParams, successCallback: { (user,dict) in
                self.isCallingLogin = false
                Bzbs.shared.userLogin = user
                NotificationCenter.default.post(name: Notification.Name.BzbsApiReset, object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
            }) { (error) in
                Bzbs.shared.userLogin = nil
                self.isCallingLogin = false
                NotificationCenter.default.post(name: Notification.Name.BzbsApiReset, object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
            }
        } else {
            Bzbs.shared.userLogin = nil
            self.isCallingLogin = false
            NotificationCenter.default.post(name: Notification.Name.BzbsApiReset, object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
            if let token = dtacLoginParams.token, token == "logout" { } else {
                BzbsCoreApi().dtacLog(token: "", ticket: "", sequence: 2, successCallback: nil) { (error) in  }
            }
        }
    }
    
    /// Re login with lated dtacLoginParams
    @objc public func reLogin()
    {
        NotificationCenter.default.post(name: NSNotification.Name.BzbsTokenTicketDidChange, object: nil)
    }
    
    @objc public func logout()
    {
        dtacLoginParams = DtacLoginParams(token: "logout", ticket: nil, language: nil, DTACSegment: nil)
        Bzbs.shared.userLogin = nil
        reLogin()
        backToMainView()
    }
    
    @objc public func updateLanguage(_ language:String)
    {
        if self.dtacLoginParams.language == language { return }
        self.dtacLoginParams.language = language
        NotificationCenter.default.post(name: NSNotification.Name.BzbsLanguageDidChange, object: nil)
    }
    
    @objc public func setNewMessage(newMessage isHasNewMessage:Bool = false)
    {
        self.isHasNewMessage = isHasNewMessage
    }
    
    @objc public func actionDeeplink(url :URL)
    {
        if let token = dtacLoginParams.token, token != ""{
            
            let scheme = url.scheme
            if  (scheme == "dtacapp" || scheme == "dtac" || scheme == "dtacapp-beta" || scheme == "dtac-beta") && url.host == "reward"
            {
                NotificationCenter.default.post(name: NSNotification.Name.BzbsDeeplinkAction, object: nil, userInfo: ["strUrl":url.absoluteString])
            }
        } else {
            delay(0.33) {
                self.actionDeeplink(url: url)
            }
        }
    }
    
    var isShowLoading = false
    private var timer : Timer?
    private var showLoaderDate : TimeInterval = 0
    public var defaultLoadingTime : TimeInterval = 30
    
    @objc public func showLoader(on vc:UIViewController)
    {
        if isShowLoading { return }
        isShowLoading = true
        if let window = UIApplication.shared.keyWindow {
            let vc = LoadingViewController.shared
            let height : CGFloat = UIScreen.main.bounds.size.height
            let widht : CGFloat = UIScreen.main.bounds.size.width
            vc.view.frame = CGRect(x: 0, y: 0, width: widht, height: height)
            
            if vc.parent == nil {
                window.addSubview(vc.view)
                window.bringSubviewToFront(vc.view)
            }
        }
        showLoaderDate = Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer()
    {
        if Date().timeIntervalSince1970 - showLoaderDate >= defaultLoadingTime
        {
            hideLoader()
            showLoaderDate = 0
        }
    }
    
    @objc public func hideLoader()
    {
        timer?.invalidate()
        timer = nil

        LoadingViewController.shared.view.removeFromSuperview()
        self.isShowLoading = false
    }
    
    @objc public func backToMainView()
    {
        NotificationCenter.default.post(name: NSNotification.Name.BzbsBackToMainView, object: nil)
    }
    
    func getUrlDtacMember() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlMemberLevel + "?level=1&locale=\(LocaleCore.shared.getUserLocale())&header=false"
        }
        return ""
    }
    
    func getUrlSilverMember() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlMemberLevel + "?level=2&locale=\(LocaleCore.shared.getUserLocale())&header=false"
        }
        return ""
    }
    
    func getUrlGoldMember() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlMemberLevel + "?level=4&locale=\(LocaleCore.shared.getUserLocale())&header=false"
        }
        return ""
    }
    
    
    func getUrlBlueMember() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlMemberLevel + "?level=8&locale=\(LocaleCore.shared.getUserLocale())&header=false"
        }
        return ""
    }
    
    func getUrlFAQ() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlFAQ + "?locale=\(LocaleCore.shared.getUserLocale())"
        }
        return ""
    }
    
    func getUrlAbout() -> String {
        if let webUrl = webMiscUrl{
            return webUrl + pathUrlAbout + "?locale=\(LocaleCore.shared.getUserLocale())"
        }
        return ""
    }
    
    // MARK:- Util
    // MARK:-
    func delay(_ afterDelay: Double = 0.01, callBack: @escaping () -> Void)
    {
        let delay = afterDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            callBack()
        })
    }
        
}

public extension NSNotification.Name {
    static let BzbsTokenTicketDidChange = Notification.Name("bzbsTokenTicketDidChange")
    static let BzbsApiReset = Notification.Name("bzbsApiReset")
    static let BzbsViewDidBecomeActive = Notification.Name("bzbsViewDidBecomeActive")
    static let BzbsInternetConnectionDidChange = Notification.Name("bzbsInternetConnectionDidChange")
    static let BzbsLanguageDidChange = Notification.Name("bzbsLanguageDidChange")
    static let BzbsDeeplinkAction = Notification.Name("bzbsDeeplinkAction")
    static let BzbsBackToMainView = Notification.Name("bzbsBackToMainView")
    static let BzbsUpdateNavigationBar = Notification.Name("bzbsUpdateNavigationBar")
}

enum DtacUserLevel {
    case customer
    case silver
    case gold
    case blue
    case no_level
    
    var campaignConfig :String {
        switch self {
        case .customer : return "campaign_dtac_customer_level"
        case .silver : return "campaign_dtac_silver_level"
        case .gold : return "campaign_dtac_gold_level"
        case .blue : return "campaign_dtac_blue_level"
        case .no_level : return "campaign_dtac"
        }
    }
    
    var campaignConfigAll :String {
        switch self {
        case .customer : return "campaign_dtac_customer_level_info"
        case .silver : return "campaign_dtac_silver_level_info"
        case .gold : return "campaign_dtac_gold_level_info"
        case .blue : return "campaign_dtac_blue_level_info"
        case .no_level : return "campaign_dtac"
        }
    }
    
    var string: String {
        switch self {
        case .customer : return "Customer"
        case .silver : return "Silver"
        case .gold : return "Gold"
        case .blue : return "Blue"
        case .no_level : return "No Level"
        }
    }
    
    var urlSecment:String {
        switch self {
        case .customer : return "Customer"
        case .silver : return "Silver"
        case .gold : return "Gold"
        case .blue : return "Blue"
        case .no_level : return "No Level"
        }
    }
}

extension BzbsUser
{
    var dtacLevel : DtacUserLevel {
        switch userLevel {
        case 0 :
            return .no_level
        case 2:
            return .silver
        case 4:
            return .gold
        case 8:
            return .blue
        default:
            return .customer
        }
    }
}

class DtacDeviceLoginParams : DeviceLoginParams {
    var DTACSegment:String!
    
    init(uuid: String, os: String, platform: String, macAddress: String, deviceNotiEnable: Bool, clientVersion: String, deviceToken: String?, customInfo: String?, language: String?, DTACSegment:String?) {
        super.init(uuid: uuid,
                   os: os,
                   platform: platform,
                   macAddress: macAddress,
                   deviceNotiEnable: deviceNotiEnable,
                   clientVersion: clientVersion,
                   deviceToken: deviceToken,
                   customInfo:customInfo,
                   language:language)
        
        self.DTACSegment = DTACSegment
    }
}
