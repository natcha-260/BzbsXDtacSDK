//
//  FooterCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 24/9/2562 BE.
//

import UIKit

class FooterCVCell: UICollectionViewCell {

    @IBOutlet weak var viewFavorite: UIView!
    @IBOutlet weak var viewHistory: UIView!
    @IBOutlet weak var viewFAQ: UIView!
    @IBOutlet weak var viewAbout: UIView!

    @IBOutlet weak var lblFavorite: UILabel!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblFAQ: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblFooter: UILabel!
    
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var btnHist: UIButton!
    @IBOutlet weak var btnFaq: UIButton!
    @IBOutlet weak var btnAbout: UIButton!
    class func getNib() -> UINib{
        return UINib(nibName: "FooterCVCell", bundle: Bzbs.shared.currentBundle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        viewFavorite.cornerRadius(borderColor: .white, borderWidth: 1)
        viewHistory.cornerRadius( borderColor: .white, borderWidth: 1)
        viewFAQ.cornerRadius( borderColor: .white, borderWidth: 1)
        viewAbout.cornerRadius( borderColor: .white, borderWidth: 1)

        lblFavorite.font = UIFont.mainFont(.small, style: .bold)
        lblHistory.font = UIFont.mainFont(.small, style: .bold)
        lblFAQ.font = UIFont.mainFont(.small, style: .bold)
        lblAbout.font = UIFont.mainFont(.small, style: .bold)
        lblFooter.font = UIFont.mainFont(.small, style: .normal)
        
        lblFavorite.text = "main_footer_fav".localized()
        lblHistory.text = "main_footer_hist".localized()
        lblFAQ.text = "main_footer_faq".localized()
        lblAbout.text = "main_footer_about".localized()
        lblFooter.text = "main_footer_msg".localized()
    }
    
    func setupWith(target:UIViewController, favSelector:Selector, histSelector:Selector, faqSelector:Selector, aboutSelector:Selector) {
        
        
        lblFavorite.text = "main_footer_fav".localized()
        lblHistory.text = "main_footer_hist".localized()
        lblFAQ.text = "main_footer_faq".localized()
        lblAbout.text = "main_footer_about".localized()
        lblFooter.text = "main_footer_msg".localized()
        
        for oldTarget in btnFav.allTargets
        {
            if let actions = btnFav.actions(forTarget: oldTarget, forControlEvent: UIControl.Event.touchUpInside)
            {
                for action in actions
                {
                    btnFav.removeTarget(oldTarget, action: Selector(action), for: UIControl.Event.touchUpInside)
                }
            }
        }
        
        for oldTarget in btnHist.allTargets
        {
            if let actions = btnHist.actions(forTarget: oldTarget, forControlEvent: UIControl.Event.touchUpInside)
            {
                for action in actions
                {
                    btnHist.removeTarget(oldTarget, action: Selector(action), for: UIControl.Event.touchUpInside)
                }
            }
        }
        
        for oldTarget in btnFaq.allTargets
        {
            if let actions = btnFaq.actions(forTarget: oldTarget, forControlEvent: UIControl.Event.touchUpInside)
            {
                for action in actions
                {
                    btnFaq.removeTarget(oldTarget, action: Selector(action), for: UIControl.Event.touchUpInside)
                }
            }
        }
        
        for oldTarget in btnAbout.allTargets
        {
            if let actions = btnAbout.actions(forTarget: oldTarget, forControlEvent: UIControl.Event.touchUpInside)
            {
                for action in actions
                {
                    btnAbout.removeTarget(oldTarget, action: Selector(action), for: UIControl.Event.touchUpInside)
                }
            }
        }
        
        btnFav.addTarget(target, action: favSelector, for: UIControl.Event.touchUpInside)
        btnHist.addTarget(target, action: histSelector, for: UIControl.Event.touchUpInside)
        btnFaq.addTarget(target, action: faqSelector, for: UIControl.Event.touchUpInside)
        btnAbout.addTarget(target, action: aboutSelector, for: UIControl.Event.touchUpInside)
        
    }

}
