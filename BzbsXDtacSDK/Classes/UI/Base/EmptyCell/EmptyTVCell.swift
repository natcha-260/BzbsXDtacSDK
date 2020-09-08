//
//  EmptyTableViewCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 7/10/2562 BE.
//

import UIKit

class EmptyTVCell: UITableViewCell {
    
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    class func getNib() -> UINib {
        return UINib(nibName: "EmptyTableViewCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbl.font = UIFont.mainFont()
        lbl.textColor = UIColor.mainGray
        lbl.numberOfLines = 0
        setupCell()
    }
    
    func setupCell(message :String = "util_no_data".localized(), imageName: String = "ico-hist-no") {
        imv.image = UIImage(named: imageName, in: Bzbs.shared.currentBundle, compatibleWith: nil)
        lbl.text = message
    }
    
}
