//
//  BuzzebeesCore.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Alamofire

/**
 Core of Buzzebees api object
 */
public class BuzzebeesCore: NSObject {
    public var isDebugMode: Bool! {
        get {
            return Bzbs.shared.isDebugLog
        }
        set {
            Bzbs.shared.isDebugLog = newValue
        }
    }
    public var appId = "353144231924127"
    public var strSubscriptionKey: String?
    
    public static let sessionManager :Session! = {
        let configuration :URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return Alamofire.Session(configuration: configuration)
    }()
    
    static var isSetEndpoint = false
    static var isCallingSetEndpoint = false
    static var apiUrl: String! = ""
    static var blobUrl : String! = ""
    static var miscUrl : String! = ""
    static var shareUrl : String! = ""
    static var inquiryBaseUrl : String! = ""
    static var redeemBaseUrl : String! = ""
    
    static var urlSegmentImageDtac : URL?
    static var urlSegmentImageSilver : URL?
    static var urlSegmentImageGold : URL?
    static var urlSegmentImageBlue : URL?
    static var urlDeeplinkHistory : URL?
    
    static var levelNameDtac = ""
    static var levelNameSilver = ""
    static var levelNameGold = ""
    static var levelNameBlue = ""
    
    static var cacheTimeSegment:TimeInterval = Date().timeIntervalSince1970 + (10 * 60)
    static var cacheTimeQuota:TimeInterval = Date().timeIntervalSince1970 + (5 * 60)
    
    let appName = "dtac"
    let agencyID = "110807"
    let prefixApp = "ios_dtw"
    static var catIdCoin : Int! = 9442854 // default as Dev env.
    static var catIdVoiceNet : Int! = 9439718 // default as stgDessert.
    static var catIdLineSticker : Int! = 9441868 // default as stgDessert.
    
    public override init() {
        super.init()
    }
    
