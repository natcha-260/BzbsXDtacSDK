//
//  BzbsXDtacBaseViewController.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 11/30/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//


import UIKit
import Alamofire

open class BzbsXDtacBaseViewController: BzbsBaseViewController {
    // MARK:- Properties
    // MARK:- Variable
    static var isInitialized = false
    static var isOpeningDeeplink = false
    var screenName = "-"
    
    // MARK:- View Life cycle
    // MARK:-
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation), name: EnumLocationManagerNotification.updateLocation.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reLogin), name: NSNotification.Name.BzbsTokenTicketDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshApi), name: NSNotification.Name.BzbsApiReset, object: nil)
        
        if !BzbsXDtacBaseViewController.isInitialized {
            BzbsXDtacBaseViewController.isInitialized = true
            baseInitial()
        }
    }
    
    func baseInitial() {
        let resourceBundle = Bzbs.shared.currentBundle
        
        UIFont.registerFont(withFilenameString: "DTAC2018-Regular.otf", bundle: resourceBundle)
        UIFont.registerFont(withFilenameString: "DTAC2018-Bold.otf", bundle: resourceBundle)
        UIFont.registerFont(withFilenameString: "MyriadPro-Regular.otf", bundle: resourceBundle)
        
        // init for wording
        LocaleCore.shared.loadLanguageString()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LocationManager.shared.checkAuthorizationStatus()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(actionDeeplink(notification:)), name: NSNotification.Name.BzbsDeeplinkAction, object: nil)
        if let url = Bzbs.shared.deepLinkUrl
        {
            openDeepLinkURL(url)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BzbsDeeplinkAction, object: nil)
    }
    
    // MARK:- Notification
    // MARK:-
    
    @objc func gotoCampaignDetail(_ notification:NSNotification)
    {
        if let campaignId = notification.object as? Int{
            if let nav = self.navigationController
            {
                let campaign = BzbsCampaign()
                campaign.ID = campaignId
                delay(0.33) {
                    GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
                }
            }
        }
    }
    
    @objc func reLogin()
    {
        Bzbs.shared.relogin()
    }
    
    @objc func refreshApi()
    {
        
    }
    
    @objc func updateLocation() {
        
    }
    
    func logout() {
        //        if let draw = self.parent as? KYDrawerController
        //        {
        //            draw.setDrawerState(KYDrawerController.DrawerState.closed, animated: true)
        //        }
        //
        //        _appDelegate.logoutBzBs()
        //        _appDelegate.facebookCore.logout()
        ////        ShortcutManager.shared.clearShortcut()
        //
        //        //ส่งเพื่อเปลี่ยนแปลงค่า point ให้เป็น 0
        //        UserDefaultManage().saveKey("isNeedUpdateLanguage", value: 0 as AnyObject)
        //        send_noti_bzbs_logout_success()
        //
    }
    
    @objc override open func back_1_step() {
        super.back_1_step()
    }
    
    func initNav()
    {
        
    }
    
    func openWebSite(_ url:URL!)
    {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK:- Action share
    // MARK:-
    func shareActivity(strLinkURL: String?, imgPhoto: UIImage?, strImageURL: String?, strTextShare: String = "")
    {
        var objToShare: [Any] = [strTextShare]
        
        if let img = imgPhoto
        {
            objToShare.append(img)
        }
        else if let strImage = strImageURL
        {
            let url = NSURL(string: strImage)
            let data = NSData(contentsOf:url! as URL)
            if data != nil {
                if let img = UIImage(data: data! as Data)
                {
                    objToShare.append(img)
                }
            }
        }
        
        if let linkURL = strLinkURL
        {
            if let website = NSURL(string: linkURL)
            {
                objToShare.append(website)
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: objToShare, applicationActivities: nil)
        
        // เช็คว่า user กดอะไร
        activityVC.completionWithItemsHandler = {
            (s, ok, items, error) in
            
            // Return if cancelled
            if (!ok) {
                print("user cancel")
                return
            }
            
            //activity complete
            print("Activity: \(String(describing: s)) Success: \(ok) Items: \(String(describing: items)) Error: \(String(describing: error))")
        }
        
        // ไม่เอาอะไรบ้าง
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop
        ]
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK:- Internet
    // MARK:-
    
    func isConnectedToInternet() -> Bool {
        ReachabilityManager.shared.isConnectedToInternet()
    }
    
    func showPopupInternet(_ closeCallback:(() -> Void)? = nil)
    {
        PopupManager.informationPopup(self, title: "alert_internet_title".errorLocalized(), message: "alert_internet_description".errorLocalized() , close: closeCallback)
    }
    
    // MARK:- Language
    // MARK:-
    func userLocale() -> Int
    {
        return LocaleCore.shared.getUserLocale()
    }
    
    // MARK:- Scroll
    // MARK:-
    @objc public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func lockTopScroll(scrollView: UIScrollView, tableView: UITableView)
    {
        if tableView.contentOffset.y < 0
        {
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    func lockBottomScroll(scrollView: UIScrollView, tableView: UITableView)
    {
        let location: CGPoint = scrollView.contentOffset
        let height = scrollView.frame.size.height
        let distanceFromBottom = scrollView.contentSize.height - location.y
        
        if distanceFromBottom < height
        {
            let bottom = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            tableView.setContentOffset(bottom, animated: false)
        }
    }
    
    // MARK:- Status Bar
    // MARK:-
    var isStatusBarHidden:Bool?
    func showHideStatusBarAndNavBar(isHidden: Bool, animated: Bool)
    {
        navigationController?.setNavigationBarHidden(isHidden, animated: animated)
        isStatusBarHidden = isHidden
    }
    
    override open var prefersStatusBarHidden: Bool
    {
        return isStatusBarHidden ?? false
    }
    
    func isLoggedIn() -> Bool{
        return Bzbs.shared.isLoggedIn()
    }
    
    // MARK:- SwiftLoader
    // MARK:-
    func showLoader(){
        Bzbs.shared.showLoader(on: self)
    }
    
    func hideLoader(){
        Bzbs.shared.hideLoader()
    }
    
    // MARK:- Analytics
    // MARK:-
    
    func analyticsSetScreen(screenName:String)
    {
        self.screenName = screenName
        Bzbs.shared.delegate?.analyticsScreen(screenName: screenName)
    }
    
    func analyticsSetEvent(event: String, category: String, action: String, label: String)
    {
        Bzbs.shared.delegate?.analyticsEvent(event: event, category: category, action: action, label: label)
    }
    
    func analyticsSetEventEcommerce(eventName:String, params: [String:AnyObject])
    {
        Bzbs.shared.delegate?.analyticsEventEcommerce(eventName: eventName, params: params)
    }
    
    func analyticsSetUserProperty(propertyName: String, value: String) {
        Bzbs.shared.delegate?.analyticsSetUserProperty(propertyName: propertyName, value: value)
    }
    
    // MARK:- GA Support
    func getPreviousScreenName() -> String {
        if let previousVC = self.parent as? BzbsXDtacBaseViewController{
            return previousVC.screenName
        }
        
        if let nav = self.navigationController {
            if let index = nav.viewControllers.firstIndex(of: self) {
                if index > 0 {
                    if let vc = nav.viewControllers[index - 1] as? BzbsXDtacBaseViewController {
                        return vc.screenName
                    }
                }
            }
        }
        return "-"
    }
}

// MARK:- Extension
// MARK:- ViewNotificationControllerDelegate

public enum BBEnumNotificationCenter: String
{
    case bzbsLogin = "bzbs_login_success"
    case bzbsLogout = "bzbs_logout_success"
    case updateCartCount = "update_cartCount"
    case updateUI = "update_language"
}

open class BzbsBaseViewController: UIViewController
{
    // MARK:- Public Variables For Class
    open var isClickBack = false
    
    // MARK:- Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BzbsBaseViewController.updateUI), name: NSNotification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BzbsBaseViewController.updateCartCount), name: NSNotification.Name(rawValue: BBEnumNotificationCenter.updateCartCount.rawValue), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(BzbsBaseViewController.buzzebees_updated_point(_:)), name: NSNotification.Name(rawValue: BBApiNotificationName.BzbsUpdatedPoint.rawValue), object: nil)
        
        updateUI()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BBEnumNotificationCenter.updateCartCount.rawValue), object: nil)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BBApiNotificationName.BzbsUpdatedPoint.rawValue), object: nil)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Notification Center
    @objc open func buzzebees_updated_point(_ notification: Notification)
    {
        
    }
    
    @objc open func updateUI()
    {
        
    }
    
    @objc open func updateCartCount()
    {
        
    }
    
    open func send_notification_updateUI()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.updateUI.rawValue), object: nil)
    }
    
    open func send_noti_bzbs_logout_success()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.bzbsLogout.rawValue), object: self)
    }
    
    open func send_noti_bzbs_login_success()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: BBEnumNotificationCenter.bzbsLogin.rawValue), object: self)
    }
    
    // MARK:- Server
    open func manageFailCallBack(strId: String, strCode: String, strMessage: String, strType: String, authenError: () -> Void, showMessage: (String, String) -> Void, sessionExpire: (String) -> Void)
    {
        // code 401: ในฟังก์ชั่นเกี่ยวกับ auth แสดงว่า login ไม่ผ่านต้อง login ใหม่
        if strCode == "401"
        {
            authenError()
            return
        }
        
        if strCode == "409"
        {
            // id 1905: Session Expire
            // id 2076: Force Logout
            if strId == "1905" || strId == "2076"
            {
                sessionExpire(strMessage)
                return
            }
        }
        
        showMessage(strId, strMessage)
    }
    
    // MARK:- Util
    open func delay(_ afterDelay: Double = 0.01, callBack: @escaping () -> Void)
    {
        let delay = afterDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            callBack()
        })
    }
    
    open func back_1_step()
    {
        if isClickBack == true { return }
        isClickBack = true
        
        if let nc = self.navigationController
        {
            if(nc.children.count > 0)
            {
                if(nc.children[0] as NSObject == self)
                {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    nc.popViewController(animated: true)
                }
            }
        }
    }
}

