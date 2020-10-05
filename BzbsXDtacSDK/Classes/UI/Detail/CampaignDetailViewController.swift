//
//  CampaignDetailViewController.swift
//  Pods
//
//  Created by macbookpro on 1/10/2562 BE.
//

import ImageSlideshow
import UIKit
import CoreLocation
import FirebaseAnalytics

enum DetailTab {
    case detail
    case condition
    case branch
}

public class CampaignDetailViewController: BzbsXDtacBaseViewController {
    // MARK:- Properties
    var campaignStatus : CampaignStatus?
    
    // MARK:- Outlet
    @IBOutlet weak var vwNav: UIView!
    @IBOutlet weak var vcLeft: UIView!
    @IBOutlet weak var lblLeft: UILabel!
    
    @IBOutlet weak var vcRight: UIView!
    @IBOutlet weak var lblRight: UILabel!
    @IBOutlet weak var vwLike: UIView!
    @IBOutlet weak var imvLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var vwShare: UIView!
    @IBOutlet weak var vwHistory: UIView!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    @IBOutlet weak var vwButton: UIView!
    @IBOutlet weak var imvCoin: UIImageView!
    @IBOutlet weak var cstCoinHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(CampaignDetailRotateCell.getNib(), forCellReuseIdentifier: "campaignRotateCell")
            tableView.register(EmptyTVCell.getNib(), forCellReuseIdentifier: "emptyCell")
        }
    }
    
    // MARK:- Variable
    var campaign: BzbsCampaign!
    var listImageCampaign = [AlamofireSource]()
    var viewImageSlideshow: ImageSlideshow!
    var isShowTab = DetailTab.detail
    var rewardLeft:CGFloat{
//        if campaign.type == 9 { return 1 }
        if let quantity = campaignStatus?.quantity {
            if quantity == -1 { return 1 }
            if quantity >= 51 || quantity <= -1 {
                return 1
            } else if quantity >= 21 && quantity < 51 {
                return 0.5
            } else if quantity < 21 {
                if quantity == 0 {
                    return 0
                }
                return 0.25
            }
            
        }
        return 0.0
        
        
    }
    
    var isCallingApiRedeem = false
    var isCallingCampaignDetail = false
    var arrBranch = [Branch]()
    
    var cellList = ["image_name","info","line","tab","detail"]
    
    // MARK:- Life Cycle
    // MARK:-
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cstCoinHeight.constant = isRedeemCoinCampaign() ? 25 : 0
        
        if let type = self.campaign.type, type == 16 {
            self.cellList = ["image_name_detail","line","detail"]
            analyticsSetScreen(screenName: "dtac_reward_blue_detail")
            isShowTab = .condition
        } else {
            analyticsSetScreen(screenName: "dtac_reward_detail")
        }
        manageFooter()
        initialUI()
        
        lblLike.font = UIFont.mainFont(.xsmall)
        lblHistory.font = UIFont.mainFont(.xsmall)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetAPI), name: NSNotification.Name.BzbsApiReset, object: nil)
        
        if Bzbs.shared.isLoggedIn() {
            resetAPI()
        } else {
            showLoader()
//            checkAPI()
        }
    }
    
    
    let gradient: CAGradientLayer = CAGradientLayer()
    public override func viewDidLayoutSubviews() {
        
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = vwNav.bounds
        
        vwNav.layer.insertSublayer(gradient, at: 0)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func updateUI() {
        super.updateUI()
        self.tableView.reloadData()
        lblLike.text = "campaign_detail_like".localized()
        lblHistory.text = "campaign_detail_history".localized()
        resetAPI()
    }
    
    func checkAPI() {
        if Bzbs.shared.isCallingLogin {
            Bzbs.shared.delay(0.1) {
                self.checkAPI()
            }
        } else {
            if Bzbs.shared.isLoggedIn() {
                self.resetAPI()
            } else {
                Bzbs.shared.relogin(completionHandler: {
                    self.resetAPI()
                }) { (_) in
                    self.hideLoader()
                }
            }
        }
    }
    
    // MARK:- Class function
    // MARK:-
    @objc public class func getView(campaignId:String) -> CampaignDetailViewController
    {
        let storyboard = UIStoryboard(name: "Campaign", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "scene_campaign_detail") as! CampaignDetailViewController
        let campaign = BzbsCampaign()
        campaign.ID = Int(campaignId)!
        controller.campaign = campaign
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        return controller
    }
    
    @objc public class func getViewWithNavigationBar(campaignId:String, isHideNavigationBar:Bool = true) -> UINavigationController
    {
        let nav = UINavigationController(rootViewController: getView(campaignId:campaignId))
        nav.isNavigationBarHidden = isHideNavigationBar
        nav.navigationBar.backgroundColor = .white
        nav.navigationBar.tintColor = .mainBlue
        nav.navigationBar.barTintColor = .white
        return nav
    }
    
    // MARK:- API
    // MARK:-
    
    @objc func resetAPI()
    {
        isLoadedStatus = false
        manageFooter()
        getApiCampaignDetail()
    }
    
    func setupNav()
    {
        imvLike.image = UIImage(named: self.campaign.isFavourite ? "img_navbar_icon_fav_active" : "img_navbar_icon_fav_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        if campaign.type! == 16 || isRedeemCoinCampaign() {
            vwLike.isHidden = true
        } else {
            vwLike.isHidden = false
        }
    }
    
    // MARK:- Call Api
    // MARK:-
    
    func getApiCampaignDetail() {
        if isCallingCampaignDetail { return }
        isCallingCampaignDetail = true
        showLoader()
        BuzzebeesCampaign().detail(campaignId: campaign.ID
            , deviceLocale: String(LocaleCore.shared.getUserLocale())
            , configRelate: nil
            , center : LocationManager.shared.getCurrentCoorndate()
            , token: Bzbs.shared.userLogin?.token
            , successCallback: { (itemCampaign) in
                self.isCallingCampaignDetail = false
                self.campaign = itemCampaign
                if self.campaign.condition == "-"
                {
                    self.cellList = ["image_name_detail"]
                }
                self.sendGAViewEvent()
                self.assignImageSlideShow()
                self.setupNav()
                self.manageFooter()
                self.getApiBranch()
                
                DispatchQueue.main.async(execute: {
                    if self.campaign.type! == 16 {
                        self.cstBottom.constant = -1 * self.vwButton.bounds.height
                        self.vwButton.isHidden = true
                    }
                    self.tableView.reloadData()
                })

                self.getCacheStatus()
        }) { (error) in

            self.isCallingCampaignDetail = false
            if error.id == "-9999"
            {
                if Bzbs.shared.isDebugMode
                {
                    print(error.code ?? "-", error.message ?? "-")
                }
                return
            }

            if !self.isConnectedToInternet() {
                self.showPopupInternet(){
                    self.back_1_step()
                }
            } else {
                if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                PopupManager.informationPopup(self, title: nil, message: "alert_error_campaign_detail".errorLocalized()) { () in
                    self.back_1_step()
                }
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            self.hideLoader()
        }
    }
    
    var isLoadedStatus = false
    
    func getCacheStatus(){
        CacheCore.shared.loadCacheData(key: BBCache.keys.statusCampaign, customKey: "\(campaign.ID!)", successCallback: { (ao) in
            if let dict = ao as? Dictionary<String, AnyObject> {
                self.campaignStatus = CampaignStatus(dict: dict)
                self.manageFooter()
                self.tableView.reloadData()
                self.hideLoader()
            } else {
                self.getApiCampaignStatus()
            }
        }) {
            self.getApiCampaignStatus()
        }
    }
    func getApiCampaignStatus() {
        if campaign.type == 16 {
            self.manageFooter()
            self.tableView.reloadData()
            self.hideLoader()
            return
        }
        
        if let token = Bzbs.shared.userLogin?.token
        {
            if Bzbs.shared.isDebugMode
            {
                let strUrl = BuzzebeesCore.inquiryBaseUrl + "/modules/dtac/campaign/\(campaign.ID ?? 0)"
                let lbl = UILabel(frame: self.view.bounds)
                lbl.text = strUrl
                lbl.textColor = .white
                lbl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                lbl.numberOfLines = 0
                lbl.font = UIFont.mainFont()
                lbl.sizeToFit()
                let width = lbl.bounds.size.width - 32
                let height =  lbl.bounds.size.height
                lbl.frame = CGRect(
                    x: (self.view.bounds.size.width - width - 16) / 2,
                    y: (self.view.bounds.size.height - height - 16),
                    width: width,
                    height: height)
                let window = UIApplication.shared.keyWindow!
                window.addSubview(lbl)
                window.bringSubviewToFront(lbl)
                delay(3.0) {
                    UIView.animate(withDuration: 0.33, animations: {
                        lbl.alpha = 0
                    }) { (_) in
                        lbl.removeFromSuperview()
                    }
                }
            }
            BzbsCoreApi().getCampaignStatus(campaignId: campaign.ID,
                                                   deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                                   center: LocationManager.shared.getCurrentCoorndate(),
                                                   token: token,
                                                   successCallback: { (status, dict) in
                                                    self.isLoadedStatus = true
                                                    self.campaignStatus = status
                                                    if status.quantity == 0 {
                                                        CacheCore.shared.saveCacheData(dict as AnyObject, key: BBCache.keys.statusCampaign,  customKey: "\(self.campaign.ID!)" , lifetime: BuzzebeesCore.cacheTimeQuota)
                                                    }
                                                    self.manageFooter()
                                                    self.tableView.reloadData()
                                                    self.hideLoader()
            },
                                                   failCallback: { (error) in
                                                    self.isLoadedStatus = true
                                                    self.campaignStatus = nil
                                                    self.manageFooter()
                                                    self.tableView.reloadData()
                                                    self.hideLoader()
                                                    
                                                    if Int(error.id)! == 412 || Int(error.code)! == 412
                                                    {
                                                        PopupManager.informationPopup(self, message: "alert_error_query_privilege_412".errorLocalized()) {
                                                            self.vcRight.isUserInteractionEnabled = false
                                                            self.vcRight.backgroundColor = UIColor.mainLightGray
                                                        }
                                                        return
                                                    }
                                                    
                                                    if Int(error.id)! == 428 || Int(error.code)! == 428
                                                    {
                                                        PopupManager.informationPopup(self, message: "alert_error_query_privilege_428".errorLocalized()) {
                                                            self.vcRight.isUserInteractionEnabled = false
                                                            self.vcRight.backgroundColor = UIColor.mainLightGray
                                                        }
                                                        return
                                                    }
                                                    
                                                    
                                                    if Int(error.id)! == 500 || Int(error.code)! == 500
                                                    {
                                                        PopupManager.informationPopup(self, title: nil, message: "alert_error_campaign_detail".errorLocalized()) { () in
                                                            self.vcRight.isUserInteractionEnabled = false
                                                            self.vcRight.backgroundColor = UIColor.mainLightGray
                                                        }
                                                        return
                                                    }
                                                    
                                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }

            })
        } else {
            if Bzbs.shared.isCallingLogin {
                delay(0.33) {
                    self.getApiCampaignStatus()
                }
            }
            self.hideLoader()
        }
    }
    
    func getApiBranch()
    {
//        return
        if let agencyID = campaign.locationAgencyId ?? campaign.agencyID
        {
            let coordinate = LocationManager.shared.getCurrentCoorndate()
            BzbsCoreApi().getBranch(strBzbsToken: Bzbs.shared.userLogin?.token
                , strAgencyId: "\(agencyID)", strCampaignId: nil, strDistance: nil, strMode: nil // "nearby"
                , strCenter: coordinate, strSearch: nil, strDeviceLocale: "\(LocaleCore.shared.getUserLocale())"
                , successCallback: { (tmpBranchList, _) in
                    self.arrBranch = tmpBranchList
                    self.tableView.reloadData()
            }) { (error) in
                self.arrBranch.removeAll()
                self.tableView.reloadData()
            }
        } else {
            self.arrBranch.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func apiRedeem()
    {
        guard let token = Bzbs.shared.userLogin?.token else { return }
        isCallingApiRedeem = true
        manageFooter()
        showLoader()
        if Bzbs.shared.isDebugMode
        {
            let strUrl = BuzzebeesCore.redeemBaseUrl + "/api/campaign/\(campaign.ID ?? 0)/redeem"
            let lbl = UILabel(frame: self.view.bounds)
            lbl.text = strUrl
            lbl.textColor = .white
            lbl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            lbl.numberOfLines = 0
            lbl.font = UIFont.mainFont()
            lbl.sizeToFit()
            let width = lbl.bounds.size.width - 32
            let height =  lbl.bounds.size.height
            lbl.frame = CGRect(
                x: (self.view.bounds.size.width - width - 16) / 2,
                y: (self.view.bounds.size.height - height - 16),
                width: width,
                height: height)
            let window = UIApplication.shared.keyWindow!
            window.addSubview(lbl)
            delay(3.0) {
                UIView.animate(withDuration: 0.33, animations: {
                    lbl.alpha = 0
                }) { (_) in
                    lbl.removeFromSuperview()
                }
            }
        }
        BuzzebeesCampaign().redeem(token:token , campaignId: campaign.ID, successCallback: { (dict) in
            self.hideLoader()
            let purchase = BzbsHistory(dict: dict)
            self.sendGAThankyouPage(purchase.redeemKey)
            if self.campaign.categoryID == BuzzebeesCore.catIdVoiceNet {
                PopupManager.subscriptionPopup(onView: self, purchase: purchase)
            } else {
                PopupManager.serialPopup(onView: self, purchase: purchase)
            }
            self.isCallingApiRedeem = false
        }) { (error) in
            self.hideLoader()
            self.refreshApi()
            self.isCallingApiRedeem = false
            
            if Int(error.id)! == 412 || Int(error.code)! == 412 {
                PopupManager.informationPopup(self, message: error.message) {
                    self.vcRight.isUserInteractionEnabled = false
                    self.vcRight.backgroundColor = UIColor.mainLightGray
                }
                return
            }
            
            if Int(error.id)! == 428 || Int(error.code)! == 428
            {
                PopupManager.informationPopup(self, message: "alert_error_redeem_428".errorLocalized(), close: nil)
                return
            }

            if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
            PopupManager.informationPopup(self, title: nil, message: "alert_error_409".errorLocalized(), close: nil)
        }
    }
    
    override func refreshApi() {
        getApiCampaignDetail()
    }
    
    // MARK:- Event
    // MARK:- Click
    @IBAction func clickDetails(_ sender: Any) {
        if isShowTab == DetailTab.detail { return }
        
        isShowTab = DetailTab.detail
        tableView.reloadData()
//        if let index = cellList.firstIndex(of: "tab")
//        {
//            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableView.ScrollPosition., animated: true)
//        }
    }
    
    @IBAction func clickConditions(_ sender: Any) {
        if isShowTab == DetailTab.condition { return }
        
        isShowTab = DetailTab.condition
        tableView.reloadData()
//        if let index = cellList.firstIndex(of: "tab")
//        {
//            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableView.ScrollPosition.none, animated: true)
//        }
    }
    
    @IBAction func clickBranch(_ sender: Any) {
        if isShowTab == DetailTab.branch { return }
        
        isShowTab = DetailTab.branch
        tableView.reloadData()
//        if let index = cellList.firstIndex(of: "tab")
//        {
//            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableView.ScrollPosition.none, animated: true)
//        }
    }
    
    @IBAction func clickBack(_ sender: Any) {
        back_1_step()
    }
    
    @IBAction func clickLike(_ sender: Any) {
        if let token = Bzbs.shared.userLogin?.token
        {
            sendGALike()
            showLoader()
            BuzzebeesCampaign().favourite(token: token, campaignId: campaign.ID, isFav: !(campaign.isFavourite ?? false), successCallback: { (str) in
                self.hideLoader()
                self.getApiCampaignDetail()
            }) { (error) in
                self.hideLoader()
            }
        }
    }
    
    @IBAction func clickShare(_ sender: Any) {
        sendGAShare()
        let webUrl = BuzzebeesCore.shareUrl + "/dtac/landing.aspx?id=" + String(campaign.ID)
        if let url = URL(string: webUrl)
        {
            let items = [url]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = sender as! UIButton
            present(ac, animated: true)
        }
    }
    
    @IBAction func clickHistory(_ sender: Any) {
        guard let nav = self.navigationController else {return}
        GotoPage.gotoHistory(nav)
    }
    
    @IBAction func clickLeft(_ sender: Any) {
        back_1_step()
    }
    
    @IBAction func clickRedeem(_ sender: Any) {
        
        if let type = campaign.type, type == 9 || isCallingApiRedeem {
            return
        }
        
        if let userLogin = Bzbs.shared.userLogin,
            let _ = userLogin.token
        {
            sendGATouchRedeem()
            let dtacLevel = userLogin.dtacLevel
            if dtacLevel == .no_level {
                PopupManager.informationPopup(self, title: nil, message: "popup_dtac_error_no_level".localized(), strClose:"popup_confirm_2".localized()) {
                    self.reLogin()
                }
                return
            }
            if let type = campaign.type
            {
                if let errorcode = campaignStatus?.errorCode,
                    errorcode == "s2009"
                    {
                        PopupManager.informationPopup(self, message: "popup_suspend_info".localized(), strClose:"popup_ok".localized(), close: nil)
                    return
                }
                if type == 1 {
                    var message = "popup_confirm_redeem_prefix".localized() + "\n" + self.campaign.name
                    
                    if isRedeemCoinCampaign() {
                        if let pointPerUnit = campaign.pointPerUnit {
                            if pointPerUnit > (Bzbs.shared.userLogin?.bzbsPoints ?? -1) {
                                return
                            }
                        }
                    
                        let strCoinToRedeem = String(format: "popup_confirm_redeem_coin".localized(), campaign.pointPerUnit.withCommas())
                        message = message + "\n\n" + strCoinToRedeem
                        
                        if let minAfterUse = campaign.minutesValidAfterUsed , minAfterUse > 0 {
                            let strMinAfteruse = String(format: "popup_confirm_redeem_minute_afteruse".localized(), TimeInterval(minAfterUse).toTimeString())
                            message = message + "\n" + strMinAfteruse
                        }
                    }
                    else if let minAfterUse = campaign.minutesValidAfterUsed , minAfterUse > 0 {
                        let strMinAfteruse = String(format: "popup_confirm_redeem_minute_afteruse".localized(), TimeInterval(minAfterUse).toTimeString())
                        message = message + "\n\n" + strMinAfteruse
                    }
                    
                    sendGARedeem()
                    
                    PopupManager.confirmPopup(self, title: "popup_confirm".localized(), message: message, confirm: { () in
                        self.sendGABeginCheckout()
                        self.apiRedeem()
                    }) {
                        
                    }
                }
            }
        } else {
            if !isLoggedIn()
            {
                PopupManager.confirmPopup(self, isWithImage:true, message: "action_click_req_login".errorLocalized()
                    , strConfirm: "popup_retry_login_fail".localized()
                    , strClose: "popup_cancel".localized()
                    , confirm: {
                    Bzbs.shared.delegate?.reTokenTicket()
                }, cancel: nil)
                return
            }
        }
    }
    
    @IBAction func clickSeeMoreDetail(_ sender: Any) {
        let locationAuthStatus = LocationManager.shared.authorizationStatus
        
        if let _ = arrBranch.first, locationAuthStatus != .denied
        {
            var campaignList = [BzbsCampaign]()
            var nearestPlace :BzbsPlace?
            var nearestDistance = Double.greatestFiniteMagnitude
            for branch in arrBranch
            {
                let tmpCampaign = BzbsCampaign(dict: campaign.raw)
                let place = BzbsPlace()
                place.id = branch.id
                place.locationId = campaign.locationAgencyId
                place.name = tmpCampaign.agencyName
                place.name_en = tmpCampaign.agencyName
                place.longitude = branch.longitude
                place.latitude = branch.latitude
                tmpCampaign.places = [place]
                if let currentLocationCoordinate = LocationManager.shared.coordinate
                {
                    if nearestPlace == nil,
                        let location = place.location
                    {
                        nearestPlace = place
                        nearestDistance = CLLocation(withCoodinate: currentLocationCoordinate).distance(from: CLLocation(withCoodinate: location))
                    } else {
                        if let location = place.location
                        {
                            let distance = CLLocation(withCoodinate: currentLocationCoordinate).distance(from: CLLocation(withCoodinate: location))
                            if distance < nearestDistance {
                                nearestDistance = distance
                                nearestPlace = place
                            }
                        }
                    }
                }
                
                campaignList.append(tmpCampaign)
            }

            if let nav = self.navigationController
            {

                let _ = GotoPage.gotoMap(nav, campaigns: campaignList, customHeader: campaign.agencyName, isShowBackToList:false, gotoPin: nearestPlace)

            } 
        }
        else if let website = campaign.website,
            website != ""
        {
            if let url = URL(string: website)
            {
                openWebSite(url)
            } else {
                PopupManager.informationPopup(self, message: "campaign_detail_url_wrong_format".localized(), close: nil)
            }
        }
    }
    
    // MARK:- Init
    // MARK:-
    func initialUI() {
        getApiCampaignDetail()
    }
    
    func initImage() {
        if viewImageSlideshow != nil {
            viewImageSlideshow.contentScaleMode = .scaleAspectFill
            viewImageSlideshow.backgroundColor = UIColor.clear
            viewImageSlideshow.setImageInputs(listImageCampaign)
            viewImageSlideshow.slideshowInterval = 5.0
        }
    }
    
    // MARK:- Image Slide Show
    // MARK:-
    func assignImageSlideShow() {
        let placeholderImage = UIImage(named: "img_placeholder", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        if let strUrl = campaign.fullImageUrl,
            let url = URL(string: strUrl)?.convertCDNAddTime()
        {
            listImageCampaign = [AlamofireSource(url: url, placeholder: placeholderImage)]
        }
        
        if campaign.pictures.count > 1
        {
            listImageCampaign.removeAll()
            
            for item in campaign.pictures
            {
                if let strUrl = item.fullImageUrl ,
                    let url = URL(string: strUrl)?.convertCDNAddTime()
                {
                    listImageCampaign.append(AlamofireSource(url: url))
                }
            }
        }
        
        initImage()
    }
    
    func isRedeemCoinCampaign() -> Bool {
        if campaign.parentCategoryID == BuzzebeesCore.catIdCoin {
            return true
        }
        return false
    }
    
    func isUse3TabInfo() -> Bool {
        if campaign.categoryID == BuzzebeesCore.catIdVoiceNet
        ||  campaign.categoryID == BuzzebeesCore.catIdLineSticker
            {
            return false
        }
        let locationAuthStatus = LocationManager.shared.authorizationStatus
        
        return (locationAuthStatus != .denied && campaign.distance != nil) || (campaign.website != "")
    }
    
    func isUse3Detail() -> Bool {
        if campaign.categoryID == BuzzebeesCore.catIdVoiceNet
            ||  campaign.categoryID == BuzzebeesCore.catIdLineSticker
        {
            return false
        }
        return arrBranch.count > 0
        
    }
    
    // MARK:- Util
    // MARK:-
    func manageFooter(){
        
        cstCoinHeight.constant = isRedeemCoinCampaign() ? 25 : 0
        lblRight.adjustsFontSizeToFitWidth = true
        
        lblLeft.font = UIFont.mainFont()
        lblRight.font = UIFont.mainFont()
        lblRight.textColor = UIColor.white
        lblLeft.textColor = UIColor.lightGray
        vcLeft.cornerRadius(corner: 4.0, borderColor: UIColor.gray, borderWidth: 1.0)
        vcRight.cornerRadius(corner: 4.0)
        
        setButton(isEnable: false)
        
        lblLeft.text = "campaign_detail_back".localized()
        lblRight.text = "campaign_detail_status_redeem".localized()
        if isRedeemCoinCampaign() {
            lblRight.text! += " \(campaign.pointPerUnit.withCommas())"
        }
        
        if let type = campaign.type{
            if type == 1 {
                lblRight.text = "campaign_detail_status_redeem".localized()
                if isRedeemCoinCampaign() {
                    if let pointPerUnit = campaign.pointPerUnit {
                        if pointPerUnit <= (Bzbs.shared.userLogin?.bzbsPoints ?? -1) {
                            lblRight.text! = "campaign_detail_status_redeem".localized() + " \(campaign.pointPerUnit.withCommas())"
                        } else {
                            setButton(isEnable: false)
                            lblRight.textColor = .gray
                            lblRight.text! = "coin_not_enough".localized()
                            cstCoinHeight.constant = 0
                        }
                    }
                }
                vcRight.backgroundColor = UIColor.dtacBlue
                
                if let _campaignStatus = campaignStatus {
                    
                    setButton(isEnable: false)
                    let remark = _campaignStatus.errorCode
                    var msgBtn = "alert_button_redeem_s2001".errorLocalized()
                    
                    switch remark {
                    case "s2001":
                        setButton(isEnable: true)
                        msgBtn = "alert_button_redeem_s2001".errorLocalized()
                        break
                    case "s2002":
                        msgBtn = "alert_button_redeem_s2002".errorLocalized()
                        break
                    case "s2003":
                        msgBtn = "alert_button_redeem_s2003".errorLocalized()
                        break
                    case "s2006":
                        msgBtn = "alert_button_redeem_s2006".errorLocalized()
                        break
                    case "s2007":
                        msgBtn = "alert_button_redeem_s2007".errorLocalized()
                        break
                    case "s2008":
                        msgBtn = "alert_button_redeem_s2008".errorLocalized()
                        break
                    case "s2009":
                        setButton(isEnable: true)
                        msgBtn = "alert_button_redeem_s2009".errorLocalized()
                        break
                    default:
                        // default เป็น case redeem
                        msgBtn = "alert_button_redeem_s2001".errorLocalized()
                        PopupManager.informationPopup(self, message: "alert_button_redeem_default".errorLocalized(), close: nil)
                    }
                    
                    if isRedeemCoinCampaign() && remark == "s2001" {
                        if let pointPerUnit = campaign.pointPerUnit {
                            if pointPerUnit <= (Bzbs.shared.userLogin?.bzbsPoints ?? -1) {
                                msgBtn = "campaign_detail_status_redeem".localized() + " \(campaign.pointPerUnit.withCommas())"
                            } else {
                                setButton(isEnable: false)
                                msgBtn = "coin_not_enough".localized()
                                lblRight.textColor = .gray
                                cstCoinHeight.constant = 0
                            }
                        }
                    } else {
                        cstCoinHeight.constant = 0
                    }
                    
                    lblRight.text = msgBtn
                    
                }
                else {
                    if !isLoadedStatus
                    {
                        if isLoggedIn()
                        {
                            if campaignStatus == nil {
                                if let type = campaign.type{
                                    if type == 9 {
                                        lblRight.text = "campaign_detail_status_use_at_shop".localized()
                                        cstCoinHeight.constant = 0
                                        setButton(isEnable: false)
                                    } else {
                                        
                                        lblRight.text = "campaign_detail_status_redeem".localized()
                                        if isRedeemCoinCampaign() {
                                            if let pointPerUnit = campaign.pointPerUnit {
                                                if pointPerUnit <= (Bzbs.shared.userLogin?.bzbsPoints ?? -1) {
                                                    lblRight.text!  = "campaign_detail_status_redeem".localized() + " \(campaign.pointPerUnit.withCommas())"
                                                } else {
                                                    setButton(isEnable: false)
                                                    lblRight.text! = "coin_not_enough".localized()
                                                    lblRight.textColor = .gray
                                                    cstCoinHeight.constant = 0
                                                }
                                            }
                                        }
                                        
                                        setButton(isEnable: isCallingApiRedeem || isCallingCampaignDetail)
                                    }
                                }
                                return
                            }

                            if let type = campaign.type, type == 9 {
                                lblRight.text = "campaign_detail_status_use_at_shop".localized()
                                cstCoinHeight.constant = 0
                                setButton(isEnable: false)
                                return
                            }
                            vcRight.backgroundColor = UIColor.mainLightGray
                        } else {
                            setButton(isEnable: true)
                        }
                    } else {
                        vcRight.backgroundColor = UIColor.dtacBlue
                    }
                }
            }
            else if type == 9 {
                lblRight.text = "campaign_detail_status_use_at_shop".localized()
                cstCoinHeight.constant = 0
                setButton(isEnable: false)
            }
        }
        
        if isCallingApiRedeem || isCallingCampaignDetail {
            setButton(isEnable: false)
        }
    }
    
    func setButton(isEnable:Bool)
    {
        vcRight.isUserInteractionEnabled = isEnable
        vcRight.backgroundColor = isEnable ? UIColor.dtacBlue : UIColor.mainLightGray
    }
    
    func getProgressColor() -> UIColor {
//        if  campaign.type == 9 {
//            return .mainGreen
//        }
        guard let _campaingStatus = campaignStatus else { return .mainLightGray }
        
        if _campaingStatus.quantity >= 51 || _campaingStatus.quantity <= -1 {
            return .mainGreen
        } else if _campaingStatus.quantity >= 21 && _campaingStatus.quantity < 51 {
            return .mainYellow
        } else if _campaingStatus.quantity < 21 {
            if _campaingStatus.quantity == 0 {
                return .mainLightGray
            }
            return .mainRed
        }
        
        return .mainLightGray
    }
    
}

// MARK:- Extension
// MARK:- UITableViewDelegate, UITableViewDataSource
extension CampaignDetailViewController : UITableViewDelegate, UITableViewDataSource
{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdent = cellList[indexPath.row]
        if cellIdent == "image_name"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImage", for: indexPath)
            
            if let vcImageSlideShow = cell.viewWithTag(10) as? ImageSlideshow {
                viewImageSlideshow = vcImageSlideShow
            }
            
            let imgAgency = cell.viewWithTag(11) as! UIImageView
            if let blobUrl = Bzbs.shared.blobUrl {
                let imageStrUrl = blobUrl + "/agencies/\(campaign.locationAgencyId ?? campaign.agencyID ?? 0)"
                imgAgency.bzbsSetImage(withURL: imageStrUrl)
            }
            
            let lblName = cell.viewWithTag(12) as! UILabel
            lblName.font = UIFont.mainFont()
            lblName.text = campaign.name
            
            let lblAgencyName = cell.viewWithTag(13) as! UILabel
            lblAgencyName.font = UIFont.mainFont(.small)
            lblAgencyName.text = campaign.agencyName
            
            return cell
        }
        
        if cellIdent == "image_name_detail"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImage2", for: indexPath)
            
            if let vcImageSlideShow = cell.viewWithTag(10) as? ImageSlideshow {
                viewImageSlideshow = vcImageSlideShow
            }
            
            let lblName = cell.viewWithTag(12) as! UILabel
            lblName.font = UIFont.mainFont()
            lblName.text = campaign.name
            
            let lblText = cell.viewWithTag(13) as! UILabel
            let txvText = cell.viewWithTag(14) as! UITextView
            lblText.font = UIFont.mainFont()
            lblText.text = campaign.detail
            
            txvText.font = UIFont.mainFont()
            txvText.dataDetectorTypes = [.phoneNumber, .link]
            txvText.isEditable = false
            let attriText = campaign.detail?.htmlToAttributedString
            attriText?.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.mainGray], range: NSRange(location: 0, length: attriText?.length ?? 0))
            lblText.attributedText = attriText
            txvText.attributedText = attriText
            
            return cell
        }
        
        if cellIdent == "info" {
            if isUse3TabInfo()
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo3Tab", for: indexPath)
                
                let lblRewardLeft = cell.viewWithTag(11) as! UILabel
                lblRewardLeft.text = "campaign_detail_reward_left".localized()
                lblRewardLeft.font = UIFont.mainFont(.small)
                
                let lblRewardFull = cell.viewWithTag(111) as! UILabel
                lblRewardFull.text = "campaign_detail_reward_full".localized()
                lblRewardFull.font = UIFont.mainFont(FontSize.xsmall, style: FontStyle.bold)
                lblRewardFull.isHidden = true
                if let quantity = self.campaignStatus?.quantity
                {
                    if quantity <= 0 && quantity != -1{
                        lblRewardFull.isHidden = false
                    } else {
                        lblRewardFull.isHidden = true
                    }
                }
                
                let progressView = cell.viewWithTag(12) as! UIProgressView
                progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                progressView.progress = Float(rewardLeft)
                progressView.progressTintColor = getProgressColor()
                progressView.trackTintColor = UIColor(hexString: "e7e7e7")
                
                let lblExp = cell.viewWithTag(21) as! UILabel
                lblExp.text = "campaign_detail_exp".localized()
                lblExp.font = UIFont.mainFont(.small)
                
                let lblExpDate = cell.viewWithTag(22) as! UILabel
                
                let dateFormat = DateFormatter()
                dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormat.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
                dateFormat.locale = LocaleCore.shared.getLocaleAndCalendar().locale
                dateFormat.dateFormat = "dd MMM yy"
                let expireDate = campaign.expireDate ?? Date().timeIntervalSince1970
                let date = Date(timeIntervalSince1970: expireDate)
                lblExpDate.text = dateFormat.string(from: date)
                lblExpDate.font = UIFont.mainFont(.small)
                
                let lblReadMore = cell.viewWithTag(31) as! UILabel
                lblReadMore.font = UIFont.mainFont(.small)
                let lblClick = cell.viewWithTag(32) as! UILabel
                lblClick.font = UIFont.mainFont(.small)
                
                let locationAuthStatus = LocationManager.shared.authorizationStatus
                if let distance = campaign.distance, locationAuthStatus != .denied
                {
                    lblReadMore.adjustsFontSizeToFitWidth = true
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    numberFormatter.maximumFractionDigits = 2
                    numberFormatter.minimumFractionDigits = 2
                    let value: Double = distance / Double(1000)
                    let formattedNumber = numberFormatter.string(from: NSNumber(value:value))
                    lblReadMore.text = String(format: "%@ : %@ %@","campaign_detail_nearest".localized(), formattedNumber ?? "0.0", "util_km".localized())
                    lblClick.text = "campaign_detail_see_map".localized()
                } else if campaign.website != "" {
                    lblReadMore.text = "campaign_detail_more_detail".localized()
                    lblClick.text = "campaign_detail_click_here".localized()
                }
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo2Tab", for: indexPath)
                
                let lblRewardLeft = cell.viewWithTag(11) as! UILabel
                lblRewardLeft.text = "campaign_detail_reward_left".localized()
                lblRewardLeft.font = UIFont.mainFont(.small)
                
                let lblRewardFull = cell.viewWithTag(111) as! UILabel
                lblRewardFull.text = "campaign_detail_reward_full".localized()
                lblRewardFull.font = UIFont.mainFont(FontSize.xsmall, style: FontStyle.bold)
                lblRewardFull.isHidden = true
                if let quantity = self.campaignStatus?.quantity
                {
                    if quantity <= 0 && quantity != -1{
                        lblRewardFull.isHidden = false
                    } else {
                        lblRewardFull.isHidden = true
                    }
                }
                
                let progressView = cell.viewWithTag(12) as! UIProgressView
                progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
                progressView.progress = Float(rewardLeft)
                progressView.progressTintColor = getProgressColor()
                progressView.trackTintColor = UIColor(hexString: "e7e7e7")
                
                let lblExp = cell.viewWithTag(21) as! UILabel
                lblExp.text = "campaign_detail_exp".localized()
                lblExp.font = UIFont.mainFont(.small)
                
                let lblExpDate = cell.viewWithTag(22) as! UILabel
                let dateFormat = DateFormatter()
                dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormat.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
                dateFormat.locale = LocaleCore.shared.getLocaleAndCalendar().locale
                dateFormat.dateFormat = "dd MMM yy"
                let expireDate = campaign.expireDate ?? Date().timeIntervalSince1970
                let date = Date(timeIntervalSince1970: expireDate)
                lblExpDate.text = dateFormat.string(from: date)
                lblExpDate.font = UIFont.mainFont(.small)
                
                return cell
            }
            
        }
        
        if cellIdent == "line" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellLine", for: indexPath)
            return cell
        }
        
        if cellIdent == "tab" {
            var cell : UITableViewCell!
            if isUse3Detail() {
                cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail3Tab", for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail2Tab", for: indexPath)
            }

            let lblDetail = cell.viewWithTag(11) as! UILabel
            lblDetail.text = "campaign_detail_detail".localized()
            lblDetail.font = UIFont.mainFont()
            lblDetail.textColor = UIColor(hexString: "1a1a1a")

            let lineDetail = cell.viewWithTag(12)!
            lineDetail.isHidden = true
            lineDetail.backgroundColor = UIColor(hexString: "19AAF8")

            let lblCondition = cell.viewWithTag(21) as! UILabel
            lblCondition.text = "campaign_detail_term".localized()
            lblCondition.font = UIFont.mainFont()
            lblCondition.textColor = UIColor(hexString: "1a1a1a")

            let lineCondition = cell.viewWithTag(22)!
            lineCondition.isHidden = true
            lineCondition.backgroundColor = UIColor(hexString: "19AAF8")
            
            if isUse3Detail() {
                let lblBranch = cell.viewWithTag(31) as! UILabel
                lblBranch.text = "campaign_detail_branch".localized()
                lblBranch.font = UIFont.mainFont()
                lblBranch.textColor = UIColor(hexString: "1a1a1a")

                let lineBranch = cell.viewWithTag(32)!
                lineBranch.isHidden = true
                lineBranch.backgroundColor = UIColor(hexString: "19AAF8")
                
                if isShowTab == DetailTab.branch {
                    lblBranch.textColor = UIColor.black
                    lblBranch.font = UIFont.mainFont(style: .bold)
                    lineBranch.isHidden = false
                }
            }

            if isShowTab == DetailTab.detail {
                lblDetail.textColor = UIColor.black
                lblDetail.font = UIFont.mainFont(style: .bold)
                lineDetail.isHidden = false
            } else if isShowTab == DetailTab.condition {
                lblCondition.textColor = UIColor.black
                lblCondition.font = UIFont.mainFont(style: .bold)
                lineCondition.isHidden = false
            }
