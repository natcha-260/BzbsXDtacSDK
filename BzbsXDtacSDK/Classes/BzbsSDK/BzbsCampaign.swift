//
//  BzbsCampaign.swift
//  BzbsSDK
//
//  Created by macbookpro on 7/12/2561 BE.
//  Copyright © 2561 Bzbs. All rights reserved.
//

import UIKit

public class BzbsCampaign {
    public var adsMessage: String!
    public var agencyAddress: String!
    public var agencyCity: String!
    public var agencyCountry: String!
    public var agencyEmail: String!
    public var agencyFAX: String!
    public var agencyID: Int!
    public var agencyLogoUrl: String!
    public var agencyName: String!
    public var agencyTel: String!
    public var agencyWebsite: String!
    public var agencyZipCode: Int!
    
    public var arrangedDate:Double?

    public var badgeJson: String!
    public var badges: String!
    public var barcode: String!
    public var bidStartPoint: Int!
    public var bidStepPoint: Int!
    public var bidUsePoint: Int!
    public var buzz: Int!

    public var caption: String!
    public var categoryDashboardSize: String!
    public var categoryID: Int!
    public var categoryName: String!
    public var categorySequence: Int!
    public var condition: String!
    public var conditionAlert: String!
    public var conditionAlertId: Int!
    public var coolDown: String!
    public var createBy: String!
    public var createDate: Double!
    public var crossAppCampaignId: Int!
    public var currentDate: Double!
    public var customCaption: String!
    public var customFacebookMessage: String!
    public var customInput: String!

    public var dayProceed: Int!
    public var dayRemain: Int!
    public var daysValidAfterExpire: Int!
    public var defaultPrivilegeMessage: String!
    public var delivered: Bool!
    public var deliveryJson: String!
    public var detail: String!
    public var discount: Double!
    public var distance: Double!

    public var emsDeliveryCostPerUnit: Int!
    public var expireDate: Double!
    public var expireIn: Double?
    public var extra: String!

    public var fanPageId: String!
    public var fullImageUrl: String!

    public var hasCrossApp: Bool!
    public var hashTagJson: String!
    public var hasWinner: Bool!

    public var ID: Int!
    public var interfaceDisplay: String!
    public var isCheckUserCampaignPermission: Bool!
    public var isConditionPass: Bool!
    public var isFavourite: Bool!
    public var isHighlight: Bool!
    public var isLike: Bool!
    public var isNotAutoUse: Bool!
    public var isRequirePoints: Bool!
    public var isRequireUniqueSerial: Bool!
    public var isShowNotiNearby: Bool!
    public var isSpecificLocation: Bool!
    public var isSpecificPrintVoucher: Bool!
    public var isSplitPointSystem: Bool!
    public var isSponsor: Bool!
    public var itemCountSold: Int!

    public var keyword: String!

    public var latestVoteDate: Double!
    public var location: String!
    public var locationAgencyId: Int!
    
    public var latitude:Double?
    public var longitude :Double?

    public var masterCampaignId: Int!
    public var merchantStatusId: Int!
    public var minutesValidAfterUsed: Int!
    public var modifyBy: String!
    public var modifyDate: Double!

    public var name: String!
    public var nextRedeemDate: Double!
    public var nextRedeemDatePerCard: Double!
    public var notificationCount: Int!

    public var originalPrice: Double!
    public var otherPointPerUnit: Int!

    public var places = [BzbsPlace]()
    public var parentCampaignId: Int!
    public var parentCategoryID: Int!
    public var peopleDislike: Int!
    public var peopleFavourite: Int!
    public var peopleLike: Int!
    public var peopleVote: Int!
    public var pictures = [BzbsPictureCampaign]()
    //    public var places: AnyObject
    public var pointPerUnit: Int!
    public var pointType: String!
    public var pricePerUnit: Double!
    public var privilegeMessage: String!
    public var privilegeMessageFormat: String!

    public var qty: Int!
    public var quantity: Int!