class ReachabilityManager: NSObject{
    static let shared = ReachabilityManager()
    
    var reachabilityManager:NetworkReachabilityManager!
    var listener:((NetworkReachabilityManager.NetworkReachabilityStatus) -> Void)? {
        didSet{
            guard let manager = reachabilityManager else { return }
            manager.listener = listener
        }
    }
    
    override init() {
        super.init()
        initReachability()
    }
    
    func initReachability()
    {
        if reachabilityManager == nil
        {
            if let manager = NetworkReachabilityManager(){
                reachabilityManager = manager
            }
        }
        guard let manager = reachabilityManager else {
            self.initReachability()
            return
        }
        
        manager.startListening()
        manager.listener = listener
    }
    
    func isConnectedToInternet() -> Bool {
        reachabilityManager.isReachable
    }
    
    func showPopupInternet(target:UIViewController, _ closeCallback:(() -> Void)? = nil)
    {
        PopupManager.informationPopup(target, title: nil, message: "util_msg_no_internet".localized() , close: closeCallback)
    }
}


extension BzbsXDtacBaseViewController {
    
    func isDtacError(_ id:Int, code:Int, message:String) -> Bool {
        if id == 1417 || code == 1417
        {
            PopupManager.informationPopup(self, message: "popup_dtac_error_suspend".localized()) {
                self.didSuspendError()
            }
            return true
        }
        
        if id == 1905 || code == 1905
        {
            self.didReLogin()
            return true
        }
        
        if id == 499 || code == 499
        {
            PopupManager.informationPopup(self, message: "alert_error_timeout".errorLocalized()) {
            }
            return true
        }
        
        if id == 1403 || code == 1403
        {
            PopupManager.informationPopup(self, message: "alert_error_redeem_1403".errorLocalized()) {
            }
            return true
        }
        
        return false
    }
    
