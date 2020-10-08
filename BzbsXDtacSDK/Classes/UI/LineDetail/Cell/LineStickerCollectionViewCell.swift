//
//  LineStickerCollectionViewCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 5/10/2563 BE.
//

import UIKit

class LineStickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imvCampaign : UIImageView!
    class func getNib() -> UINib {
        return UINib(nibName: "LineStickerCollectionViewCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
