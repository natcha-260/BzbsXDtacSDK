//
//  PointBurnHistoryCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2563 BE.
//

import UIKit

class PointBurnHistoryCell: PointHistoryCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vwStatus: UIView!
    
    override class func getNib() -> UINib{
        return UINib(nibName: "PointBurnHistoryCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblStatus.font = UIFont.mainFont()
        vwStatus.backgroundColor = .historyStatusAvailable
        vwStatus.cornerRadius()
    }
    
    override func setupUI(_ item: BzbsHistory) {
        super.setupUI(item)
        
        if item.serial == "XXXXXXX" {
            lblStatus.text = "coin_history_expired".localized()
            vwStatus.backgroundColor = .historyStatusExpired
        } else {
            lblStatus.text = "coin_history_available".localized()
            vwStatus.backgroundColor = .historyStatusAvailable
        }
    }
}

