//
//  LineStickerRedeemViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 6/10/2563 BE.
//

import UIKit
import FirebaseAnalytics

class LineStickerRedeemViewController: BzbsXDtacBaseViewController {
    
    //MARK:- Properties
    //MARK:- Outlet
    @IBOutlet weak var lblYouChoose: UILabel!
    @IBOutlet weak var imvSticker: UIImageView!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPointUse: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblMobileTitle: UILabel!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var lblMobileInfo: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var imvTerm: UIImageView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    @IBOutlet weak var vwBtn: UIView!
    
    //MARK:- Variable
    var campaignId : String!
    var packageId : String!
    var lineCampaign : LineStickerCampaign!
    var bzbsCampaign : BzbsCampaign!
    var isCheckTerm = false
    
    //MARK:- View life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsSetScreen(screenName: "reward_detail")
        
        lblYouChoose.font = UIFont.mainFont()
        lblAgency.font = UIFont.mainFont()
        lblName.font = UIFont.mainFont()
        lblPointUse.font = UIFont.mainFont()
        lblPoints.font = UIFont.mainFont()
        lblMobileTitle.font = UIFont.mainFont()
        lblMobileInfo.font = UIFont.mainFont()
        txtMobile.font = UIFont.mainFont()
        lblTerm.font = UIFont.mainFont()
        lblContinue.font = UIFont.mainFont()
        
        lblAgency.textColor = .gray
        lblMobileInfo.textColor = .gray
        
        lblYouChoose.text = "line_redeem_you_choose".localized()
        lblAgency.text = bzbsCampaign.agencyName
        lblName.text = lineCampaign.stickerTitle
        lblPointUse.text = "line_redeem_point_use".localized()
        lblPoints.text = bzbsCampaign.pointPerUnit!.withCommas() + " " + "line_redeem_coin".localized()
        lblMobileTitle.text = "line_redeem_mobile_title".localized()
        txtMobile.placeholder = "08X-XXX-XXXX"
        lblMobileInfo.text = "line_redeem_mobile_info".localized()
        lblTerm.text = "line_redeem_term".localized()
        lblContinue.text = "line_redeem_continue".localized()
        imvSticker.bzbsSetImage(withURL: lineCampaign.logoUrl ?? "")
        
        imvTerm.tintColor = .lineGreen
        self.view.backgroundColor = .lineBG
        initNav()
        
