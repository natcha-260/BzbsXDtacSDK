//
//  BuzzebeesExtension.swift
//  buzzebeesSDK
//
//  Created by macbookpro on 28/11/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation
import Kingfisher

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
    func withCommas(fractionDigits:Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = fractionDigits
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension UIImageView {
    func bzbsSetImage(withURL strUrl:String, isUsePlaceholder:Bool = true, completionHandler:(() -> Void)? = nil) {
        if let url = URL(string: strUrl) {
            let placeholderImage = UIImage(named: "img_placeholder", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            if strUrl.lowercased().contains(".gif") {
                self.kf.setImage(with: url, placeholder: isUsePlaceholder ?  placeholderImage : nil, options: nil, progressBlock: nil)
                { (image, error, cacheType, url) in
                    completionHandler?()
                }
                
            } else {
                af_setImage(withURL: url.convertCDNAddTime(),placeholderImage: isUsePlaceholder ?  placeholderImage : nil)
                af_setImage(withURL: url.convertCDNAddTime(), placeholderImage: isUsePlaceholder ?  placeholderImage : nil, completion:
                                { (image) in
                                    completionHandler?()
                })
            }
        } else {
            self.image = UIImage(named: "img_placeholder", in: Bzbs.shared.currentBundle, compatibleWith: nil)
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

extension BzbsDashboard
{
    class func filterDashboard(dashboard:BzbsDashboard) -> Bool{
        if let dashboardLevel = dashboard.level
        {
            let userLevel = (Bzbs.shared.userLogin?.userLevel ?? 1) & 15 // Default as customer level === 1
            return userLevel & dashboardLevel == userLevel
        }
        return true
    }
    
    class func filterDashboardWithTelType(dashboard:BzbsDashboard) -> Bool{
        if let dashboardLevel = dashboard.level
        {
            let userLevel = (Bzbs.shared.userLogin?.userLevel ?? 1) & 15 // Default as customer level === 1
            let userTeltype = Bzbs.shared.userLogin?.telType.rawValue ?? 64
            return (userLevel & dashboardLevel == userLevel) && (userTeltype & dashboardLevel == userTeltype)
        }
        return true
    }
}


extension CLLocation {
    convenience init(withCoodinate coordinate2D:CLLocationCoordinate2D) {
        self.init(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
    }
}