    func didReLogin()
    {
        Bzbs.shared.delegate?.reLogin()
    }
    
    func didSuspendError()
    {
        Bzbs.shared.delegate?.suspend()
    }
    
    @objc func actionDeeplink(notification: Notification)
    {
        if BzbsXDtacBaseViewController.isOpeningDeeplink { return }
        BzbsXDtacBaseViewController.isOpeningDeeplink = true
        guard let userInfo = notification.userInfo else { return }
        guard let strUrl = userInfo["strUrl"] as? String,
            let url = URL(string: strUrl) else { return }
        openDeepLinkURL(url)
        delay(0.44) {
            BzbsXDtacBaseViewController.isOpeningDeeplink = false
        }
    }
    
    func openDeepLinkURL(_ _url:URL?)
    {
        guard let url = _url else { return }
        Bzbs.shared.deepLinkUrl = nil
        if url.isDtacDeepLinkPrefix()
        {
            var params = Dictionary<String, AnyObject>()
            if let query = url.query
            {
                for item in query.split(separator: "&") {
                    let element = item.split(separator: "=")
                    if let key = element.first,
                        let value = element.last
                    {
                        params[String(key)] = String(value) as AnyObject
                    }
                }
            }
            
            if let strFunc = url.pathComponents.last
            {
                switch strFunc {
                case "category":
                    let catName = Int((params["category_id"] as? String ?? ""))
                    let subCatName = Int((params["sub_category"] as? String ?? ""))
                    gotoCategory(categoryId: catName, subCategoryId: subCatName)
                    break
                case "favorite":
                    gotoFavorite()
                    break
                case "nearme":
                    gotoNearby()
                    break
                case "blue":
                    gotoBlueMember()
                    break
                case "major":
                    if let hashtag = params["majorCmpg"] as? String{
                        openCampaignHashtag(hashtag)
                    }
                    break
                case "coin_history" :
                    gotoCoinHistory()
                    break
                default:
                    if let strId = params["bzbID"] as? String,
                        let intId = Int(strId){
                        openCampaignDetail(intId)
                    } else {
                        print(url.absoluteString)
                    }
                    break
                }
            }
        }
    }
    