    public var rankFavourite: String!
    public var rankLike: Int!
    public var rankVote: Int!
    public var rating: String!
    public var redeemCount: Int!
    public var redeemDate: Double!
    public var redeemMedia: Int!
    public var redeemMostPerPerson: Int!
    public var redeemMostPerCard: Int!
    public var redeemMostPerCardInPeriod: Int!
    public var redeems: String!
    public var refAISCampaignID: Int!
    public var referenceCode: String!
    public var refPTTAgencyID: Int!
    public var regularDeliveryCostPerUnit: Int!
    public var related = [BzbsCampaign]()

    public var score: Int!
    public var sendNotifications: Bool!
    public var serial: String!
    public var serialCount: Int!
    public var serialFormat: String!
    public var serialPreFix: String!
    public var shippingBy: String!
    public var shippingPayment: String!
    public var soldOutDate: Double!
    public var specifyBranch: Bool!
    public var sponsorCategoryName: String!
    public var startDate: Double!
    public var statusID: Int!
    public var styleJson: String!
    public var subCampaigns: String!
    public var subCampaignStyles: String!

    public var termsAndConditions: String!
    public var timeRounding: String!
    public var topVotes: String!
    public var tracesJson: String!
    public var type: Int!

    public var under18: Bool!
    public var updated_points: String!
    public var updated_points_other: String!
    public var useCount: Int!
    public var useLevel: Int!
    public var userPackagePoints: Int!
    public var userPackagePrices: Int!
    public var userProfileScore: Int!
    public var userRequirePoints: Int!
    public var userSummaryPrices: Int!
    public var userVisibility: Int!

    public var visibility: Int!
    public var voucherExpireDate: Double!

    public var website: String!
    public var winnerUserId: String!
    public var winnerUserName: String!
    public var isUsed:Bool?

    public var listSubCampaign = [BzbsSubCampaign]()
    
    public var raw : Dictionary<String, AnyObject>!
    
    init()
    {
    }
    
    public init(purchase: BzbsHistory) {
        agencyName = purchase.agencyName
        barcode = purchase.barcode
        expireIn = purchase.expireIn
        fullImageUrl = purchase.fullImageUrl
        name = purchase.name
        serial = purchase.serial
        privilegeMessageFormat = purchase.privilegeMessageFormat
        privilegeMessage = purchase.privilegeMessage

        redeemDate = purchase.redeemDate
        condition = purchase.condition
        isUsed = purchase.isUsed
        arrangedDate = purchase.arrangedDate

        // Replace serial in privilege message
        self.customPrivilegeMessage()
    }
    
    func copy() -> BzbsCampaign
    {
        return BzbsCampaign(dict: raw)
    }
    
