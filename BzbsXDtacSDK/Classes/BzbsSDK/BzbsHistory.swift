//
//  BzbsHistory.swift
//  BzbsSDK
//
//  Created by macbookpro on 17/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import Foundation

public class BzbsHistory {
    public var adsMessage: String!
    public var agencyID: Int!
    public var agencyName: String!
    public var barcode: String!
    public var caption: String!
    public var categoryID: Int!
    public var condition: String!
    public var currentDate: Double!
    public var delivered: Bool!
    public var discount: Int!
    public var expireIn: Double?
    public var fullImageUrl: String!
    public var hasWinner: Bool!
    public var ID: Int!
    public var installAppIosSchema: String!
    public var installAppUrl: String!
    public var installedAppDate: Double!
    public var installingMessage: String!
    public var installPackageName: String!
    public var interfaceDisplay: String!
    public var isCampaignTopup: Bool!
    public var isConditionPass: Bool!
    public var isInstalledApp: Bool!
    public var isNotAutoUse: Bool!
    public var isShipped: Bool!
    public var isSpecificPrintVoucher: Bool!
    public var isUsed: Bool!
    public var isWinner: Bool!
    public var itemNumber: Int!
    public var minutesValidAfterUsed: Int!
    public var modifyDate: Double!
    public var name: String!
    public var originalPrice: Int!
    public var otherPointPerUnit: Int!
    public var parcelNo: String!
    public var parentCategoryID: Int!
    public var pointPerUnit: Int!
    public var pointType: String!
    public var pricePerUnit: Int!
    public var privilegeMessage: String!
    public var privilegeMessageFormat: String!
    public var redeemDate: Double!
    public var redeemKey: String?
    public var serial: String!
    public var shippedStatus: String!
    public var shippingDate: Double!
    public var styleSize: String!
    public var styleType: String!
    public var type: Int!
    public var usedDate: Double!
    public var verifyingMessage: String!
    public var verifyTypeAndroid: String!
    public var verifyTypeIos: String!
    public var voucherExpireDate: Double!
    public var winnerDate: Double!
    public var website : String!
    
    public var convertPrice: Double!
    public var convertPoint: Double!
    public var pointsToBahtRate: String!
    public var bahtToPointsRate: Double!
    public var arrangedDate: Double!
    public var hasSplitProfile: Bool!
    public var walletCard: String!
    public var walletAmount: Double!
    public var privilegeMessageEN: String!
    public var refPaymentTranId: String!
    public var installIsOpenApp: Bool!
    public var approveSurvey: Bool!
    
    public var info1:String?
    public var info2:String?
    public var info3:String?
    public var categoryName:String?
    