//            else if isShowTab == DetailTab.branch {
//                lblBranch.textColor = UIColor.black
//                lblBranch.font = UIFont.mainFont(style: .bold)
//                lineBranch.isHidden = false
//            }

            return cell
        }
        
        if cellIdent == "detail"
        {
            if campaign.condition == "-" || isCallingCampaignDetail
            {
                return tableView.dequeueReusableCell(withIdentifier: "cellBlank", for: indexPath)
            }
            
            var str:String?
            switch isShowTab {
            case .detail:
                str = campaign.detail
            case .condition:
                str = campaign.condition
            case .branch :
                var text = ""
                for branch in arrBranch{
                    if let name = branch.name, name != "" {
                        if text == ""{
                            text = "- " + name
                        } else {
                            text = text + "\n- " + name
                        }
                    }
                }
                str = text
            }
            
            if str == nil || str == "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellText", for: indexPath)
            
            let lblText = cell.viewWithTag(11) as! UILabel
            let txvText = cell.viewWithTag(12) as! UITextView
            
            lblText.font = UIFont.mainFont()
            txvText.font = UIFont.mainFont()
            txvText.dataDetectorTypes = [.phoneNumber, .link]
            txvText.isEditable = false
            if isShowTab == .branch
            {
                lblText.attributedText = nil
                txvText.attributedText = nil
                lblText.text = str
                txvText.text = str
            } else {
                let attriText = str?.htmlToAttributedString
                attriText?.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.mainGray], range: NSRange(location: 0, length: attriText?.length ?? 0))
                lblText.attributedText = attriText
                txvText.attributedText = attriText
                
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "cellBlank", for: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellHeight(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellIdent = cellList[indexPath.row]
        if cellIdent == "detail"
        {
            var str:String?
            switch isShowTab {
            case .detail:
               str = campaign.detail
            case .condition:
               str = campaign.condition
            case .branch :
               var text = ""
               for branch in arrBranch{
                   if text == ""{
                       text = "- " + (branch.name ?? "")
                   } else {
                       text = text + "<br>- " + (branch.name ?? "")
                   }
               }
               str = text.replace("<br>", replacement: "\n")
            }
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: Double(tableView.frame.size.width), height: Double.leastNonzeroMagnitude))
            lbl.numberOfLines = 0
            lbl.font = UIFont.mainFont()
            lbl.text = str
            lbl.sizeToFit()
            let height = 8 + lbl.frame.size.height + 8
            return height
        }
        return getCellHeight(indexPath)
    }
    
    func getCellHeight(_ indexPath:IndexPath) -> CGFloat{
        let cellIdent = cellList[indexPath.row]
        if cellIdent == "line"
        {
            return 5
        }
        return UITableView.automaticDimension
    }
}


