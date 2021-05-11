//
//  HistoryCell.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 1/10/2562 BE.
//

import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRedeemDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewBGStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont()
        lblRedeemDate.font = UIFont.mainFont(.small)
        lblRedeemDate.textColor = .mainGray
        viewBGStatus.cornerRadius()
        
        lblStatus.textColor = UIColor.white
        lblStatus.font = UIFont.mainFont(.small)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "HistoryCell", bundle: Bzbs.shared.currentBundle)
    }
    
    func setupWith(_ item:BzbsHistory) {
        
        if let strUrl = item.fullImageUrl {
            imv.bzbsSetImage(withURL: strUrl)
        }
        
        lblTitle.text = item.name
        
        let date = Date(timeIntervalSince1970: item.redeemDate ?? Date().timeIntervalSince1970)
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        dateFormat.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        dateFormat.dateFormat = "dd/MM/yyyy HH:mm"
        
        lblRedeemDate.text = "history_redeem_on".localized() + " " + dateFormat.string(from: date)

        lblStatus.text = "history_status_avilable".localized()
        viewBGStatus.backgroundColor = UIColor(hexString: "39c166")
        if let _ = item.arrangedDate
        {
            lblStatus.text = "history_status_expired".localized()
            viewBGStatus.backgroundColor = UIColor(hexString: "c2c9cc")
        } else if let expireIn = item.expireIn, expireIn <= 0
        {
            lblStatus.text = "history_status_expired".localized()
            viewBGStatus.backgroundColor = UIColor(hexString: "c2c9cc")
        }
    }
}
