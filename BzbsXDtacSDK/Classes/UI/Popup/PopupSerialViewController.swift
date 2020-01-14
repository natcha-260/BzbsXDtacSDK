//
//  HistoryViewPopupExpiredController.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 2/10/2562 BE.
//

import UIKit
import AlamofireImage
import FirebaseAnalytics

protocol PopupSerialDelegate {
    func didClosePopup()
}

class PopupSerialViewController: BzbsXDtacBaseViewController {
    
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var vwQrShadow: UIView!
    @IBOutlet weak var imgQRcode: UIImageView!
    @IBOutlet weak var imgBarcode: UIImageView!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var vwTimer: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var imvExpireOverlay: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var vwCopy: UIView!
    @IBOutlet weak var lblCopy: UILabel!
    @IBOutlet weak var vwBtnUse: UIView!
    @IBOutlet weak var lblBtnUse: UILabel!
    @IBOutlet weak var imvSeasonHeader: UIImageView!
    @IBOutlet weak var imvSeasonBG: UIImageView!
    @IBOutlet weak var imvDecoTop: UIImageView!
    @IBOutlet weak var imvDecoBottom: UIImageView!
    @IBOutlet weak var scollView: UIScrollView!
    
    @IBOutlet weak var cstNameTop: NSLayoutConstraint! // 24
    @IBOutlet weak var cstAgencyBottom: NSLayoutConstraint! // 4
    @IBOutlet weak var cstQRWidth: NSLayoutConstraint!
    
    @IBOutlet weak var cstWidthPad: NSLayoutConstraint!
    @IBOutlet weak var cstWidthPhone: NSLayoutConstraint!
    @IBOutlet weak var cstPopupContentHeight: NSLayoutConstraint!
    @IBOutlet weak var cstBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var vwNotiCopy: UIView!
    @IBOutlet weak var lblNotiCopy: UILabel!
    
    var delegate :PopupSerialDelegate?
    
    var timer :Timer?
    var expireIn : Double? = 70
    var countDown: Int = 0
    
    var purchase: BzbsHistory?
    
    var isNeedUpdate = false
    
