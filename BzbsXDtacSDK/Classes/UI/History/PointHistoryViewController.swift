//
//  PointHistoryViewController.swift
//  Alamofire
//
//  Created by Buzzebees iMac on 10/8/2563 BE.
//

import UIKit

open class PointHistoryViewController: BaseListController {
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var vwEarnLine: UIView!
    @IBOutlet weak var lblRedeemed: UILabel!
    @IBOutlet weak var vwRedeemedLine: UIView!
    @IBOutlet weak var cstFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var vwFooter: UIView!
    @IBOutlet weak var imvFooter: UIImageView!
    
    // MARK:- Variable
    var isEarn = false
    var arrPointLogEarn = [PointLog]()
    var arrPointLogBurn = [PointLog]()
    var strEarnDate:String = ""
    var strBurnDate:String = ""
    var isEarnEnd:Bool {
        if strEarnDate == "" {
            return false
        }
        let endDate = Date().timeIntervalSince1970 + (-2 * 30 * 24 * 60 * 60)
        if let date = dateFormatter.date(from: strEarnDate)?.timeIntervalSince1970 {
            return endDate > date
        }

        return false
    }
    var isBurnEnd : Bool {
        return true
//        if strBurnDate == "" {
//            return false
//        }
//        let endDate = Date().timeIntervalSince1970 + (-2 * 30 * 24 * 60 * 60)
//        if let date = dateFormatter.date(from: strBurnDate)?.timeIntervalSince1970 {
//            return endDate > date
//        }
//
//        return false
    }
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.locale = Locale(identifier: Locale.identifier(fromWindowsLocaleCode: 1033)!)
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    var strUrlFooter :String {
        if LocaleCore.shared.getUserLocale() == 1054 {
            return BuzzebeesCore.blobUrl + "/config/353144231924127/history/bannerth.jpg"
        }
        return BuzzebeesCore.blobUrl + "/config/353144231924127/history/banneren.jpg"
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
        cstFooterHeight.constant = 0
        tableView.register(PointHistoryCell.getNib(), forCellReuseIdentifier: "pointHistoryCell")
        tableView.register(EmptyHistoryCell.getNib(), forCellReuseIdentifier: "emptyCell")
        tableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
        
        lblPoint.font = UIFont.mainFont(.big, style: .bold)
        lblExpireDate.font = UIFont.mainFont(.small,style: .bold)
        lblEarn.font = UIFont.mainFont()
        lblRedeemed.font = UIFont.mainFont()
        lblPoint.text = ""
        lblExpireDate.text = ""
        initNav()
        clickEarn(self)
        
        tableView.es.addPullToRefresh {
            self.resetList()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetList), name: NSNotification.Name.BzbsApiReset, object: nil)
        
        if Bzbs.shared.isLoggedIn() {
            getApi()
            getExpiringPoint()
        } else {
            showLoader()
            checkAPI()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsSetScreen(screenName: "your_coin_earn")
        apiGetimagefooter()
    }
    
    func apiGetimagefooter() {
        if let url = URL(string: strUrlFooter) {
            BzbsCoreApi().getImage(imageUrl: url) { (image) in
                DispatchQueue.main.async {
                    self.setImagefooter(image: image)
                }
            }
        }
    }
    
