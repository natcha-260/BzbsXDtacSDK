//
//  MainViewController.swift
//  iOS_Dtac_Rewards
//
//  Created by Buzzebees iMac on 12/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation
import AVFoundation
import FirebaseAnalytics
import WebKit
import ImageSlideshow

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
            collectionView.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "recommendCoinCell")
            
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
    var coinCategory: BzbsCategory?
    var arrCampaign = [BzbsCampaign]()
    var currentCenter = LocationManager.shared.getCurrentCoorndate()
    
    var isSendImpressionItems = false
    var isSendImpressionBanner = false
    
    var arrCoinCampaign = [BzbsDashboard]()
    var _intSkipCoin = 0
    var _isCallApiCoin = false
    var _isEndCoin = false
    var _isLoadDataCoin = false
    
    var webView : WKWebView?
    var isCallingExpiringPoint = false
    
    var rotateImageSlider : ImageSlideshow?
    
    // MARK:- Life Cycle
    // MARK:-
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addPullToRefresh(on: collectionView)
        
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
    
    private let refreshControl = UIRefreshControl()
    func addPullToRefresh(on collectionView: UICollectionView) {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSelector), for: .valueChanged)
    }
    
    @objc func refreshSelector() {
        self.currentCenter = LocationManager.shared.getCurrentCoorndate()
        self._intSkip = 0
        self._isEnd = false
        self._intSkipCoin = 0
        self._isEndCoin = false
        self.getExpiringPoint()
        self.getApiGreeting()
        self.getApiCategory()
        self.getApiRecommend()
        self.getApiCoinRecommend()
        self.getApi()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavigationBar()
        
        analyticsSetScreen(screenName: "reward")
        self.getExpiringPoint()
        
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
        rotateImageSlider?.unpauseTimer()
//        if !isLoggedIn()
//        {
//            Bzbs.shared.delegate?.reTokenTicket()
//        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rotateImageSlider?.pauseTimer()
//        self._intSkip = 0
//        self._isEnd = false
    }
    
    func initialUI() {
        
        getApiGreeting()
        if let token = Bzbs.shared.dtacLoginParams.token, token != "",
            let ticket = Bzbs.shared.dtacLoginParams.ticket, ticket != "",
            let DTACSegment = Bzbs.shared.dtacLoginParams.DTACSegment, DTACSegment != "",
            let TelType = Bzbs.shared.dtacLoginParams.TelType
        {
            let language = Bzbs.shared.dtacLoginParams.language ?? "th"
            let appVersion = Bzbs.shared.dtacLoginParams.appVersion ?? ""
            apiLogin(token, ticket: ticket, language:language, DTACSegment: DTACSegment, TelType: TelType, appVersion: appVersion)
            if Bzbs.shared.userLogin != nil {
                getApiCategory()
                getApiRecommend()
                getApiCoinRecommend()
                getApi()
            }
        } else {
            getApiCategory()
            getApiRecommend()
            getApiCoinRecommend()
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
        if let navController = self.navigationController,
           navController.viewControllers.first != self
        {
            navigationItem.leftBarButtonItems = BarItem.generate_logo(isShowBack: true, target: self, selector: #selector(dismissMain), isWhiteIcon: false)
        } else {
            navigationItem.leftBarButtonItems = BarItem.generate_logo()
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            navigationItem.rightBarButtonItems = BarItem.generate_message(self, isHasNewMessage: Bzbs.shared.isHasNewMessage, messageSelector: #selector(clickMessage))
        }
    }
    
    @objc func dismissMain() {
        self.navigationController?.popViewController(animated: true)
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
            _intSkipCoin = 0
            _isEnd = false
            getApiGreeting()
            getApiCategory()
            getApiRecommend()
            getApiCoinRecommend()
            getApi()
        }
    }
    
    func apiLogin(_ token:String, ticket: String, language:String, DTACSegment:String, TelType: String, appVersion: String)
    {
        let isNeedupdateUI = Bzbs.shared.userLogin == nil
        if !isNeedupdateUI {
            showLoader()
        }
        Bzbs.shared.login(token: token, ticket: ticket, language: language, DTACSegment:DTACSegment, TelType: TelType, appVersion: appVersion, completionHandler: {
            
            if let user = Bzbs.shared.userLogin, user.dtacLevel == .no_level {
                Bzbs.shared.delegate?.reLogin()
            }
            if isNeedupdateUI {
                NotificationCenter.default.post(name: NSNotification.Name(BBEnumNotificationCenter.updateUI.rawValue), object: nil)
            } else {
                self.hideLoader()
            }
            
        }) { (error) in
            self.hideLoader()
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!, message: error.message) {
                return
            } else {
                Bzbs.shared.delegate?.reLogin()
            }
        }
    }
    
    @objc open class func getView() -> BzbsMainViewController
    {
        let rect = UIScreen.main.bounds
        return getView(rect)
    }

    @objc open class func getView(_ frame:CGRect) -> BzbsMainViewController
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
    
    func getExpiringPoint()
    {
        guard let token = Bzbs.shared.userLogin?.token else { return }
        if isCallingExpiringPoint { return }
        isCallingExpiringPoint = true
        showLoader()
        BuzzebeesHistory().getExpiringPoint(token: token, successCallback: { (dict) in
            if let arr = dict["expiring_points"] as? [Dictionary<String, AnyObject>] ,
                let first = arr.first
            {
                if let expiringPoint = first["points"] as? Int {
                    Bzbs.shared.userLogin?.bzbsPoints = expiringPoint
                }
            }
            if self.collectionView.numberOfSections > 1 {
                self.collectionView.reloadData()
            }
            self.isCallingExpiringPoint = false
            self.hideLoader()
        }) { (error) in
            self.isCallingExpiringPoint = false
            self.hideLoader()
        }
    }
    
    override func getApi() {
        BuzzebeesDashboard().sub(dashboardName: "dtac_main",
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    self.dashboardItems = dashboard
                                    self.loadedData()
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
        BuzzebeesCategory().list(config: "menu_dtac_coins",
                                 token: Bzbs.shared.userLogin?.token,
                                 successCallback: { (listCategory) in
                                    self.arrCategory = listCategory
                                    // first cat is always Blue
                                    Bzbs.shared.blueCategory = listCategory.first
                                    Bzbs.shared.coinCategory = listCategory.last
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
                                        
                                        if userLogin.telType == .postpaid {
                                            Bzbs.shared.coinCategory?.subCat.removeAll { (cat) -> Bool in
                                                return cat.id == BuzzebeesCore.catIdVoiceNet
                                            }
                                        }
                                    } else {
                                        self.arrCategory.removeAll { (cat) -> Bool in
                                            return cat.id == Bzbs.shared.blueCategory?.id
                                        }
                                        
                                        Bzbs.shared.coinCategory?.subCat.removeAll { (cat) -> Bool in
                                            return cat.id == BuzzebeesCore.catIdVoiceNet
                                        }
                                    }
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                                 self.loadedData()
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
                                    
                                    if listCampaign.count < 4 {
                                        self._isEnd = true
                                    }

                                    self.arrCampaign = listCampaign
                                    
                                    // wordaround odd collection list count
                                    if self.arrCampaign.count % 2 != 0 {
                                        let dummyCampaign = BzbsCampaign()
                                        dummyCampaign.ID = -1
                                        self.arrCampaign.append(dummyCampaign)
                                    }
                                    //------
//                                    self._intSkip += 6
                                    self._isCallApi = false
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                    if error.id == "-9999"
                                    {
                                        self._isCallApi = false
                                        self.loadedData()
                                        return
                                    }
                                    self._isEnd = true
                                    self._isCallApi = false
                                    self.loadedData()
                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    // api get Dashboard for cat All
    func getApiCoinRecommend()
    {
        
        showLoader()
        BuzzebeesDashboard().sub(dashboardName: Bzbs.shared.userLogin?.telType.configRecommendAll ?? DTACTelType.postpaid.configRecommendAll,
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    self.arrCoinCampaign = dashboard.filter(BzbsDashboard.filterDashboardWithTelType(dashboard:))
                                        // wordaround odd collection list count
                                    if self.arrCoinCampaign.count % 2 != 0 {
                                        let dummyCampaign = BzbsDashboard()
                                        dummyCampaign.id = "-1"
                                        self.arrCoinCampaign.append(dummyCampaign)
                                    }
                                    if self.arrCoinCampaign.count > 4 {
                                        self.arrCoinCampaign.removeSubrange(4..<self.arrCoinCampaign.count)
                                    }
                                    
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                 self.arrCoinCampaign.removeAll()
                                 self.loadedData()
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    override func loadedData() {
        collectionView.stopPullToRefresh()
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
        self.hideLoader()
    }
    
    override func refreshApi() {
        _intSkip = 0
        _intSkipCoin = 0
        _isEnd = false
        getApiGreeting()
        getApiCategory()
        getApiRecommend()
        getApiCoinRecommend()
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
        _intSkipCoin = 0
        getApiRecommend()
        getApiCoinRecommend()
    }
    
    // MARK:- Action
    // MARK:-
    
    @IBAction func clickViewAllCampaign(_ sender: Any) {
        self.view.endEditing(true)
        
        analyticsSendRecommendedViewAll()
        
        if let nav = self.navigationController {
            nav.pushViewController(RecommendListViewController.getViewController(), animated: true)
        }
    }
    
    @IBAction func clickViewAllCoinRecommend(_ sender: Any) {
        self.view.endEditing(true)
        analyticsViewRecommendCoinAll()
        if let nav = self.navigationController {
            nav.pushViewController(RecommendCoinListViewController.getViewController(), animated: true)
        }
    }
    
    @IBAction func clickScan(_ sender: Any) {
        
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
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        // analyticsSetEvent(event:"track_event", category: "reward", action: "scan", label: "screen_name")
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
            PopupManager.confirmPopup(self, isWithImage:true, message: "action_click_req_login".errorLocalized()
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
        
        sendGATouchFooter(strLable: "main_footer_fav".localized())
        
        if let nav = self.navigationController {
            GotoPage.gotoFavourite(nav)
        }
        
    }
    
    @IBAction func clickHistory(_ sender: Any) {
        self.view.endEditing(true)
        
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
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        
        sendGATouchFooter(strLable: "main_footer_hist".localized())
        
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
        
        sendGATouchFooter(strLable: "main_footer_faq".localized())
        
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
        
        sendGATouchFooter(strLable: "main_footer_about".localized())
        
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
            case .gold :
                strUrl = Bzbs.shared.getUrlGoldMember()
                strTitle = BuzzebeesCore.levelNameGold
            case .silver :
                strUrl = Bzbs.shared.getUrlSilverMember()
                strTitle = BuzzebeesCore.levelNameSilver
            case .customer:
                strUrl = Bzbs.shared.getUrlDtacMember()
                strTitle = BuzzebeesCore.levelNameDtac
            case .no_level:
                strUrl = Bzbs.shared.getUrlDtacMember()
                strTitle = BuzzebeesCore.levelNameDtac
            }
            
            if let nav = self.navigationController {
                GotoPage.gotoWebSite(nav, strUrl: strUrl, strTitle: strTitle)
            }
        }
    }
    
    @objc func clickCoin() {
        analyticsTapCoinHist()
        if let nav = self.navigationController {
            GotoPage.gotoCoinHistory(nav)
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
    
    // FIXME:GA#1
    func analyticsTapSegment(segmentName:String) {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "your_segment | \(segmentName)")
    }
    
    // FIXME:GA#2
    func analyticsTapCoinHist() {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "your_coin")
    }
    
    // FIXME:GA#3
    func sendImpressionBanner(item:BzbsDashboard, index:Int)
    {
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID : (item.id ?? "") as AnyObject,
            AnalyticsParameterItemName : (item.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory : "reward/\(item.categoryName ?? "")/reward_banner" as AnyObject,
            AnalyticsParameterItemBrand : (item.line2 ?? "") as AnyObject,
            AnalyticsParameterIndex : NSNumber(value: index) as AnyObject,
            "metric1" : Double("\(item.price ?? "0")") ?? 0 as Any,
        ]
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "impression_banner" as NSString,
            "eventLabel" : "hero | \(item.categoryName ?? "") | reward_banner | \(index) | \(item.id ?? "")" as NSString,
            AnalyticsParameterItemListName: "reward_banner" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: ecommerce)
    }
    
    // FIXME:GA#4
    func analyticsSendSelectDashboard(_ item: BzbsDashboard, _ index: Int) {
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID : (item.id ?? "") as AnyObject,
            AnalyticsParameterItemName : (item.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory : "reward/\(item.categoryName ?? "")/reward_banner" as AnyObject,
            AnalyticsParameterItemBrand : (item.line2 ?? "") as AnyObject,
            AnalyticsParameterIndex : NSNumber(value: index) as AnyObject,
            "metric1" : Double("\(item.price ?? "0")") ?? 0 as Any,
        ]
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_banner" as NSString,
            "eventLabel" : "hero | \(item.categoryName ?? "") | reward_banner | \(index) | \(item.id ?? "")" as NSString,
            AnalyticsParameterItemListName: "reward_banner" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: ecommerce)
    }
    
    // FIXME:GA#5
    func analyticsSelectCategory(_ name: String) {
        analyticsSetEvent(event:"event_app", category: "reward", action: "touch_button", label: "reward_main_category | \(name)")
    }
    
    // FIXME:GA#6
    func analyticsSendRecommendedViewAll() {
        let eventLabel = "recommended_for_you | view_all"
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: eventLabel)
    }
    
    // FIXME:GA#7
    func sendImpressionItem(item:BzbsCampaign, index:Int)
    {
        if item.ID == -1 {
            return
        }
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID : "\(item.ID ?? -1)" as AnyObject,
            AnalyticsParameterItemName : (item.name ?? "") as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(item.categoryName ?? "")/reward_main".lowercased() as NSString,
            AnalyticsParameterItemBrand : (item.agencyName ?? "") as AnyObject,
            AnalyticsParameterIndex : NSNumber(value: index) as AnyObject,
            "metric1" : 0 as NSNumber,
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " impression_list" as NSString,
            "eventLabel" : "recommended_for_you" as NSString,
            AnalyticsParameterItemListName: "reward_main" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: ecommerce)
    }
    
    // FIXME:GA#8
    func sendGATouchEvent(_ campaign:BzbsCampaign, indexPath:IndexPath)
    {
        if campaign.ID == -1 {
            return
        }
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID : "\(campaign.ID ?? 0)" as AnyObject,
            AnalyticsParameterItemName : campaign.name as AnyObject,
            AnalyticsParameterItemCategory: "reward/\(campaign.categoryName ?? "")/reward_main".lowercased() as NSString,
            AnalyticsParameterItemBrand: campaign.agencyName as AnyObject,
            AnalyticsParameterIndex: NSNumber(value: (indexPath.row - 1)) as AnyObject,
            "metric1" : 0 as NSNumber,
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_list" as NSString,
            "eventLabel" : "recommended_for_you | {reward_index} | {reward_id}" as NSString,
            AnalyticsParameterItemListName: "reward_main" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: ecommerce)
    }
    
    // FIXME:GA#9
    func analyticsViewRecommendCoinAll() {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "recommend_coin_reward | view_all")
    }
    
    // FIXME:GA#10
    func sendImpressionCoinItem(item:BzbsDashboard, index:Int)
    {
        if item.id == "-1" {
            return
        }
        var name = item.line1
        if LocaleCore.shared.getUserLocale() == 1033
        {
            name = item.line2
        }
        
        if name == nil {
            name = item.line1 ?? item.line2 ?? "-"
        }
        
        
        var agencyName = item.line3
        if LocaleCore.shared.getUserLocale() == 1033
        {
            agencyName = item.line4
        }
        if agencyName == nil {
            agencyName = item.line3 ?? item.line4 ?? "-"
        }
        
        var intPointPerUnit = 0
        if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
            intPointPerUnit = pointPerUnit
        }
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = (item.id ?? "") as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/coins/reward_main" as AnyObject
        reward[AnalyticsParameterItemBrand] = agencyName as AnyObject
        reward[AnalyticsParameterIndex] = NSNumber(value: index) as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " impression_list" as NSString,
            "eventLabel" : "recommended_coin_rewards" as NSString,
            AnalyticsParameterItemListName: "reward_main" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: ecommerce)
    }
    
    // FIXME:GA#11
    func sendCoinGATouchEvent(_ item:BzbsDashboard, indexPath:IndexPath)
    {
        if item.id == "-1" {
            return
        }
        var name = item.line1
        if LocaleCore.shared.getUserLocale() == 1033
        {
            name = item.line2
        }
        
        if name == nil {
            name = item.line1 ?? item.line2 ?? "-"
        }
        
        var agencyName = item.line3
        if LocaleCore.shared.getUserLocale() == 1033
        {
            agencyName = item.line4
        }
        if agencyName == nil {
            agencyName = item.line3 ?? item.line4 ?? "-"
        }
        
        var intPointPerUnit = 0
        if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
            intPointPerUnit = pointPerUnit
        }
        let index = indexPath.row
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = (item.id ?? "") as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/coins/reward_main" as AnyObject
        reward[AnalyticsParameterItemBrand] = agencyName as AnyObject
        reward[AnalyticsParameterIndex] = NSNumber(value: index) as AnyObject
