//
//  ViewCampaignByCatController.swift
//  Pods
//
//  Created by Buzzebees iMac on 20/9/2562 BE.
//

import UIKit
import Alamofire
import CoreLocation
import AVFoundation
import FirebaseAnalytics
import WebKit
import ImageSlideshow

open class CampaignByCatViewController: BaseListController {
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var txtSearch: UITextField!{
        didSet{
            txtSearch.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.font : UIFont.mainFont()])
            txtSearch.delegate = self
        }
    }
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewScan: UIView!
    @IBOutlet weak var lblScan: UILabel!
    @IBOutlet weak var imvScan: UIImageView!
    @IBOutlet weak var subCategoryCV: UICollectionView!{
        didSet{
            subCategoryCV.register(SubCatCVCell.getNib(), forCellWithReuseIdentifier: "subCatCVCell")
            if let flow = subCategoryCV.collectionViewLayout as? UICollectionViewFlowLayout
            {
                flow.scrollDirection = .horizontal
            }
            subCategoryCV.register(UIView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "none")
        }
    }
    
    @IBOutlet weak var cstCategoryHeight: NSLayoutConstraint!
    @IBOutlet weak var cstCampaignListTop: NSLayoutConstraint!
    @IBOutlet weak var vwCategory: UIView!
    @IBOutlet weak var categoryCV: UICollectionView!{
        didSet{
            categoryCV.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: Bzbs.shared.currentBundle), forCellWithReuseIdentifier: "cellCollectionCategory")
            if let flow = categoryCV.collectionViewLayout as? UICollectionViewFlowLayout
            {
                flow.scrollDirection = .vertical
            }
            categoryCV.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            categoryCV.register(UIView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "none")
        }
    }
    
    @IBOutlet weak var cstTopViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var campaignCV: UICollectionView! {
        didSet{
            if let layout = campaignCV.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
            }
            campaignCV.isPagingEnabled = false
            campaignCV.delegate = self
            campaignCV.dataSource = self
            campaignCV.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "dashboardHeaderCell")
            campaignCV.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "campaignCell")
            campaignCV.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "campaignCoinCell")
            campaignCV.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
            campaignCV.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCVCell")
            campaignCV.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 8, right: 2)
            campaignCV.alwaysBounceVertical = true
            addPullToRefresh(on: campaignCV)
        }
        
    }
    @IBOutlet weak var vwPointExpire: UIView!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var imvCoin: UIImageView!
    @IBOutlet weak var lblExpireDate: UILabel!
    
    private let refreshControl = UIRefreshControl()
    func addPullToRefresh(on collectionView: UICollectionView) {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSelector), for: .valueChanged)
    }
    
    @objc func refreshSelector() {
        self._intSkip = 0
        self._isEnd = false
        
        if self.isCategoryAll()  {
            self.getAllDashboard()
        } else {
            self.getApi()
        }
    }
    
    
    // MARK:- Variable
    var dashboardItems = [BzbsDashboard]()
    var dashboardAllItems = [BzbsDashboard]()
    var arrCategory = [BzbsCategory]()
    {
        didSet{
            Bzbs.shared.arrCategory = arrCategory
        }
    }
    
    var currentCat :BzbsCategory? {
        didSet{
            guard let currentCat = currentCat else {
                getApiCategory()
                return
            }
            let name = currentCat.name.lowercased()
            if let blueCat = Bzbs.shared.blueCategory, blueCat.id == currentCat.id {
                analyticsSetScreen(screenName: "reward_blue")
            } else {
                let screenName = "reward_" + name.replace(" ", replacement: "_")
                analyticsSetScreen(screenName: screenName)
            }
            
            sendGACategoryTouchEvent(category: currentCat)
            if let first = currentCat.subCat.first
            {
                currentSubCat = first
                sendGACategoryTouchEvent(subCat: first)
                self.subCategoryCV?.reloadData()
                self.subCategoryCV?.scrollRectToVisible(CGRect.zero, animated: false)
                self._isEnd = false
                self._intSkip = 0
                generateSubCatView()
            }
        }
    }
    var currentSubCat :BzbsCategory? {
        didSet{
            self._isEnd = false
            self._intSkip = 0
            self.generateSubCatView()
            if campaignCV != nil {
                if isCategoryAll()  {
                    // to hide items on all cat
                    campaignCV.reloadData()
                    getAllDashboard()
                    return
                }
                delay(0.33) {
                    self.getApi()
                }
            }
        }
    }
    var campaignConfig = "campaign_dtac_customer_level"
    //    var campaignList = RecommendListViewController.getViewController()
    var isShowCat = false
    var isSendImpressionItems = false
    var impressionItems = [BzbsCampaign]()
    var webView : WKWebView?
    
    var strCategory:String?
    var strSubCategory:String?
    
    var imageSlider : ImageSlideshow?
    
    // MARK:- Class function
    // MARK:-
    @objc public class func getView(category: String?, subCategory:String?) -> CampaignByCatViewController
    {
        
        let storyboard = UIStoryboard(name: "Category", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "campaign_by_category_view") as! CampaignByCatViewController
        controller.strCategory = category
        controller.strSubCategory = subCategory
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        return controller
    }
    
    @objc public class func getViewWithNavigationBar(category: String, subCategory:String?, isHideNavigationBar:Bool = true) -> UINavigationController
    {
        let nav = UINavigationController(rootViewController: getView(category: category, subCategory:subCategory))
        nav.isNavigationBarHidden = isHideNavigationBar
        nav.navigationBar.backgroundColor = .white
        nav.navigationBar.tintColor = .mainBlue
        nav.navigationBar.barTintColor = .white
        return nav
    }
    
    // MARK:- View life cycle
    // MARK:-
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let arrCategory = Bzbs.shared.arrCategory{
            if currentCat == nil {
                self.arrCategory = arrCategory
                categoryLoaded()
            }
            initNav()
            getApi()
            if isCategoryAll() {
                getAllDashboard()
            }
            getDashboard()
        } else {
            showLoader()
            getApiCategory()
        }
        
        checkSearchBarOrPoint()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.vwCategory.alpha = 0
        imageSlider?.unpauseTimer()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkSearchBarOrPoint()
        
        if let name = currentCat?.name.lowercased() {
            if let blueCat = Bzbs.shared.blueCategory, blueCat.id == currentCat?.id {
                analyticsSetScreen(screenName: "reward_blue")
            } else {
                let screenName = "reward_" + name.replace(" ", replacement: "_")
                analyticsSetScreen(screenName: screenName)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name: NSNotification.Name.BzbsViewDidBecomeActive, object: nil)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageSlider?.pauseTimer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BzbsViewDidBecomeActive, object: nil)
    }
    
    open override func updateUI() {
        super.updateUI()
        if userLocale() == BBLocaleKey.mm.rawValue {
            getExpiringPoint()
            
            lblPoint.font = UIFont.mainFont(.big, style: .bold)
            lblExpireDate.font = UIFont.mainFont(.small,style: .bold)
            lblPoint.text = ""
            imvCoin.isHidden = true
            lblExpireDate.text = ""
            
            vwPointExpire.isHidden = false
            viewSearch.isHidden = true
            viewScan.isHidden = true
        } else {
            UIView.animate(withDuration: 0) {
                self.cstTopViewHeight.constant = 60
                self.view.layoutIfNeeded()
            }
            lblScan?.text = "scan_title".localized()
            txtSearch?.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
            vwPointExpire.isHidden = true
            viewSearch.isHidden = false
            viewScan.isHidden = false
            viewScan.cornerRadius()
            viewSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        }
    }
    
    // MARK:- Util
    // MARK:- generateSubCatView
    func generateSubCatView(){
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        vw.cornerRadius(borderColor: UIColor.darkGray, borderWidth: 1)
        let lbl = UILabel(frame: vw.bounds)
        lbl.font = UIFont.mainFont()
        lbl.textColor = .black
        if let currentCat = currentCat {
            lbl.text = currentCat.name
        }
        lbl.textAlignment = .center
        lbl.sizeToFit()
        lbl.frame = CGRect(x: 8, y: 0, width:  lbl.bounds.size.width, height: 30)
        vw.addSubview(lbl)
        if userLocale() != BBLocaleKey.mm.rawValue {
            let imv = UIImageView(frame: CGRect(x: lbl.frame.origin.x + lbl.frame.size.width + 6, y: 10, width: 10, height: 10))
            imv.image = UIImage(named: "img_navbar_icon_dropdown",in: Bzbs.shared.currentBundle, compatibleWith: nil)
            imv.contentMode = .scaleAspectFit
            vw.addSubview(imv)
            vw.frame = CGRect(x: 0, y: 0, width: 8 + lbl.bounds.size.width + 6 + 10 + 8, height: 30)
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: vw.frame.width, height: 44))
            btn.addTarget(self, action: #selector(clickCat), for: UIControl.Event.touchUpInside)
            vw.addSubview(btn)
        } else {
            vw.frame = CGRect(x: 0, y: 0, width: 8 + lbl.bounds.size.width + 8, height: 30)
        }
        
        self.navigationItem.titleView = vw
    }
    
    @objc func clickCat(){
        let width = categoryCV.frame.size.width / 4.5
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.leastNonzeroMagnitude))
        lbl.font = UIFont.mainFont(.small)
        lbl.text = "\n"
        lbl.sizeToFit()
        let cellHeight = (width / 2) + lbl.frame.size.height
        let rows = ceil(CGFloat(arrCategory.count) / 4)
        let height = rows * cellHeight
        cstCategoryHeight.constant = height + 8
        isShowCat.toggle()
        UIView.animate(withDuration: 0.22, animations: {
            self.vwCategory.alpha = self.isShowCat ? 1 : 0
            self.categoryCV.reloadData()
        }) { (isComplete) in
            UIView.animate(withDuration: 0.33) {
                if let cells = self.subCategoryCV.visibleCells as? [SubCatCVCell] {
                    var indexPath = IndexPath(item: 0, section: 0)
                    if let cell = cells.first(where: { (tmp) -> Bool in
                        return tmp.isActive
                    }){
                        indexPath = self.subCategoryCV.indexPath(for: cell) ?? IndexPath(item: 0, section: 0  )
                    }
                    self.subCategoryCV.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
                }
                
            }
        }
        print("Click Cat")
    }
    
    override func initNav() {
        generateSubCatView()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
    }
    
    func isCategoryAll() -> Bool {
        if userLocale() == BBLocaleKey.mm.rawValue { return false }
        guard let currentCat = currentCat , let currentSubCat = currentSubCat else { return false }
        //#54590 if cat all and not blue member
        return currentSubCat.nameEn.lowercased() == ((currentCat.subCat.first?.nameEn.lowercased()) ?? "") && currentCat.id != Bzbs.shared.blueCategory?.id
    }
    
    func checkSearchBarOrPoint() {
        if userLocale() == BBLocaleKey.mm.rawValue {
            getExpiringPoint()
            getApiCategory(isReloadOnly: false)
            lblPoint.font = UIFont.mainFont(.big, style: .bold)
            lblExpireDate.font = UIFont.mainFont(.small,style: .bold)
            lblPoint.text = ""
            imvCoin.isHidden = true
            lblExpireDate.text = ""
            
            vwPointExpire.isHidden = false
            viewSearch.isHidden = true
            viewScan.isHidden = true
        } else {
            vwPointExpire.isHidden = true
            viewSearch.isHidden = false
            viewScan.isHidden = false
            viewScan.cornerRadius()
            viewSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        }
    }
    
    
    // MARK:- Event
    // MARK:- Click
    @IBAction func clickScan(_ sender: Any) {
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
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
    @IBAction func clickCatDismiss(_ sender: Any) {
        clickCat()
    }
    
    // MARK:- Api
    // MARK:- get campaign list
    let _intTop = 25
    let controller = BuzzebeesCampaign()
    override func getApi() {
        if _isCallApi || _isEnd { return }
        guard let currentSubCat = currentSubCat else { return }
        _isCallApi = true
        showLoader()
        controller.list(config: currentSubCat.listConfig
                        , top : _intTop
                        , skip: _intSkip
                        , search: ""
                        , catId: currentSubCat.id
                        , token: Bzbs.shared.userLogin?.token
                        , center : LocationManager.shared.getCurrentCoorndate()
                        , isAllowCancel: true
                        , successCallback: { (tmpList) in
                            
                            if self._intSkip == 0 {
                                self._arrDataShow = tmpList
                            } else {
                                self._arrDataShow.append(contentsOf: tmpList)
                            }
                            self._isEnd = tmpList.count < self._intTop
                            self._intSkip += self._intTop
                            self.loadedData()
                        }) { (error) in
            if error.message != "cancelled" {
                self._arrDataShow.removeAll()
                self._isEnd = true
                self.loadedData()
                
            }
        }
    }
    
    // api get Dashboard Top
    func getDashboard()
    {
        if self.currentCat == nil {
            self.currentCat = arrCategory.first
        }
        guard let currentCat = currentCat else { return }
        if currentCat.id == Bzbs.shared.blueCategory?.id {
            var imageUrl = BuzzebeesCore.blobUrl + "/dtac/category/\(self.currentSubCat?.id ?? 0)"
            if let url = URL(string:imageUrl), let host = url.host, host == "buzzebees.blob.core.windows.net"
            {
                let newStrUrl = imageUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                if let _ = URL(string: newStrUrl)
                {
                    imageUrl = newStrUrl
                }
            }
            let dashboard = BzbsDashboard()
            dashboard.imageUrl = imageUrl
            dashboard.type = "none"
            self.dashboardItems = [dashboard]
            self.campaignCV.reloadData()
        } else {
            apiGetSubDashboard(getBannerDashboardConfig())
        }
    }
    
    func apiGetSubDashboard(_ dashboardName:String) {
        BuzzebeesDashboard().sub(dashboardName: dashboardName,
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    self.dashboardItems.removeAll()
                                    if let first = dashboard.first {
                                        self.dashboardItems = first.subCampaignDetails
                                    }
                                    self.campaignCV.reloadData()
                                 },
                                 failCallback: { (error) in
                                    self.dashboardItems.removeAll()
                                    self.campaignCV.reloadData()
                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                                 })
    }
    
    func getAllDashboardConfig() -> String {
        let config = "dtac_category_\(currentCat?.id ?? 0)_all"
        if currentCat?.id == BuzzebeesCore.catIdCoin {
            return Bzbs.shared.userLogin?.telType.configRecommendAll ?? DTACTelType.postpaid.configRecommendAll
        }
        return config
    }
    
    func getBannerDashboardConfig() -> String {
        let config = "dtac_category_\(currentCat?.id ?? 0)"
        if userLocale() == BBLocaleKey.mm.rawValue {
            if let id = currentSubCat?.id {
                return "dtac_category_\(id)"
            }
        }
        else if currentCat?.id == BuzzebeesCore.catIdCoin {
            return Bzbs.shared.userLogin?.telType.configRecommend ?? config
        }
        return config
    }
    
    // api get Dashboard for cat All
    func getAllDashboard()
    {
        showLoader()
        BuzzebeesDashboard().sub(dashboardName: getAllDashboardConfig(),
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    if self.currentCat?.id == BuzzebeesCore.catIdCoin {
                                        self.dashboardAllItems = dashboard.filter(BzbsDashboard.filterDashboardWithTelType(dashboard:))
                                    } else {
                                        self.dashboardAllItems = dashboard.filter(BzbsDashboard.filterDashboard(dashboard:))
                                    }
                                    self.loadedData()
                                 },
                                 failCallback: { (error) in
                                    self.dashboardAllItems.removeAll()
                                    self.loadedData()
                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                                 })
    }
    
    var isCallingCategory = false
    func getApiCategory(isReloadOnly:Bool = false) {
        if Bzbs.shared.userLogin?.token == nil {
            delay(1) {
                self.getApiCategory(isReloadOnly:isReloadOnly)
            }
            return
        }
        if isCallingCategory { return }
        isCallingCategory = true
        
        BuzzebeesCategory().list(config: "menu_dtac_coins_v2",
                                 token: Bzbs.shared.userLogin?.token,
                                 isAllowCancel: true,
                                 successCallback: { (listCategory) in
                                    self.arrCategory = listCategory
                                    // first cat is always Blue
                                    Bzbs.shared.blueCategory = listCategory.first
                                    if self.userLocale() == BBLocaleKey.mm.rawValue {
                                        if let coinCat =  self.arrCategory.first(where: { (cat) -> Bool in
                                            return cat.id == BuzzebeesCore.catIdCoin
                                        }) {
                                            coinCat.subCat.removeAll { (subcat) -> Bool in
                                                subcat.id != BuzzebeesCore.catIdVoiceNet
                                            }
                                            self.arrCategory = [coinCat]
                                        } else {
                                            self.arrCategory.removeAll()
                                        }
                                        
                                        
                                    } else {
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
                                                self.arrCategory.forEach { (cat) in
                                                    cat.subCat.removeAll { (cat) -> Bool in
                                                        return cat.id == BuzzebeesCore.catIdVoiceNet
                                                    }
                                                }
                                            }
                                        } else {
                                            self.arrCategory.removeAll { (cat) -> Bool in
                                                return cat.id == Bzbs.shared.blueCategory?.id
                                            }
                                            
                                            self.arrCategory.forEach { (cat) in
                                                cat.subCat.removeAll { (cat) -> Bool in
                                                    return cat.id == BuzzebeesCore.catIdVoiceNet
                                                }
                                            }
                                        }
                                    }
                                    if isReloadOnly {
                                        if let currentCat = self.currentCat {
                                            self.currentCat = self.arrCategory.first(where: { (c) -> Bool in
                                                c.id == currentCat.id
                                            })
                                        }
                                    } else {
                                        self.categoryLoaded()
                                        self.getDashboard()
                                    }
                                    self.loadedData()
                                    self.isCallingCategory = false
                                 },
                                 failCallback: { (error) in
                                    if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
                                    self.loadedData()
                                    self.isCallingCategory = false
                                 })
    }
    
    func categoryLoaded(){
        let tmpCatId = Int((strCategory?.removingPercentEncoding ?? ""))
        let tmpSubCatId = Int(strSubCategory?.removingPercentEncoding ?? "")
        print("goto \(tmpCatId ?? 0), \(tmpSubCatId ?? 0)")
        
        var cat :BzbsCategory?
        var subCat : BzbsCategory?
        if let catId = tmpCatId {
            if let _cat = arrCategory.first(where: { (tmpCat) -> Bool in
                                                return tmpCat.id == catId })
            {
                cat = _cat
                if let subCatId = tmpSubCatId
                {
                    if let _subCat = _cat.subCat.first(where: { (tmpSubCat) -> Bool in
                                                        return tmpSubCat.id == subCatId })
                    {
                        subCat = _subCat
                    }
                }
            }
        } else {
            if let first = arrCategory.first {
                cat = first
            }
        }
        
        if cat == nil { return }
        self.currentCat = cat
        if let _ = subCat
        {
            self.currentSubCat = subCat
        } else {
            self.currentSubCat = currentCat?.subCat.first
        }
        
        if let index = currentCat?.subCat.firstIndex(where: { (cat) -> Bool in
            return cat.id == currentSubCat?.id
        }) {
            subCategoryCV.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.right, animated: false)
        }
    }
    
    func analyticsSetRemainingCoin() {
        analyticsSetUserProperty(propertyName: "remaining_coin", value: "\(Bzbs.shared.userLogin?.bzbsPoints ?? 0)")
    }
    
    func getExpiringPoint()
    {
        guard let token = Bzbs.shared.userLogin?.token else {
            lblPoint.text = ""
            imvCoin.isHidden = true
            lblExpireDate.text = ""
            UIView.animate(withDuration: 0) {
                self.cstTopViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            return
        }
        self.lblPoint.text = "your_coin".localized() + " " + 0.withCommas()
        self.imvCoin.isHidden = false
        
        let expireDate = Date()
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd MMM yyyy"
        self.lblExpireDate.text = "valid_till".localized() + " " + formatter.string(from: expireDate)
        
        showLoader()
        BuzzebeesHistory().getExpiringPoint(token: token, successCallback: { (dict) in
            if let arr = dict["expiring_points"] as? [Dictionary<String, AnyObject>] ,
               let first = arr.first
            {
                UIView.animate(withDuration: 0.1) {
                    self.cstTopViewHeight.constant = 60
                    self.view.layoutIfNeeded()
                }
                if let expiringPoint = first["points"] as? Int {
                    self.lblPoint.text = "your_coin".localized() + " " + expiringPoint.withCommas()
                    self.imvCoin.isHidden = false
                    Bzbs.shared.userLogin?.bzbsPoints = expiringPoint
                    self.analyticsSetRemainingCoin()
                }
                if let time = first["time"] as? TimeInterval
                {
                    let expireDate = Date(timeIntervalSince1970: time)
                    let formatter = DateFormatter()
                    formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
                    formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    formatter.dateFormat = "dd MMM yyyy"
                    self.lblExpireDate.text = "valid_till".localized() + " " + formatter.string(from: expireDate)
                }
            } else {
                UIView.animate(withDuration: 0) {
                    self.cstTopViewHeight.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
            self.hideLoader()
        }) { (error) in
            self.hideLoader()
        }
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
//        if Bzbs.shared.arrCategory == nil { return }
        getApiCategory()
        getApi()
        getDashboard()
    }
    
    override func loadedData() {
        self.campaignCV.reloadData()
        self._isCallApi = false
        self.campaignCV.stopPullToRefresh()
        self.hideLoader()
    }
    
    // MARK:- Analytic Impression
    // MARK:-
    // FIXME:GA#13
    func sendGACategoryTouchEvent(category:BzbsCategory)
    {
        let name = category.nameEn.lowercased()
        analyticsSetEvent(event:"event_app", category: "reward", action: "touch_button", label: "dropdown_category | \(name)")
    }
    
    // FIXME:GA#14
    func anaylticsTapSearch() {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search_box")
    }
    
    // FIXME:GA#15
    func sendGACategoryTouchEvent(subCat:BzbsCategory)
    {
        let categoryName = currentCat?.nameEn.lowercased() ?? BzbsAnalyticDefault.category.rawValue
        let subCategoryName = subCat.nameEn.lowercased()
        analyticsSetEvent(event:"event_app", category: "reward", action: "touch_button", label: "filter | \(categoryName) | \(subCategoryName)")
    }
    
    // FIXME:GA#16
    func sendCoinImpressionBanner(_ item:BzbsDashboard, index:Int)
    {
        if item.id == "-1" {
            return
        }
        
        var name = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if let line1 = item.line1 ,!line1.isEmpty {
                name = item.line1
            }
        } else {
            if let line2 = item.line2 ,!line2.isEmpty {
                name = item.line2
            }
        }
        
        var catName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentCat?.nameEn, !nameEn.isEmpty {
            catName = nameEn
        }
        var subCatName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentSubCat?.nameEn, !nameEn.isEmpty {
            subCatName = nameEn
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if let line3 = item.line3 ,!line3.isEmpty {
                agencyName = item.line3
            }
        } else {
            if let line4 = item.line4 ,!line4.isEmpty {
                agencyName = item.line4
            }
        }
        
        var intPointPerUnit = 0
        if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
            intPointPerUnit = pointPerUnit
        }
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = (item.id ?? "") as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/\(catName)/\(subCatName)".lowercased() as AnyObject
        reward[AnalyticsParameterItemBrand] = (agencyName) as AnyObject
        reward[AnalyticsParameterIndex] = NSNumber(value: index + 1) as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        let label =  "hero | \(catName) | \(subCatName) | \(index + 1) | \(item.id ?? "")".lowercased()
        let ecommerce : [String: AnyObject] = [
            "items" : [reward] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "impression_banner" as NSString,
            "eventLabel" : label as NSString,
            AnalyticsParameterItemListName: "reward_banner_\(catName)" as AnyObject
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewItemList, params: ecommerce)
    }
    
    // FIXME:GA#17
    func sendCoinTouchBanner(_ item:BzbsDashboard, index:Int)
    {
        if item.id == "-1" {
            return
        }
        
        var name = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if let line1 = item.line1 ,!line1.isEmpty {
                name = item.line1
            }
        } else {
            if let line2 = item.line2 ,!line2.isEmpty {
                name = item.line2
            }
        }
        
        var catName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentCat?.nameEn, !nameEn.isEmpty {
            catName = nameEn
        }
        var subCatName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentSubCat?.nameEn, !nameEn.isEmpty {
            subCatName = nameEn
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if let line3 = item.line3 ,!line3.isEmpty {
                agencyName = item.line3
            }
        } else {
            if let line4 = item.line4 ,!line4.isEmpty {
                agencyName = item.line4
            }
        }
        
        var intPointPerUnit = 0
        if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
            intPointPerUnit = pointPerUnit
        }
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = (item.id ?? "") as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/\(catName)/\(subCatName)".lowercased() as AnyObject
        reward[AnalyticsParameterItemBrand] = (agencyName) as AnyObject
        reward[AnalyticsParameterIndex] = NSNumber(value: index + 1) as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        let label =  "hero | \(catName) | \(subCatName) | \(index + 1) | \(item.id ?? "")"
        let ecommerce : [String:AnyObject] = [
            "items" : [reward] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_banner" as NSString,
            "eventLabel" : label as NSString,
            AnalyticsParameterItemListName: "reward_banner_\(catName)" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventSelectItem, params: ecommerce)
    }
    
    // FIXME:GA#18
    func sendImpressionCampaign(_ item:BzbsCampaign, index:Int)
    {
        if item.ID == -1 {
            return
        }
        var name = BzbsAnalyticDefault.name.rawValue
        if !item.name.isEmpty {
            name = item.name
        }
        
        var catName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentCat?.nameEn, !nameEn.isEmpty {
            catName = nameEn
        }
        var subCatName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentSubCat?.nameEn, !nameEn.isEmpty {
            subCatName = nameEn
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if !item.agencyName.isEmpty {
            agencyName = item.agencyName
        }
        let intPointPerUnit = item.pointPerUnit ?? 0
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = "\(item.ID ?? 0)" as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/\(catName)/\(subCatName)".lowercased() as AnyObject
        reward[AnalyticsParameterItemBrand] = (agencyName) as AnyObject
        reward[AnalyticsParameterIndex] = NSNumber(value: index + 1) as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        
        let label =  "reward_list | \(catName) | \(subCatName) | \(index + 1) | \(item.ID!)".lowercased()
        let ecommerce : [String: AnyObject] = [
            "items" : [reward] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "impression_list" as NSString,
            "eventLabel" : label as NSString,
            AnalyticsParameterItemListName: "reward_main_\(catName)" as AnyObject
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewItemList, params: ecommerce)
    }
    
    // FIXME:GA#19
    func sendTouchCampaign(_ campaign:BzbsCampaign, indexPath:IndexPath)
    {
        if campaign.ID == -1 {
            return
        }
        var name = BzbsAnalyticDefault.name.rawValue
        if !campaign.name.isEmpty {
            name = campaign.name
        }
        
        var catName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentCat?.nameEn, !nameEn.isEmpty {
            catName = nameEn
        }
        var subCatName = BzbsAnalyticDefault.name.rawValue
        if let nameEn =  currentSubCat?.nameEn, !nameEn.isEmpty {
            subCatName = nameEn
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if !campaign.agencyName.isEmpty {
            agencyName = campaign.agencyName
        }
        let intPointPerUnit = campaign.pointPerUnit ?? 0
        
        var reward = [String:Any]()
        reward[AnalyticsParameterItemID] = "\(campaign.ID ?? 0)"
        reward[AnalyticsParameterItemName] = name as NSString
        reward[AnalyticsParameterItemCategory] = "reward/\(catName)/\(subCatName)".lowercased() as AnyObject
        reward[AnalyticsParameterItemBrand] = agencyName
        reward[AnalyticsParameterIndex] = NSNumber(value: indexPath.row + 1)
        reward["metric1"] = intPointPerUnit
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward]
        
        let eventLabel = "reward_list | \(catName) | \(subCatName) | \(indexPath.row + 1) | \(campaign.ID!)".lowercased()
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_list" as NSString,
            "eventLabel" : eventLabel as NSString,
            AnalyticsParameterItemListName: "reward_main_\(subCatName)" as AnyObject
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventSelectItem, params: ecommerce)
    }
    
}

