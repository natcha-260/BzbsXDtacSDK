//
//  PointHistoryViewController.swift
//  Alamofire
//
//  Created by Buzzebees iMac on 10/8/2563 BE.
//

import UIKit

extension Date {
    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }

    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
}

open class PointHistoryViewController: BaseListController {
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var imvCoin: UIImageView!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var vwEarnLine: UIView!
    @IBOutlet weak var lblRedeemed: UILabel!
    @IBOutlet weak var vwRedeemedLine: UIView!
    @IBOutlet weak var cstFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var vwFooter: UIView!
    @IBOutlet weak var imvFooter: UIImageView!
    @IBOutlet weak var burnTableView: UITableView!
    
    // MARK:- Variable
    var isEarn = false
    var arrPointLogEarn = [PointLog]()
    var arrPointLogBurn = [BzbsHistory]()
    var strEarnDate:String = ""
    var strBurnDate:String = ""
    var isEarnEnd:Bool {
        if strEarnDate == "" {
            return false
        }
        var endDate = Date().timeIntervalSince1970 + (-2 * 30 * 24 * 60 * 60)
        if let last2Month = Date().getPreviousMonth()?.getPreviousMonth()?.timeIntervalSince1970 {
            endDate = last2Month
        }
        if let date = dateFormatter.date(from: strEarnDate)?.timeIntervalSince1970 {
            return endDate > date
        }

        return false
    }
    
    var isBurnEnd = false
    var _isCallBurnApi = false
    var defaultTabEarn = true
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.locale = Locale(identifier: Locale.identifier(fromWindowsLocaleCode: 1033)!)
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    var strUrlFooter :String {
        if isEarn {
            if LocaleCore.shared.getUserLocale() == 1054 {
                return BuzzebeesCore.blobUrl + "/config/353144231924127/history/bannerth.jpg"
            }
            return BuzzebeesCore.blobUrl + "/config/353144231924127/history/banneren.jpg"
        } else {
            if LocaleCore.shared.getUserLocale() == 1054 {
                return BuzzebeesCore.blobUrl + "/config/353144231924127/history/bannerth_redeemed.jpg"
            }
            return BuzzebeesCore.blobUrl + "/config/353144231924127/history/banneren_redeemed.jpg"
        }
    }
    
    // MARK:- Class function
    // MARK:-
    @objc public class func getView() -> PointHistoryViewController
    {
        let storyboard = UIStoryboard(name: "History", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "scene_point_history")
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        return controller as! PointHistoryViewController
    }
    
    @objc public class func getViewWithNavigationBar(_ isHideNavigationBar:Bool = true) -> UINavigationController
    {
        let nav = UINavigationController(rootViewController: getView())
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
        imvFooter.contentMode = .scaleAspectFit
        imvFooter.alpha = 0
        cstFooterHeight.constant = 0
        registerCell()
        lblPoint.font = UIFont.mainFont(.big, style: .bold)
        lblExpireDate.font = UIFont.mainFont(.small,style: .bold)
        lblEarn.font = UIFont.mainFont()
        lblRedeemed.font = UIFont.mainFont()
        lblPoint.text = ""
        imvCoin.isHidden = true
        lblExpireDate.text = ""
        initNav()
        clickEarn(self)
        delay{
            if self.defaultTabEarn {
                self.clickEarn(self)
            } else {
                self.clickRedeemed(self)
            }
        }
        
        addPullToRefreshEarn(on: tableView)
        
        addPullToRefreshBurn(on: burnTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetList), name: NSNotification.Name.BzbsApiReset, object: nil)
        
