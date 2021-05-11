//
//  LoadMoreCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 24/9/2562 BE.
//

import UIKit

class LoadMoreCVCell: UICollectionViewCell {
    
    class func getNib() -> UINib{
        return UINib(nibName: "LoadMoreCVCell", bundle: Bzbs.shared.currentBundle)
    }
    @IBOutlet weak var vwLoadMore: UIView!
    @IBOutlet weak var lblLoadMore: UILabel!
    @IBOutlet weak var vwLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        vwLine.backgroundColor = .lightGray
        vwLine.isHidden = true
        vwLoadMore.cornerRadius(borderColor: UIColor.darkGray, borderWidth: 1)
        lblLoadMore.font = UIFont.mainFont()
        lblLoadMore.text = "see_more".localized()
    }
    
    func setLine()
    {
        lblLoadMore.text = "see_more".localized()
        vwLine.isHidden = false
        vwLoadMore.isHidden = true
    }
    
    func setLoadMore()
    {
        lblLoadMore.text = "see_more".localized()
        vwLine.isHidden = true
        vwLoadMore.isHidden = false
    }

}