    // MARK:- View life cycle
    // MARK:-
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if cstWidthPhone != nil && cstWidthPhone.isActive {
                cstWidthPhone.isActive = false
            }
        } else {
            if cstWidthPad != nil && cstWidthPad.isActive {
                cstWidthPad.isActive = false
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delay(0.33) {
            UIView.animate(withDuration: 0.33) {
                self.vwContent.alpha = 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContent.alpha = 0
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        vwNotiCopy.cornerRadius(corner: 25)
        vwNotiCopy.alpha = 0
        
        let color = UIColor.popupBGCustomer
//        if let level = Bzbs.shared.userLogin?.dtacLevel
//        {
//            switch level {
//            case .blue :
//                color = UIColor.popupBGBlue
//                break
//            case .gold :
//                color = UIColor.popupBGGold
//                break
//            case .silver :
//                color = UIColor.popupBGSilver
//                break
//            case .customer :
//                color = UIColor.popupBGCustomer
//                break
//            case .no_level :
//                color = UIColor.popupBGCustomer
//                break
//            }
//        }
        viewBG.backgroundColor = color
        viewMain.cornerRadius(corner: 8, borderWidth: 1)
        vwContent.cornerRadius(corner: 8, borderWidth: 1)
        imvExpireOverlay.alpha = 0
        lblCopy.font = UIFont.mainFont()
        lblBtnUse.font = UIFont.mainFont()
        lblTimeValue.font = UIFont.mainFont()
        lblTime.font = UIFont.mainFont(.xxsmall)
        lblCode.font = UIFont.mainFont()
        lblName.font = UIFont.mainFont()
        lblNotiCopy.font = UIFont.mainFont()
        if UIDevice.current.deviceName() == .iPhone_5_or_5S_or_5C
        {
            lblName.font = UIFont.mainFont(.small)
        }
        lblAgency.font = UIFont.mainFont(.xsmall)
        
        lblCopy.textColor = .mainGray
        lblBtnUse.textColor = .mainGray
        lblTimeValue.textColor = .mainBlue
        lblTime.textColor = .mainGray
        lblCode.textColor = .mainBlue
        lblName.textColor = .white
        lblAgency.textColor = .white
        lblBtnUse.adjustsFontSizeToFitWidth = true
        
        vwBtnUse.cornerRadius(borderColor: UIColor.mainGray, borderWidth: 1)
        vwCopy.cornerRadius(borderColor: UIColor.mainGray, borderWidth: 1)
        
        imvSeasonHeader.image = UIImage(named: "img_header", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        imvSeasonBG.image = UIImage()
        imvDecoTop.image = UIImage()
        imvDecoBottom.image = UIImage()
        vwQrShadow.addShadow(shadowRadius: 4)
        
        let bgStrUrl = BuzzebeesCore.blobUrl + "/dtac/redeem/edge.png?time=" + Date().toString()
        imvSeasonBG.bzbsSetImage(withURL: bgStrUrl)

        let headerStrUrl = BuzzebeesCore.blobUrl + "/dtac/redeem/header.png?time=" + Date().toString()
        imvSeasonHeader.bzbsSetImage(withURL: headerStrUrl)
        
        let decoTopStrUrl = BuzzebeesCore.blobUrl + "/dtac/redeem/decoration1.png?time=" + Date().toString()
        imvDecoTop.bzbsSetImage(withURL: decoTopStrUrl)
        
        let decoBottomStrUrl = BuzzebeesCore.blobUrl + "/dtac/redeem/decoration2.png?time=" + Date().toString()
        imvDecoBottom.bzbsSetImage(withURL: decoBottomStrUrl)
        
        if UIDevice.current.deviceName() == .iPhone_XR_11
        {
            cstNameTop.constant = 24 + 25
            cstAgencyBottom.constant = 25
            cstQRWidth.constant = 25
        }
        sendGABeginEvent()
        analyticsSetScreen(screenName: "dtac_reward_redeem")
    }
    
    func sendGABeginEvent()
    {
        let screenName = "dtac_reward"
        let reward1 : [String : AnyObject] = [
            AnalyticsParameterItemID : (purchase?.ID ?? -1) as AnyObject,
            AnalyticsParameterItemName : (purchase?.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(purchase?.categoryID ?? -1)" as AnyObject,
            AnalyticsParameterItemBrand: (purchase?.agencyName ?? "") as AnyObject,
            AnalyticsParameterIndex: "1" as AnyObject
        ]
        let ecommerce : [String:AnyObject] = [
            "items" : reward1  as AnyObject,
            AnalyticsParameterItemList : screenName as AnyObject,
            AnalyticsParameterCheckoutStep: 1 as AnyObject,
            AnalyticsParameterCheckoutOption: "Create Code" as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventBeginCheckout, params: ecommerce)
    }
    
    func sendGAUseEvent()
    {
        let screenName = "dtac_reward"
        let reward1 : [String : AnyObject] = [
            AnalyticsParameterItemID : (purchase?.ID ?? -1) as AnyObject,
            AnalyticsParameterItemName : (purchase?.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(purchase?.categoryID ?? -1)" as AnyObject,
            AnalyticsParameterItemBrand: (purchase?.agencyName ?? "") as AnyObject,
            AnalyticsParameterIndex: "1" as AnyObject
        ]
        
        let ecommerce : [String:AnyObject] = [
            "items" : reward1  as AnyObject,
            AnalyticsParameterItemList : screenName as AnyObject,
            AnalyticsParameterTransactionID: (purchase?.privilegeMessage ?? purchase?.serial ?? "XXXXXXXX") as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventEcommercePurchase, params: ecommerce)
    }
    
    override func updateUI() {
        super.updateUI()
        lblCopy.text = "popup_serial_copy".localized()
        lblTime.text = "popup_serial_time_out".localized()
        lblBtnUse.text = "popup_serial_staff_use".localized()
        lblNotiCopy.text = "popup_seiral_code_copied".localized()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(apiUse), name: NSNotification.Name.BzbsViewDidBecomeActive, object: nil)
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BzbsViewDidBecomeActive, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        initUI()
        if isNeedUpdate {
            apiUse()
        } 
    }
    
    func initUI()
    {
        if let expireIn = purchase?.expireIn, expireIn != -1
        {
            self.expireIn = expireIn
            updateTimer()
            startTimer()
        } else {
            vwTimer.isHidden = true
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        countDown = 1
    }
    
    @objc func updateTimer() {
        var remain = Int(expireIn!) - countDown
        if remain < 0 {
            remain = 0
        }
        if remain <= 0 {
            timer?.invalidate()
            timer = nil
            purchase?.privilegeMessage = "XXXXXXXX"
            purchase?.serial = "XXXXXXXX"
            setupUI()
        }
        countDown += 1
        let sec = remain % 60
        let min = remain / 60
        let str = String(format: "%02d : %02d", min,sec)
        print(str)
        lblTimeValue.text = str
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI() {
        
        let remain = Int(expireIn!) - countDown
        if let _ = purchase?.arrangedDate {
            purchase?.privilegeMessage = "XXXXXXXX"
            purchase?.serial = "XXXXXXXX"
            imvExpireOverlay.alpha = 1
            var imageName = "img_icon_redeem_sucessed"
            if LocaleCore.shared.getUserLocale() == BBLocaleKey.th.rawValue {
                imageName = "img_icon_redeem_sucessed_thai"
            }
            imvExpireOverlay.image = UIImage(named: imageName, in: Bzbs.shared.currentBundle, compatibleWith: nil)
            lblTime.textColor = .red
            lblCode.textColor = .red
            vwBtnUse.isHidden = true
            vwTimer.isHidden = true
            vwCopy.isHidden = true
            UIPasteboard.general.string = ""
            cstBtnBottom.constant = (vwBtnUse.frame.size.height + 8) * -1
        } else if expireIn! <= 0.0 || remain <= 0{
            purchase?.privilegeMessage = "XXXXXXXX"
            purchase?.serial = "XXXXXXXX"
            imvExpireOverlay.alpha = 1
            var imageName = "img_icon_redeem_expired"
            if LocaleCore.shared.getUserLocale() == BBLocaleKey.th.rawValue {
                imageName = "img_icon_redeem_expired_thai"
            }
            imvExpireOverlay.image = UIImage(named: imageName, in: Bzbs.shared.currentBundle, compatibleWith: nil)
            lblTime.textColor = .red
            lblCode.textColor = .red
            vwBtnUse.isHidden = true
            vwTimer.isHidden = true
            vwCopy.isHidden = true
            UIPasteboard.general.string = ""
            cstBtnBottom.constant = (vwBtnUse.frame.size.height + 8) * -1
        }
        lblName.text = purchase?.name ?? "-"
        lblAgency.text = purchase?.agencyName ?? ""
        lblCode.text = purchase?.privilegeMessage ?? purchase?.serial ?? "XXXXXXXX"
        imgQRcode.image = Barcode.qrcodeFromString(purchase?.privilegeMessage ?? purchase?.serial ?? "-" , width: self.viewMain.frame.width/2, height: self.viewMain.frame.width/2)
        imgQRcode.addShadow()
        imgBarcode.image = Barcode.barcodeFromString(purchase?.privilegeMessage ?? purchase?.serial ?? "-", width: self.viewMain.frame.width - 16, height: self.viewMain.frame.width/2)
        
        let contentHeight = scollView.contentSize.height
        if cstPopupContentHeight.constant != contentHeight
        {
            if contentHeight > 325 {
                cstPopupContentHeight.constant = contentHeight
            }
        }

        UIView.animate(withDuration: 0.33) {
            self.vwContent.layoutIfNeeded()
        }
    }
    
    // MARK:- Api
    // MARK:-
    func apiStaffUse()
    {
        if let redeemKey = purchase!.redeemKey
        {
            showLoader()
            BzbsCoreApi().usedByStaff(Bzbs.shared.userLogin?.token,keyId:redeemKey , successCallback: { (result) in
                self.purchase?.arrangedDate = Date().timeIntervalSince1970
                self.expireIn = 0
                self.setupUI()
                self.hideLoader()
            }) { (error) in
                self.hideLoader()
                PopupManager.informationPopup(self, title: "Error", message: error.message) { () in }
            }
        }
    }
    
    // เพื่ออัพเดต expireIn กับ arrangeDate
    @objc func apiUse()
    {
        if let redeemKey = purchase?.redeemKey, let token = Bzbs.shared.userLogin?.token
        {
            showLoader()
            BzbsCoreApi().useCampaign(token:token , redeemKey: redeemKey, successCallback: { (dict) in
                let tmpItem = BzbsHistory(dict: dict)
                self.purchase?.expireIn = tmpItem.expireIn
                self.purchase?.arrangedDate = tmpItem.arrangedDate
                self.countDown = 1
                self.timer?.invalidate()
                self.timer = nil
                self.initUI()
                self.delay(1) {
                    self.hideLoader()
                }
            }) { (error) in
                self.purchase?.expireIn = -999
//                self.purchase?.arrangedDate = Date().timeIntervalSince1970
                self.countDown = 1
                self.timer?.invalidate()
                self.timer = nil
                self.initUI()
                self.delay(1) {
                    self.hideLoader()
                }
            }
        } else {
            clickClose(UIButton())
        }
    }

    
    // MARK:- Event click
    // MARK:-
    @IBAction func clickClose(_ sender: Any) {
        timer?.invalidate()
        timer = nil
//        self.view.removeFromSuperview()
        delegate?.didClosePopup()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickCopy(_ sender: Any) {
        UIPasteboard.general.string = purchase?.privilegeMessage ?? purchase?.serial ?? ""
        showCopylabel()
//        PopupManager.informationPopup(self, title: nil, message: "Serial copied", close: nil)
    }
    
    var isShowingCopy = false
    func showCopylabel()
    {
        if isShowingCopy { return }
        isShowingCopy = true
        vwNotiCopy.alpha = 1
        delay(2) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.33) {
                    self.vwNotiCopy.alpha = 0
                    self.isShowingCopy = false
                }
            }
        }
    }
    
    @IBAction func clickUse(_ sender: Any) {
        if let _ = purchase?.arrangedDate {
            return
        } else if let expireIn = purchase?.expireIn{
            let remain = Int(expireIn) - countDown
            if expireIn <= 0 || remain <= 0
            {
                return
            }
        }
        PopupManager.confirmPopup(self, title: "popup_confirm".localized(), message: purchase?.name ?? "-", confirm: {
            self.apiStaffUse()
        }) {
            
        }
    }
}

// Keep ratio while fix width
class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width

            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
}

extension Date{
    func toString(format:String = "ddMMyyyy") -> String{
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        dateFormat.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}

enum EnumDeviceName {
    case iPhone_5_or_5S_or_5C
    case iPhone_6_6S_7_8
    case iPhone_6_plus_6S_plus_7_plus_8_plus
    case iPhone_X_XS_11_Pro
    case iPhone_XS_Max_11_Pro_Max
    case iPhone_XR_11
    case unknown
}

extension UIDevice
{
    
    func deviceName() -> EnumDeviceName
    {
        if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
            case 1136:
                return .iPhone_5_or_5S_or_5C
            case 1334:
                return .iPhone_6_6S_7_8
            case 1920, 2208:
                return .iPhone_6_plus_6S_plus_7_plus_8_plus
            case 2436:
                return .iPhone_X_XS_11_Pro
            case 2688:
                return .iPhone_XS_Max_11_Pro_Max
            case 1792:
                return .iPhone_XR_11
            default:
                return .unknown
            }
        }
        return .unknown
    }
}