    init(dict: Dictionary<String, AnyObject>)
    {
        raw = dict
        adsMessage = BuzzebeesConvert.StringFromObject(dict["AdsMessage"])
        agencyAddress = BuzzebeesConvert.StringFromObject(dict["AgencyAddress"])
        agencyCity = BuzzebeesConvert.StringFromObject(dict["AgencyCity"])
        agencyCountry = BuzzebeesConvert.StringFromObject(dict["AgencyCountry"])
        agencyEmail = BuzzebeesConvert.StringFromObject(dict["AgencyEmail"])
        agencyFAX = BuzzebeesConvert.StringFromObject(dict["AgencyFAX"])
        agencyID = BuzzebeesConvert.IntFromObject(dict["AgencyID"])
        if(agencyID == 0) {
            agencyID = BuzzebeesConvert.IntFromObject(dict["AgencyId"])
        }

        agencyLogoUrl = BuzzebeesConvert.StringFromObject(dict["AgencyLogoUrl"])
        if let url = URL(string:agencyLogoUrl), let host = url.host, host == "buzzebees.blob.core.windows.net"
        {
            let newStrUrl = agencyLogoUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
            if let _ = URL(string: newStrUrl)
            {
                agencyLogoUrl = newStrUrl
            }
        }
        agencyName = BuzzebeesConvert.StringFromObject(dict["AgencyName"])
        agencyTel = BuzzebeesConvert.StringFromObject(dict["AgencyTel"])
        agencyWebsite = BuzzebeesConvert.StringFromObject(dict["AgencyWebsite"])
        agencyZipCode = BuzzebeesConvert.IntFromObject(dict["AgencyZipCode"])

        badgeJson = BuzzebeesConvert.StringFromObject(dict["BadgeJson"])
        badges = BuzzebeesConvert.StringFromObject(dict["Badges"])
        barcode = BuzzebeesConvert.StringFromObject(dict["Barcode"])
        bidStartPoint = BuzzebeesConvert.IntFromObject(dict["BidStartPoint"])
        bidStepPoint = BuzzebeesConvert.IntFromObject(dict["BidStepPoint"])
        bidUsePoint = BuzzebeesConvert.IntFromObject(dict["BidUsePoint"])
        buzz = BuzzebeesConvert.IntFromObject(dict["Buzz"])

        caption = BuzzebeesConvert.StringFromObject(dict["Caption"])
        categoryDashboardSize = BuzzebeesConvert.StringFromObject(dict["CategoryDashboardSize"])
        categoryID = BuzzebeesConvert.IntFromObject(dict["CategoryID"])
        if(categoryID == 0)
        {
            categoryID = BuzzebeesConvert.IntFromObject(dict["CategoryId"])
        }
        categoryName = BuzzebeesConvert.StringFromObject(dict["CategoryName"])
        categorySequence = BuzzebeesConvert.IntFromObject(dict["CategorySequence"])
        condition = BuzzebeesConvert.StringFromObject(dict["Condition"])
        conditionAlert = BuzzebeesConvert.StringFromObject(dict["ConditionAlert"])
        conditionAlertId = BuzzebeesConvert.IntFromObject(dict["ConditionAlertId"])
        coolDown = BuzzebeesConvert.StringFromObject(dict["CoolDown"])
        createBy = BuzzebeesConvert.StringFromObject(dict["CreateBy"])
        createDate = BuzzebeesConvert.DoubleFromObject(dict["CreateDate"])
        crossAppCampaignId = BuzzebeesConvert.IntFromObject(dict["CrossAppCampaignId"])
        currentDate = BuzzebeesConvert.DoubleFromObject(dict["CurrentDate"])
        customCaption = BuzzebeesConvert.StringFromObject(dict["CustomCaption"])
        customFacebookMessage = BuzzebeesConvert.StringFromObject(dict["CustomFacebookMessage"])
        customInput = BuzzebeesConvert.StringFromObject(dict["CustomInput"])

        dayProceed = BuzzebeesConvert.IntFromObject(dict["DayProceed"])
        dayRemain = BuzzebeesConvert.IntFromObject(dict["DayRemain"])
        daysValidAfterExpire = BuzzebeesConvert.IntFromObject(dict["DaysValidAfterExpire"])
        defaultPrivilegeMessage = BuzzebeesConvert.StringFromObject(dict["DefaultPrivilegeMessage"])
        delivered = BuzzebeesConvert.BoolFromObject(dict["Delivered"])
        deliveryJson = BuzzebeesConvert.StringFromObject(dict["DeliveryJson"])
        detail = BuzzebeesConvert.StringFromObject(dict["Detail"])
        discount = BuzzebeesConvert.DoubleFromObject(dict["Discount"])
        distance = BuzzebeesConvert.DoubleFromObjectNull(dict["Distance"])

        emsDeliveryCostPerUnit = BuzzebeesConvert.IntFromObject(dict["EMSDeliveryCostPerUnit"])
        expireDate = BuzzebeesConvert.DoubleFromObject(dict["ExpireDate"])
        extra = BuzzebeesConvert.StringFromObject(dict["Extra"])
        expireIn = BuzzebeesConvert.DoubleFromObjectNull(dict["ExpireIn"])

        fanPageId = BuzzebeesConvert.StringFromObject(dict["FanPageId"])

        hasCrossApp = BuzzebeesConvert.BoolFromObject(dict["HasCrossApp"])
        hashTagJson = BuzzebeesConvert.StringFromObject(dict["HashTagJson"])
        hasWinner = BuzzebeesConvert.BoolFromObject(dict["HasWinner"])

        ID = BuzzebeesConvert.IntFromObject(dict["ID"])
        interfaceDisplay = BuzzebeesConvert.StringFromObject(dict["InterfaceDisplay"])
        isCheckUserCampaignPermission = BuzzebeesConvert.BoolFromObject(dict["IsCheckUserCampaignPermission"])
        isConditionPass = BuzzebeesConvert.BoolFromObject(dict["IsConditionPass"])
        isFavourite = BuzzebeesConvert.BoolFromObject(dict["IsFavourite"])
        isHighlight = BuzzebeesConvert.BoolFromObject(dict["IsHighlight"])
        isLike = BuzzebeesConvert.BoolFromObject(dict["IsLike"])

        isNotAutoUse = BuzzebeesConvert.BoolFromObject(dict["IsNotAutoUse"])
        isRequirePoints = BuzzebeesConvert.BoolFromObject(dict["IsRequirePoints"])
        isRequireUniqueSerial = BuzzebeesConvert.BoolFromObject(dict["IsRequireUniqueSerial"])
        isShowNotiNearby = BuzzebeesConvert.BoolFromObject(dict["IsShowNotiNearby"])
        isSpecificLocation = BuzzebeesConvert.BoolFromObject(dict["IsSpecificLocation"])
        isSpecificPrintVoucher = BuzzebeesConvert.BoolFromObject(dict["IsSpecificPrintVoucher"])
        isSplitPointSystem = BuzzebeesConvert.BoolFromObject(dict["IsSplitPointSystem"])
        isSponsor = BuzzebeesConvert.BoolFromObject(dict["IsSponsor"])
        itemCountSold = BuzzebeesConvert.IntFromObject(dict["ItemCountSold"])

        keyword = BuzzebeesConvert.StringFromObject(dict["Keyword"])

        latestVoteDate = BuzzebeesConvert.DoubleFromObject(dict["LatestVoteDate"])
        location = BuzzebeesConvert.StringFromObject(dict["Location"])
        locationAgencyId = BuzzebeesConvert.IntFromObject(dict["LocationAgencyId"])
        
        latitude = BuzzebeesConvert.DoubleFromObjectNull(dict["Latitude"])
        longitude = BuzzebeesConvert.DoubleFromObjectNull(dict["Longitude"])

        masterCampaignId = BuzzebeesConvert.IntFromObject(dict["MasterCampaignId"])
        merchantStatusId = BuzzebeesConvert.IntFromObject(dict["MerchantStatusId"])
        minutesValidAfterUsed = BuzzebeesConvert.IntFromObject(dict["MinutesValidAfterUsed"])
        modifyBy = BuzzebeesConvert.StringFromObject(dict["ModifyBy"])
        modifyDate = BuzzebeesConvert.DoubleFromObject(dict["ModifyDate"])

        name = BuzzebeesConvert.StringFromObject(dict["Name"])
        nextRedeemDate = BuzzebeesConvert.DoubleFromObject(dict["NextRedeemDate"])
        nextRedeemDatePerCard = BuzzebeesConvert.DoubleFromObject(dict["NextRedeemDatePerCard"])
        notificationCount = BuzzebeesConvert.IntFromObject(dict["NotificationCount"])

        originalPrice = BuzzebeesConvert.DoubleFromObject(dict["OriginalPrice"])
        otherPointPerUnit = BuzzebeesConvert.IntFromObject(dict["OtherPointPerUnit"])

        parentCampaignId = BuzzebeesConvert.IntFromObject(dict["ParentCampaignId"])
        if(parentCampaignId == 0) {
            parentCampaignId = BuzzebeesConvert.IntFromObject(dict["ParentCampaignID"])
        }

        parentCategoryID = BuzzebeesConvert.IntFromObject(dict["ParentCategoryID"])
        if(parentCategoryID == 0) {
            parentCategoryID = BuzzebeesConvert.IntFromObject(dict["ParentCategoryId"])
        }

        peopleDislike = BuzzebeesConvert.IntFromObject(dict["PeopleDislike"])
        peopleFavourite = BuzzebeesConvert.IntFromObject(dict["PeopleFavourite"])
        peopleLike = BuzzebeesConvert.IntFromObject(dict["PeopleLike"])

        // support case like in list
        let intLike = BuzzebeesConvert.IntFromObject(dict["Like"])
        if(intLike != 0)
        {
            peopleLike = intLike
        }

        peopleVote = BuzzebeesConvert.IntFromObject(dict["PeopleVote"])

        let objPicture: AnyObject? = dict["Pictures"]
        if let itemPicture = objPicture as? [Dictionary<String, AnyObject>] {
            pictures.removeAll(keepingCapacity: false)
            for i in 0..<itemPicture.count {
                pictures.append(BzbsPictureCampaign(dict: itemPicture[i]))
            }
        }

        //        places = BuzzebeesConvert.IntFromObject(dict["Places"])
        pointPerUnit = BuzzebeesConvert.IntFromObject(dict["PointPerUnit"])
        pointType = BuzzebeesConvert.StringFromObject(dict["PointType"])
        pricePerUnit = BuzzebeesConvert.DoubleFromObject(dict["PricePerUnit"])
        privilegeMessage = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessage"])
        privilegeMessageFormat = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessageFormat"])

        qty = BuzzebeesConvert.IntFromObject(dict["Qty"])
        quantity = BuzzebeesConvert.IntFromObject(dict["Quantity"])

        rankFavourite = BuzzebeesConvert.StringFromObject(dict["RankFavourite"])
        rankLike = BuzzebeesConvert.IntFromObject(dict["RankLike"])
        rankVote = BuzzebeesConvert.IntFromObject(dict["RankVote"])
        rating = BuzzebeesConvert.StringFromObject(dict["Rating"])
        redeemCount = BuzzebeesConvert.IntFromObject(dict["RedeemCount"])
        redeemDate = BuzzebeesConvert.DoubleFromObject(dict["RedeemDate"])
        redeemMedia = BuzzebeesConvert.IntFromObject(dict["RedeemMedia"])
        redeemMostPerPerson = BuzzebeesConvert.IntFromObject(dict["RedeemMostPerPerson"])

        // JU : PerCard น่าจะใช้กับ Wallet
        redeemMostPerCard = BuzzebeesConvert.IntFromObject(dict["RedeemMostPerCard"])
        redeemMostPerCardInPeriod = BuzzebeesConvert.IntFromObject(dict["RedeemMostPerCardInPeriod"])
        redeems = BuzzebeesConvert.StringFromObject(dict["Redeems"])
        refAISCampaignID = BuzzebeesConvert.IntFromObject(dict["RefAISCampaignID"])
        referenceCode = BuzzebeesConvert.StringFromObject(dict["ReferenceCode"])
        refPTTAgencyID = BuzzebeesConvert.IntFromObject(dict["RefPTTAgencyID"])
        regularDeliveryCostPerUnit = BuzzebeesConvert.IntFromObject(dict["RegularDeliveryCostPerUnit"])

        let objRelated: AnyObject? = dict["Related"]
        if let itemRelated = objRelated as? [Dictionary<String, AnyObject>] {
            related.removeAll(keepingCapacity: false)
            for i in 0..<itemRelated.count {
                let dict = itemRelated[i]
                related.append(BzbsCampaign(dict: dict))
            }
        }

        score = BuzzebeesConvert.IntFromObject(dict["Score"])
        sendNotifications = BuzzebeesConvert.BoolFromObject(dict["SendNotifications"])
        serial = BuzzebeesConvert.StringFromObject(dict["Serial"])
        serialCount = BuzzebeesConvert.IntFromObject(dict["SerialCount"])
        serialFormat = BuzzebeesConvert.StringFromObject(dict["SerialFormat"])
        serialPreFix = BuzzebeesConvert.StringFromObject(dict["SerialPreFix"])
        shippingBy = BuzzebeesConvert.StringFromObject(dict["ShippingBy"])
        shippingPayment = BuzzebeesConvert.StringFromObject(dict["ShippingPayment"])
        soldOutDate = BuzzebeesConvert.DoubleFromObject(dict["SoldOutDate"])
        specifyBranch = BuzzebeesConvert.BoolFromObject(dict["SpecifyBranch"])
        sponsorCategoryName = BuzzebeesConvert.StringFromObject(dict["SponsorCategoryName"])
        startDate = BuzzebeesConvert.DoubleFromObject(dict["StartDate"])
        statusID = BuzzebeesConvert.IntFromObject(dict["StatusID"])
        styleJson = BuzzebeesConvert.StringFromObject(dict["StyleJson"])
        subCampaigns = BuzzebeesConvert.StringFromObject(dict["SubCampaigns"])
        subCampaignStyles = BuzzebeesConvert.StringFromObject(dict["SubCampaignStyles"])

        termsAndConditions = BuzzebeesConvert.StringFromObject(dict["TermsAndConditions"])
        timeRounding = BuzzebeesConvert.StringFromObject(dict["TimeRounding"])
        topVotes = BuzzebeesConvert.StringFromObject(dict["TopVotes"])
        tracesJson = BuzzebeesConvert.StringFromObject(dict["TracesJson"])
        type = BuzzebeesConvert.IntFromObject(dict["Type"])

        under18 = BuzzebeesConvert.BoolFromObject(dict["Under18"])
        updated_points = BuzzebeesConvert.StringFromObject(dict["updated_points"])
        updated_points_other = BuzzebeesConvert.StringFromObject(dict["updated_points_other"])
        useCount = BuzzebeesConvert.IntFromObject(dict["UseCount"])
        useLevel = BuzzebeesConvert.IntFromObject(dict["UseLevel"])
        userPackagePoints = BuzzebeesConvert.IntFromObject(dict["UserPackagePoints"])
        userPackagePrices = BuzzebeesConvert.IntFromObject(dict["UserPackagePrices"])
        userProfileScore = BuzzebeesConvert.IntFromObject(dict["UserProfileScore"])
        userRequirePoints = BuzzebeesConvert.IntFromObject(dict["UserRequirePoints"])
        userSummaryPrices = BuzzebeesConvert.IntFromObject(dict["UserSummaryPrices"])
        userVisibility = BuzzebeesConvert.IntFromObject(dict["userVisibility"])

        visibility = BuzzebeesConvert.IntFromObject(dict["Visibility"])
        voucherExpireDate = BuzzebeesConvert.DoubleFromObject(dict["VoucherExpireDate"])

        website = BuzzebeesConvert.StringFromObject(dict["Website"])
        winnerUserId = BuzzebeesConvert.StringFromObject(dict["WinnerUserId"])
        winnerUserName = BuzzebeesConvert.StringFromObject(dict["WinnerUserName"])

        //fullImageUrl เขาไม่ได้ใส่ type large มาให้ ต้องใส่เอง
        fullImageUrl = BuzzebeesConvert.StringFromObject(dict["FullImageUrl"])
        if fullImageUrl != "" {
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

        getPlace(pArrPlace: dict["Locations"] as? [Dictionary<String, AnyObject>])
        getSubCampaign(pDictSub: dict["SubCampaignStyles"] as? Dictionary<String, AnyObject>)

        // Replace serial in privilege message
        customPrivilegeMessage()
    }
    
    func getPlace(pArrPlace: [Dictionary<String, AnyObject>]?){
        places.removeAll()
        if let arr = pArrPlace {
            for item in arr{
                places.append(BzbsPlace(dict: item))
            }
        }
    }
    
    public func getSubCampaign(pDictSub: Dictionary<String, AnyObject>?)
    {
        if let dict = pDictSub
        {
            listSubCampaign.removeAll(keepingCapacity: false)

            if let arrStyle = dict["styles"] as? [Dictionary<String, AnyObject>]
            {
                for item in arrStyle
                {
                    listSubCampaign.append(BzbsSubCampaign(dict: item))
                }
            }
        }
    }
    
    public func updateAfterRedeem(dict: Dictionary<String, AnyObject>)
    {
        redeemCount = BuzzebeesConvert.IntFromObject(dict["RedeemCount"])
        serial = BuzzebeesConvert.StringFromObject(dict["Serial"])
        nextRedeemDate = BuzzebeesConvert.DoubleFromObject(dict["NextRedeemDate"])
        useCount = BuzzebeesConvert.IntFromObject(dict["UseCount"])
        qty = BuzzebeesConvert.IntFromObject(dict["Qty"])
        isConditionPass = BuzzebeesConvert.BoolFromObject(dict["IsConditionPass"])
        adsMessage = BuzzebeesConvert.StringFromObject(dict["AdsMessage"])
        expireIn = BuzzebeesConvert.DoubleFromObjectNull(dict["ExpireIn"])
        isNotAutoUse = BuzzebeesConvert.BoolFromObject(dict["IsNotAutoUse"])
        privilegeMessage = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessage"])
        privilegeMessageFormat = BuzzebeesConvert.StringFromObject(dict["PrivilegeMessageFormat"])
        pointType = BuzzebeesConvert.StringFromObject(dict["PointType"])
        conditionAlert = BuzzebeesConvert.StringFromObject(dict["ConditionAlert"])
        currentDate = BuzzebeesConvert.DoubleFromObject(dict["CurrentDate"])

        // Replace serial in privilege message
        customPrivilegeMessage()
    }
    
    // MARK:- Util
    func isExpired() -> Bool?
    {
        if let expire = expireIn
        {
            if(expire <= 0)
            {
                return true
            }else{
                return false
            }
        }
        return nil
    }
    
    // MARK: Private Function
    func customPrivilegeMessage() {
        if privilegeMessage != "" && serial != "" {
            privilegeMessage = privilegeMessage.replace("<serial>", replacement: serial)
        }
    }
}

public class BzbsSubCampaign {
    public var campaignId: Int!
    public var name: String!
    public var points: Int!
    public var price: Int!
    public var quantity: Int!
    public var type: String!
    public var value: String!
    
