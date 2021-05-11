//
//  CampaignBigRotateCVCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 16/9/2562 BE.
//

import UIKit

class CampaignBigRotateCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imvCampaign : UIImageView!
    
    class func getNib() -> UINib {
        return UINib(nibName: "CampaignBigRotateCVCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imvCampaign.contentMode = .scaleAspectFill
        // Initialization code
    }

}
