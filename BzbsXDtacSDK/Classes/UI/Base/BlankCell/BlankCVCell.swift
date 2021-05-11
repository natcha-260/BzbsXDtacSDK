//
//  BlankCVCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 22/11/2562 BE.
//

import UIKit

class BlankCVCell: UICollectionViewCell {
    
    class func getNib() -> UINib{
        return UINib(nibName: "BlankCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
