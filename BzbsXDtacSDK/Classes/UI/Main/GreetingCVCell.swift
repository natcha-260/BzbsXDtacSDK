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
    @IBOutlet weak var vwGreeting: UIView!
    @IBOutlet weak var lblGreeting: UILabel!
    @IBOutlet weak var vwLevel: UIView!
    @IBOutlet weak var lblLevelTitle: UILabel!
    @IBOutlet weak var imvLevel: UIImageView!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var vwCoinAmount: UIView!
    @IBOutlet weak var vwCoin: UIView!
    @IBOutlet weak var lblCoinTitle: UILabel!
    @IBOutlet weak var lblCoin: UILabel!
    @IBOutlet weak var btnCoin: UIButton!
    
    class func getNib() -> UINib{
        return UINib(nibName: "GreetingCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        lblGreeting.font = UIFont.mainFont(.big ,style:.bold)
        lblGreeting.textAlignment = .right
        lblGreeting.text = "Good morning".localized()
        lblGreeting.textColor = .mainGray
        lblGreeting.adjustsFontSizeToFitWidth = true
//        vwGreeting.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//        vwGreeting.cornerRadius()
        
        vwCoinAmount.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        vwCoinAmount.cornerRadius()
        
        lblLevelTitle.font = UIFont.mainFont()
        lblCoinTitle.font = UIFont.mainFont()
        lblCoin.font = UIFont.mainFont()
        lblCoin.adjustsFontSizeToFitWidth = true
        
        lblLevelTitle.textColor = .mainGray
        lblCoinTitle.textColor = .mainGray
        
        imvLevel.image = nil// UIImage(named: "imgt_icon_dtac", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        vwLevel.isHidden = true
        vwCoin.isHidden = true
    }
    
    func setupWithModel(_ item:GreetingModel?, coin: Int, target:UIViewController, levelSelector:Selector, coinSelector: Selector)
    {
        btnLevel.addTarget(target, action: levelSelector, for: UIControl.Event.touchUpInside)
        btnCoin.addTarget(target, action: coinSelector, for: UIControl.Event.touchUpInside)
        lblLevelTitle.text = "main_level_title".localized()
        lblCoinTitle.text = "your_coin".localized()
        if item != nil
        {
            let strGreeting = item?.greetingText ?? "Good morning"
            lblGreeting.text = strGreeting

            if let strUrl = item?.imageUrl {
                imvGreeting.bzbsSetImage(withURL: strUrl, isUsePlaceholder:false)
            }
        }
        
        lblCoin.text = coin.withCommas()
        
        var levelImageUrl:URL?
        vwLevel.isHidden = false
        vwCoin.isHidden = false
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
                vwCoin.isHidden = true
            }
        } else {
            vwLevel.isHidden = true
            vwCoin.isHidden = true
        }
        if let url = levelImageUrl
        {
            imvLevel.bzbsSetImage(withURL: url.absoluteString, isUsePlaceholder:false)
        } else {
            vwLevel.isHidden = true
        }
    }
}
