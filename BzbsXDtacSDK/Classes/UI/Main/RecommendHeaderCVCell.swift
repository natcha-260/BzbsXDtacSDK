//
//  RecommendCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import UIKit

class RecommendHeaderCVCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblViewAll: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    
    class func getNib() -> UINib{
        return UINib(nibName: "RecommendHeaderCVCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont(style:.bold)
        lblViewAll.font = UIFont.mainFont()
        lblViewAll.textColor = .dtacBlue
        
        lblTitle.text = "recommend_title".localized()
        lblViewAll.text = "view_all".localized()
    }
    
    func setupWith(target:UIViewController, selector:Selector)
    {
        lblTitle.text = "recommend_title".localized()
        lblViewAll.text = "view_all".localized()
        btnViewAll.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
    }

}
