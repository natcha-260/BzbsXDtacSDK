//
//  AutoCompleteTVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 17/10/2562 BE.
//

import UIKit

class AutoCompleteTVCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    class func getNib() -> UINib{
        return UINib(nibName: "AutoCompleteTVCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .gray
    }
    
    func setText(_ text:String, hilightText:String)
    {
        let nsString = NSString(string:text)
        let range = nsString.range(of: hilightText)
        let attrText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.mainFont()])
        attrText.addAttributes([NSAttributedString.Key.font : UIFont.mainFont(style:.bold)], range: range)
        lblTitle.attributedText = attrText
    }
    
}
