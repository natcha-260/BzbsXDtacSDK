//
//  MainViewController.swift
//  iOS_Dtac_Rewards
//
//  Created by Buzzebees iMac on 12/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Alamofire
import AlamofireImage
import CoreLocation
import AVFoundation
import FirebaseAnalytics
import WebKit

@objc public class BzbsMainViewController: BaseListController {

    @IBOutlet weak var collectionView: UICollectionView!
    {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.alwaysBounceVertical = true
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
            
            collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
            collectionView.register(GreetingCVCell.getNib(), forCellWithReuseIdentifier: "greetingCell")
            collectionView.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "campaignRotateCell")
            collectionView.register(CategoryCVCell.getNib(), forCellWithReuseIdentifier: "categoryCell")
            collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "recommendCell")
            collectionView.register(LoadMoreCVCell.getNib(), forCellWithReuseIdentifier: "loadMoreCell")
            collectionView.register(FooterCVCell.getNib(), forCellWithReuseIdentifier: "footerCVCell")
            collectionView.register(RecommendHeaderCVCell.getNib(), forCellWithReuseIdentifier: "recommendHeaderCVCell")
        }
    }
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var vwMAPage: UIView!
    
    @IBOutlet weak var viewScan: UIView!
    @IBOutlet weak var lblScan: UILabel!
    @IBOutlet weak var imvScan: UIImageView!
    
    var campaignConfig: String! {
        if LocationManager.shared.authorizationStatus != .authorizedWhenInUse {
            if let level = Bzbs.shared.userLogin?.dtacLevel{
                if level == .no_level {
                    return "campaign_dtac_guest_nolocation"
                }
                return level.campaignConfigAll
            }
            return "campaign_dtac_guest_nolocation"
        }

        if let level = Bzbs.shared.userLogin?.dtacLevel{
            if level == .no_level {
                return "campaign_dtac_guest"
            }
            return level.campaignConfig
        }
        return "campaign_dtac_guest"
    }
    
    let listSection = ["greeting", "dashboard", "category", "header_recommend", "recommend", "footer"]
    var greetingModel: GreetingModel?
    var dashboardItems = [BzbsDashboard]()
    var arrCategory = [BzbsCategory]()
    {
        didSet{
            Bzbs.shared.arrCategory = arrCategory
        }
    }
    var arrCampaign = [BzbsCampaign]()
    var currentCenter = LocationManager.shared.getCurrentCoorndate()
    
    var isSendImpressionItems = false
    var isSendImpressionBanner = false
    var impressionItems = [BzbsCampaign]()
    
    var webView : WKWebView?
    
    // MARK:- Life Cycle
    // MARK:-
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let resourceBundle = Bzbs.shared.currentBundle
        
        UIFont.registerFont(withFilenameString: "DTAC2018-Regular.otf", bundle: resourceBundle)
        UIFont.registerFont(withFilenameString: "DTAC2018-Bold.otf", bundle: resourceBundle)
        UIFont.registerFont(withFilenameString: "MyriadPro-Regular.otf", bundle: resourceBundle)
        
        // init for wording
        LocaleCore.shared.loadLanguageString()
        
        collectionView.es.addPullToRefresh {
            self.currentCenter = LocationManager.shared.getCurrentCoorndate()
            self._intSkip = 0
            self._isEnd = false
            self.getApiGreeting()
            self.getApiCategory()
            self.getApiRecommend()
            self.getApi()
        }
        
        if !isConnectedToInternet()
        {
            self.vwMAPage.isHidden = false
            return
        }
        
        if !BuzzebeesCore.isSetEndpoint{
            showLoader()
            BuzzebeesCore.apiSetupPrefix(successCallback: {
                self.hideLoader()
                self.initialUI()
            }) {
                self.hideLoader()
                self.vwMAPage.isHidden = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetAPI), name: NSNotification.Name.BzbsApiReset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reLogin), name: NSNotification.Name.BzbsLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backToMainView), name: NSNotification.Name.BzbsBackToMainView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBar), name: NSNotification.Name.BzbsUpdateNavigationBar, object: nil)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavigationBar()
        
        analyticsSetScreen(screenName: "dtac_reward")
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.tintColorDidChange()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.mainFont(), NSAttributedString.Key.foregroundColor:UIColor.black]
//        if BuzzebeesCore.isSetEndpoint && self._intSkip == 0{
//            getApiRecommend()
//            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
//        }
    }
    
    func reloadSetupPrefix()
    {
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        BuzzebeesCore.apiSetupPrefix(successCallback: {
            self.hideLoader()
            self.initialUI()
            self.delay(2) {
                self.vwMAPage.isHidden = true
            }
        }) {
            self.hideLoader()
            self.vwMAPage.isHidden = false
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.tintColorDidChange()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.mainFont(), NSAttributedString.Key.foregroundColor:UIColor.black]
        
//        if !isLoggedIn()
//        {
//            Bzbs.shared.delegate?.reTokenTicket()
//        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self._intSkip = 0
//        self._isEnd = false
    }
    
    func initialUI() {
        
        getApiGreeting()
        if let token = Bzbs.shared.dtacLoginParams.token, token != "",
            let ticket = Bzbs.shared.dtacLoginParams.ticket, ticket != ""
        {
            let language = Bzbs.shared.dtacLoginParams.language ?? "th"
            apiLogin(token, ticket: ticket, language:language)
            if Bzbs.shared.userLogin != nil {
                getApiCategory()
                getApiRecommend()
                getApi()
            }
        } else {
            getApiCategory()
            getApiRecommend()
            getApi()
        }
        updateNavigationBar()
        viewSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        viewSearch.addShadow()
        viewScan.cornerRadius()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
        lblScan.font = UIFont.mainFont()
        lblScan.text = "scan_title".localized()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.tintColorDidChange()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.mainFont(), NSAttributedString.Key.foregroundColor:UIColor.black]
    }
    
    @objc func updateNavigationBar()
    {
        navigationItem.leftBarButtonItems = BarItem.generate_logo()
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            navigationItem.rightBarButtonItems = BarItem.generate_message(self, isHasNewMessage: Bzbs.shared.isHasNewMessage, messageSelector: #selector(clickMessage))
        }
    }
    
    public override func updateUI() {
        super.updateUI()
        updateNavigationBar()
        viewSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        viewSearch.addShadow()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
        lblScan.text = "scan_title".localized()
        self.collectionView.reloadData()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.tintColorDidChange()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.mainFont(), NSAttributedString.Key.foregroundColor:UIColor.black]
        resetAPI()
    }
    
    @objc func resetAPI() {
        if BuzzebeesCore.isSetEndpoint
        {
            currentCenter = LocationManager.shared.getCurrentCoorndate()
            _intSkip = 0
            _isEnd = false
            getApiGreeting()
            getApiCategory()
            getApiRecommend()
            getApi()
        }
    }
    
    func apiLogin(_ token:String, ticket: String, language:String)
    {
        let isNeedupdateUI = Bzbs.shared.userLogin == nil
        Bzbs.shared.login(token: token, ticket: ticket, language: language, completionHandler: {
            
            if let user = Bzbs.shared.userLogin, user.dtacLevel == .no_level {
                Bzbs.shared.delegate?.reLogin()
            }
            if isNeedupdateUI {
                NotificationCenter.default.post(name: NSNotification.Name(BBEnumNotificationCenter.updateUI.rawValue), object: nil)
            } else {
                self.hideLoader()
            }
            
        }) { (error) in
            
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!, message: error.message) {
                return
            } else {
                Bzbs.shared.delegate?.reLogin()
            }
        }
    }
    
    class func getView() -> BzbsMainViewController
    {
        let rect = UIScreen.main.bounds
        return getView(rect)
    }

    class func getView(_ frame:CGRect) -> BzbsMainViewController
    {
        let storyboard = UIStoryboard(name: "DtacRewardsMain", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "main_view")
        controller.view.frame = frame
        return controller as! BzbsMainViewController
    }
    
    @objc public class func getViewWithNavigationBar(_ isHideNavigationBar:Bool = true) -> UINavigationController
    {
        let storyboard = UIStoryboard(name: "DtacRewardsMain", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "main_view") as! BzbsMainViewController
        let nav = UINavigationController(rootViewController: controller)
        nav.isNavigationBarHidden = isHideNavigationBar
        nav.navigationBar.backgroundColor = .white
        nav.navigationBar.tintColor = .mainBlue
        nav.navigationBar.barTintColor = .white
        return nav
    }
    
    @objc public class func initialView(viewController: UIViewController, containnerView: UIView? = nil) {
        let storyboard = UIStoryboard(name: "DtacRewardsMain", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "main_view") as! BzbsMainViewController
        let nav = UINavigationController(rootViewController: controller)
        viewController.addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        (containnerView ?? viewController.view).addSubview(nav.view)

        NSLayoutConstraint.activate([
            nav.view.leadingAnchor.constraint(equalTo: (containnerView ?? viewController.view).leadingAnchor, constant: 0),
            nav.view.trailingAnchor.constraint(equalTo: (containnerView ?? viewController.view).trailingAnchor, constant: 0),
            nav.view.topAnchor.constraint(equalTo: (containnerView ?? viewController.view).topAnchor, constant: 0),
            nav.view.bottomAnchor.constraint(equalTo: (containnerView ?? viewController.view).bottomAnchor, constant: 0)
            ])
        nav.didMove(toParent: viewController)
    }
    
    @objc func backToMainView()
    {
        if let nav = self.navigationController
        {
            nav.popToViewController(self, animated: false)
        }
    }
    
    // MARK:- API
    // MARK:-
    override func getCache() {
        
    }
    
    override func getApi() {
        BuzzebeesDashboard().sub(dashboardName: "dtac_main",
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    self.dashboardItems = dashboard
                                    self.loadedData()
                                    if !self.isSendImpressionBanner
                                    {
                                        self.sendImpressionBanner()
                                    }
        },
                                 failCallback: { (error) in
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
        
    }
    
    func getApiGreeting() {
        BzbsCoreApi().getGreetingText(Bzbs.shared.userLogin?.token, successCallback: { (result) in
            self.greetingModel = result
            self.loadedData()
        },failCallback: { (error) in
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    func getApiCategory() {
        BuzzebeesCategory().list(config: "menu_dtac",
                                 token: Bzbs.shared.userLogin?.token,
                                 successCallback: { (listCategory) in
                                    self.arrCategory = listCategory
                                    // first cat is always Blue
                                    Bzbs.shared.blueCategory = listCategory.first
                                    
                                    for cat in self.arrCategory{
                                        let allCat = BzbsCategory(dict: Dictionary<String, AnyObject>())
                                        allCat.nameEn = "Recommend"
                                        allCat.nameTh = "แนะนำ"
                                        allCat.listConfig = cat.listConfig
                                        allCat.id = cat.id
                                        cat.subCat.insert(allCat, at: 0)
                                    }
        
                                    if let userLogin = Bzbs.shared.userLogin
                                    {
                                        if userLogin.dtacLevel != .blue
                                        {
                                            self.arrCategory.removeAll { (cat) -> Bool in
                                                return cat.id == Bzbs.shared.blueCategory?.id
                                            }
                                        }
                                    } else {
                                        self.arrCategory.removeAll { (cat) -> Bool in
                                            return cat.id == Bzbs.shared.blueCategory?.id
                                        }
                                    }
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    func getApiRecommend() {
        if _isCallApi || _isEnd {
            return
        }
        _isCallApi = true
        self.showLoader()
        
        BuzzebeesCampaign().list(config: campaignConfig,
                                 top: 6,
                                 skip: _intSkip,
                                 search: "",
                                 catId: nil,
                                 token: Bzbs.shared.userLogin?.token,
                                 center: currentCenter,
                                 successCallback: { (listCampaign) in
                                    
                                    if listCampaign.count < 6 {
                                        self._isEnd = true
                                    }

                                    if self._intSkip == 0 {
                                        self.arrCampaign = listCampaign
                                    } else {
                                        self.arrCampaign.append(contentsOf: listCampaign)
                                    }
                                    
                                    self._intSkip += 6
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                    if error.id == "-9999"
                                    {
                                        self.loadedData()
                                        return
                                    }
                                    self._isEnd = true
                                    self.loadedData()
                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    override func loadedData() {
        self._isCallApi = false
        collectionView.es.stopPullToRefresh()
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
        self.hideLoader()
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApiGreeting()
        getApiCategory()
        getApiRecommend()
        getApi()
    }
    
    override func updateLocation() {
        currentCenter = LocationManager.shared.getCurrentCoorndate()
        if _isCallApi {
            delay(0.33){
                self.updateLocation()
            }
            return
        }
        _isEnd = false
        _intSkip = 0
        getApiRecommend()
    }
    
    // MARK:- Action
    // MARK:-
    @IBAction func clickViewAllCampaign(_ sender: Any) {
        self.view.endEditing(true)
        
        if let nav = self.navigationController {
            nav.pushViewController(RecommendListViewController.getViewController(), animated: true)
        }
    }
    
    @IBAction func clickScan(_ sender: Any) {
        
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
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        analyticsSetEvent(category: "reward", action: "scan", label: "screen_name")
        AVCaptureDevice.requestAccess(for: .video) { success in
          if success { // if request is granted (success is true)
            DispatchQueue.main.async {
                if let nav = self.navigationController
                {

                    GotoPage.gotoScanQR(nav,target: self)
                }
            }
          } else { // if request is denied (success is false)
            DispatchQueue.main.async {
                PopupManager.confirmPopup(self, message: "popup_scan_not_allow".localized(), strConfirm: "popup_setting".localized(), confirm: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        } else {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    }
                }, cancel: nil)
            }
          }
        }
    }
    
    @IBAction func clickFavorite(_ sender: Any) {
        self.view.endEditing(true)
        
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
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        analyticsSetEvent(category: "reward", action: "touch", label: "favorite")
        if let nav = self.navigationController {
            GotoPage.gotoFavorite(nav)
        }
        
    }
    
    @IBAction func clickHistory(_ sender: Any) {
        self.view.endEditing(true)
        
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
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        analyticsSetEvent(category: "reward", action: "touch", label: "history")
        if let nav = self.navigationController {
            GotoPage.gotoHistory(nav)
        }
    }
    
    @IBAction func clickFAQ(_ sender: Any) {
        self.view.endEditing(true)
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        
        analyticsSetEvent(category: "reward", action: "touch", label: "faq")
        if let nav = self.navigationController {
            GotoPage.gotoWebSite(nav, strUrl: Bzbs.shared.getUrlFAQ(), strTitle: "main_footer_faq".localized())
        }
    }
    
    @IBAction func clickAbout(_ sender: Any) {
        self.view.endEditing(true)
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        analyticsSetEvent(category: "reward", action: "touch", label: "about")
        if let nav = self.navigationController {
            GotoPage.gotoWebSite(nav, strUrl: Bzbs.shared.getUrlAbout(), strTitle: "main_footer_about".localized())
        }
    }
    
    @objc func clickMessage()
    {
        Bzbs.shared.delegate?.clickMessage()
    }
    
    @objc func clickLevel()
    {

        if let userLogin = Bzbs.shared.userLogin ,
            let _ = userLogin.token ,
        userLogin.dtacLevel != .no_level
        {
            
            var strUrl = Bzbs.shared.getUrlDtacMember()
            var strTitle = "Dtac Member"
            
            switch userLogin.dtacLevel {
            case .blue :
                strUrl = Bzbs.shared.getUrlBlueMember()
                strTitle = BuzzebeesCore.levelNameBlue
                analyticsSetEvent(category: "reward", action: "touch", label: "blue")
            case .gold :
                strUrl = Bzbs.shared.getUrlGoldMember()
                strTitle = BuzzebeesCore.levelNameGold
                analyticsSetEvent(category: "reward", action: "touch", label: "gold")
            case .silver :
                strUrl = Bzbs.shared.getUrlSilverMember()
                strTitle = BuzzebeesCore.levelNameSilver
                analyticsSetEvent(category: "reward", action: "touch", label: "silver")
            case .customer:
                strUrl = Bzbs.shared.getUrlDtacMember()
                strTitle = BuzzebeesCore.levelNameDtac
                analyticsSetEvent(category: "reward", action: "touch", label: "reward")
            case .no_level:
                strUrl = Bzbs.shared.getUrlDtacMember()
                strTitle = BuzzebeesCore.levelNameDtac
                analyticsSetEvent(category: "reward", action: "touch", label: "reward")
            }
            
            if let nav = self.navigationController {
                GotoPage.gotoWebSite(nav, strUrl: strUrl, strTitle: strTitle)
            }
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ma_segue"
        {
            if let target = segue.destination as? MAPageViewController
            {
                target.delegate = self
            }
        }
    }
    
    // MARK:- Analytic Impression
    // MARK:-
    
    func sendImpressionItems()
    {
        if isSendImpressionItems { return }
        isSendImpressionItems = true
        var items = [[String:AnyObject]]()
        var i = 0
        for item in impressionItems
        {
            let reward : [String:AnyObject] = [
                AnalyticsParameterItemID : (item.ID ?? -1) as AnyObject,
                AnalyticsParameterItemName : (item.name ?? "") as AnyObject,
                AnalyticsParameterItemCategory : (item.categoryID ?? -1) as AnyObject,
                AnalyticsParameterItemBrand : (item.agencyName ?? "") as AnyObject,
                AnalyticsParameterIndex : i as AnyObject
            ]
            i += 1
            items.append(reward)
        }
         
        let ecommerce  : [String:AnyObject] = [
            "items" : items as AnyObject,
            AnalyticsParameterItemList : "dtac_reward" as AnyObject
        ]
        
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewSearchResults, params: ecommerce)
    }
    
    func sendImpressionBanner()
    {
        guard let impressionBanner = self.dashboardItems.first else { return }
        if isSendImpressionBanner { return }
        isSendImpressionBanner = true
        var items = [[String:AnyObject]]()
        var i = 0
        for item in impressionBanner.subCampaignDetails
        {
            var rewardType = ""
            let type = item.type
            switch type {
            case "hashtag" :
                rewardType = "group"
            case "link" :
                rewardType = "none"
            case "cat" :
                rewardType = "category"
            case "none" :
                rewardType = "none"
            case "campaign" :
                rewardType = "campaign"
            default:
                break
            }
            
            let reward : [String:AnyObject] = [
                AnalyticsParameterItemID : (item.id ?? "") as AnyObject,
                AnalyticsParameterItemName : (item.name ?? "") as AnyObject,
                AnalyticsParameterItemCategory : "reward/\(rewardType)" as AnyObject,
                AnalyticsParameterItemBrand : (item.line2 ?? "") as AnyObject,
                AnalyticsParameterIndex : i as AnyObject
            ]
            i += 1
            items.append(reward)
        }
         
        let ecommerce  : [String:AnyObject] = [
            "items" : items as AnyObject,
            AnalyticsParameterItemList : "dtac_reward_banner" as AnyObject
        ]
        
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewSearchResults, params: ecommerce)
    }
}

// MARK:- Extension
// MARK:- MAPageDelegate
extension BzbsMainViewController: MAPageDelegate
{
    func didReload() {
        reloadSetupPrefix()
    }
}

// MARK:- UITextFieldDelegate
extension BzbsMainViewController: UITextFieldDelegate
{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !isLoggedIn()
        {
            PopupManager.confirmPopup(self, isWithImage:true, message: "popup_dtac_login_fail".localized()
                , strConfirm: "popup_retry_login_fail".localized()
                , strClose: "popup_cancel".localized()
                , confirm: {
                Bzbs.shared.delegate?.reTokenTicket()
            }, cancel: nil)
            return false
        }
        
        GotoPage.gotoSearch(self.navigationController!)
        return false
    }
}

extension BzbsMainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1 :
            return 1
        case 2 :
            return 1
        case 3 :
            return 1
        case 4 :
            return 1 + arrCampaign.count + (_isEnd ? 0 : 1)
        case 5 :
            return 1
        default:
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "greetingCell", for: indexPath) as! GreetingCVCell
            cell.setupWithModel(self.greetingModel, target: self, levelSelector: #selector(clickLevel))
            return cell
        }
        if section == 1 {
            if dashboardItems.count <= 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignRotateCell", for: indexPath) as! CampaignRotateCVCell
            cell.dashboardItems = dashboardItems
            cell.delegate = self
            return cell
        }
        if section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCVCell
            cell.delegate = self
            cell.arrCategory = self.arrCategory
            return cell
        }
        if section == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadMoreCell", for: indexPath) as! LoadMoreCVCell
            cell.setLine()
            return cell
        }
        if section == 4 {
            if row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendHeaderCVCell", for: indexPath) as! RecommendHeaderCVCell
                cell.setupWith(target: self, selector: #selector(clickViewAllCampaign(_:)))
                return cell
            }
            if row == arrCampaign.count + 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadMoreCell", for: indexPath) as! LoadMoreCVCell
                cell.setLoadMore()
                if !isSendImpressionItems
                {
                    sendImpressionItems()
                }
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
            let item = arrCampaign[row - 1]
            if !isSendImpressionItems{
                impressionItems.append(item)
            }
            cell.setupWith(item, isShowDistance: true)
            return cell
        }
        if section == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "footerCVCell", for: indexPath) as! FooterCVCell
            cell.setupWith(target: self
                , favSelector: #selector(clickFavorite(_:))
                , histSelector: #selector(clickHistory(_:))
                , faqSelector: #selector(clickFAQ(_:))
                , aboutSelector: #selector(clickAbout(_:)))
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
        }
        else if indexPath.section == 4 {
            if (indexPath.row - 1) == arrCampaign.count{
                getApiRecommend()
            } else {
                if arrCampaign.count < indexPath.row - 1 || indexPath.row == 0 { return }
                let item = arrCampaign[indexPath.row - 1]
                sendGATouchEvent(item,indexPath: indexPath)
                if let nav = self.navigationController {
                    GotoPage.gotoCampaignDetail(nav, campaign: item, target: self)
                }
            }
        }
    }
    
    func sendGATouchEvent(_ campaign:BzbsCampaign, indexPath:IndexPath)
    {
        let reward1 : [String : AnyObject] = [
            AnalyticsParameterItemID : campaign.ID as AnyObject,
            AnalyticsParameterItemName : campaign.name as AnyObject,
            AnalyticsParameterItemCategory: "dtac_reward" as AnyObject,
            AnalyticsParameterItemBrand: campaign.agencyName as AnyObject,
            AnalyticsParameterIndex: "\(indexPath.row - 1)" as AnyObject
        ]
        let ecommerce : [String:AnyObject] = [
            "items" : reward1  as AnyObject,
            AnalyticsParameterItemList : "dtac_reward" as AnyObject
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventSelectContent, params: ecommerce)
        
        let gaLabel = "\(campaign.ID!)|\(campaign.name ?? "")|\(campaign.agencyName ?? "")"
        analyticsSetEvent(event: "track_event", category: "reward", action: "dtac_reward", label: gaLabel)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let width = collectionView.bounds.size.width
        if section == 0 {
            return CGSize(width: width, height: 60)
        }
        if section == 1 {
            if let first = dashboardItems.first
            {
                if first.subCampaignDetails.filter(CampaignRotateCVCell.filterDashboard(dashboard:)).count > 0
                {
                    return CGSize(width: width, height: width * 2 / 3)
                }
            }
            return CGSize(width: width, height: 1)
        }
        if section == 2 {
            let rows = ceil(CGFloat(arrCategory.count) / 4.0)
            return CGSize(width: width - 10, height: (85 * rows))
        }
        if section == 3 {
            return CGSize(width: width, height: 13)
        }
        if section == 4 {
            if indexPath.row == 0 {
                return CGSize(width: (width - 8 - 8), height: 30)
            }
            if indexPath.row == arrCampaign.count + 1 {
                return CGSize(width: width - 8 - 8, height: 40)
            }
            
            return CampaignCVCell.getSize(collectionView)
        }
        if section == 5 {
            let str = "main_footer_msg".localized()
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 16 - 16, height: CGFloat.leastNonzeroMagnitude))
            lbl.font = UIFont.mainFont(style: .normal)
            lbl.text = str
            lbl.sizeToFit()
            let lblHeight:CGFloat = lbl.frame.size.height
            let height:CGFloat = 16 + 8 + 30 + 8 + 30 + 16 + lblHeight + 30
            return CGSize(width: width, height: height)
        }
        
        return CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 4 {
            return UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4)
        }
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
}