        if Bzbs.shared.isLoggedIn() {
            getApi()
            getApiPurchase()
            getExpiringPoint()
        } else {
            showLoader()
//            checkAPI()
        }
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Tabale Refresher
    //MARK:-
    private let refreshEarnControl = UIRefreshControl()
    func addPullToRefreshEarn(on tableView: UITableView) {
        tableView.refreshControl = refreshEarnControl
        refreshEarnControl.addTarget(self, action: #selector(refreshEarnSelector), for: .valueChanged)
    }
    
    @objc func refreshEarnSelector() {
        self.arrPointLogEarn.removeAll()
        self.strEarnDate = ""
        self.apiGetimagefooter()
        self.getApi()
        self.getExpiringPoint()
    }
    
    private let refreshBurnControl = UIRefreshControl()
    func addPullToRefreshBurn(on tableView: UITableView) {
        tableView.refreshControl = refreshBurnControl
        refreshBurnControl.addTarget(self, action: #selector(refreshBurnSelector), for: .valueChanged)
    }
    
    @objc func refreshBurnSelector() {
        self._intSkip = 0
        self.isBurnEnd = false
        self.arrPointLogBurn.removeAll()
        self.apiGetimagefooter()
        self.getApiPurchase()
        self.getExpiringPoint()
    }
    
    
    open override func updateUI() {
        super.updateUI()
        initNav()
    }
    
    func registerCell() {
        
        tableView.register(PointHistoryCell.getNib(), forCellReuseIdentifier: "pointHistoryCell")
        tableView.register(PointBurnHistoryCell.getNib(), forCellReuseIdentifier: "pointBurnHistoryCell")
        tableView.register(EmptyHistoryCell.getNib(), forCellReuseIdentifier: "emptyCell")
        tableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
        
        burnTableView.register(PointHistoryCell.getNib(), forCellReuseIdentifier: "pointHistoryCell")
        burnTableView.register(PointBurnHistoryCell.getNib(), forCellReuseIdentifier: "pointBurnHistoryCell")
        burnTableView.register(EmptyHistoryCell.getNib(), forCellReuseIdentifier: "emptyCell")
        burnTableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiGetimagefooter()
    }
    
    @objc override func resetList() {
        self.arrPointLogBurn.removeAll()
        self.strBurnDate = ""
        self.arrPointLogEarn.removeAll()
        self.strEarnDate = ""
        self._intSkip = 0
        isBurnEnd = false
        apiGetimagefooter()
        getApi()
        getApiPurchase()
        getExpiringPoint()
    }
    
    override func initNav() {
        super.initNav()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont(.big, style: .bold)
        lblTitle.textColor = .black
        lblTitle.numberOfLines = 0
        lblTitle.sizeToFit()
        lblTitle.text = "coin_balance_title".localized()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        
        lblEarn.text = "coin_earn_title".localized()
        lblRedeemed.text = "coin_burn_title".localized()
    }
    
    
    // MARK:- Util
    // MARK:-
    func getDate() -> String {
        var strDate = strEarnDate
        if strDate == "" {
            strDate = dateFormatter.string(from: Date())
        } else {
            if let lastDate = dateFormatter.date(from: strDate) {
                let lastMonthDate = lastDate.getPreviousMonth() ?? lastDate.addingTimeInterval(-1 * 30 * 24 * 60 * 60)
                strDate = dateFormatter.string(from: lastMonthDate)
            }
        }
        
        strEarnDate = strDate
        return strDate
    }
    
    func resetButton() {
        vwEarnLine.isHidden = true
        vwRedeemedLine.isHidden = true
        lblEarn.textColor = .mainLightGray
        lblRedeemed.textColor = .mainLightGray
        lblEarn.font = UIFont.mainFont(style:.bold)
        lblRedeemed.font = UIFont.mainFont(style:.bold)
    }
    
    // MARK:- Event
    // MARK:- Click
    
    @IBAction func clickEarn(_ sender: Any) {
        if isEarn { return }
        isEarn = true
        resetButton()
        lblEarn.textColor = .black
        vwEarnLine.isHidden = false
        
        tableView.isHidden = false
        burnTableView.isHidden = true
        analyticsSetScreen(screenName: "your_coin_earn")
        sendGAClickEarn()
        apiGetimagefooter()
    }
    
    @IBAction func clickRedeemed(_ sender: Any) {
        if !isEarn { return }
        isEarn = false
        resetButton()
        lblRedeemed.textColor = .black
        vwRedeemedLine.isHidden = false
        
        tableView.isHidden = true
        burnTableView.isHidden = false
        analyticsSetScreen(screenName: "your_coin_burn")
        sendGAClickBurn()
        apiGetimagefooter()
    }
    
    @IBAction func clickGotoMission(_ sender: Any) {
        var url:URL?
        if isEarn {
            url = BuzzebeesCore.urlDeeplinkHistory
            sendGAClickEarnBanner(strUrl: url?.absoluteString ?? "")
        } else {
            url = BuzzebeesCore.urlDeeplinkHistoryRedeemed
            sendGAClickBurnBanner(strUrl: url?.absoluteString ?? "")
        }
        if let _url = url {
            UIApplication.shared.open(_url, options: [:], completionHandler: nil)
        }
    }
    
    func gotoLineHistory(_ item:BzbsHistory) {
        guard let nav = self.navigationController
              , let token = Bzbs.shared.userLogin?.token
              , let packageId = item.info2
              , let contactNumber = item.info3
        else {
            return
        }
        showLoader()
        BzbsCoreApi().getLineDetail(token: token, campaignId: String(item.ID!), packageId: packageId) { (lineCampaign) in
            self.hideLoader()
            GotoPage.gotoLineHistory(nav, isFromHistory: true , lineCampaign: lineCampaign, bzbsCampaign: BzbsCampaign(purchase: item), bzbsHistory: item, contactNumber: contactNumber, packageId:packageId)
        } failCallback: { (error) in
            self.hideLoader()
        }

    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.tableView {
            if !_isCallApi && (scrollView.contentOffset.y >= scrollView.contentSize.height * 0.9) {
                getApi()
            }
        } else {
            if !_isCallBurnApi  && (scrollView.contentOffset.y >= scrollView.contentSize.height * 0.9) {
                getApiPurchase()
            }
        }
    }
    
    // MARK:- Api
    // MARK:-
    override func getApi() {
        guard let token = Bzbs.shared.userLogin?.token else {
            self.loadedData()
            return
        }
        if _isCallApi { return }
        if isEarnEnd { return }
        _isCallApi = true
        showLoader()
        let strDate = getDate()
        BuzzebeesHistory().pointHistory(token: token, date: strDate, successCallback: { (arr) in
            if arr.count == 0 {
                self.loadedData()
                self.getApi()
            } else {
                for dict in arr {
                    let item = PointLog(dict: dict)
                    if item.type == "rollback" || item.type == "redeem" { continue }
                    self.arrPointLogEarn.append(item)
                }
                if self.arrPointLogEarn.count == 0 {
                    self.loadedData()
                    self.getApi()
                }
            }
            print("pointHistory(\(strDate)) : \(arr.count)")
            self.loadedData()
            self.tableView.stopPullToRefresh()
        }) { (error) in
            self.loadedData()
            self.tableView.stopPullToRefresh()
            print(error.description())
        }
    }
    
    func getApiPurchase() {
        guard let token = Bzbs.shared.userLogin?.token else {
            self.loadedData()
            return
        }
        
        if isBurnEnd { return }
        _isCallBurnApi = true
        showLoader()

        BuzzebeesHistory().list(config: BzbsConfig.historyPointPurchase, token: token, skip: _intSkip) { (arr) in
            if self._intSkip == 0 {
                self.arrPointLogBurn = arr
            } else {
                self.arrPointLogBurn.append(contentsOf: arr)
            }
            self._intSkip += 25
            self.isBurnEnd = arr.count < 25
            self.loadedData()
            self._isCallBurnApi = false
            self.burnTableView.reloadData()
            self.burnTableView.stopPullToRefresh()
        } failCallback: { (error) in
            self.loadedData()
            self.burnTableView.reloadData()
            self.burnTableView.stopPullToRefresh()
            self._isCallBurnApi = false
            print(error.description())
        }
    }
    
    func getExpiringPoint()
    {
        guard let token = Bzbs.shared.userLogin?.token else {
            lblPoint.text = ""
            imvCoin.isHidden = true
            lblExpireDate.text = ""
            return
        }
        showLoader()
        BuzzebeesHistory().getExpiringPoint(token: token, successCallback: { (dict) in
            if let arr = dict["expiring_points"] as? [Dictionary<String, AnyObject>] ,
                let first = arr.first
            {
                if let expiringPoint = first["points"] as? Int {
                    self.lblPoint.text = expiringPoint.withCommas()
                    self.imvCoin.isHidden = false
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
            }
            self.hideLoader()
        }) { (error) in
            self.hideLoader()
        }
    }
    
    
    func apiGetimagefooter() {
        imvFooter.bzbsSetImage(withURL: strUrlFooter, isUsePlaceholder: false) { (image) in
            if image == nil {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0) {
                        self.cstFooterHeight.constant = 0
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                let width = self.tableView.frame.size.width
                let height = (width / 827) * 192
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0, animations: {
                        self.cstFooterHeight.constant = height
                        self.view.layoutIfNeeded()
                    }) { (_) in
                        UIView.animate(withDuration: 0.33) {
                            self.imvFooter.alpha = 1
                        }
                    }
                }
            }
        }
    }
}

// MARK:- Extension
// MARK:- UITableViewDelegate, UITableViewDataSource
extension PointHistoryViewController : UITableViewDelegate, UITableViewDataSource
{
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            if arrPointLogEarn.count == 0 { return tableView.bounds.size.height * 0.9 }
        } else {
            if arrPointLogBurn.count == 0 { return tableView.bounds.size.height * 0.9 }
        }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return arrPointLogEarn.count == 0 ? 1 : arrPointLogEarn.count
        } else {
            return arrPointLogBurn.count == 0 ? 1 : arrPointLogBurn.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if  arrPointLogEarn.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyHistoryCell
                cell.setupCell(message: "coin_earn_no_data".localized(), imageName: "doll-earned")
                return cell
            }
            
            let item = arrPointLogEarn[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "pointHistoryCell", for: indexPath) as! PointHistoryCell
            cell.setupUI(item)
            return cell
        } else {
            if  arrPointLogBurn.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyHistoryCell
                cell.setupCell(message: "coin_burn_no_data".localized(), imageName: "doll-redeem")
                return cell
            }
            
            let item = arrPointLogBurn[indexPath.row]
            if item.categoryID == BuzzebeesCore.catIdVoiceNet
                || item.categoryID == BuzzebeesCore.catIdLineSticker
                || item.categoryID == BuzzebeesCore.catIdLuckyGame
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pointHistoryCell", for: indexPath) as! PointHistoryCell
                cell.setupUI(item)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pointBurnHistoryCell", for: indexPath) as! PointBurnHistoryCell
                cell.setupUI(item)
                return cell
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if  arrPointLogEarn.count == 0 {
                return
            }
            
            let item = arrPointLogEarn[indexPath.row]
            sendGATouchEarnItem(item)
            PopupManager.pointHistoryPopup(onView: self, pointlog: item)
    
        } else {
            if  arrPointLogBurn.count == 0 {
                return
            }
            let item = arrPointLogBurn[indexPath.row]
            sendGATouchBurnItem(item)
            if item.categoryID == BuzzebeesCore.catIdVoiceNet {
                PopupManager.subscriptionPopup(onView: self, purchase: item)
            } else if item.categoryID == BuzzebeesCore.catIdLineSticker {
                gotoLineHistory(item)
            } else if item.categoryID == BuzzebeesCore.catIdLuckyGame {
                PopupManager.pointHistoryPopup(onView: self, purchase: item)
            } else {
                PopupManager.serialPopup(onView: self, purchase: item)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if indexPath.row == self.arrPointLogEarn.count - 1{
                if tableView.contentSize.height < tableView.frame.size.height {
                    getApi()
                }
            }
        } else {
            if indexPath.row == self.arrPointLogBurn.count - 1 {
                if tableView.contentSize.height < tableView.frame.size.height {
                    getApiPurchase()
                }
            }
        }
    }
}


