//
//  FavoriteCell.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 16/10/2562 BE.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRedeemDate: UILabel!
    @IBOutlet weak var imgExp: UIImageView!
    @IBOutlet weak var viewExp: UIView!
    @IBOutlet weak var btnFav: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgExp.isHidden = true
        viewExp.isHidden = true
        imv.contentMode = .scaleAspectFill
        lblTitle.font = UIFont.mainFont()
        lblRedeemDate.font = UIFont.mainFont()
        lblRedeemDate.textColor = .mainGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "FavoriteCell", bundle: Bzbs.shared.currentBundle)
    }
    
    func setupWith(_ item:BzbsCampaign) {
        
        if let strUrl = item.fullImageUrl {
            imv.bzbsSetImage(withURL: strUrl)
        }
        
        lblTitle.text = item.name
        
        let date = Date(timeIntervalSince1970: item.expireDate ?? Date().timeIntervalSince1970)
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat.dateFormat = "dd MMM yy"
        dateFormat.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        dateFormat.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        lblRedeemDate.text = "favorite_exp".localized() + " " + dateFormat.string(from: date)
        imgExp.isHidden = true
        viewExp.isHidden = true
        if item.currentDate > item.expireDate{
            imgExp.isHidden = false
            viewExp.isHidden = false
        }
    }
    
}
