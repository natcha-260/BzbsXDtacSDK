//
//  UIFontExtension.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit

public enum FontSize : CGFloat{
    public typealias RawValue = CGFloat
    
    case categorySize = 12
    case xxsmall = 7
    case xsmall = 10
    case small = 13
    case normal = 15
    case big = 17
    case dtacHeaderSize = 18
    case xbig = 21
    
}

public enum FontStyle {
    case normal
    case bold
}

extension UIFont{
    
    public class func mainFont(_ size:FontSize = .normal, style: FontStyle = .normal) -> UIFont{
        if style == FontStyle.normal{
            return UIFont(name: "DTAC2018-Regular", size: size.rawValue) ?? UIFont.systemFont(ofSize: size.rawValue)
        }
        return UIFont(name: "DTAC2018-Bold", size: size.rawValue) ?? UIFont.boldSystemFont(ofSize: size.rawValue)
    }
    
    // MARK:- Register
    public static func registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
}