        imvTerm.image = UIImage(named: "checkbox_inactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        updateButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification :)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func initNav() {
        super.initNav()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont(.big, style: .bold)
        lblTitle.textColor = .white
        lblTitle.numberOfLines = 0
        lblTitle.text = "line_detail_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step), isWhiteIcon: true)
        self.navigationController?.navigationBar.tintColor = .lineNav
        self.navigationController?.navigationBar.backgroundColor = .lineNav
        self.navigationController?.navigationBar.barTintColor = .lineNav
    }
    
    
    // MARK:- Notification
    // MARK:- Resign Keyboard
    @objc func keyboardWillShow(notification: NSNotification)
    {
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue ?? 0.33
        
        UIView.animate(withDuration: keyboardDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            if let heightKeyBoard = keyboardFrame?.size.height
            {
                self.cstBottom.constant = heightKeyBoard
            }
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        // Expanding size of table
        //        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        UIView.animate(withDuration: keyboardDuration!, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.cstBottom.constant = 0
            self.view.layoutIfNeeded()
        }, completion:  { (finished: Bool) in
        })
    }
    
    
    //MARK:- Event
    //MARK:-
    @IBAction func clickView(_ sender: Any) {
        self.view.endEditing(true)
        updateButton()
    }
    
    @IBAction func clickTerm(_ sender: Any) {
        isCheckTerm.toggle()
        imvTerm.image = isCheckTerm
            ? UIImage(named: "checkbox_active", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            : UIImage(named: "checkbox_inactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        updateButton()
    }
    
    @IBAction func clickContinue(_ sender: Any) {
        if validate() {
            sendGAContinue()
            apiValidateLineSticker()
        }
    }
    func apiValidateLineSticker() {
        guard let token = Bzbs.shared.userLogin?.token,
              let contactNumber = txtMobile.text?.removeContactFormat()
              else {
            return
        }
        showLoader()
        BzbsCoreApi().getValidateLineSticker(token: token, campaignId: campaignId, packageId: packageId, contactNumber: contactNumber) { (dict) in
            self.hideLoader()
            if let refId = dict["refId"] as? String {
                PopupManager.lineConfirmPopup(onView: self, strContactNumber: contactNumber, campaign: self.lineCampaign, pointPerUnit: self.bzbsCampaign.pointPerUnit ?? 0) {
                    self.sendGAConfirm()
                    self.apiRedeemLineSticker(refId)
                } cancel: {
                    
                }

            }
        } failCallback: { (error) in
            self.hideLoader()
            var message = "line_error_msg_not_found".localized()
            var info = "line_error_msg_not_found_info".localized()
            if error.message == "1001" {
                message = "line_error_msg_not_found".localized()
                info = "line_error_msg_not_found_info".localized()
            } else if error.message == "1003" {
                message = "line_error_msg_redeemed".localized()
                info = "line_error_msg_redeemed_info".localized()
            }
            self.sendGARedeemLineFail(strMessage: message)
            PopupManager.lineErrorPopup(onView: self, strMessage: message, strInfo: info)
        }
    }
    
    func apiRedeemLineSticker(_ refID:String){
        guard let token = Bzbs.shared.userLogin?.token,
              let contactNumber = txtMobile.text?.removeContactFormat()
              else {
            return
        }
        showLoader()
        BzbsCoreApi().getRedeemLineSticker(token: token, refId: refID, campaignId: campaignId, packageId: packageId, contactNumber: contactNumber) { (_) in
            self.hideLoader()
            GotoPage.gotoLineHistory(self.navigationController!, lineCampaign: self.lineCampaign, bzbsCampaign: self.bzbsCampaign, contactNumber: contactNumber, packageId:self.packageId) {
                self.sendGARedeemSuccessEvent()
                NotificationCenter.default.post(name: NSNotification.Name.BzbsApiReset, object: nil)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        } failCallback: { (error) in
            self.hideLoader()
            self.sendGARedeemLineFail(strMessage: "line_error_msg_not_found".localized())
            print(error.description())
            PopupManager.lineErrorPopup(onView: self, strMessage: "line_error_msg_not_found".localized(), strInfo: "line_error_msg_not_found_info".localized())
        }
    }
    
    func validate() -> Bool {
        if !isCheckTerm { return false}
        guard let mobile = txtMobile.text else { return false }
        if let first = mobile.first, first != "0" { return false}
        if mobile.removeContactFormat().count < 10 { return false }
        return true
    }

    func updateButton() {
        vwBtn.backgroundColor = validate() ? .lineGreen : .lineDisable
    }
    
}

extension LineStickerRedeemViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateButton()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
        if textField == txtMobile {
            txtMobile.text = txtMobile.text!.getContactFormat()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtMobile {
            txtMobile.text = txtMobile.text!.removeContactFormat()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let intNewLength = textField.text!.length - range.length + string.length
        
        if txtMobile == textField {
            
            // check first text
            if textField.text!.count == 0 && string != "0" {
                return false
            }
            
            if intNewLength > 10 { return false }
            if intNewLength == 10 {
                Bzbs.shared.delay(0.2) {
                    DispatchQueue.main.async {
                        self.view.endEditing(true)
                    }
                }
                return true
            }
        }
        
        return true
    }
}

extension String {
    func getContactFormat() -> String {
        if self.count != 10 { return self }
        var encript = self.substringWithRange(0, end: 3)
        encript += "-"
        encript += self.substringWithRange(3, end: 6)
        encript += "-"
        encript += self.substringWithRange(6, end: 10)
        return encript
    }

    func removeContactFormat() -> String {
        return self.replace("-", replacement: "")
    }
}

//MARK:- GA
//MARK:-
extension LineStickerRedeemViewController {
    
    // FIXME:GA#27
    func sendGARedeemSuccessEvent()
    {
        let screenName = "reward"
        let reward1 : [String : AnyObject] = [
            AnalyticsParameterItemID : "\(bzbsCampaign?.ID ?? -1)" as AnyObject,
            AnalyticsParameterItemName : (bzbsCampaign?.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(bzbsCampaign?.categoryID ?? -1)" as AnyObject,
            AnalyticsParameterItemBrand: (bzbsCampaign?.agencyName ?? "") as AnyObject,
            AnalyticsParameterIndex: NSNumber(value: 1) as AnyObject
        ]
        let ecommerce : [String:AnyObject] = [
            "items" : reward1  as AnyObject,
            AnalyticsParameterItemList : screenName as AnyObject,
            AnalyticsParameterCheckoutStep: 1 as AnyObject,
            AnalyticsParameterCheckoutOption: "Create Code" as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventBeginCheckout, params: ecommerce)
    }
    
    // FIXME:GA#45
    func sendGAContinue() {
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(campaignId ?? "0")" as NSString,
            AnalyticsParameterItemName: "\(bzbsCampaign.name ?? "")" as NSString,
            AnalyticsParameterItemCategory: "reward/coins/\(bzbsCampaign.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue)" as NSString,
            AnalyticsParameterItemBrand: "\(bzbsCampaign.agencyName ?? "")" as NSString,
            AnalyticsParameterPrice: 0 as NSNumber,
            AnalyticsParameterCurrency: "THB" as NSString,
            AnalyticsParameterQuantity: 1 as NSNumber,
            AnalyticsParameterIndex: NSNumber(value: 1),
            "metric1" : (bzbsCampaign.pointPerUnit ?? 0) as NSNumber
        ]
        
        let ecommerce : [String:AnyObject] = [
            "items" : [reward1] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_button" as NSString,
            "eventLabel" : "redeem_shipping | coins | \(bzbsCampaign.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue)| 1 | \(bzbsCampaign.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: getPreviousScreenName() as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventAddShippingInfo, params: ecommerce)
    }
    
    // FIXME:GA#46
    func sendGAConfirm() {
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(campaignId ?? "0")" as NSString,
            AnalyticsParameterItemName: "\(bzbsCampaign.name ?? "")" as NSString,
            AnalyticsParameterItemCategory: "reward/coins/\(bzbsCampaign.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue)" as NSString,
            AnalyticsParameterItemBrand: "\(bzbsCampaign.agencyName ?? "")" as NSString,
            AnalyticsParameterPrice: 0 as NSNumber,
            AnalyticsParameterCurrency: "THB" as NSString,
            AnalyticsParameterQuantity: 1 as NSNumber,
            AnalyticsParameterIndex: NSNumber(value: 1),
            "metric1" : (bzbsCampaign.pointPerUnit ?? 0) as NSNumber
        ]
        
        let ecommerce : [String:AnyObject] = [
            "items" : [reward1] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_button" as NSString,
            "eventLabel" : "redeem_payment/coin | \(bzbsCampaign.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue) | 1 | \(bzbsCampaign.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: getPreviousScreenName().lowercased() as NSString,
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventAddPaymentInfo, params: ecommerce)
        
    }
    
    // FIXME:GA#48
    func sendGARedeemLineFail(strMessage:String) {
        analyticsSetEvent(event: "event_app", category: "reward", action: "seen_text", label: "line_sticker_error | \(bzbsCampaign.ID ?? -1) | \(strMessage)")
    }
    
//    func sendGAThankyouPage(_ redeemKey:String?) {
//
//        var reward1 = [String:AnyObject]()
//        reward1[AnalyticsParameterItemID] = "\(bzbsCampaign.ID ?? 0)" as AnyObject
//        reward1[AnalyticsParameterItemName] = bzbsCampaign.name as AnyObject
//        reward1[AnalyticsParameterItemCategory] = "reward/coins/\(bzbsCampaign.categoryName ?? "")".lowercased() as AnyObject
//        reward1[AnalyticsParameterItemBrand] = bzbsCampaign.agencyName as AnyObject
//        reward1[AnalyticsParameterPrice] = 0 as NSNumber
//        reward1[AnalyticsParameterCurrency] = "THB" as NSString
//        reward1[AnalyticsParameterQuantity] = 1 as NSNumber
//        reward1[AnalyticsParameterIndex] = NSNumber(value: 1)
////        reward1[AnalyticsParameterItemVariant] = (campaign.expireIn?.toTimeString() ?? "") as AnyObject
//        reward1["metric1"] = (bzbsCampaign.pointPerUnit ?? 0) as AnyObject
//
//        // Prepare ecommerce dictionary.
//        let items : [Any] = [reward1]
//
//        let ecommerce : [String:AnyObject] = [
//            "items" : items as AnyObject,
//            "eventCategory" : "reward" as NSString,
//            "eventAction" : "seen_text" as NSString,
//            "eventLabel" : "redeem_complete | \(bzbsCampaign.ID ?? -1)" as NSString,
//            AnalyticsParameterItemListName: getPreviousScreenName().lowercased() as NSString,
//            AnalyticsParameterTransactionID: "\(redeemKey ?? "-")" as NSString
//
//        ]
//
//        // Log select_content event with ecommerce dictionary.
//        analyticsSetEventEcommerce(eventName: AnalyticsEventPurchase, params: ecommerce)
//
//        analyticsSetEventEcommerce(eventName: AnalyticsEventSpendVirtualCurrency, params: [
//             AnalyticsParameterItemName : "\(bzbsCampaign.ID ?? -1) | \(bzbsCampaign.name ?? "")" as NSString,
//             AnalyticsParameterItemVariant : bzbsCampaign.agencyName as NSString,
//             AnalyticsParameterVirtualCurrencyName : "Coin" as NSString,
//             AnalyticsParameterValue: (bzbsCampaign.pointPerUnit ?? 0) as NSNumber,
//             AnalyticsParameterTransactionID: "\(redeemKey ?? "-")" as NSString
//         ])
//
//
//        let gaLabel = "redeem_complete | \(bzbsCampaign.ID ?? -1) | \(bzbsCampaign.pointPerUnit ?? 0)"
//        analyticsSetEvent(event: AnalyticsEventPurchase, category: "reward", action: "seen_text", label: gaLabel)
//        analyticsSetEvent(event: AnalyticsEventSpendVirtualCurrency, category: "reward", action: "seen_text", label: gaLabel)
//
//        //Push to Front-End Team
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMdd"
//        analyticsSetUserProperty(propertyName: "last_redeem_coin", value: "\(formatter.string(from: Date()))")
//        analyticsSetUserProperty(propertyName: "remaining_coin", value: "\((Bzbs.shared.userLogin?.bzbsPoints ?? 0) - bzbsCampaign.pointPerUnit)")
//    }
    
}
