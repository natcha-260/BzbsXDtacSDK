//
//  CoinHistoryMockupViewController.swift
//  BzbsXDtacSDK_Example
//
//  Created by Buzzebees iMac on 25/8/2563 BE.
//  Copyright © 2563 CocoaPods. All rights reserved.
//

import UIKit
import BzbsXDtacSDK

class CoinHistoryMockupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var coinHistoryList = Dictionary<String, [PointLog]>()
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.locale = Locale(identifier: Locale.identifier(fromWindowsLocaleCode: 1033)!)
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    
    // MARK:- Variable
    var isEarn = false
    var strEarnDate:String = ""
    var strBurnDate:String = ""
    var dateKey = [String]()
    var strDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CoinHistoryMockup"
        
        for _ in 0..<3
        {
            let date = getDate()
            dateKey.append(date)
            coinHistoryList[date] = [PointLog]()
        }
        tableView.reloadData()
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add_mockup_data" {
            if let vc = segue.destination as? CoinHistoryMockupDataViewController,
                let index = sender as? Int
            {
                vc.date = dateKey[index]
                vc.delegate = self
            }
        }
    }
}

extension CoinHistoryMockupViewController : UITableViewDataSource, UITableViewDelegate
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinHistoryList[dateKey[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointHistoryCell", for: indexPath) as! PointHistoryCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        vw.addSubview(lbl)
        lbl.text = dateKey[section]
        let btn = UIButton(type: UIButton.ButtonType.contactAdd)
        btn.frame = CGRect(x: vw.bounds.size.width - 40, y: 0, width: 40, height: 40)
        btn.tag = section
        btn.addTarget(self, action: #selector(clickAdd(_:)), for: UIControl.Event.touchUpInside)
        vw.addSubview(btn)
        return vw
    }
    
    @objc func clickAdd(_ sender:AnyObject) {
        if let btn = sender as? UIButton {
            self.performSegue(withIdentifier: "add_mockup_data", sender: btn.tag)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension CoinHistoryMockupViewController : MockupDataDelegate {
    func didAddData(data: PointLog, date: String) {
        
    }
}


class PointHistoryCell: UITableViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont()
        lblEarn.font = UIFont.mainFont(style: FontStyle.bold)
        lblDate.font = UIFont.mainFont(FontSize.small)
        lblDate.textColor = .darkGray
        
    }
    
    func setupU(_ item:PointLog) {
        if item.type == "adjust" {
            if item.points > 0 {
                lblEarn.text = "Add" + " : \(item.points.withCommas())"
            } else {
                lblEarn.text = "Deduct" + " : \(item.points.withCommas())"
            }
        } else {
            lblEarn.text = "Earn  : \(item.points.withCommas())"
        }
        
        lblTitle.text = item.title ?? ""
        
        let date = Date(timeIntervalSince1970: item.timestamp ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        lblDate.text = "on " + formatter.string(from: date)
        
    }
    
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
