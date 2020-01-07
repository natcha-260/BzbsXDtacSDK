//
//  StringExtension.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 10/10/2562 BE.
//

import UIKit

extension String {
    
    func localized() -> String {
        
        let lang = LocaleCore.shared.getUserLocale() == 1033 ? "en" : "th"
        if let wordingDict = LocaleCore.shared.wordingDict[lang]
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
