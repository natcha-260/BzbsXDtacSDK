//
//  PointHistoryDetailCellTableViewCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 13/8/2563 BE.
//

import UIKit

class PointHistoryDetailCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    var title:String?{
        didSet{
            lblTitle.text = title
        }
    }
    var detail:String? {
        didSet{
            lblDetail.text = detail
        }
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "PointHistoryDetailCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont(.small)
        lblDetail.font = UIFont.mainFont()
        
        lblTitle.textColor = .mainGray
    }
    
}