// MARK:- CellCategoryDelegate
extension BzbsMainViewController : CategoryCVCellDelegate
{
    func didSelectedItem(index: Int) {
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
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        let item = arrCategory[index]
        if let nav = self.navigationController
        {
            let name = item.nameEn ?? ""
            analyticsSetEvent(category: "reward", action: "touch", label: name)
            if item.mode == "near_by"
            {
                if LocationManager.shared.authorizationStatus == .denied  {
                   PopupManager.confirmPopup(self, message: "popup_location_denied".localized(), strConfirm: "popup_setting".localized(), strClose: "popup_deny".localized(), confirm: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                            UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                UIApplication.shared.openURL(settingsUrl)
                            }
                        }
                    }) {
                        GotoPage.gotoNearby(nav)
                    }
                } else {
                    GotoPage.gotoNearby(nav)
                }
            }else {
                GotoPage.gotoCategory(nav, cat: item, arrCategory: arrCategory)
            }
        }
    }
}
// MARK:- CampaignRotateCVDelegate
extension BzbsMainViewController : CampaignRotateCVDelegate
{
    func didSelectDashboard(_ item: BzbsDashboard) {
        if let type = item.type
        {
            var eventLabel = ""
            switch type {
            case "hashtag" :
                if let nav = self.navigationController {
                    let vc = CampaignGroupListViewController.getViewController()
                    vc.dashboard = item
                    vc.hidesBottomBarWhenPushed = true
                    eventLabel = "\(item.hashtag ?? "")|\(item.line1 ?? "")"
                    nav.pushViewController(vc, animated: true)
                }
            case "link" :
                if let strUrl = item.url, let url = URL(string: strUrl)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    eventLabel = strUrl
                }
            case "cat" :
                if let _ = self.navigationController {
                    if let catId = item.cat
                    {
                        print("click cat:\(catId)")
                        if let arrCat = Bzbs.shared.arrCategory,
                            let nav = self.navigationController
                        {
                            if let first = arrCat.first(where: { (tmpCat) -> Bool in
                                return tmpCat.id == Int(catId)!
                            }){
                                GotoPage.gotoCategory(nav, cat: first, arrCategory: arrCat)
                            } else {
                                GotoPage.gotoCategory(nav, cat: arrCat.first!, arrCategory: arrCat)
                            }
                        }
                        let name = item.name ?? ""
                        eventLabel = "\(catId)|\(name)"
                    }
                }
            case "none" :
                eventLabel = "\(item.imageUrl ?? "")"
                break
            case "campaign" :
                if let nav = self.navigationController {
                    if let id = item.id {
                        let campaign = BzbsCampaign()
                        campaign.ID = Int(id)!
                        GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
                        // ไม่มี name/agency ส่งมา เดาๆไป
                        eventLabel = "\(id)|\(item.name ?? "")|\(item.line1 ?? "")"
                    }
                }
            default:
                break
            }
            
            analyticsSetEvent(category: "reward", action: "dtac_reward_banner", label: eventLabel)
        }
    }
}
// MARK:- ScanQRViewControllerDelegate
extension BzbsMainViewController: ScanQRViewControllerDelegate{
    func didScanWithResult(result: String) {
        if let url = URL(string:result){
            if let params = url.queryParameters
            {
                if params.keys.contains("thrdPrtyCmpgId") || params.keys.contains("cmpggroupid"){
                    var campaignId :Int?
                    if let id = BuzzebeesConvert.IntFromObjectNull(params["thrdPrtyCmpgId"] as AnyObject?) {
                        campaignId = id
                    } else if let id = BuzzebeesConvert.IntFromObjectNull(params["cmpggroupid"] as AnyObject?) {
                        campaignId = id
                    }
                    guard let _ = campaignId else{
                        DispatchQueue.main.async {
                            PopupManager.scanQrFailPopup(self, close: nil)
                        }
                        return
                    }
                    // Check Campaign is valid for Dtac
                    showLoader()
                    BzbsCoreApi().getCampaignStatus(campaignId: campaignId!,
                                                    deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                                    center: LocationManager.shared.getCurrentCoorndate(),
                                                    token: Bzbs.shared.userLogin?.token,
                                                    successCallback: { (status) in
                                                        let campaign = BzbsCampaign()
                                                        campaign.ID = campaignId!
                                                        DispatchQueue.main.async {
                                                            GotoPage.gotoCampaignDetail(self.navigationController!, campaign: campaign, target: self)
                                                        }
                                                        self.hideLoader()
                    },
                                                    failCallback: { (error) in
                                                        self.hideLoader()
                                                        if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                                                        DispatchQueue.main.async {
                                                            PopupManager.scanQrFailPopup(self, close: nil)
                                                        }
                    })
                    
                }
            } else {
                showLoader()
                if webView == nil {
                    let config = WKWebViewConfiguration()
                    let contentController = WKUserContentController()
                    contentController.add(
                        self,
                        name: "callbackHandler"
                    )
                    config.userContentController = contentController
                    webView = WKWebView(frame: self.view.frame, configuration: config)
                    webView!.navigationDelegate = self
                    webView!.isHidden = true
                    self.view.addSubview(webView!)
                }
                if let scheme = url.scheme, scheme == "http"
                {
                    let newStrUrl = url.absoluteString.replace("http", replacement: "https")
                    let request = URLRequest(url: URL(string:newStrUrl)!)
                    webView!.load(request)
                } else {
                    let request = URLRequest(url: url)
                    webView!.load(request)
                }
            }
        } else {
            PopupManager.scanQrFailPopup(self, close: nil)
        }
    }
}

extension BzbsMainViewController : WKNavigationDelegate, WKScriptMessageHandler
{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url
        {
            let strUrl = url.absoluteString
            print("didStartProvisionalNavigation : \(strUrl)")
            if isDeepLinkPrefix(url) {
                openDeepLinkURL(url)
                webView.stopLoading()
                hideLoader()
            } else if let params = url.queryParameters {
                if params.keys.contains("thrdPrtyCmpgId") || params.keys.contains("cmpggroupid"){
                    didScanWithResult(result: strUrl)
                    webView.stopLoading()
                    hideLoader()
                }
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = webView.url
        {
            let strUrl = url.absoluteString
            print("navigationResponse URL Open : \(strUrl)")
        }

        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = webView.url
        {
            let strUrl = url.absoluteString
            print("navigationAction URL Open : \(strUrl)")
        }
        decisionHandler(.allow)
    }
    
}
