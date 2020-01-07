//
//  SubCatCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 20/9/2562 BE.
//

import UIKit

class SubCatCVCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var imvBG: UIImageView!
    
    var isActive = false {
        didSet{
            imvBG.image = UIImage(named: isActive ? "img_bg_cat_active" : "img_bg_cat_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            lblName.textColor = isActive ? .white : .mainGray
        }
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "SubCatCVCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        lblName.font = UIFont.mainFont()
        lblName.textColor = .mainGray
        vwContent.cornerRadius()
    }

}
