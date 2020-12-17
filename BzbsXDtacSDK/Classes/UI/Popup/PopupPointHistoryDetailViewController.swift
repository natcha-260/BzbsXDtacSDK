//
//  PopupPointHistoryDetailViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 13/8/2563 BE.
//

import UIKit

class PopupPointHistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cstHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    @IBOutlet weak var vwClose: UIView!
    
    var pointLog : PointLog!
    var purchase : BzbsHistory?
    var closeSelector:(() -> Void)?
    var listCell = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        lblTitle.text = "-"
        lblPoint.text = "coin_earn_detail".localized() + ":-"
        lblTitle.font = UIFont.mainFont(style:.bold)
        lblPoint.font = UIFont.mainFont(style:.bold)
        lblClose.font = UIFont.mainFont()
        lblClose.text = "popup_close".localized()
        vwClose.cornerRadius()
        vwClose.backgroundColor = .dtacBlue
        tableView.isUserInteractionEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(PointHistoryDetailCell.getNib(), forCellReuseIdentifier: "pointHistoryDetailCell")
        Bzbs.shared.showLoader(on: self)
        imv.bzbsSetImage(withURL: "")
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI() {
        if let _purchase = purchase {
            imv.bzbsSetImage(withURL: purchase?.fullImageUrl ?? "")
            lblTitle.text = _purchase.name
            lblPoint.text = "coin_use".localized() + ": \(_purchase.pointPerUnit.withCommas())"
            listCell = ["redeem_date"]
        } else {
            lblTitle.text = pointLog.title
            if pointLog.type == "adjust"
            {
                var strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/"
                if pointLog.points > 0 {
                    strUrl = strUrl + "add.jpg"
                    lblPoint.text = "coin_adjust_add".localized() + ": \(pointLog.points.withCommas())"
                } else {
                    strUrl = strUrl + "deduct.jpg"
                    lblPoint.text = "coin_adjust_deduct".localized() + ": \(pointLog.points.withCommas())"
                }
                imv.bzbsSetImage(withURL: strUrl)
                listCell = ["adjust_date"]
            }
            else if pointLog.type == "transfer"
            {
                lblTitle.text = "coin_transfer".localized()
                let strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/transfer.jpg"
                lblPoint.text = "coin_earn_detail".localized() + ": \(pointLog.points.withCommas())"
                imv.bzbsSetImage(withURL: strUrl)
                listCell = ["transfer_from", "transfer_date"]
            }
            else {
                lblPoint.text = "coin_earn_detail".localized() + ": " + pointLog.points.withCommas()
                let productID = pointLog.productId ?? "0"
                var strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/product\(productID).jpg"
                if productID == "12" && (pointLog.isUnlock ?? false) {
                    strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/reach1tier.jpg"
                }
                imv.bzbsSetImage(withURL: strUrl)
                
                switch pointLog.productId {
                    case "1":
                        listCell = ["package_sub", "sub_date", "package_fee"]
                        break
                    case "2":
                        listCell = ["refill_date"]
                        break
                    case "3":
                        listCell = ["paid_amount" , "paid_date"]
                        break
                    case "4":
                        listCell = ["paid_amount" , "paid_date"]
                        break
                    case "5":
                        listCell = ["first_use_date"]
                        break
                    case "6":
                        listCell = ["checkin_date"]
                        break
                    case "7":
                        listCell = ["jaidee_service","usage_date"]
                        break
                    case "8":
                        listCell = ["jaidee_service","usage_date"]
                        break
                    case "9":
                        listCell = ["jaidee_service","usage_date"]
                        break
                    case "10":
                        listCell = ["jaidee_service","usage_date"]
                        break
                    case "11":
                        listCell = ["jaidee_service","usage_date"]
                        break
                    case "12":
                        listCell = ["activity" , "paid_amount", "accum_paid_amount" , "c2c_paid_date"]
                        if (pointLog.isUnlock ?? false) {
                            listCell = ["activity" , "accum_paid_amount" , "c2c_paid_date"]
                        }
                        break
                    case "13":
                        listCell = ["activity" , "paid_amount", "accum_paid_amount" , "c2c_paid_date"]
                        break
                    default:
                        break
                }
            }
        }
        tableView.reloadData()
        Bzbs.shared.delay(0.33) {
            let newHeight = self.tableView.contentSize.height
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0, animations: {
                    self.cstHeight.constant = newHeight * 1.2
                    self.view.layoutIfNeeded()
                }) { (_) in
                    Bzbs.shared.hideLoader()
                }
            }
            
        }
    }
    
    @IBAction func clickClose(_ sender: Any) {
        closeSelector?()
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopupPointHistoryDetailViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdent = listCell[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointHistoryDetailCell", for: indexPath) as! PointHistoryDetailCell
        if cellIdent == "package_sub" {
            cell.title = "coin_package_sub".localized() + ": "
            cell.detail = pointLog.historyDetail
        }
        else if cellIdent == "jaidee_service" {
            cell.title = "coin_jaidee_service".localized() + ": "
            cell.detail = pointLog.title
        }
        else if cellIdent == "package_fee" ||
                    cellIdent == "paid_amount"
        {
            if cellIdent == "package_fee" {
                cell.title = "coin_package_fee".localized() + ": "
            } else if cellIdent == "paid_amount" {
                cell.title = "coin_paid_amount".localized() + ": "
            }
            
            if let amount = pointLog.amount {
                cell.detail = amount.withCommas() + " " + "baht".localized()
            } else {
                cell.detail = "-"
            }
        }
        else if cellIdent == "transfer_from" {
            cell.title = "coin_transfer_from".localized() + ": "
            cell.detail = pointLog.title
        }
        else if cellIdent == "activity" {
            cell.title = "activity".localized() + ": "
            cell.detail = pointLog.historyDetail
        }
        else if cellIdent == "accum_paid_amount" {
            cell.title = "accum_paid_amount".localized() + ": "
            cell.detail = Double(pointLog.totalAmount ?? 0).withCommas() + " " + "baht".localized()
        }
        else if cellIdent.contains("date") {
            
            let formatter = DateFormatter()
            formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
            formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
            formatter.dateFormat = "d MMMM yyyy"
            if let periodFormat = pointLog.periodFormat
            {
                formatter.dateFormat = periodFormat
            }
            
            if cellIdent == "sub_date" {
                cell.title = "coin_sub_date".localized() + ": "
                formatter.dateFormat = "dd/MM/yyyy - HH:mm"
                if let activityDate = pointLog.activityDate {
                    cell.detail = formatter.string(from:  Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "paid_date" {
                
                cell.title = "coin_paid_date".localized() + ": "
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "checkin_date"
            {
                cell.title = "coin_checkin_date".localized() + ": "
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "refill_date"
            {
                cell.title = "coin_refill_date".localized() + ": "
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "first_use_date"
            {
                cell.title = "coin_first_use_date".localized() + ": "
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "adjust_date"
            {
                cell.title = "coin_adjust_date".localized() + ": "
                formatter.dateFormat = "d MMM yyyy"
                if let activityDate = pointLog.timestamp {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "usage_date"
            {
                cell.title = "coin_usage_date".localized() + ": "
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "transfer_date"
            {
                cell.title = "coin_transfer_date".localized() + ": "
                
                if let activityDate = pointLog.timestamp {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "redeem_date" {
                cell.title = "redeem_date".localized() + ": "
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "d MMM yyyy"
                if let redeemDate = purchase?.redeemDate {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: redeemDate))
                } else {
                    cell.detail = "-"
                }
            } else if cellIdent == "c2c_paid_date" {
                if pointLog.isUnlock ?? false {
                    cell.title = "c2c_paid_date_unlock".localized() + ": "
                } else {
                    cell.title = "c2c_paid_date".localized() + ": "
                }
                
                if let activityDate = pointLog.period {
                    cell.detail = formatter.string(from: Date(timeIntervalSince1970: activityDate))
                } else {
                    cell.detail = "-"
                }
            }
            
        }
        
        return cell
    }
}
