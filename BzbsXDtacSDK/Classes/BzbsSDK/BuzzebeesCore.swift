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
    public var isDebugMode: Bool! = true
    public var appId = "353144231924127"
    public var strSubscriptionKey: String?
    
    static var isSetEndpoint = false
    static var apiUrl: String! = ""
    static var blobUrl : String! = ""
    static var miscUrl : String! = ""
    static var shareUrl : String! = ""
    
    static var urlSegmentImageDtac : URL?
    static var urlSegmentImageSilver : URL?
    static var urlSegmentImageGold : URL?
    static var urlSegmentImageBlue : URL?
    
    static var levelNameDtac = ""
    static var levelNameSilver = ""
    static var levelNameGold = ""
    static var levelNameBlue = ""
    
    let appName = "dtac"
    let agencyID = "110807"
    let prefixApp = "ios_dtw"
    
    public override init() {
        super.init()
    }
    
    class func apiSetupPrefix(successCallback:@escaping () -> Void, failCallback:@escaping () -> Void)
    {
        let startTime = Date()
        let version = Bzbs.shared.versionString
        let endpointUrl = "https://apidtw.buzzebees.com/api/config/353144231924127_config_ios_\(version)/blob/"
        guard let url = URL(string:endpointUrl) else {
            failCallback()
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request(urlRequest).responseJSON { response in
            do{
                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                print("**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
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
                    
                    if let blobUrl = dictJSON["url_blob"] as? String ,
                        let baseUrl = dictJSON["url_base"] as? String ,
                        let miscUrl = dictJSON["url_misc"] as? String ,
                        let shareUrl = dictJSON["url_share"] as? String
                    {
                        BuzzebeesCore.blobUrl = blobUrl
                        BuzzebeesCore.apiUrl = baseUrl
                        BuzzebeesCore.miscUrl = miscUrl
                        BuzzebeesCore.shareUrl = shareUrl
                        
                        if BuzzebeesCore.blobUrl .last == "/" {
                            BuzzebeesCore.blobUrl .removeLast()
                        }
                        
                        if BuzzebeesCore.apiUrl .last == "/" {
                            BuzzebeesCore.apiUrl .removeLast()
                        }
                        
                        if BuzzebeesCore.miscUrl .last == "/" {
                            BuzzebeesCore.miscUrl .removeLast()
                        }
                        
                        if BuzzebeesCore.shareUrl .last == "/" {
                            BuzzebeesCore.shareUrl .removeLast()
                        }
                        
                        
                        isSetEndpoint = true
                        successCallback()
                        return
                    }
                }
                failCallback()
            } catch _ as NSError {
                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                print("**response time =====\(endpointUrl) === : \(String(format:"%.2f sec",resposeTime))")
                failCallback()
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
        itemParams!["app_id"] = self.appId as AnyObject?
        itemParams!["device_app_id"] = self.appId as AnyObject?
        if let dtacId = Bzbs.shared.userLogin?.uuid
        {
            itemParams!["dtac_id"] = dtacId as AnyObject
        }
        
        // Add Ocp-Apim-Subscription-Key
        var itemHeaders = headers ?? HTTPHeaders()
        itemHeaders["App-id"] = self.appId
        
        if let subKey = strSubscriptionKey
        {
            itemHeaders["Ocp-Apim-Subscription-Key"] = subKey
        }
        
        if(self.isDebugMode) {
            print("\r\n//\(startTime.toString()) ==============================")
            print("Method:= \(method.rawValue)")
            print("URL:= " + strURL)
            print("Params:= ")
            
            if let paramsTemp = itemParams {
                for item in paramsTemp {
                    if let value = item.value as? String {
                        print(item.key + ":" + value)
                    } else {
                        print(item.key + ":" + String(describing: item.value))
                    }
                }
            }
            
            print("")
            print("Header:= ")
            for headersTemp in itemHeaders {
                print(headersTemp.key + ":" + (headersTemp.value))
            }
            print("//==============================\r\n")
        }
        
        request(strURL, method: method, parameters: itemParams, encoding: URLEncoding(destination: .methodDependent), headers: itemHeaders)
            .responseJSON { response in
                do{
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
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
                            if(self.isDebugMode) {
                                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                                print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                            }
                            successCallback(json as AnyObject)
                        }
                    } else if let arrJson = json as? [Dictionary<String, AnyObject>]  {
                        if(self.isDebugMode) {
                            let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                            print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                        }
                        successCallback(arrJson as AnyObject)
                    } else{
                        if(self.isDebugMode) {
                            let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                            print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                        }
                        successCallback(json as AnyObject)
                    }
                } catch _ as NSError {
                    // work around support server success than not return data, use check status code
                    if let statusCode = response.response?.statusCode {
                        // 200: Success, 204: No content
                        if statusCode == 200 || statusCode == 204 {
                            if(self.isDebugMode) {
                                let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                                print("**response time =====\(strURL) === : \(String(format:"%.2f sec",resposeTime))")
                            }
                            successCallback("Success" as AnyObject)
                            return
                        }
                    }

                    if(self.isDebugMode) {
                        let resposeTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                        print("**response time =====\(strURL) ===  : \(String(format:"%.2f sec",resposeTime))")
                    }
                    let error = BzbsError(strId: "-9999", strCode: "-9999", strType: "framework send", strMessage: "json serialization error")
                    failCallback(error)
                }
        }
    }
    
    func requestAlamofireUpload(_ strURL: String
        , uiImage: UIImage
        , strKeyImage: String
        , params: Dictionary<String, AnyObject>
        , headers:[String: String]? = nil
        , successCallback: @escaping (AnyObject) -> Void
        , failCallback: @escaping (_ error: BzbsError) -> Void) {
        
        // Add appId all api
        var itemParams = params
        itemParams["device_app_id"] = self.appId as AnyObject?
        itemParams["app_id"] = self.appId as AnyObject?
        
        // Add Ocp-Apim-Subscription-Key
        var itemHeaders = headers
        if(itemHeaders == nil) {
            itemHeaders = HTTPHeaders()
        }
        itemHeaders!["Ocp-Apim-Subscription-Key"] = self.strSubscriptionKey
        
        if(isDebugMode == true) {
            print("\r\n//==============================")
            print("URL:= " + strURL)
            print("Params:= ")
            
            for item in itemParams {
                if let value = item.value as? String
                {
                    print(item.key + ":" + value)
                } else {
                    print(item.key + ":" + String(describing: item.value))
                }
            }
            
            if let item = itemHeaders {
                print("")
                print("Header:= ")
                for headersTemp in item
                {
                    print(headersTemp.key + ":" + (headersTemp.value))
                }
                print("//==============================\r\n")
            }
        }
        
        let imageData = uiImage.pngData()
        
        upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: strKeyImage, mimeType: "image/png")
                
                for (key, value) in params {
                    if let valueData = value as? String
                    {
                        multipartFormData.append(valueData.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
        },
            to: strURL,
            headers: itemHeaders,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        do{
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
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
                                    successCallback("Success" as AnyObject)
                                    return
                                }
                            }
                            
                            let error = BzbsError(strId: "-9999", strCode: "-9999", strType: "framework send", strMessage: "json serialization error")
                            failCallback(error)
                        }
                    }
                case .failure( _):
                    let error = BzbsError(strId: "-9999", strCode: "-9999", strType: "framework send", strMessage: "json serialization error")
                    failCallback(error)
                }
        }
        )
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
