//
//  CategoryCollectionViewCell.swift
//  ChildViewDemo
//
//  Created by apple on 16/9/2562 BE.
//  Copyright © 2562 cyts. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var imgCategory: UIImageView!
    var cat : BzbsCategory!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblCategory.textColor = UIColor.mainGray
        lblCategory.font = UIFont.mainFont(.categorySize, style: .normal)
        lblCategory.numberOfLines = 2
        lblCategory.adjustsFontSizeToFitWidth = true
    }
    
    func setupCell(_ item:BzbsCategory)
    {
        self.cat = item
        var name = item.nameEn
        if LocaleCore.shared.getUserLocale() == BBLocaleKey.th.rawValue {
            name = item.nameTh
        }
        if item.nameEn.lowercased() == "nearby"
        {
            name = "nearby_title".localized()
        }
        
        lblCategory.text = name
    }
    
    func setActive(_ isActive:Bool)
    {
        lblCategory.textColor = isActive ? UIColor.dtacBlue : UIColor(hexString: "1A1A1A")
        let time = Date().toString()
        self.imgCategory.image = UIImage()
        let strUrl = cat.imageUrl + (isActive ? "_active?time=\(time)" : "_inactive?time=\(time)")
        self.imgCategory.bzbsSetImage(withURL: strUrl)
    }
    
}
