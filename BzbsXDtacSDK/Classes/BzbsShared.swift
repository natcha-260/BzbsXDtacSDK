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
    
    var dtacLoginParams = DtacLoginParams() {
        didSet{
            NotificationCenter.default.post(name: NSNotification.Name.BzbsTokenTicketDidChange, object: nil)
        }
    }
    @objc public var delegate: BzbsDelegate?
    @objc public var isHasNewMessage :Bool = false
    
    var apiPrefix:String?// = "https://dev.buzzebees.com"
    private var webMiscUrl:String?{
        BuzzebeesCore.miscUrl
    }
    var blobUrl:String?{
        BuzzebeesCore.blobUrl
    }
    private let pathUrlMemberLevel = "/DTW/level-info.aspx"
    private let pathUrlFAQ = "/DTW/faq.aspx"
    private let pathUrlAbout = "/DTW/about-us.aspx"
    
    @objc public var versionString :String = "0.0.3"
    let agencyID = "110807"
    let prefixApp = "ios_dtw"
    
    @objc public var isDebugMode = false
    var userLogin: BzbsUser?
    var arrCategory :[BzbsCategory]?
    var blueCategory : BzbsCategory?
    var deepLinkUrl : URL?
    
    var currentBundle : Bundle {
        let bundle = Bundle(for: BzbsMainViewController.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("BzbsXDtacSDK.bundle"),
            let resourceBundle = Bundle(url: bundleURL)
            else {
                return Bundle.main
        }
        
        return resourceBundle
    }
    
    @objc public func setup(token:String, ticket:String, language:String, delegate:BzbsDelegate? = nil, isHasNewMessage:Bool = true){
        var loginParams = DtacLoginParams()
        loginParams.token = token
        loginParams.ticket = ticket
        loginParams.language = language
        
        self.dtacLoginParams = loginParams
        self.isHasNewMessage = isHasNewMessage
        if delegate != nil {
            self.delegate = delegate
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
    
    @objc public func login(token:String, ticket:String, language:String)
    {
        login(token: token, ticket: ticket, language: language, completionHandler: nil, failureHandler: nil)
    }
    
    func login(token:String, ticket:String, language:String, completionHandler:(() -> Void)? = nil, failureHandler:((BzbsError) -> Void)? = nil)
    {
        if isCallingLogin { return }
        isCallingLogin = true
        if !BuzzebeesCore.isSetEndpoint
        {
            BuzzebeesCore.apiSetupPrefix(successCallback: {
                self.isCallingLogin = false
                self.login(token:token, ticket:ticket, language:language, completionHandler: completionHandler, failureHandler: failureHandler)
            }) {
                self.isCallingLogin = false
            }
            return
        }
        
        Bzbs.shared.dtacLoginParams = DtacLoginParams(token: token, ticket: ticket, language: language)
        
        if let token = dtacLoginParams.token, token != "",
            let ticket = dtacLoginParams.ticket, ticket != "",
            let language = dtacLoginParams.language
        {
            let version = Bzbs.shared.versionString
            let strVersion = Bzbs.shared.prefixApp + version
            let loginParams = DeviceLoginParams(uuid: token
                , os: "ios " + UIDevice.current.systemVersion
                , platform: UIDevice.current.model
                , macAddress: UIDevice.current.identifierForVendor!.uuidString
                , deviceNotiEnable: false
                , clientVersion: strVersion
                , deviceToken: token, customInfo: ticket, language:language)
            
            BuzzebeesAuth().login(loginParams: loginParams, successCallback: { (user,dict) in
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
        }
    }
    
    /// Re login with lated dtacLoginParams
    @objc public func reLogin()
    {
        NotificationCenter.default.post(name: NSNotification.Name.BzbsTokenTicketDidChange, object: nil)
    }
    
    @objc public func logout()
    {
        dtacLoginParams = DtacLoginParams()
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
            if  (scheme == "dtacapp" || scheme == "dtac" || scheme == "dtacapp-beta") && url.host == "reward"
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
        if isShowLoading || vc.presentedViewController != nil { return }
        isShowLoading = true
        LoadingViewController.shared.modalPresentationStyle = .overFullScreen
        vc.present(LoadingViewController.shared, animated: false, completion: nil)
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
        
        LoadingViewController.shared.dismiss(animated: false) {
            self.isShowLoading = false
        }
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