    init(){
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        adsMessage = BuzzebeesConvert.StringFromObject(dict["AdsMessage"])
        agencyID = BuzzebeesConvert.IntFromObject(dict["AgencyID"])
        agencyName = BuzzebeesConvert.StringFromObject(dict["AgencyName"])
        barcode = BuzzebeesConvert.StringFromObject(dict["Barcode"])
        categoryID = BuzzebeesConvert.IntFromObject(dict["CategoryID"])
        caption = BuzzebeesConvert.StringFromObject(dict["Caption"])
        condition = BuzzebeesConvert.StringFromObject(dict["Condition"])
        currentDate = BuzzebeesConvert.DoubleFromObject(dict["CurrentDate"])
        delivered = BuzzebeesConvert.BoolFromObject(dict["Delivered"])
        discount = BuzzebeesConvert.IntFromObject(dict["Discount"])
        expireIn = BuzzebeesConvert.DoubleFromObjectNull(dict["ExpireIn"])
        fullImageUrl = BuzzebeesConvert.StringFromObject(dict["FullImageUrl"])
        hasWinner = BuzzebeesConvert.BoolFromObject(dict["HasWinner"])
        ID = BuzzebeesConvert.IntFromObject(dict["ID"])
        installAppIosSchema = BuzzebeesConvert.StringFromObject(dict["InstallAppIosSchema"])
        installAppUrl = BuzzebeesConvert.StringFromObject(dict["InstallAppUrl"])
        installedAppDate = BuzzebeesConvert.DoubleFromObject(dict["InstalledAppDate"])
        installingMessage = BuzzebeesConvert.StringFromObject(dict["InstallingMessage"])
        installPackageName = BuzzebeesConvert.StringFromObject(dict["InstallPackageName"])
        interfaceDisplay = BuzzebeesConvert.StringFromObject(dict["InterfaceDisplay"])
        isCampaignTopup = BuzzebeesConvert.BoolFromObject(dict["IsCampaignTopup"])
        isConditionPass = BuzzebeesConvert.BoolFromObject(dict["IsConditionPass"])
        isInstalledApp = BuzzebeesConvert.BoolFromObject(dict["IsInstalledApp"])
        isNotAutoUse = BuzzebeesConvert.BoolFromObject(dict["IsNotAutoUse"])
        isShipped = BuzzebeesConvert.BoolFromObject(dict["IsShipped"])
        isSpecificPrintVoucher = BuzzebeesConvert.BoolFromObject(dict["IsSpecificPrintVoucher"])
        isUsed = BuzzebeesConvert.BoolFromObject(dict["IsUsed"])
        isWinner = BuzzebeesConvert.BoolFromObject(dict["IsWinner"])
        itemNumber = BuzzebeesConvert.IntFromObject(dict["ItemNumber"])
        minutesValidAfterUsed = BuzzebeesConvert.IntFromObject(dict["MinutesValidAfterUsed"])
        modifyDate = BuzzebeesConvert.DoubleFromObject(dict["ModifyDate"])
        name = BuzzebeesConvert.StringFromObject(dict["Name"])
        originalPrice = BuzzebeesConvert.IntFromObject(dict["OriginalPrice"])
        otherPointPerUnit = BuzzebeesConvert.IntFromObject(dict["OtherPointPerUnit"])
        parcelNo = BuzzebeesConvert.StringFromObject(dict["ParcelNo"])
        parentCategoryID = BuzzebeesConvert.IntFromObject(dict["ParentCategoryID"])
        pointPerUnit = BuzzebeesConvert.IntFromObject(dict["PointPerUnit"])
        pointType = BuzzebeesConvert.StringFromObject(dict["PointType"])
        pricePerUnit = BuzzebeesConvert.IntFromObject(dict["PricePerUnit"])
        privilegeMessage = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessage"])
        privilegeMessageFormat = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessageFormat"])
        
        redeemDate = BuzzebeesConvert.DoubleFromObject(dict["RedeemDate"])
//        if isRemoveTimeSurvey == true {
//            if redeemDate = nil {
//                redeemDate = redeemDate - (7 * 60 * 60)
//            }
//        }
        
        redeemKey = BuzzebeesConvert.StringFromObjectNull(dict["RedeemKey"])
        serial = BuzzebeesConvert.StringFromObject(dict["Serial"])
        shippedStatus = BuzzebeesConvert.StringFromObject(dict["ShippedStatus"])
        shippingDate = BuzzebeesConvert.DoubleFromObject(dict["ShippingDate"])
        styleSize = BuzzebeesConvert.StringFromObject(dict["StyleSize"])
        styleType = BuzzebeesConvert.StringFromObject(dict["StyleType"])
        type = BuzzebeesConvert.IntFromObject(dict["Type"])
        usedDate = BuzzebeesConvert.DoubleFromObject(dict["UsedDate"])
        verifyingMessage = BuzzebeesConvert.StringFromObject(dict["VerifyingMessage"])
        verifyTypeAndroid = BuzzebeesConvert.StringFromObject(dict["VerifyTypeAndroid"])
        verifyTypeIos = BuzzebeesConvert.StringFromObject(dict["VerifyTypeIos"])
        voucherExpireDate = BuzzebeesConvert.DoubleFromObject(dict["VoucherExpireDate"])
        winnerDate = BuzzebeesConvert.DoubleFromObject(dict["WinnerDate"])
        website = BuzzebeesConvert.StringFromObject(dict["Website"]);
        
        if(fullImageUrl != "") {
            if fullImageUrl.range(of: "-large") == nil {
                var newString = fullImageUrl.replacingOccurrences(of: "?", with: "-large?", options: NSString.CompareOptions.literal, range: nil)
                if let url = URL(string:newString), let host = url.host, host == "buzzebees.blob.core.windows.net"
                {
                    let newStrUrl = newString.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                    if let _ = URL(string: newStrUrl)
                    {
                        newString = newStrUrl
                    }
                }
                fullImageUrl = newString
            }
        }
        
        convertPrice = BuzzebeesConvert.DoubleFromObject(dict["ConvertPrice"])
        convertPoint = BuzzebeesConvert.DoubleFromObject(dict["ConvertPoint"])
        pointsToBahtRate = BuzzebeesConvert.StringFromObject(dict["PointsToBahtRate"])
        bahtToPointsRate = BuzzebeesConvert.DoubleFromObject(dict["BahtToPointsRate"])
        arrangedDate = BuzzebeesConvert.DoubleFromObjectNull(dict["ArrangedDate"])
        hasSplitProfile = BuzzebeesConvert.BoolFromObject(dict["HasSplitProfile"])
        walletCard = BuzzebeesConvert.StringFromObject(dict["WalletCard"])
        walletAmount = BuzzebeesConvert.DoubleFromObject(dict["WalletAmount"])
        privilegeMessageEN = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessageEN"])
        refPaymentTranId = BuzzebeesConvert.StringFromObject(dict["RefPaymentTranId"])
        installIsOpenApp = BuzzebeesConvert.BoolFromObject(dict["InstallIsOpenApp"])
        approveSurvey = BuzzebeesConvert.BoolFromObject(dict["ApproveSurvey"])
        
        info1 = BuzzebeesConvert.StringFromObject(dict["Info1"])
        info2 = BuzzebeesConvert.StringFromObject(dict["Info2"])
        info3 = BuzzebeesConvert.StringFromObject(dict["Info3"])
        
        categoryName = BuzzebeesConvert.StringFromObject(dict["CategoryName"]) 
    }
}
