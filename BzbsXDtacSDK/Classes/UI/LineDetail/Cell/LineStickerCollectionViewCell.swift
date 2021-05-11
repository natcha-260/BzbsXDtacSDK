//
//  LineStickerCollectionViewCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 5/10/2563 BE.
//

import UIKit

class LineStickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imvCampaign : UIImageView!
    @IBOutlet weak var vwOverlay: UIView!
    class func getNib() -> UINib {
        return UINib(nibName: "LineStickerCollectionViewCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        vwOverlay.isHidden = true
        imvCampaign.transform = .identity
    }

    func setAction(_ mode:CellLineAction) {
        switch mode {
            case .unselected:
                imvCampaign.alpha = 1
                imvCampaign.transform = .identity
            case .deselected:
                imvCampaign.alpha = 0.3
                imvCampaign.transform = .identity
            case .selected:
                imvCampaign.alpha = 1
                vwOverlay.isHidden = true
                imvCampaign.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }
}


enum CellLineAction {
    case selected
    case deselected
    case unselected
}