    public var name_en: String!
    public var itemCountSold: Int!
    public var sequence: Int!
    public var originalPrice: Double!
    public var discount: Double!
    
    public var listSubItem = [BzbsSubCampaign]()
    
    init() {
        
    }
    
    init(dict: Dictionary<String, AnyObject>) {
        campaignId = BuzzebeesConvert.IntFromObject(dict["campaignId"])
        name = BuzzebeesConvert.StringFromObject(dict["name"])
        points = BuzzebeesConvert.IntFromObject(dict["points"])
        price = BuzzebeesConvert.IntFromObject(dict["price"])
        quantity = BuzzebeesConvert.IntFromObject(dict["quantity"])
        type = BuzzebeesConvert.StringFromObject(dict["type"])
        value = BuzzebeesConvert.StringFromObject(dict["value"])
        
        name_en = BuzzebeesConvert.StringFromObject(dict["name_en"])
        itemCountSold = BuzzebeesConvert.IntFromObject(dict["itemCountSold"])
        sequence = BuzzebeesConvert.IntFromObject(dict["sequence"])
        originalPrice = BuzzebeesConvert.DoubleFromObject(dict["originalPrice"])
        discount = BuzzebeesConvert.DoubleFromObject(dict["discount"])
        
        getSubItems(arr: dict["subitems"] as? [Dictionary<String, AnyObject>])
    }
    
    func getSubItems(arr: [Dictionary<String, AnyObject>]?) {
        listSubItem.removeAll(keepingCapacity: false)
        
        if let list = arr {
            for item in list {
                listSubItem.append(BzbsSubCampaign(dict: item))
            }
        }
    }
}