    class func apiSetupPrefix(successCallback:@escaping () -> Void, failCallback:@escaping () -> Void)
    {
//        if isCallingSetEndpoint {
//            successCallback()
//            return
//        }
//        isCallingSetEndpoint = true
        let startTime = Date()
        let version = Bzbs.shared.versionString
        let endpointUrl = "https://apidtw.buzzebees.com/api/config/353144231924127_config_ios_\(version)/blob/"
        guard let url = URL(string:endpointUrl) else {
            failCallback()
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        BuzzebeesCore.sessionManager.request(urlRequest).responseJSON { response in
            do{
                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                if Bzbs.shared.isDebugLog {
                    Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                    print("**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                }
                guard let rawData = response.data else {
                    failCallback()
                    return
                }
                let json = try JSONSerialization.jsonObject(with: rawData, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let dictJSON = json as? Dictionary<String, AnyObject>  {

                    if let dtacLevel = dictJSON["dtac_label"] as? String
                    {
                        levelNameDtac = dtacLevel
                    }
                    
                    if let silverLevel = dictJSON["silver_label"] as? String
                    {
                        levelNameSilver = silverLevel
                    }
                    
                    if let goldLevel = dictJSON["gold_label"] as? String
                    {
                        levelNameGold = goldLevel
                    }
                    
                    if let blueLevel = dictJSON["blue_label"] as? String
                    {
                        levelNameBlue = blueLevel
                    }
                    
                    if let dtacUrl = dictJSON["dtac_image_url"] as? String
                    {
                        urlSegmentImageDtac = URL(string: dtacUrl)
                    }
                    
                    if let silverUrl = dictJSON["silver_image_url"] as? String
                    {
                        urlSegmentImageSilver = URL(string: silverUrl)
                    }
                    
                    if let goldUrl = dictJSON["gold_image_url"] as? String
                    {
                        urlSegmentImageGold = URL(string: goldUrl)
                    }
                    
                    if let blueUrl = dictJSON["blue_image_url"] as? String
                    {
                        urlSegmentImageBlue = URL(string: blueUrl)
                    }
                    
                    if let deeplink = dictJSON["deeplink"] as? String {
                        urlDeeplinkHistory = URL(string: deeplink)
                    }

                    if let cacheConfig = dictJSON["cache"] as? Dictionary<String, AnyObject> {
                        if let cacheTimeSegment = cacheConfig["segment"] as? Int
                        {
                            let cacheDateSegment = Date().timeIntervalSince1970 + TimeInterval(cacheTimeSegment * 60)
                            self.cacheTimeSegment = cacheDateSegment
                        }
                        
                        if let cacheTimeQuota = cacheConfig["quota"] as? Int
                        {
                            let cacheDateQuota = Date().timeIntervalSince1970 + TimeInterval(cacheTimeQuota * 60)
                            self.cacheTimeQuota = cacheDateQuota
                        }
                    }
                    
                    if let catIdCoin = BuzzebeesConvert.IntFromObject(dictJSON["category_coin"]) {
                        BuzzebeesCore.catIdCoin = catIdCoin
                    }
                    
                    if let catIdVoiceNet = BuzzebeesConvert.IntFromObject(dictJSON["sub_category_voice_net"]){
                        BuzzebeesCore.catIdVoiceNet = catIdVoiceNet
                    }
                    
                    if let catIdLineSticker = BuzzebeesConvert.IntFromObject(dictJSON["sub_category_line_sticker"]){
                        BuzzebeesCore.catIdLineSticker = catIdLineSticker
                    }
                    
                    if let blobUrl = dictJSON["url_blob"] as? String ,
                        let baseUrl = dictJSON["url_base"] as? String ,
                        let miscUrl = dictJSON["url_misc"] as? String ,
                        let shareUrl = dictJSON["url_share"] as? String ,
                        let inquiryBaseUrl = dictJSON["url_base_inquiry"] as? String ,
                        let redeemBaseUrl = dictJSON["url_base_redeem"] as? String
                    {
                        BuzzebeesCore.blobUrl = blobUrl
                        BuzzebeesCore.apiUrl = baseUrl
                        BuzzebeesCore.miscUrl = miscUrl
                        BuzzebeesCore.shareUrl = shareUrl
                        BuzzebeesCore.inquiryBaseUrl = inquiryBaseUrl
                        BuzzebeesCore.redeemBaseUrl = redeemBaseUrl
                        
                        if BuzzebeesCore.blobUrl.last == "/" {
                            BuzzebeesCore.blobUrl.removeLast()
                        }
                        
                        if BuzzebeesCore.apiUrl.last == "/" {
                            BuzzebeesCore.apiUrl.removeLast()
                        }
                        
                        if BuzzebeesCore.miscUrl.last == "/" {
                            BuzzebeesCore.miscUrl.removeLast()
                        }
                        
                        if BuzzebeesCore.shareUrl.last == "/" {
                            BuzzebeesCore.shareUrl.removeLast()
                        }
                        
                        if BuzzebeesCore.inquiryBaseUrl.last == "/" {
                            BuzzebeesCore.inquiryBaseUrl.removeLast()
                        }
                        
                        if BuzzebeesCore.redeemBaseUrl.last == "/" {
                            BuzzebeesCore.redeemBaseUrl.removeLast()
                        }
                        
                        if let languageUrl = dictJSON["language"] as? Dictionary<String,AnyObject>
                        {
                            getLanguage(languageUrl, successCallback: successCallback, failCallback: failCallback)
                            isCallingSetEndpoint = false
                        } else {
                            failCallback()
                            isSetEndpoint = true
                            isCallingSetEndpoint = false
                        }
                        
                    } else {
                        failCallback()
                    }
                } else {
                   failCallback()
               }
            } catch _ as NSError {
                isCallingSetEndpoint = false
                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                if Bzbs.shared.isDebugLog {
                    Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                    print("**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                }
                failCallback()
            }
        }
    }
    
    class func getLanguage(_ languageDict:Dictionary<String,AnyObject>, successCallback:@escaping () -> Void, failCallback:@escaping () -> Void){
        if let language = Convert.IntFromObject(languageDict["version"])
        {
            let userDefault = UserDefaults.standard
            let languageKey = "bzbs_langauge_\(language)"
            if let languageDict = userDefault.object(forKey: languageKey) as? Dictionary<String,AnyObject>
            {
                LocaleCore.shared.generateExtraWordingString(languageDict)
                isSetEndpoint = true
                successCallback()
            } else {
                if let strUrl = languageDict["file"] as? String,
                    let url = URL(string: strUrl)
                {
                    let startTime = Date()
                    let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
                    BuzzebeesCore.sessionManager.request(urlRequest).responseJSON { (response) in
                        do {
                            let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                            if Bzbs.shared.isDebugLog {
                                Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(strUrl) === : \(String(format:"%.2f sec",resposeTime))")
                                print("**response time =====\(strUrl) === : \(String(format:"%.2f sec",resposeTime))")
                            }
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            if let dictJSON = json as? Dictionary<String, AnyObject>  {
                                userDefault.set(dictJSON, forKey: languageKey)
                                
                                LocaleCore.shared.generateExtraWordingString(dictJSON)
                                isSetEndpoint = true
                                successCallback()
                            } else {
                                failCallback()
                            }
                        } catch _ as NSError {
                            let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                            if Bzbs.shared.isDebugLog {
                                Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(strUrl) === : \(String(format:"%.2f sec",resposeTime))")
                                print("**response time =====\(strUrl) === : \(String(format:"%.2f sec",resposeTime))")
                            }
                            failCallback()
                        }
                    }
                } else {
                    failCallback()
                }
            }
        }
    }
    
    func haveErrorFromDict(dict: Dictionary<String, AnyObject>, failCallback: @escaping (_ error: BzbsError) -> Void) -> Bool {
        if let itemError = dict["error"] as? Dictionary<String, AnyObject> {
            let id = BuzzebeesConvert.StringFromObject(itemError["id"] as AnyObject?)
            let code = BuzzebeesConvert.StringFromObject(itemError["code"] as AnyObject?)
            let message = BuzzebeesConvert.StringFromObject(itemError["message"] as AnyObject?)
            let type = BuzzebeesConvert.StringFromObject(itemError["type"] as AnyObject?)
            
            // ถ้าเป็น force logout จะไม่ callback ไปทาง fail แต่จะยิง noti ออกไปให้โชว์ popup แล้ว logout
            if code == "409" {
                // id 1905: Session Expire
                // id 2076: Force Logout
                if id == "1905"
                {
                    let error = BzbsError(strId: id, strCode: code, strType: type, strMessage: "session expire")
                    failCallback(error)
                    return true
                } else if id == "2076" {
                    let error = BzbsError(strId: id, strCode: code, strType: type, strMessage: "force logout")
                    failCallback(error)
                    return true
                }
            }
            
            let error = BzbsError(strId: id, strCode: code, strType: type, strMessage: message)
            failCallback(error)
            return true
        }
        
        return false
    }
    
    func serverSendDataWrongFormat(failCallback: @escaping (_ error: BzbsError) -> Void) {
        let error = BzbsError(strId: "-9999", strCode: "-9999", strType: "framework send", strMessage: "data wrong format")
        failCallback(error)
    }
    
    func requestAlamofire(_ method: HTTPMethod
        , strURL: String
        , params: [String: AnyObject]?
        , headers:[String: String]? = nil
        , successCallback: @escaping (AnyObject) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        // Add appId all api
        let startTime = Date()
        var itemParams = params
        if(itemParams == nil) {
            itemParams = [String: String]() as [String : AnyObject]?
        }
//        itemParams!["app_id"] = self.appId as AnyObject?
//        itemParams!["device_app_id"] = self.appId as AnyObject?
        if let dtacId = Bzbs.shared.userLogin?.uuid
        {
            itemParams!["dtac_id"] = dtacId as AnyObject
        }
        
        // Add Ocp-Apim-Subscription-Key
        var itemHeaders :HTTPHeaders = HTTPHeaders(headers ?? [String:String]())
        itemHeaders["App-id"] = self.appId
        
        if let subKey = strSubscriptionKey
        {
            itemHeaders["Ocp-Apim-Subscription-Key"] = subKey
        }
        
        if self.isDebugMode {
            var stringLog = ""
            stringLog = stringLog + "\r\n//\(startTime.toString()) =============================="
            stringLog = stringLog + "\nMethod:= \(method.rawValue)"
            stringLog = stringLog + "\nURL:= " + strURL
            stringLog = stringLog + "\nParams:= "
            
            if let paramsTemp = itemParams {
                for item in paramsTemp {
                    if let value = item.value as? String {
                        stringLog = stringLog + "\n" + item.key + ":" + value
                    } else {
                        stringLog = stringLog + "\n" + item.key + ":" + String(describing: item.value)
                    }
                }
            }
            
            stringLog = stringLog + "\n"
            stringLog = stringLog + "\nHeader:= "
            for headersTemp in itemHeaders {
                stringLog = stringLog + "\n" + headersTemp.name + ":" + (headersTemp.value)
                print()
            }
            stringLog = stringLog + "\n//==============================\r\n"
            print(stringLog)
            Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + stringLog)
        }
        
        BuzzebeesCore.sessionManager.request(strURL, method: method, parameters: itemParams, encoding: URLEncoding(destination:.methodDependent), headers: itemHeaders)
           .responseJSON { response in
                do{
                    guard let rawData = response.data else {
                        self.serverSendDataWrongFormat(failCallback: failCallback)
                        return
                    }
                    let json = try JSONSerialization.jsonObject(with: rawData, options: JSONSerialization.ReadingOptions.mutableContainers)

                    if self.isDebugMode {
                        let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                        Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                        print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                    }
                    if let dictJSON = json as? Dictionary<String, AnyObject>  {
                        // Check error azure portal
                        if let statusCode = dictJSON["statusCode"] as? Int {
                            if let statusMessage = dictJSON["message"] as? String {
                                let error = BzbsError(strId: "-9999", strCode: String(statusCode), strType: "framework send", strMessage: statusMessage)
                                failCallback(error)
                                return
                            }
                        }
                        
                        if(self.haveErrorFromDict(dict: dictJSON, failCallback: failCallback) == false) {
                            successCallback(json as AnyObject)
                        }
                    } else if let arrJson = json as? [Dictionary<String, AnyObject>]  {
                        successCallback(arrJson as AnyObject)
                    } else{
                        successCallback(json as AnyObject)
                    }
                } catch _ as NSError {
                    // work around support server success than not return data, use check status code
                    if let statusCode = response.response?.statusCode {
                        // 200: Success, 204: No content
                        if statusCode == 200 || statusCode == 204 {
                            if self.isDebugMode {
                                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                                Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                                print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                            }
                            successCallback("Success" as AnyObject)
                            return
                        }
                    }
                    
                    var statusCode = "-9999"
                    var message = "json serialization error"
                    
                    if let resultError = response.error,
                       let responseCode = resultError.responseCode,
                       let errorDescription = resultError.errorDescription
                    {
                        statusCode = "\(responseCode)"
                        message = errorDescription
                    }
                    
                    if self.isDebugMode {
                        let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                        Bzbs.shared.delegate?.analyticsScreen(screenName: "log\n" + "**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                        print("**response time =====\(strURL) ===  : \(String(format:"%.2f sec",resposeTime))")
                    }
                    let error = BzbsError(strId: "-9999", strCode: statusCode, strType: "framework send", strMessage: message)
                    failCallback(error)
                }
        }
    }
    
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using:.utf8, allowLossyConversion: false)
        return request
    }
    
}