// MARK:- Extension
// MARK:- UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CampaignByCatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView == campaignCV ? 2 : 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Bzbs.shared.arrCategory == nil { return 0 }
        if collectionView == subCategoryCV {
            return currentCat?.subCat.count ?? 0
        }
        if collectionView == categoryCV{
            return arrCategory.count
        }
        if collectionView == campaignCV {
            if section == 0 {
                return 1
            }
            if isCategoryAll() {
                return dashboardAllItems.count == 0 ? (_isCallApi ? 0 : 1) : dashboardAllItems.count
            }
            return _arrDataShow.count == 0 ? (_isCallApi ? 0 : 1) : _arrDataShow.count
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subCategoryCV {
            guard let currentCat = currentCat else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCVCell", for: indexPath)
            }
            let item = currentCat.subCat[indexPath.row]
            return generateCellSubcat(item, collectionView:collectionView, indexPath: indexPath)
        } else if collectionView == categoryCV{
            let item = arrCategory[indexPath.row]
            return generateCellCategory(item, collectionView:collectionView, indexPath: indexPath)
        }
        else {
            if indexPath.section == 0 {
                if dashboardItems.count == 0 {
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCVCell", for: indexPath)
                }
                let headerView = collectionView.dequeueReusableCell(withReuseIdentifier: "dashboardHeaderCell", for: indexPath) as! CampaignRotateCVCell
                if imageSlider != headerView.imageSlideShow {
                    imageSlider = headerView.imageSlideShow
                }
                guard let currentCat = currentCat else {
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCVCell", for: indexPath)
                }
                if currentCat.id == Bzbs.shared.blueCategory?.id {
                    let width = collectionView.frame.size.width
                    let height = width / 2
                    headerView.customSize = CGSize(width: width, height: height)
                } else {
                    headerView.customSize = nil
                }
                
                let tmpDashboard = BzbsDashboard()
                tmpDashboard.subCampaignDetails = dashboardItems
                headerView.dashboardItems = [tmpDashboard]
                headerView.backgroundColor = .white
                headerView.delegate = self
                return headerView
            }
            
            if isCategoryAll()
            {
                if dashboardAllItems.count == 0 {
                    if _isCallApi
                    {
                        return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCVCell", for: indexPath)
                    }
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
                    cell.imv.image = UIImage(named: "ic_reward_document", in: Bzbs.shared.currentBundle, compatibleWith: nil)
                    cell.lbl.text = "major_empty".localized()
                    return cell
                }
                let item = dashboardAllItems[indexPath.row]
                guard let currentCat = currentCat else {
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCVCell", for: indexPath)
                }
                if currentCat.id == BuzzebeesCore.catIdCoin {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCoinCell", for: indexPath) as! CampaignCoinCVCell
                    cell.setupWith(item)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCell", for: indexPath) as! CampaignCVCell
                    cell.setupWith(item)
                    return cell
                }
            }
            
            if self._arrDataShow.count == 0
            {
                if _isCallApi
                {
                    return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
                cell.imv.image = UIImage(named: "ic_reward_document", in: Bzbs.shared.currentBundle, compatibleWith: nil)
                cell.lbl.text = "major_empty".localized()
                return cell
            }
            let item = _arrDataShow[indexPath.row] as! BzbsCampaign
            sendImpressionCampaign(item, index: indexPath.row)
            if item.parentCategoryID == BuzzebeesCore.catIdCoin {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCoinCell", for: indexPath) as! CampaignCoinCVCell
                cell.setupWith(item)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCell", for: indexPath) as! CampaignCVCell
                cell.setupWith(item)
                return cell
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == subCategoryCV {
            guard let currentCat = currentCat else {
                return .zero
            }
            let item = currentCat.subCat[indexPath.row]
            let name = item.name
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: 40))
            lbl.font = UIFont.mainFont()
            lbl.text = name
            lbl.sizeToFit()
            return CGSize(width: 16 + lbl.frame.size.width + 16, height: 45)
        } else if collectionView == categoryCV{
            let width = collectionView.frame.size.width / 4.5
            
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.leastNonzeroMagnitude))
            lbl.font = UIFont.mainFont(.small)
            lbl.text = "\n"
            lbl.sizeToFit()
            let height = (width / 2) + lbl.frame.size.height
            
            return CGSize(width: width, height:  height)
        } else {
            if indexPath.section == 0 {
                let width = collectionView.frame.size.width - 8
                if dashboardItems.count == 0 {
                    return CGSize(width: width, height: 0)
                }
                if self.currentCat?.id == Bzbs.shared.blueCategory?.id {
                    
                    let height = width / 2
                    return CGSize(width: width, height: height)
                }
                let height = width * 2 / 3
                return CGSize(width: width, height: height)
            }
            if (isCategoryAll() && dashboardAllItems.count == 0 ) || _arrDataShow.count == 0 {
                let width = collectionView.frame.size.width
                let height = collectionView.frame.size.height
                guard let currentCat = currentCat else {
                    return .zero
                }
                if currentCat.subCat.count > 0 {
                    let width = collectionView.frame.size.width
                    if currentCat.id == Bzbs.shared.blueCategory?.id {
                        let height = width / 2
                        let headerHeight = collectionView.frame.size.height - height - 8
                        return CGSize(width: width, height: headerHeight)
                    }
                    let height = width * 2 / 3
                    let headerHeight = collectionView.frame.size.height - height - 8
                    return CGSize(width: width, height: headerHeight)
                }
                return CGSize(width: width, height: height)
            }
            
            let row = indexPath.row
            if _arrDataShow.count - 1  < row { return CampaignCVCell.getSize(collectionView) }
            let item = _arrDataShow[row] as! BzbsCampaign
            var sideItem : BzbsCampaign?
            var sideRow = row
            
            if row % 2 == 0 {
                sideRow = row + 1
            } else {
                sideRow = row - 1
            }
            
            if !(sideRow > (_arrDataShow.count - 1) || sideRow < 0) {
                sideItem = _arrDataShow[sideRow] as? BzbsCampaign
            }
            
            if item.parentCategoryID == BuzzebeesCore.catIdCoin || (sideItem != nil && sideItem?.parentCategoryID == BuzzebeesCore.catIdCoin) {
                return CampaignCoinCVCell.getSize(collectionView)
            }
            return CampaignCVCell.getSize(collectionView)
            
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        
        if collectionView == subCategoryCV {
            guard let currentCat = currentCat else { return }
            let item = currentCat.subCat[indexPath.row]
            sendGACategoryTouchEvent(subCat: item)
            if item.id != currentSubCat?.id {
                currentSubCat = item
                if currentCat.id == Bzbs.shared.blueCategory?.id {
                    // Blue member จะเปลี่ยนทุก subcat
                    var imageUrl = BuzzebeesCore.blobUrl + "/dtac/category/\(self.currentSubCat?.id ?? 0)"
                    if LocaleCore.shared.getUserLocale() == BBLocaleKey.en.rawValue
                    {
                        imageUrl = BuzzebeesCore.blobUrl + "/dtac/category/\(self.currentSubCat?.id ?? 0)_en"
                    }
                    if let url = URL(string:imageUrl), let host = url.host, host == "buzzebees.blob.core.windows.net"
                    {
                        let newStrUrl = imageUrl.replace("buzzebees.blob.core.windows.net", replacement: "cdndtw.buzzebees.com")
                        if let _ = URL(string: newStrUrl)
                        {
                            imageUrl = newStrUrl
                        }
                    }
                    let dashboard = BzbsDashboard()
                    dashboard.imageUrl = imageUrl
                    dashboard.type = "none"
                    self.dashboardItems = [dashboard]
                    self.campaignCV.reloadData()
                }
                else if self.currentCat?.id == BuzzebeesCore.catIdCoin {
                    if currentSubCat?.id == currentCat.subCat.first?.id && currentSubCat != nil{
                        apiGetSubDashboard(getBannerDashboardConfig())
                    } else {
                        let dashboardName = "dtac_category_\(currentSubCat?.id ?? 0)"
                        apiGetSubDashboard(dashboardName)
                    }
                }
                collectionView.reloadData()
            }
            return
        }  else if collectionView == campaignCV {
            if isCategoryAll()
            {
                if dashboardAllItems.count == 0 || indexPath.section == 0 { return }
                let item = dashboardAllItems[indexPath.row]
                if let nav = self.navigationController
                {
                    let campaign = item.toCampaign()
                    sendTouchCampaign(campaign, indexPath: indexPath)
                    GotoPage.gotoCampaignDetail(nav, campaign: campaign, parentCategoryName: currentSubCat?.name ?? "-", target: self, gaIndex: indexPath.row + 1)
                }
                return
            }
            if _arrDataShow.count == 0 || indexPath.section == 0 { return }
            let campaign = _arrDataShow[indexPath.row] as! BzbsCampaign
            if campaign.ID == -1 { return }
            sendTouchCampaign(campaign, indexPath: indexPath)
            if let nav = self.navigationController
            {
                GotoPage.gotoCampaignDetail(nav, campaign: campaign, parentCategoryName: currentCat?.name ?? "-", target: self, gaIndex: indexPath.row + 1)
            }
            return
        }
        clickCat()
        let item = arrCategory[indexPath.row]
        if item.mode == "near_by"
        {
            if let nav = self.navigationController
            {
                
                GotoPage.gotoNearby(nav)
            }
            return
        }
        currentCat = item
        generateSubCatView()
        getApi()
        getDashboard()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == campaignCV {
            if section == 0 {
                return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
            }
            return UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
        }
        return UIEdgeInsets.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == campaignCV {
            if indexPath.section == 1 {
                loadMore(indexPath)
            }
        }
    }
    
    func loadMore(_ indexPath:IndexPath? = nil)
    {
        if _isCallApi || _isEnd { return }
        if indexPath != nil
        {
            if indexPath!.row > _arrDataShow.count - 2 {
                getApi()
            }
        } else {
            getApi()
        }
    }
    
    
    // MARK:- Generate Cell
    
    func generateCellCategory(_ item:BzbsCategory, collectionView:UICollectionView, indexPath:IndexPath) -> CategoryCollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectionCategory", for: indexPath) as! CategoryCollectionViewCell
        cell.setupCell(item)
        cell.setActive(item.id == currentCat?.id)
        return cell
    }
    
    func generateCellSubcat(_ item: BzbsCategory, collectionView:UICollectionView, indexPath:IndexPath) -> SubCatCVCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subCatCVCell", for: indexPath) as! SubCatCVCell
        cell.lblName.text = item.name
        cell.isActive = item.id == currentSubCat?.id
        return cell
    }
    
    func generateCellDashboardRotate(_ item:BzbsDashboard, collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "campaignBigRotateCVCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CampaignBigRotateCVCell
        let imageUrl = item.imageUrl ?? ""
        cell.imvCampaign.bzbsSetImage(withURL: imageUrl)
        return cell
    }
    
}

