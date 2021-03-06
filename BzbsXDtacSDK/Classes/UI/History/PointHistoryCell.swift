//
//  PointHistoryCell.swift
//  Alamofire
//
//  Created by Buzzebees iMac on 10/8/2563 BE.
//

import UIKit

class PointHistoryCell: UITableViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    class func getNib() -> UINib{
        return UINib(nibName: "PointHistoryCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont()
        lblEarn.font = UIFont.mainFont(style: FontStyle.bold)
        lblDate.font = UIFont.mainFont(FontSize.small)
        lblDate.textColor = .darkGray
        
    }
    
    func setupUI(_ item:PointLog) {
        var strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/"
        
        lblTitle.text = item.title ?? ""
        lblEarn.text = "coin_earn".localized() + ": \(item.points.withCommas())"
        
        if item.type == "adjust" {
            if item.points > 0 {
                strUrl = strUrl + "add.jpg"
                lblEarn.text = "coin_adjust_add".localized() + ": \(item.points.withCommas())"
            } else {
                strUrl = strUrl + "deduct.jpg"
                lblEarn.text = "coin_adjust_deduct".localized() + ": \(item.points.withCommas())"
            }
        }
        else if item.type == "transfer" {
            strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/transfer.jpg"
            lblTitle.text = "coin_transfer".localized()
        }
        else if item.type == "earn_bonus" {
            strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/bonus.jpg"
        }
        else {
            let productID = item.productId ?? "0"
            
            if (productID == "12" ||  productID == "13") && (item.isUnlock ?? false) {
                strUrl = strUrl + "reach1tier.jpg"
            } else {
                strUrl = strUrl + "product\(productID).jpg"   
            }
        }
        imv.bzbsSetImage(withURL: strUrl)
        
        let date = Date(timeIntervalSince1970: item.timestamp ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        lblDate.text = "coin_earn_on".localized() + " " + formatter.string(from: date)
        
    }
    
    
    
    func setupUI(_ item: BzbsHistory) {
        lblTitle.text = item.name
        lblEarn.text = "coin_use".localized() + ": \(item.pointPerUnit.withCommas())"
        imv.bzbsSetImage(withURL: item.fullImageUrl)
        let date = Date(timeIntervalSince1970: item.redeemDate ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: -1 * (7 * 60 * 60))
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        lblDate.text = "coin_earn_on".localized() + " " + formatter.string(from: date)
        
    }
}
