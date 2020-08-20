//
//  PointHistoryViewController.swift
//  Alamofire
//
//  Created by Buzzebees iMac on 10/8/2563 BE.
//

import UIKit

class PointHistoryViewController: BaseListController {
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var vwEarnLine: UIView!
    @IBOutlet weak var lblRedeemed: UILabel!
    @IBOutlet weak var vwRedeemedLine: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PointHistoryCell.getNib(), forCellReuseIdentifier: "pointHistoryCell")
        tableView.register(EmptyHistoryCell.getNib(), forCellReuseIdentifier: "emptyCell")
        tableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
        
        lblPoint.font = UIFont.mainFont(.big, style: .bold)
        lblExpireDate.font = UIFont.mainFont(.small,style: .bold)
        lblEarn.font = UIFont.mainFont()
        lblRedeemed.font = UIFont.mainFont()
        initNav()
        clickEarn(self)
        
        tableView.es.addPullToRefresh {
            if self.isEarn {
                self.arrPointLogEarn.removeAll()
                self.strEarnDate = ""
            } else {
                self.arrPointLogBurn.removeAll()
                self.strBurnDate = ""
            }

            self.getApi()
        }
        
        getApi()
        getExpiringPoint()
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
    
    func getExpiringPoint()
    {
        lblPoint.text = ""
        lblExpireDate.text = ""
        guard let token = Bzbs.shared.userLogin?.token else { return }
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
    
    // MARK:- Api
    // MARK:-
    override func getApi() {
        if _isCallApi { return }
        _isCallApi = true
        if isEarn {
            if isEarnEnd { return }
            guard let token = Bzbs.shared.userLogin?.token else {return}
            showLoader()
            BuzzebeesHistory().pointHistory(token: token, date: getDate(), successCallback: { (arr) in
                if arr.count == 0 {
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
            }
        } else {
            if isBurnEnd { return }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEarn {
            if arrPointLogEarn.count == 0 { return tableView.bounds.size.height * 0.9 }
        } else {
            if arrPointLogBurn.count == 0 { return tableView.bounds.size.height * 0.9 }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEarn {
            return arrPointLogEarn.count == 0 ? 1 : arrPointLogEarn.count
        } else {
            return arrPointLogBurn.count == 0 ? 1 : arrPointLogBurn.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        PopupManager.pointHistoryPopup(onView: self, pointlog: item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