// MARK:- PopupSerialDelegate
extension CampaignDetailViewController: PopupSerialDelegate
{
    func didClosePopup() {
        vcRight.isUserInteractionEnabled = false
        vcRight.backgroundColor = UIColor.mainLightGray
        getApiCampaignDetail()
    }
}

// MARK:- Analytics
extension CampaignDetailViewController {
    
    func sendGAViewEvent()
    {
        if campaign.parentCategoryID == BuzzebeesCore.catIdCoin {
            var reward1 = [String:AnyObject]()
            reward1[AnalyticsParameterItemID] = (campaign.ID ?? -1) as AnyObject
            reward1[AnalyticsParameterItemName] = campaign.name as AnyObject
            reward1[AnalyticsParameterItemCategory] = "reward/coins/\(campaign.categoryName ?? "")" as AnyObject
            reward1[AnalyticsParameterItemBrand] = campaign.agencyName as AnyObject
            reward1[AnalyticsParameterIndex] = 1 as NSNumber
            reward1[AnalyticsParameterItemVariant] = (campaign.expireIn?.toTimeString() ?? "") as AnyObject
            reward1["metric1"] = (campaign.pointPerUnit ?? 0) as AnyObject
            
            
            // Prepare ecommerce dictionary.
            let items : [Any] = [reward1]
            
            let ecommerce : [String:AnyObject] = [
                "items" : items as AnyObject,
                "eventCategory" : "reward" as NSString,
                "eventAction" : " seen_text" as NSString,
                "eventLabel" : "reward_detail | \(campaign.ID ?? -1)" as NSString,
                AnalyticsParameterItemListName: "dtac_coin_reward_\(campaign.categoryName ?? "")" as NSString
            ]
            
            // Log select_content event with ecommerce dictionary.
            analyticsSetEventEcommerce(eventName: AnalyticsEventViewItem, params: ecommerce)
            
            analyticsSetEvent(event: AnalyticsEventViewItem, category: "reward", action: "seen_text", label: "reward_detail | \(campaign.ID ?? -1) | \(campaign.pointPerUnit ?? 0)")
            return
        }
        
        let name = (campaign.categoryName ?? "").lowercased()
        let screenName = "dtac_reward_" + name.replace(" ", replacement: "_")
        let reward1 : [String : AnyObject] = [
            AnalyticsParameterItemID : (campaign.ID ?? -1) as AnyObject,
            AnalyticsParameterItemName : campaign.name as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(name.replace(" ", replacement: "_"))" as AnyObject,
            AnalyticsParameterItemBrand: campaign.agencyName as AnyObject,
            AnalyticsParameterIndex: "1" as AnyObject
        ]
        let ecommerce : [String:AnyObject] = [
            "items" : reward1  as AnyObject,
            AnalyticsParameterItemList : screenName as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewItem, params: ecommerce)
    }
    