    func setImagefooter(image:UIImage?)
    {
        imvFooter.image = image
        imvFooter.contentMode = .scaleAspectFit
        imvFooter.alpha = 0
        if image == nil {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0) {
                    self.cstFooterHeight.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let width = self.tableView.bounds.size.width
            let height = (width / 827) * 192
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.33, animations: {
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
    
    func checkAPI() {
        if Bzbs.shared.isCallingLogin {
            Bzbs.shared.delay(0.5) {
                self.checkAPI()
            }
        } else {
            if Bzbs.shared.isLoggedIn() {
                resetList()
            } else {
                Bzbs.shared.relogin(completionHandler: {
                    self.resetList()
                }) { (_) in
                    self.loadedData()
                }
            }
        }
    }
    
    @objc override func resetList() {
        if self.isEarn {
            self.arrPointLogEarn.removeAll()
            self.strEarnDate = ""
        } else {
            self.arrPointLogBurn.removeAll()
            self.strBurnDate = ""
        }
        apiGetimagefooter()
        self.getApi()
        self.getExpiringPoint()
    }
    
    override func initNav() {
        super.initNav()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont(.big, style: .bold)
        lblTitle.textColor = .black
        lblTitle.numberOfLines = 0
        lblTitle.text = "coin_balance_title".localized()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        
        lblEarn.text = "coin_earn_title".localized()
        lblRedeemed.text = "coin_burn_title".localized()
    }
    
    
    // MARK:- API
    // MARK:-
    func getExpiringPoint()
    {
        guard let token = Bzbs.shared.userLogin?.token else {
            lblPoint.text = ""
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
    
    // MARK:- Util
    // MARK:-
    func getDate() -> String {
        var strDate = isEarn ? strEarnDate : strBurnDate
        if strDate == "" {
            strDate = dateFormatter.string(from: Date())
        } else {
            if let lastDate = dateFormatter.date(from: strDate) {
                let lastMonthDate = lastDate.addingTimeInterval(-1 * 30 * 24 * 60 * 60)
                strDate = dateFormatter.string(from: lastMonthDate)
            }
        }
        
        if isEarn {
            strEarnDate = strDate
        } else {
            strBurnDate = strDate
        }
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
        tableView.reloadData()
    }
    
    @IBAction func clickRedeemed(_ sender: Any) {
        if !isEarn { return }
        isEarn = false
        resetButton()
        lblRedeemed.font = UIFont.mainFont(style:.bold)
        lblRedeemed.textColor = .black
        vwRedeemedLine.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func clickGotoMission(_ sender: Any) {
        analyticsSetEvent(isNeedProcess: false, event: "event_app", category: "your_coin_earn", action: "touch_banner", label: "go_to_your_missions")
        if let url = BuzzebeesCore.urlDeeplinkHistory {
            UIApplication.shared.openURL(url)
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
        if isEarn {
            if isEarnEnd { return }
            _isCallApi = true
            showLoader()
            BuzzebeesHistory().pointHistory(token: token, date: getDate(), successCallback: { (arr) in
                if arr.count == 0 {
                    self.loadedData()
                    self.getApi()
                } else {
                    for dict in arr {
                        self.arrPointLogEarn.append(PointLog(dict: dict))
                    }
                }
                self.loadedData()
                self.tableView.es.stopPullToRefresh()
            }) { (error) in
                self.loadedData()
                self.tableView.es.stopPullToRefresh()
                print(error.description())
            }
        } else {
            if isBurnEnd { return }
            _isCallApi = true
            self.loadedData()
            self.tableView.es.stopPullToRefresh()
            return
        }
    }
}

// MARK:- Extension
// MARK:- UITableViewDelegate, UITableViewDataSource
extension PointHistoryViewController : UITableViewDelegate, UITableViewDataSource
{
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEarn {
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
        if isEarn {
            return arrPointLogEarn.count == 0 ? 1 : arrPointLogEarn.count
        } else {
            return arrPointLogBurn.count == 0 ? 1 : arrPointLogBurn.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEarn {
            if  arrPointLogEarn.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyHistoryCell
                cell.setupCell(message: "coin_earn_no_data".localized(), imageName: "doll-earned")
                return cell
            }
        } else {
            if  arrPointLogBurn.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyHistoryCell
                cell.setupCell(message: "coin_burn_no_data".localized(), imageName: "doll-redeem")
                return cell
            }
        }
        
        let item = isEarn ? arrPointLogEarn[indexPath.row] : arrPointLogBurn[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointHistoryCell", for: indexPath) as! PointHistoryCell
        cell.setupU(item)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEarn {
            if  arrPointLogEarn.count == 0 {
                return
            }
        } else {
            if  arrPointLogBurn.count == 0 {
                return
            }
        }
        
        let item = isEarn ? arrPointLogEarn[indexPath.row] : arrPointLogBurn[indexPath.row]
        
        let date = Date(timeIntervalSince1970: item.timestamp ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        analyticsSetEvent(isNeedProcess: false,event: "event_app", category: "your_coin_earn", action: "touch_list", label: "mission_list | \(item.title ?? "") | \(formatter.string(from: date)) | \(item.points ?? 0)")
        
        PopupManager.pointHistoryPopup(onView: self, pointlog: item)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isEarn {
            if indexPath.row > arrPointLogEarn.count - 3 {
                getApi()
            }
        } else {
            if indexPath.row == arrPointLogBurn.count - 2 {
                getApi()
            }
        }
    }
}