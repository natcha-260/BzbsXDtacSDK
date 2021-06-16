//
//  LocaleCore.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 11/30/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//


import UIKit

class LocaleCore: BBLocale {
    // MARK: Singleton Pattern
    static var shared: LocaleCore! = LocaleCore()
    
    override init() {
        super.init()
        loadLanguageString()
    }

    // MARK: Private Variables For Class
//    let _appDelegate = UIApplication.shared.delegate as! AppDelegate

//    func getMessageFromError(_ errorCode:String, message:String) -> String{
//        return getMessageFromServer(key: message)
//    }
//
//    // MARK: Get Message Text
//    func getMessageFromServer(key: String) -> String
//    {
//        if key == "Your points are not enough to redeem this reward." || key == "คุณมีจำนวน Point ไม่เพียงพอสำหรับการรับสิทธิพิเศษนี้"
//        {
//            return language(string: "message_points_not_enough")
//        } else if key == "Invalid Username or Password" {
//            return language(string: "message_invalid_username_or_password")
//        } else if key == "This username has already been taken."
//        {
//            return language(string: "val_duplicate_number")
//        } else if key == "crash NSJSONSerialization"
//        {
//            return language(string: "val_general_error")
//        }
//        return key
//    }

    func getUserLocale() -> Int
    {
//        // ถ้า profile.userid ไม่มี ไปใช้ login
//        var localeKey = _appDelegate.userLogin.locale
//        if(_appDelegate.userLogin.userId != nil)
//        {
//            localeKey = _appDelegate.userLogin.locale
//        }
//
//        if(_appDelegate.userProfile.userId != nil)
//        {
//            localeKey = _appDelegate.userProfile.locale!
//        }
        
        if let userLogin = Bzbs.shared.userLogin{
            return userLogin.locale
        } else if let language = Bzbs.shared.dtacLoginParams.language
        {
            if language == "th" {
                return 1054
            } else if language == "mm" || language == "my" {
                return 1109
            } else {
                return 1033
            }
        }

        return 1033
    }

    func getLocaleAndCalendar() -> (locale: Locale, calendar: Calendar)
    {
        var locale = Locale(identifier: "en_EN")
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        if (LocaleCore.shared.getUserLocale() ==  BBLocaleKey.th.rawValue)
        {
            locale = Locale(identifier: "th_TH")
            calendar =  Calendar(identifier: Calendar.Identifier.buddhist)
        }

        return (locale, calendar)
    }

//    func language(string:String) -> String
//    {
//        return self.languageSelectedStringForKey(string, localeKey: getUserLocale())
//    }
    
}


/**
 Enum ของ LocaleKey
 */
public enum BBLocaleKey: Int {
    /**
     ไทย
     */
    case th = 1054
    /**
     อังกฤษ
     */
    case en = 1033
    /**
     พม่า
     */
    case mm = 1109
}
/**
 เกี่ยวกับภาษา
 */
open class BBLocale: NSObject
{
    public override init()
    {
        print("init BBLocale");
    }
    /**
     ดึงข้อความตามภาษาที่เลือก
     */
//    open func languageSelectedStringForKey(_ key: String, localeKey: Int = BBLocaleKey.en.rawValue) -> String
//    {
//        let path = getPathLanguage(localeKey)
//        if let languageBundle = Bundle(path: path) {
//            if !languageBundle.isLoaded
//            {
//                languageBundle.load()
//            }
//            return NSLocalizedString(key, comment: "")// languageBundle.localizedString(forKey: key, value: "", table: nil)
//        }
//        return key
//    }
//    /**
//     get path ของไฟล์ภาษา
//     */
//    fileprivate func getPathLanguage(_ pIntLocale: Int) -> String
//    {
//        let bundle = Bzbs.shared.currentBundle
//        if(pIntLocale == BBLocaleKey.th.rawValue)
//        {
//            return bundle.path(forResource: "th", ofType: "lproj")!;
//        }
//        else{
//            return bundle.path(forResource: "en", ofType: "lproj")!;
//        }
//    }
//    /**
//     get key ของภาษา
//     */
//    open func getWindowLocaleCode(_ key: String) -> String
//    {
//        let uint_window_locale_code = Foundation.Locale.windowsLocaleCode(fromIdentifier: key);
//
//        return String(describing: uint_window_locale_code);
//    }
    
    var wordingDict = Dictionary<String,Dictionary<String,String>>()
    var extraWordingDict = Dictionary<String,Dictionary<String,String>>()
    func loadLanguageString()
    {
        let mainBundle = Bzbs.shared.currentBundle
        
        if let url = mainBundle.url(forResource: "en_Localized", withExtension: "json") {
            do {
                let raw = try String(contentsOf: url, encoding: String.Encoding.utf8)
                if let data = raw.data(using: String.Encoding.utf8)
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let dict = json as? Dictionary<String,String>
                    {
                        wordingDict["en"] = dict
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        
        if let url = mainBundle.url(forResource: "th_Localized", withExtension: "json") {
            do {
                let raw = try String(contentsOf: url, encoding: String.Encoding.utf8)
                if let data = raw.data(using: String.Encoding.utf8)
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let dict = json as? Dictionary<String,String>
                    {
                        wordingDict["th"] = dict
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        
        if let url = mainBundle.url(forResource: "mm_Localized", withExtension: "json") {
            do {
                let raw = try String(contentsOf: url, encoding: String.Encoding.utf8)
                if let data = raw.data(using: String.Encoding.utf8)
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let dict = json as? Dictionary<String,String>
                    {
                        wordingDict["mm"] = dict
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func generateExtraWordingString(_ dict:Dictionary<String,AnyObject>)
    {
        extraWordingDict = Dictionary<String,Dictionary<String,String>>()
        extraWordingDict["th"] = Dictionary<String,String>()
        extraWordingDict["en"] = Dictionary<String,String>()
        extraWordingDict["mm"] = Dictionary<String,String>()
        
        for key in dict.keys{
            if let word = dict[key]
            {
                if let en = word["EN"] as? String ,
                    let th = word["TH"] as? String
                {
                    extraWordingDict["th"]![key] = th
                    extraWordingDict["en"]![key] = en
                    extraWordingDict["mm"]![key] = en
                }
            }
        }
    }
}
