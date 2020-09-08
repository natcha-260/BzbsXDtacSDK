//
//  EmptyCollectionViewCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 7/10/2562 BE.
//

import UIKit

class EmptyCVCell: UICollectionViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    
    class func getNib() -> UINib {
        return UINib(nibName: "EmptyCollectionViewCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbl.font = UIFont.mainFont()
        lbl.textColor = UIColor.mainGray
        lbl.numberOfLines = 0
        setupCell()
    }
    
    func setupCell() {
        imv.image = UIImage(named: "ico-hist-no", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        lbl.text = "util_no_data".localized()
    }

}
