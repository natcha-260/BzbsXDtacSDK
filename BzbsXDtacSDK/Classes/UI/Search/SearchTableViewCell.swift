//
//  SearchTableViewCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    class func getNib() -> UINib{
        return UINib(nibName: "SearchTableViewCell", bundle: Bzbs.shared.currentBundle)
    }
    
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvAccessory: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .gray
    }
    
    func setupSearchCell(image:UIImage?, title:String, isShowClosure:Bool = true)
    {
        lblTitle.text = title
        imvIcon.image = image
        imvAccessory.isHidden = !isShowClosure
    }
    
}