//        reward[AnalyticsParameterItemVariant] = "{code_duration}" as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_list" as NSString,
            "eventLabel" : "recommended_coin_rewards | coins | reward_main | {reward_index} | {reward_id}" as NSString,
            AnalyticsParameterItemListName: "reward_main" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: ecommerce)
    }
    
    // FIXME:GA#12
    func sendGATouchFooter(strLable:String) {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "footer | \(strLable)")
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
            PopupManager.confirmPopup(self, isWithImage:true, message: "action_click_req_login".errorLocalized()
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
        return 7
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
            return 1 + arrCampaign.count + 1// + (_isEnd ? 0 : 1)
        case 5 :
            return 1 + arrCoinCampaign.count + 1// + (_isEnd ? 0 : 1)
        case 6 :
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
            cell.setupWithModel(self.greetingModel, coin: Bzbs.shared.userLogin?.bzbsPoints ?? 0, target: self, levelSelector: #selector(clickLevel), coinSelector: #selector(clickCoin))
            return cell
        }
        if section == 1 {
            if dashboardItems.count <= 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignRotateCell", for: indexPath) as! CampaignRotateCVCell
            cell.dashboardItems = dashboardItems
            if rotateImageSlider != cell.imageSlideShow {
                rotateImageSlider = cell.imageSlideShow
            }
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
                cell.setupWith(title: "recommend_title".localized() ,target: self, selector: #selector(clickViewAllCampaign(_:)))
                return cell
            }
            if row == arrCampaign.count + 1 {
                // Workaround bug apple : https://stackoverflow.com/questions/36716834/ios-uicollectionview-layout-last-row
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
            let item = arrCampaign[row - 1]
            cell.setupWith(item, isShowDistance: true)
            sendImpressionItem(item: item, index: row - 1)
            return cell
        }
        if section == 5 {
            if row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendHeaderCVCell", for: indexPath) as! RecommendHeaderCVCell
                cell.setupWith(title: "recommend_coin_title".localized() ,target: self, selector: #selector(clickViewAllCoinRecommend(_:)))
                return cell
            }
            if row == arrCoinCampaign.count + 1 {
                // Workaround bug apple : https://stackoverflow.com/questions/36716834/ios-uicollectionview-layout-last-row
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCoinCell", for: indexPath) as! CampaignCoinCVCell
            let item = arrCoinCampaign[row - 1]
            cell.setupWith(item, isShowDistance: true)
            sendImpressionCoinItem(item: item, index: row - 1)
            analyticsSetEvent(event: AnalyticsEventViewItemList, category: "reward", action: "impression_list", label: "recommend_coin_reward")
            return cell
        }
        if section == 6 {
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
                if item.ID == -1 { return }
                sendGATouchEvent(item,indexPath: indexPath)
                if let nav = self.navigationController {
                    GotoPage.gotoCampaignDetail(nav, campaign: item, target: self)
                }
            }
        }else if indexPath.section == 5 {
            if (indexPath.row - 1) == arrCoinCampaign.count{
                getApiCoinRecommend()
            } else {
                if arrCoinCampaign.count < indexPath.row - 1 || indexPath.row == 0 { return }
                let item = arrCoinCampaign[indexPath.row - 1]
                if item.id == "-1" { return }
                sendCoinGATouchEvent(item,indexPath: indexPath)
                if let nav = self.navigationController {
                    let campaign = item.toCampaign()
                    GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let width = collectionView.bounds.size.width
        if section == 0 {
            return CGSize(width: width, height: ((width * 104) / 375) + 4)
        }
        if section == 1 {
            if let first = dashboardItems.first
            {
                if first.subCampaignDetails.filter(BzbsDashboard.filterDashboard(dashboard:)).count > 0
                {
                    return CGSize(width: width, height: width * 2 / 3)
                }
            }
            return CGSize(width: width, height: 1)
        }
        if section == 2 {
            if arrCategory.count == 0 {
                return CGSize(width: width - 10, height: 0.1)
            }
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
                return CGSize(width: width, height: 0)
//                return CGSize(width: width - 8 - 8, height: 40)
            }
            
            return CampaignCVCell.getSize(collectionView)
        }
        if section == 5 {
            if indexPath.row == 0 {
                return CGSize(width: (width - 8 - 8), height: 30)
            }
            if indexPath.row == arrCoinCampaign.count + 1 {
                return CGSize(width: width, height: 0)
//                return CGSize(width: width - 8 - 8, height: 40)
            }
            
            return CampaignCoinCVCell.getSize(collectionView)
        }
        if section == 6 {
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
        if section == 4 || section == 5 {
            return UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4)
        }
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4).left
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
            PopupManager.confirmPopup(self, isWithImage:true, message: "action_click_req_login".errorLocalized()
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
            analyticsSelectCategory(name)
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
    func didViewDashboard(_ item: BzbsDashboard, index: Int) {
        sendImpressionBanner(item: item, index: index)
    }
    
    func didSelectDashboard(_ item: BzbsDashboard, index: Int) {
        if let type = item.type
        {
            switch type {
            case "hashtag" :
                if let nav = self.navigationController {
                    let vc = MajorCampaignListViewController.getViewController()
                    vc.dashboard = item
                    vc.hidesBottomBarWhenPushed = true
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
                    }
                }
            case "none" :
                break
            case "campaign" :
                if let nav = self.navigationController {
                    let campaign = item.toCampaign()
                    GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
                }
            default:
                break
            }
            
            analyticsSendSelectDashboard(item, index)
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
                                                    successCallback: { (status, _) in
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
            if url.isDtacDeepLinkPrefix() {
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
