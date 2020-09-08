//
//  DashboardModel.swift
//  Pods
//
//  Created by apple on 20/9/2562 BE.
//

import Foundation

public class GreetingModel: NSObject {
    
    var greetingText: String?{
        if LocaleCore.shared.getUserLocale() == 1054 {
            return greetingText_th
        }
        return greetingText_en
    }
    var greetingText_th: String!
    var greetingText_en: String!
    var imageUrl: String!
    var imageBannerUrl: String!
    
    init(dict: Dictionary<String, AnyObject>) {
        super.init()
        
        greetingText_th = BuzzebeesConvert.StringFromObject(dict["Text"])
        greetingText_en = BuzzebeesConvert.StringFromObject(dict["TextEN"])
        imageUrl = BuzzebeesConvert.StringFromObject(dict["ImageUrl"])
        imageBannerUrl = BuzzebeesConvert.StringFromObject(dict["ImageUrl01"])
    }
    
}

