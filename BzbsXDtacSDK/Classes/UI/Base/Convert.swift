//
//  Convert.swift
//  BeerLao_iOS
//
//  Created by macbookpro on 10/2/2558 BE.
//  Copyright (c) 2015 wongsakorn.s. All rights reserved.
//

import Foundation

open class Convert
{
    // MARK: Object
    open class func StringFromObject(_ ao: AnyObject?) -> String?
    {
        if(ao == nil)
        {
            return nil
        }
        
        if let itemStr = ao as? String
        {
            return itemStr.trim()
        }
        
        if let itemInt = ao as? Int
        {
            return String(itemInt).trim()
        }
        
        if let itemFloat = ao as? Float
        {
            return (NSString(format: "%.2f", itemFloat) as String).trim()
        }
        
        return nil
    }
    
    open class func StringFromObjectNotNull(_ ao: AnyObject?) -> String
    {
        if(ao == nil)
        {
            return ""
        }
        
        if let str = StringFromObject(ao)
        {
            return str
        }
        
        return ""
    }
    
    open class func BoolFromObject(_ ao: AnyObject?) -> Bool?
    {
        if(ao == nil)
        {
            return nil
        }
        
        if let itemBool = ao as? Bool
        {
            return itemBool
        }
        
        if let itemFloat = ao as? Float
        {
            return itemFloat == 1.0
        }
        
        if let itemInt = ao as? Int
        {
            return itemInt == 1
        }
        
        if let itemStr = ao as? String
        {
            switch itemStr {
            case "True", "true", "yes", "1":
                return true
            case "False", "false", "no", "0":
                return false
            default:
                return nil
            }
        }
        
        return nil
    }
    
    open class func DoubleFromObject(_ ao: AnyObject?) -> Double?
    {
        if(ao == nil)
        {
            return Double(0)
        }
        
        if let itemDouble = ao as? Double
        {
            return itemDouble
        }
        
        if let itemInt = ao as? Int
        {
            return Double(itemInt)
        }
        
        if let itemFloat = ao as? Float
        {
            return Double(itemFloat)
        }
        
        if let str = ao as? String
        {
            return (str as NSString).doubleValue
        }
        
        return nil
    }
    
    open class func IntFromObject(_ ao: AnyObject?) -> Int?
    {
        if(ao == nil)
        {
            return 0
        }
        
        if let itemInt = ao as? Int
        {
            return itemInt
        }
        
        if let itemFloat = ao as? Float
        {
            return Int(itemFloat)
        }
        
        if let str = ao as? String
        {
            return Int(str)
        }
        
        return 0
    }
    
    open class func Int64FromObject(_ ao: AnyObject?) -> UInt64?
    {
        if(ao == nil)
        {
            return 0
        }
        
        if let itemInt = ao as? UInt64
        {
            return itemInt
        }
        
        if let itemFloat = ao as? Float
        {
            return UInt64(itemFloat)
        }
        
        if let str = ao as? String
        {
            return UInt64(str)
        }
        
        return 0
    }
    
    open class func DictionaryFromJSON(_ ao : AnyObject) -> [String: AnyObject]? {
        return ao as? [String: AnyObject]
    }
    
    /**
    Json To String
    */
    open class func JSONStringify(_ value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions!
        if(prettyPrinted)
        {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }else{
            options = nil
        }
        
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: options) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    open class func DateToString(_ dateValue: Date, stringFormat: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringFormat
        
        //TODO : ios8
//        let gregorian = NSCalendar(calendarIdentifier: NSBuddhistCalendar)
        let gregorian = Calendar(identifier: Calendar.Identifier.buddhist)
        dateFormatter.calendar = gregorian
        
        let nsLocale = generate_NSLocale_from_base_locale_code("th_TH")
        dateFormatter.locale = nsLocale
        
        return dateFormatter.string(from: dateValue)
    }
    
    /**
    NSLocale With String
    */
    open class func generate_NSLocale_from_base_locale_code(_ pStrWindowsLocaleCode: String) -> Foundation.Locale
    {
        return Foundation.Locale(identifier: pStrWindowsLocaleCode)
    }
}
