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
    
    func setupU(_ item:PointLog) {
        let productID = item.productId ?? "0"
        let strUrl = BuzzebeesCore.blobUrl + "/config/353144231924127/history/product\(productID).jpg"
        imv.bzbsSetImage(withURL: strUrl)
        
        lblTitle.text = item.title ?? ""
        
        lblEarn.text = "Earned : \(item.points.withCommas())"
        
        let date = Date(timeIntervalSince1970: item.timestamp ?? Date().timeIntervalSince1970) + (7 * 60 * 60)
        let formatter = DateFormatter()
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        lblDate.text = "on " + formatter.string(from: date)
        
    }
    
}
