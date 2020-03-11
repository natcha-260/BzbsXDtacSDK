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

class CampaignDetailViewController: BzbsXDtacBaseViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    let gradient: CAGradientLayer = CAGradientLayer()
    override func viewDidLayoutSubviews() {
        
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = vwNav.bounds
        
        vwNav.layer.insertSublayer(gradient, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func updateUI() {
        super.updateUI()
        self.tableView.reloadData()
        lblLike.text = "campaign_detail_like".localized()
        lblHistory.text = "campaign_detail_history".localized()
        resetAPI()
    }
    
    @objc func resetAPI()
    {
        isLoadedStatus = false
        manageFooter()
        getApiCampaignDetail()
    }
    
    func setupNav()
    {
        imvLike.image = UIImage(named: self.campaign.isFavourite ? "img_navbar_icon_fav_active" : "img_navbar_icon_fav_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        if self.campaign.type! == 16 {
//            vwShare.isHidden = true
            vwLike.isHidden = true
        } else {
//            vwShare.isHidden = false
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
                self.sendGATouchEvent()
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

                self.getApiCampaignStatus()
        }) { (error) in

            self.isCallingCampaignDetail = false
            if error.id == "-9999"
            {
//                if !self.isRetry{
//                    self.isRetry = true
//                    self.delay(0.33) {
//                        self.getApiCampaignDetail()
//                    }
//                } else {
//                    PopupManager.informationPopup(self, title: nil, message: "campaign_detail_fail".localized()) { () in
//                        self.back_1_step()
//                    }
//                }

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
                PopupManager.informationPopup(self, title: nil, message: "campaign_detail_fail".localized()) { () in
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
    func getApiCampaignStatus() {
        if campaign.type == 16 {
            self.manageFooter()
            self.tableView.reloadData()
            self.hideLoader()
            return
        }
        
        if let token = Bzbs.shared.userLogin?.token
        {
            BzbsCoreApi().getCampaignStatus(campaignId: campaign.ID,
                                                   deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                                   center: LocationManager.shared.getCurrentCoorndate(),
                                                   token: token,
                                                   successCallback: { (status) in
                                                    self.isLoadedStatus = true
                                                    self.campaignStatus = status
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
                                                    
                                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
//                                                    PopupManager.informationPopup(self, title: nil, message: "campaign_detail_status_fail".localized()) {
//                                                        let tmp = CampaignStatus()
//                                                        tmp.quantity = 0
//                                                        tmp.status = false
//
//                                                        self.campaignStatus = nil
//                                                        self.manageFooter()
//                                                        self.tableView.reloadData()
//                                                    }
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
        BuzzebeesCampaign().redeem(token:token , campaignId: campaign.ID, successCallback: { (dict) in
            self.hideLoader()
            let purchase = BzbsHistory(dict: dict)
            PopupManager.serialPopup(onView: self, purchase: purchase)
            self.isCallingApiRedeem = false
        }) { (error) in
            self.hideLoader()
//            var message = error.message
//            if message == nil || message?.lowercased() == "conflict"{
//                message = "campaign_detail_status_fail".localized()
//            }
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
            PopupManager.informationPopup(self, title: nil, message: "campaign_detail_status_fail".localized(), close: nil)
            self.refreshApi()
            self.isCallingApiRedeem = false
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
    
    @IBAction func clickRight(_ sender: Any) {
        
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
                if type == 1 {
                    let message = "popup_confirm_redeem_prefix".localized() + "\n" + self.campaign.name
                    PopupManager.confirmPopup(self, title: "popup_confirm".localized(), message: message, confirm: { () in
                        self.apiRedeem()
                    }) {
                        
                    }
//                    showLoader()
//                    BzbsCoreApi().getCampaignStatus(campaignId: campaign.ID,
//                                                    deviceLocale: String(LocaleCore.shared.getUserLocale()),
//                                                    center: LocationManager.shared.getCurrentCoorndate(),
//                                                    token: Bzbs.shared.userLogin?.token,
//                                                    successCallback: { (status) in
//                                                        self.hideLoader()
//                                                        let message = "popup_confirm_redeem_prefix".localized() + "\n" + self.campaign.name
//                                                        PopupManager.confirmPopup(self, title: "popup_confirm".localized(), message: message, confirm: { () in
//                                                            self.apiRedeem()
//                                                        }) {
//
//                                                        }
//                                                        self.hideLoader()
//                    },
//                                                    failCallback: { (error) in
//                                                        self.hideLoader()
//                                                        if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
//                                                        PopupManager.informationPopup(self, title: nil, message: "campaign_detail_status_fail".localized()) {
//                                                            let tmp = CampaignStatus()
//                                                            tmp.quantity = 0
//                                                            tmp.status = false
//
//                                                            self.campaignStatus = tmp
//                                                            self.manageFooter()
//                                                            self.tableView.reloadData()
//                                                        }
//                    })
                }
            }
        } else {
            if !isLoggedIn()
            {
                PopupManager.confirmPopup(self, isWithImage:true, message: "popup_dtac_login_fail".localized()
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
    
    // MARK:- Util
    // MARK:-
    func manageFooter(){
        
        vcRight.isUserInteractionEnabled = true
        lblLeft.font = UIFont.mainFont()
        lblRight.font = UIFont.mainFont()
        lblRight.textColor = UIColor.white
        lblLeft.textColor = UIColor.lightGray
        vcLeft.cornerRadius(corner: 4.0, borderColor: UIColor.gray, borderWidth: 1.0)
        vcRight.cornerRadius(corner: 4.0)
        vcRight.backgroundColor = UIColor.mainLightGray
        
        lblLeft.text = "campaign_detail_back".localized()
        lblRight.text = "campaign_detail_status_redeem".localized()
        
        if let type = campaign.type{
            if type == 1 {
                lblRight.text = "campaign_detail_status_redeem".localized()
                vcRight.backgroundColor = UIColor.dtacBlue
            } else if type == 9 {
                lblRight.text = "campaign_detail_status_use_at_shop".localized()
                vcRight.backgroundColor = UIColor.mainLightGray
            }
        }
        
        if let _campaignStatus = campaignStatus {
            if !_campaignStatus.status {
                
                vcRight.isUserInteractionEnabled = false
                vcRight.backgroundColor = UIColor.mainLightGray
                
                if _campaignStatus.remark.lowercased() == "Not eligible with any campaign criteria".lowercased() {
                    lblRight.text = "campaign_detail_status_not_eligible".localized()
                }else if _campaignStatus.remark.lowercased() == "Redeemed".lowercased() {
                    lblRight.text = "campaign_detail_status_redeemed".localized()
                }else if _campaignStatus.remark.lowercased() == "Run out".lowercased() {
                    lblRight.text = "campaign_detail_status_sold".localized()
                }
            }
        } else {
            if !isLoadedStatus
            {
                if isLoggedIn()
                {
                    if campaignStatus == nil {
                        
                        lblRight.text = "campaign_detail_status_redeem".localized()
                        vcRight.backgroundColor = UIColor.dtacBlue
                        
                        if let type = campaign.type{
                            if type == 9 {
                                lblRight.text = "campaign_detail_status_use_at_shop".localized()
                                vcRight.backgroundColor = UIColor.mainLightGray
                            }
                        }
                        return
                    }

                    if let type = campaign.type, type == 9 {
                        lblRight.text = "campaign_detail_status_use_at_shop".localized()
                        vcRight.backgroundColor = UIColor.mainLightGray
                        return
                    }
                    vcRight.backgroundColor = UIColor.mainLightGray
                } else {
                    vcRight.backgroundColor = UIColor.dtacBlue
                }
            } else {
                vcRight.backgroundColor = UIColor.dtacBlue
            }
        }
        
        if isCallingApiRedeem || isCallingCampaignDetail {
            vcRight.isUserInteractionEnabled = false
            vcRight.backgroundColor = UIColor.mainLightGray
        }
    }
    
    func getProgressColor() -> UIColor {
        
        guard let _campaingStatus = campaignStatus else { return .gray }
        
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
    
    // MARK:- Analytics
    // MARK:-
    
    func sendGATouchEvent()
    {
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
}

// MARK:- Extension
// MARK:- UITableViewDelegate, UITableViewDataSource
extension CampaignDetailViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let locationAuthStatus = LocationManager.shared.authorizationStatus
            
            if (locationAuthStatus != .denied && campaign.distance != nil) ||
                (campaign.website != "")
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell3Tab", for: indexPath)
                
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
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2Tab", for: indexPath)
                
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTab", for: indexPath)

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

            let lblBranch = cell.viewWithTag(31) as! UILabel
            lblBranch.text = "campaign_detail_branch".localized()
            lblBranch.font = UIFont.mainFont()
            lblBranch.textColor = UIColor(hexString: "1a1a1a")

            let lineBranch = cell.viewWithTag(32)!
            lineBranch.isHidden = true
            lineBranch.backgroundColor = UIColor(hexString: "19AAF8")

            if isShowTab == DetailTab.detail {
                lblDetail.textColor = UIColor.black
                lblDetail.font = UIFont.mainFont(style: .bold)
                lineDetail.isHidden = false
            } else if isShowTab == DetailTab.condition {
                lblCondition.textColor = UIColor.black
                lblCondition.font = UIFont.mainFont(style: .bold)
                lineCondition.isHidden = false
            } else if isShowTab == DetailTab.branch {
                lblBranch.textColor = UIColor.black
                lblBranch.font = UIFont.mainFont(style: .bold)
                lineBranch.isHidden = false
            }

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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellHeight(indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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


extension CampaignDetailViewController: PopupSerialDelegate
{
    func didClosePopup() {
        vcRight.isUserInteractionEnabled = false
        vcRight.backgroundColor = UIColor.mainLightGray
        getApiCampaignDetail()
    }
}

extension CLLocation {
    convenience init(withCoodinate coordinate2D:CLLocationCoordinate2D) {
        self.init(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
    }
}
