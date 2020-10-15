//
//  UIColorExtension.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 13/9/2562 BE.
//

import UIKit

extension UIColor {
    
    class var dtacBlue: UIColor { return UIColor(hexString: "#007ad0") }
    class var mainBlue: UIColor { return UIColor(hexString: "#013471") }
    class var mainSilver: UIColor { return UIColor(hexString: "#939598") }
    class var mainGold: UIColor { return UIColor(hexString: "#d09c2c") }
    class var mainBlack: UIColor { return UIColor(hexString: "#333333") }
    class var mainGray: UIColor { return UIColor(hexString: "#767676") }
    class var mainGreen: UIColor { return UIColor(hexString: "#B0F0B2") }
    class var mainYellow: UIColor { return UIColor(hexString: "#FFCB96") }
    class var mainRed: UIColor { return UIColor(hexString: "#FFB4B4") }
    class var mainLightGray: UIColor { return UIColor(hexString: "#D6D6D6") }
    class var mainBlueSubscription: UIColor { return UIColor(hexString: "#E6FBFF") }
    
    
    class var popupBGBlue: UIColor { return UIColor(hexString: "#003371") }
    class var popupBGGold: UIColor { return UIColor(hexString: "#D9B14F") }
    class var popupBGSilver: UIColor { return UIColor(hexString: "#B9B9B9") }
    class var popupBGCustomer: UIColor { return UIColor(hexString: "#009EF0") }
    
    class var historyStatusAvailable: UIColor { return UIColor(hexString: "#87E6BF") }
    class var historyStatusExpired: UIColor { return UIColor(hexString: "#C7C7C7") }
    
    class var lineGreen: UIColor { return UIColor(hexString: "#1CAE40") }
    class var lineBG: UIColor { return UIColor(hexString: "#F8F8F8") }
    class var lineNav: UIColor { return UIColor(hexString: "#263146") }
    class var lineDisable: UIColor { return UIColor(hexString: "#CFCCCF") }
    
    convenience init(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            self.init(white: 0.5, alpha: 1.0)
        } else {
            let rString: String = (cString as NSString).substring(to: 2)
            let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
            
            var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
            Scanner(string: rString).scanHexInt32(&r)
            Scanner(string: gString).scanHexInt32(&g)
            Scanner(string: bString).scanHexInt32(&b)
            
            self.init(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: CGFloat(1))
        }
    }
}
