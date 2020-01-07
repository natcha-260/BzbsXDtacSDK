//
//  BzbsProfile.swift
//  BzbsSDK
//
//  Created by macbookpro on 21/8/2562 BE.
//  Copyright © 2562 Bzbs. All rights reserved.
//

import UIKit

public class BzbsProfile {
    public var address: String?
    public var age: String?
    public var birthDate: Double?
    public var contact_Number: String?
    public var creditCardExpireMonth: String?
    public var creditCardExpireYear: String?
    public var creditCardHolder: String?
    public var creditCardNo: String?
    public var creditCardType: String?
    public var displayName: String?
    public var districtCode: Int?
    public var email: String?
    public var extensionJsonProperty: Dictionary<String, AnyObject>?
    public var firstName: String?
    public var gender: String?
    public var interests: String?
    public var isUpdateBirthday: Bool = true
    public var lastName: String?
    public var locale: Int?
    public var membershipUserName: String?
    public var modifyDate: Double?
    public var name: String?
    public var nationalIdCard: String?
    public var notificationEnable: Bool?
    public var otherUserId: String?
    public var playboyCampaignId: String?
    public var postToFacebook: Bool?
    public var provinceCode: Int?
    public var subDistrictCode: Int?
    public var userId: String?
    public var userType: String?
    public var userTypeName: String?
    public var zipcode: String?
    
    // MARK:- Shipping Property
    public var shippingFirstName: String?
    public var shippingLastName: String?
    public var shippingAddress: String?
    public var shippingDistrictCode: String?
    public var shippingDistrictName: String?
    public var shippingSubDistrictCode: String?
    public var shippingSubDistrictName: String?
    public var shippingProvinceCode: String?
    public var shippingProvinceName: String?
    public var shippingZipcode: String?
    public var shippingContactNumber: String?
    
    init() {
        locale = 1033
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        address = BuzzebeesConvert.StringFromObject(dict["Address"])
        age = BuzzebeesConvert.StringFromObject(dict["Age"])
        birthDate = BuzzebeesConvert.DoubleFromObject(dict["BirthDate"])
        contact_Number = BuzzebeesConvert.StringFromObject(dict["Contact_Number"])
        creditCardExpireMonth = BuzzebeesConvert.StringFromObject(dict["CreditCardExpireMonth"])
        creditCardExpireYear = BuzzebeesConvert.StringFromObject(dict["CreditCardExpireYear"])
        creditCardHolder = BuzzebeesConvert.StringFromObject(dict["CreditCardHolder"])
        creditCardNo = BuzzebeesConvert.StringFromObject(dict["CreditCardNo"])
        creditCardType = BuzzebeesConvert.StringFromObject(dict["CreditCardType"])
        displayName = BuzzebeesConvert.StringFromObject(dict["DisplayName"])
        districtCode = BuzzebeesConvert.IntFromObject(dict["DistrictCode"])
        email = BuzzebeesConvert.StringFromObject(dict["Email"])
        firstName = BuzzebeesConvert.StringFromObject(dict["FirstName"])
        gender = BuzzebeesConvert.StringFromObject(dict["Gender"])
        interests = BuzzebeesConvert.StringFromObject(dict["Interests"])
        lastName = BuzzebeesConvert.StringFromObject(dict["LastName"])
        locale = BuzzebeesConvert.IntFromObject(dict["Locale"])
        membershipUserName = BuzzebeesConvert.StringFromObject(dict["MembershipUserName"])
        modifyDate = BuzzebeesConvert.DoubleFromObject(dict["ModifyDate"])
        name = BuzzebeesConvert.StringFromObject(dict["Name"])
        nationalIdCard = BuzzebeesConvert.StringFromObject(dict["NationalIdCard"])
        
        notificationEnable = BuzzebeesConvert.BoolFromObject(dict["NotificationEnable"])
        if(notificationEnable == nil) {
            notificationEnable = BuzzebeesConvert.BoolFromObject(dict["notification"])
        }
        
        otherUserId = BuzzebeesConvert.StringFromObject(dict["OtherUserId"])
        playboyCampaignId = BuzzebeesConvert.StringFromObject(dict["PlayboyCampaignId"])
        postToFacebook = BuzzebeesConvert.BoolFromObject(dict["PostToFacebook"])
        provinceCode = BuzzebeesConvert.IntFromObject(dict["ProvinceCode"])
        subDistrictCode = BuzzebeesConvert.IntFromObject(dict["SubDistrictCode"])
        userId = BuzzebeesConvert.StringFromObject(dict["UserId"])
        userType = BuzzebeesConvert.StringFromObject(dict["UserType"])
        userTypeName = BuzzebeesConvert.StringFromObject(dict["UserTypeName"])
        zipcode = BuzzebeesConvert.StringFromObject(dict["Zipcode"])
        
        // Shipping
        shippingFirstName = BuzzebeesConvert.StringFromObject(dict["ShippingFirstName"])
        shippingLastName = BuzzebeesConvert.StringFromObject(dict["ShippingLastName"])
        shippingAddress = BuzzebeesConvert.StringFromObject(dict["ShippingAddress"])
        shippingDistrictCode = BuzzebeesConvert.StringFromObject(dict["ShippingDistrictCode"])
        shippingDistrictName = BuzzebeesConvert.StringFromObject(dict["ShippingDistrictName"])
        shippingSubDistrictCode = BuzzebeesConvert.StringFromObject(dict["ShippingSubDistrictCode"])
        shippingSubDistrictName = BuzzebeesConvert.StringFromObject(dict["ShippingSubDistrictName"])
        shippingProvinceCode = BuzzebeesConvert.StringFromObject(dict["ShippingProvinceCode"])
        shippingProvinceName = BuzzebeesConvert.StringFromObject(dict["ShippingProvinceName"])
        shippingZipcode = BuzzebeesConvert.StringFromObject(dict["ShippingZipcode"])
        subDistrictCode = BuzzebeesConvert.IntFromObject(dict["SubDistrictCode"])
        shippingContactNumber = BuzzebeesConvert.StringFromObject(dict["ShippingContactNumber"])
        
        if let extenJson = dict["ExtensionJsonProperty"] as? Dictionary<String, AnyObject> {
            extensionJsonProperty = extenJson
        }
    }
}
