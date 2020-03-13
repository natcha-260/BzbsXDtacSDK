//
//  GreetingCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 24/9/2562 BE.
//

import UIKit
import Alamofire
import AlamofireImage

class GreetingCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imvGreeting: UIImageView!
    @IBOutlet weak var lblGreeting: UILabel!
    @IBOutlet weak var vwLevel: UIView!
    @IBOutlet weak var lblLevelTitle: UILabel!
    @IBOutlet weak var imvLevel: UIImageView!
    @IBOutlet weak var btnLevel: UIButton!
    
    class func getNib() -> UINib{
        return UINib(nibName: "GreetingCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        lblGreeting.font = UIFont.mainFont(style:.bold)
        lblGreeting.textAlignment = .right
        lblGreeting.text = "Good morning".localized()
        lblGreeting.textColor = .mainGray
        
        lblLevelTitle.font = UIFont.mainFont()
        lblLevelTitle.textColor = .mainGray
        
        imvGreeting.cornerRadius(corner: 16)
        imvLevel.image = nil// UIImage(named: "imgt_icon_dtac", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        vwLevel.isHidden = true
    }
    
    func setupWithModel(_ item:GreetingModel?, target:UIViewController, levelSelector:Selector)
    {
        btnLevel.addTarget(target, action: levelSelector, for: UIControl.Event.touchUpInside)
        lblLevelTitle.text = "main_level_title".localized()
        if item != nil
        {
            let strGreeting = item?.greetingText ?? "Good morning"
            lblGreeting.text = strGreeting

            if let strUrl = item?.imageUrl {
                imvGreeting.bzbsSetImage(withURL: strUrl)
            }
        }
        
        var levelImageUrl:URL?
        vwLevel.isHidden = false
        if let userLogin = Bzbs.shared.userLogin
        {
            switch userLogin.dtacLevel {
            case .blue :
                levelImageUrl = BuzzebeesCore.urlSegmentImageBlue
            case .gold :
                levelImageUrl = BuzzebeesCore.urlSegmentImageGold
            case .silver :
                levelImageUrl = BuzzebeesCore.urlSegmentImageSilver
            case .customer:
                levelImageUrl = BuzzebeesCore.urlSegmentImageDtac
            case .no_level:
                vwLevel.isHidden = true
            }
        } else {
            vwLevel.isHidden = true
        }
        if let url = levelImageUrl
        {
            imvLevel.bzbsSetImage(withURL: url.absoluteString)
        } else {
            vwLevel.isHidden = true
        }
    }
}