    func sendGATouchRedeem()
    {
        let gaLabel = "\(campaign.ID!)|\(campaign.name ?? "")|\(campaign.agencyName ?? "")"
        analyticsSetEvent(event: "track_event", category: "reward", action: "redeem", label: gaLabel)
    }
    
    
    func sendGALike()
    {
        let reward1 : [String : AnyObject] = [
            "eventCategory": "reward" as AnyObject,
            "eventAction": "add_to_favorite" as AnyObject,
            "eventLabel": (campaign.agencyName ?? "") as AnyObject,
            AnalyticsParameterItemID: (campaign.ID ?? -1) as AnyObject,
            AnalyticsParameterContentType: (campaign.name ?? "") as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventAddToWishlist, params: reward1)
        
        let gaLabel = "\(campaign.ID!)|\(campaign.name ?? "")|\(campaign.agencyName ?? "")"
        analyticsSetEvent(event: "track_event", category: "reward", action: "add_to_favorite", label: gaLabel)
    }
    
    func sendGAShare()
    {
        let reward1 : [String : AnyObject] = [
            "eventCategory": "reward" as AnyObject,
            "eventAction": "share" as AnyObject,
            "eventLabel": (campaign.agencyName ?? "") as AnyObject,
            AnalyticsParameterItemID: (campaign.ID ?? -1) as AnyObject,
            AnalyticsParameterContentType: (campaign.name ?? "") as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventShare, params: reward1)
        
        let gaLabel = "\(campaign.ID!)|\(campaign.name ?? "")|\(campaign.agencyName ?? "")"
        analyticsSetEvent(event: "track_event", category: "reward", action: "share", label: gaLabel)
    }
    
