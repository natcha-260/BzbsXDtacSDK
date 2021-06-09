//
//  StringExtension.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 10/10/2562 BE.
//

import UIKit

extension String {
    
    func localized(locale _locale:Int? = nil) -> String {
        let locale = _locale ?? LocaleCore.shared.getUserLocale()
        var lang = "en"
        switch locale {
        case BBLocaleKey.en.rawValue:
            lang = "en"
        case BBLocaleKey.th.rawValue:
            lang = "th"
        case BBLocaleKey.mm.rawValue:
            lang = "mm"
        default:
            lang = "en"
        }
        if let wordingDict = LocaleCore.shared.wordingDict[lang]
        {
            if let wording = wordingDict[self]
            {
                return wording
            }
        }
        return self
    }
    
    func errorLocalized() -> String {
        let locale = LocaleCore.shared.getUserLocale()
        var lang = "en"
        switch locale {
        case BBLocaleKey.en.rawValue:
            lang = "en"
        case BBLocaleKey.th.rawValue:
            lang = "th"
        case BBLocaleKey.mm.rawValue:
            lang = "mm"
        default:
            lang = "en"
        }
        
        if let wordingDict = LocaleCore.shared.extraWordingDict[lang]
        {
            if let wording = wordingDict[self]
            {
                return wording
            }
        }
        return self
    }
    
    var htmlToAttributedString: NSMutableAttributedString? {
        let tmpString = self.replace("\n", replacement: "<br>")
        guard let data = tmpString.data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            let attr = try NSMutableAttributedString(data: data,
                                                     options: [.documentType: NSAttributedString.DocumentType.html,
                                                               .characterEncoding:String.Encoding.utf8.rawValue],
                                                     documentAttributes: nil)
            attr.addAttributes([NSAttributedString.Key.font: UIFont.mainFont()], range: NSRange(location: 0, length: attr.length))
            return attr
        } catch {
            return NSMutableAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension TimeInterval {
    func toTimeString() -> String {
        let remainingTime = Int(self)
        
        let min = remainingTime % 60
        let hour = (remainingTime / 60) % 24
        let day = (remainingTime / 60) / 24
        
        if day > 0 {
            return "\(Int(day)) " + "time_days".localized()
        }
        
        if hour > 0 {
            return "\(Int(hour)) " + "time_hours".localized()
        }
        
        return "\(Int(min)) " + "time_minutes".localized()
    }
}
