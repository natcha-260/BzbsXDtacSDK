//
//  BuzzebeesExtension.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public extension String {
    var length: Int { return self.count; }
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path);
    }
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func substringWithRange(_ start: Int, end: Int) -> String
    {
        if (start < 0 || start > self.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if end < 0 || end > self.count
        {
            print("end index \(end) out of bounds")
            return ""
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        let substring = self[startIndex..<endIndex]
        return String(substring)
    }
    
    func substringWithRange(_ start: Int, location: Int) -> String
    {
        if (start < 0 || start > self.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if location < 0 || start + location > self.count
        {
            print("end index \(start + location) out of bounds")
            return ""
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: start + location)
        let substring = self[startIndex..<endIndex]
        return String(substring)
    }
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func locationStringIndex(_ i: Int) -> String {
        return String(self[i] as Character)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension UIImageView {
    func bzbsSetImage(withURL strUrl:String) {
        if let url = URL(string: strUrl) {
            af_setImage(withURL: url.convertCDNAddTime())
        }
    }
}

extension URL {
    func convertCDNAddTime() -> URL
    {
        let strUrl = self.absoluteString
        var url = URL(string: strUrl)!
        
        if let host = url.host, host == "buzzebees.blob.core.windows.net"
        {
            let newStrUrl = strUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
            if let newUrl = URL(string: newStrUrl)
            {
                url = newUrl
            }
        }
        
        if !url.absoluteString.contains("time=") {
            var newStrUrl = url.absoluteString
            let date = Date()
            var dateString = date.toString(format: "ddMMyyyyHH")
            var min = Int(date.toString(format: "mm")) ?? 0
            
            switch min {
            case 0..<15:
                min = 0
                break
            case 15..<30:
                min = 15
                break
            case 30..<45:
                min = 30
                break
            default:
                min = 45
            }
            
            dateString = dateString + "\(min)"
            
            if !newStrUrl.contains("?")
            {
                newStrUrl = newStrUrl + "?time=" + dateString
                if let newUrl = URL(string: newStrUrl)
                {
                    url = newUrl
                }
            } else {
                newStrUrl = newStrUrl + "&time=" + dateString
                if let newUrl = URL(string: newStrUrl)
                {
                    url = newUrl
                }
            }
        }
        return url
    }
}