    func gotoCategory(categoryId tmpCatId:Int?,subCategoryId tmpSubCatId:Int?)
    {
        print("goto \(tmpCatId ?? 0), \(tmpSubCatId ?? 0)")
        guard let arrCat = Bzbs.shared.arrCategory else {
            delay(0.33) {
                self.gotoCategory(categoryId: tmpCatId, subCategoryId: tmpSubCatId)
            }
            return
        }
        
        var cat :BzbsCategory?
        var subCat : BzbsCategory?
        if let catId = tmpCatId {
            if let _cat = arrCat.first(where: { (tmpCat) -> Bool in
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
            if let first = arrCat.first {
                cat = first
            }
        }
        
        if cat == nil { return }
        if self is CampaignByCatViewController
        {
            let vc = self as! CampaignByCatViewController
            vc.currentCat = cat
            if let _ = subCat
            {
                vc.currentSubCat = subCat
            }
        } else {
            if let nav = self.navigationController {
                GotoPage.gotoCategory(nav, cat: cat!, subCat: subCat, arrCategory: arrCat)
            } else {
                delay(0.33) {
                    self.gotoCategory(categoryId: tmpCatId, subCategoryId: tmpSubCatId)
                }
            }
        }
    }
    
    func gotoFavorite()
    {
        if let nav = self.navigationController
        {
            GotoPage.gotoFavourite(nav)
        } else {
            delay(0.33){
                self.gotoFavorite()
            }
        }
    }
    
    func gotoNearby()
    {
        if let nav = self.navigationController
        {
            GotoPage.gotoNearby(nav)
        } else {
            delay(0.33){
                self.gotoNearby()
            }
        }
    }
    
    func gotoCoinHistory()
    {
        if let nav = self.navigationController
        {
            GotoPage.gotoCoinHistory(nav)
        } else {
            delay(0.33){
                self.gotoCoinHistory()
            }
        }
    }
    
    func gotoBlueMember()
    {
        guard let userLogin = Bzbs.shared.userLogin,
              let arrCat = Bzbs.shared.arrCategory,
              let blueCat = Bzbs.shared.blueCategory
        else {
            delay(0.33) {
                self.gotoBlueMember()
            }
            return
        }
        
        let targetCat = (userLogin.dtacLevel == .blue) ? blueCat : arrCat.first!
        
        if self is CampaignByCatViewController
        {
            let vc = self as! CampaignByCatViewController
            vc.currentCat = targetCat
        } else {
            if let nav = self.navigationController {
                GotoPage.gotoCategory(nav, cat: targetCat, subCat: nil, arrCategory: arrCat)
            }
        }
        
    }
    
    func openCampaignDetail(_ campaignId:Int) {
        let campaign = BzbsCampaign()
        campaign.ID = campaignId
        let storboard = UIStoryboard(name: "Campaign", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "scene_campaign_detail") as! CampaignDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.campaign = campaign
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openCampaignHashtag(_ hashtag:String) {
        if let nav = self.navigationController {
            let vc = MajorCampaignListViewController.getViewController()
            let item = BzbsDashboard()
            item.hashtag = hashtag
            vc.dashboard = item
            vc.hidesBottomBarWhenPushed = true
            nav.pushViewController(vc, animated: true)
        }
    }
    
}