    func sendGARedeem() {
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: (campaign.ID ?? -1),
            AnalyticsParameterItemName: (campaign.name ?? "") as NSString,
            AnalyticsParameterItemCategory: "reward/coins/{reward_filter}" as NSString,
            AnalyticsParameterItemBrand: (campaign.agencyName ?? "") as NSString,
            AnalyticsParameterPrice: 0 as NSNumber,
            AnalyticsParameterCurrency: "THB" as NSString,
            AnalyticsParameterQuantity: 1 as NSNumber,
            AnalyticsParameterIndex: 1 as NSNumber,
            AnalyticsParameterItemVariant: campaign.expireIn?.toTimeString() ?? "" as NSString,
            "metric1" : campaign.pointPerUnit ?? 0 as NSNumber
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_button" as NSString,
            "eventLabel" : "redeem_reward | \(campaign.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: "dtac_coin_reward_{reward_filiter}" as NSString,
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventAddToCart, params: ecommerce)
        
        let gaLabel = "redeem_reward | \(campaign.ID ?? -1) | \(campaign.pointPerUnit ?? 0)"
        analyticsSetEvent(event: AnalyticsEventAddToCart, category: "reward", action: "touch_button", label: gaLabel)
    }
    
    func sendGABeginCheckout() {
        
        var reward1 = [String:AnyObject]()
        reward1[AnalyticsParameterItemID] = (campaign.ID ?? -1) as AnyObject
        reward1[AnalyticsParameterItemName] = campaign.name as AnyObject
        reward1[AnalyticsParameterItemCategory] = "reward/coins/\(campaign.categoryName ?? "")" as AnyObject
        reward1[AnalyticsParameterItemBrand] = campaign.agencyName as AnyObject
        reward1[AnalyticsParameterPrice] = 0 as NSNumber
        reward1[AnalyticsParameterCurrency] = "THB" as NSString
        reward1[AnalyticsParameterQuantity] = 1 as NSNumber
        reward1[AnalyticsParameterIndex] = 1 as NSNumber
        reward1[AnalyticsParameterItemVariant] = (campaign.expireIn?.toTimeString() ?? "") as AnyObject
        reward1["metric1"] = (campaign.pointPerUnit ?? 0) as AnyObject
        
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_button" as NSString,
            "eventLabel" : "confirm_reward | {reward_id}" as NSString,
            AnalyticsParameterItemListName: "dtac_coin_reward_{reward_filter}" as NSString,
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventBeginCheckout, params: ecommerce)
        
        let gaLabel = "confirm_reward | \(campaign.ID ?? -1) | \(campaign.pointPerUnit ?? 0)"
        analyticsSetEvent(event: AnalyticsEventBeginCheckout, category: "reward", action: "touch_button", label: gaLabel)
    }
    
    func sendGAThankyouPage(_ redeemKey:String?) {
            
        var reward1 = [String:AnyObject]()
        reward1[AnalyticsParameterItemID] = (campaign.ID ?? -1) as AnyObject
        reward1[AnalyticsParameterItemName] = campaign.name as AnyObject
        reward1[AnalyticsParameterItemCategory] = "reward/coins/\(campaign.categoryName ?? "")" as AnyObject
        reward1[AnalyticsParameterItemBrand] = campaign.agencyName as AnyObject
        reward1[AnalyticsParameterPrice] = 0 as NSNumber
        reward1[AnalyticsParameterCurrency] = "THB" as NSString
        reward1[AnalyticsParameterQuantity] = 1 as NSNumber
        reward1[AnalyticsParameterIndex] = 1 as NSNumber
        reward1[AnalyticsParameterItemVariant] = (campaign.expireIn?.toTimeString() ?? "") as AnyObject
        reward1["metric1"] = (campaign.pointPerUnit ?? 0) as AnyObject
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " seen_text" as NSString,
            "eventLabel" : "redeem_complete | \(campaign.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: "dtac_coin_reward_{reward_filter}" as NSString,
            AnalyticsParameterTransactionID: "\(redeemKey ?? "-")" as NSString,
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventPurchase, params: ecommerce)
        
        Analytics.logEvent(AnalyticsEventSpendVirtualCurrency, parameters: [
             AnalyticsParameterItemName : "\(campaign.ID ?? -1) | \(campaign.name ?? "")" as NSString,
             AnalyticsParameterItemVariant : campaign.agencyName as NSString,
             AnalyticsParameterVirtualCurrencyName : "Coin" as NSString,
             AnalyticsParameterValue: (campaign.pointPerUnit ?? 0) as NSNumber,
             AnalyticsParameterTransactionID: "\(redeemKey ?? "-")" as NSString
         ])
        analyticsSetEventEcommerce(eventName: AnalyticsEventSpendVirtualCurrency, params: ecommerce)

        //Push to Front-End Team
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        analyticsSetUserProperty(propertyName: "last_redeem_coin", value: "\(formatter.string(from: Date()))")
        analyticsSetUserProperty(propertyName: "remaining_coin", value: "\((Bzbs.shared.userLogin?.bzbsPoints ?? 0) - campaign.pointPerUnit)")
        
        
        let gaLabel = "redeem_complete | \(campaign.ID ?? -1) | \(campaign.pointPerUnit ?? 0)"
        analyticsSetEvent(event: AnalyticsEventPurchase, category: "reward", action: "seen_text", label: gaLabel)
        analyticsSetEvent(event: AnalyticsEventSpendVirtualCurrency, category: "reward", action: "seen_text", label: gaLabel)

    }
    
}

