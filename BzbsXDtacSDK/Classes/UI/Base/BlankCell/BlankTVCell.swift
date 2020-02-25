//
//  BlankCVCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 22/11/2562 BE.
//

import UIKit

class BlankTVCell: UITableViewCell {
    
    class func getNib() -> UINib{
        return UINib(nibName: "BlankTVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