// MARK:- UITextFieldDelegate
extension CampaignByCatViewController: UITextFieldDelegate
{
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if !isLoggedIn()
        {
            PopupManager.confirmPopup(self, isWithImage:true, message: "action_click_req_login".errorLocalized()
                                      , strConfirm: "popup_retry_login_fail".localized()
                                      , strClose: "popup_cancel".localized()
                                      , confirm: {
                                        Bzbs.shared.delegate?.reTokenTicket()
                                      }, cancel: nil)
        } else {
            anaylticsTapSearch()
            if let nav = self.navigationController
            {
                GotoPage.gotoSearch(nav)
            }
        }
        return false
    }
}

// MARK:- CampaignRotateCVDelegate
extension CampaignByCatViewController: CampaignRotateCVDelegate
{
    func didViewDashboard(_ item: BzbsDashboard, index:Int) {
        sendCoinImpressionBanner(item, index: index)
    }
    
    func didSelectDashboard(_ item: BzbsDashboard, index:Int) {
        sendCoinTouchBanner(item, index: index)
        if let type = item.type
        {
            switch type {
                case "hashtag" :
                    if let nav = self.navigationController {
                        let vc = MajorCampaignListViewController.getViewController()
                        vc.dashboard = item
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
                        GotoPage.gotoCampaignDetail(nav, campaign: campaign, parentCategoryName: currentCat?.name ?? "-", target: self, gaIndex: 1)
                    }
                default:
                    break
            }
            
        }
    }
}

// MARK:- ScanQRViewControllerDelegate
extension CampaignByCatViewController: ScanQRViewControllerDelegate{
    func didScanWithResult(result: String) {
        if let url = URL(string:result){
            if let params = url.queryParameters
            {
                if params.keys.contains("thrdPrtyCmpgId") || params.keys.contains("cmpggroupid"){
                    var campaignId :Int?
                    if let id = BuzzebeesConvert.IntOrNull(params["thrdPrtyCmpgId"] as AnyObject?) {
                        campaignId = id
                    } else if let id = BuzzebeesConvert.IntOrNull(params["cmpggroupid"] as AnyObject?) {
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
                                                    successCallback: { (status, _)  in
                                                        let campaign = BzbsCampaign()
                                                        campaign.ID = campaignId!
                                                        DispatchQueue.main.async {
                                                            GotoPage.gotoCampaignDetail(self.navigationController!, campaign: campaign, target: self, gaIndex: 1)
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

extension CampaignByCatViewController : WKNavigationDelegate, WKScriptMessageHandler
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
