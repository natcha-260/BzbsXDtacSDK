//
//  PopupSubscriptionViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2563 BE.
//

import UIKit
import FirebaseAnalytics

class PopupSubscriptionViewController: BzbsXDtacBaseViewController {
    
    @IBOutlet weak var lblThankyou: UILabel!
    @IBOutlet weak var vwProduct: UIView!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblClose: UILabel!
    
    var history : BzbsHistory!
    let formatter = DateFormatter()
    var parentCategoryName = BzbsAnalyticDefault.category.rawValue
    var parentSubCategoryName = BzbsAnalyticDefault.subCategory.rawValue
    var gaIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm, dd MMM yyyy"
        lblThankyou.font = UIFont.mainFont(.big, style: .bold)
        lblProduct.font = UIFont.mainFont(style: .bold)
        lblDate.font = UIFont.mainFont(style: .bold)
        lblProductName.font = UIFont.mainFont(style: .bold)
        lblClose.font = UIFont.mainFont(style: .bold)
        
        lblThankyou.textColor = .white
        lblDate.textColor = .lightGray
        
        vwProduct.backgroundColor = .mainBlueSubscription
        vwClose.backgroundColor = .dtacBlue
        vwClose.cornerRadius()
        
        Bzbs.shared.delegate?.analyticsScreen(screenName: "reward_detail")
        sendGABeginEvent()
        setupUI()
    }
    
    func setupUI() {
        
        lblThankyou.text = "popup_voice_net_thank_you".localized()
        lblProduct.text = "popup_voice_net_detail".localized()
        var date = Date()
        if let period = history.redeemDate
        {
            date = Date(timeIntervalSince1970: period)
        }
        formatter.dateFormat = "HH:mm, d MMM yyyy"
        
        lblDate.text = formatter.string(from: date)
        lblProductName.text = history.name
        lblClose.text = "popup_done".localized()
        
    }
    
    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // FIXME:GA#29
    func sendGABeginEvent()
    {
        analyticsSetScreen(screenName: "reward_detail")
        let purchase = history
        
        let subCategoryName = purchase?.categoryName ?? parentSubCategoryName
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(purchase?.ID ?? -1)" as NSString,
            AnalyticsParameterItemName: "\(purchase?.name ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterItemCategory: "reward/\(parentCategoryName)/\(subCategoryName)" as NSString,
            AnalyticsParameterItemBrand: "\(purchase?.agencyName ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterIndex: gaIndex as NSNumber,
            "metric1" : (purchase?.pointPerUnit ?? 0) as NSNumber,
            AnalyticsParameterPrice: 0 as NSNumber,
            AnalyticsParameterCurrency: "THB" as NSString,
            AnalyticsParameterQuantity: 1 as NSNumber,
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_button" as NSString,
            "eventLabel" : "redeem_success | \(parentCategoryName) | \(subCategoryName) | \(gaIndex) | \(purchase?.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: "reward_main_\(parentCategoryName)" as NSString,
            AnalyticsParameterTransactionID: "\(purchase?.redeemKey ?? "-")" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventPurchase, params: ecommerce)
        
        //        Additional send only Burn coin
        analyticsSetEventEcommerce(eventName: AnalyticsEventSpendVirtualCurrency, params: [
            AnalyticsParameterItemName : "\(purchase?.ID ?? -1) | \(purchase?.name ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterItemVariant : "\(purchase?.name ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterVirtualCurrencyName : "Coin" as NSString,
            AnalyticsParameterValue: (purchase?.pointPerUnit ?? 0) as NSNumber,
            AnalyticsParameterTransactionID: "\(purchase?.redeemKey ?? "-")" as NSString
        ])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        analyticsSetUserProperty(propertyName: "last_redeem_coin", value: dateFormatter.string(from: Date(timeIntervalSince1970: purchase?.redeemDate ?? Date().timeIntervalSince1970)))
    }
}

