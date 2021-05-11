//
//  FavoriteExpireCVCell.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 1/10/2562 BE.
//

import UIKit

class FavoriteExpireCVCell: CampaignCVCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override class func getNib() -> UINib{
        return UINib(nibName: "FavoriteExpireCVCell", bundle: Bzbs.shared.currentBundle)
    }
}