extension PointHistoryViewController: PopupSerialDelegate
{
    func didClosePopup() {
        _intSkip = 0
        isBurnEnd = false
        self.apiGetimagefooter()
        self.getApiPurchase()
        self.getExpiringPoint()
    }
}

// MARK:- GA
// MARK:-
extension PointHistoryViewController {
    // FIXME:GA#49
    func sendGAClickEarn(){
        analyticsSetEvent(event: "event_app", category: "your_coin_earn", action: "touch_tab", label: "go_to_burn_tab")
    }
    
    // FIXME:GA#49
    func sendGAClickBurn(){
        analyticsSetEvent(event: "event_app", category: "your_coin_burn", action: "touch_tab", label: "go_to_earn_tab")
    }
    
    // FIXME:GA#50
    func sendGATouchEarnItem(_ purchase:PointLog){
        
        let date = Date(timeIntervalSince1970: purchase.timestamp ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        analyticsSetEvent(event: "event_app", category: "your_coin_earn", action: "touch_list", label: "earned_list | \(purchase.productName ?? BzbsAnalyticDefault.name.rawValue) | \(purchase.type ?? "-") | \(purchase.points ?? 0) | \(formatter.string(from: date))")
    }
    
    // FIXME:GA#51
    func sendGAClickEarnBanner(strUrl: String) {
        analyticsSetEvent(event: "event_app", category: "your_coin_earn", action: "touch_banner", label: strUrl)
    }
    
    // FIXME:GA#52
    func sendGATouchBurnItem(_ purchase:BzbsHistory){
        var status = "available"
        if purchase.serial == "XXXXXXX" || purchase.arrangedDate != nil{
            status = "expire"
        }
        let date = Date(timeIntervalSince1970: purchase.redeemDate ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        let gaLabel = "redeemed_list | \(purchase.name ?? "") | \(status) | \(purchase.pointPerUnit ?? 0) | \(formatter.string(from: date))"
        analyticsSetEvent(event: "event_app", category: "your_coin_burn", action: "touch_list", label: gaLabel)
    }
    
    // FIXME:GA#53
    func sendGAClickBurnBanner(strUrl: String) {
        analyticsSetEvent(event: "event_app", category: "your_coin_burn", action: "touch_banner", label: strUrl)
    }
    
}
