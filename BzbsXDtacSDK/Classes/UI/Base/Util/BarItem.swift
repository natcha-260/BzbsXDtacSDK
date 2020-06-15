//
//  BarItem.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 11/30/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//

import UIKit


class BarItem: NSObject {
    private static let barHeight :CGFloat = 44
    class func generate_logo() -> [UIBarButtonItem]? 
    {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        
        var titleWidth:CGFloat = 0
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: 30))
        lblTitle.textColor = .black
        lblTitle.font = UIFont.mainFont(.dtacHeaderSize,style:.bold)
        lblTitle.textAlignment = .left
        lblTitle.text = "main_title".localized()

        lblTitle.sizeToFit()
        titleWidth = lblTitle.frame.size.width + 4
        lblTitle.frame = CGRect(x: 0, y: 0, width: titleWidth, height: 44)
        
        let vwHeader = UIView(frame: CGRect(x: 0, y: 0, width: titleWidth + 4 , height: barHeight))
        vwHeader.backgroundColor = .clear
//        let imv = UIImageView(frame: CGRect(x: 0, y: 10, width: 27, height: 27))
//        imv.image = UIImage(named: "img_navbar_logo", in: Bzbs.shared.currentBundle, compatibleWith: nil)
//        imv.contentMode = .scaleAspectFill
//        vwHeader.addSubview(imv)
//
        vwHeader.addSubview(lblTitle)
        
        return [spaceFix, UIBarDtacIcon(), UIBarButtonItem(customView: vwHeader)]
    }
    
    class func UIBarDtacIcon() -> UIBarButtonItem {
        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
        
        let icon = UIImageView(image: UIImage(named: "img_navbar_logo", in: Bzbs.shared.currentBundle, compatibleWith: nil))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        iconView.addSubview(icon)
        
        icon.topAnchor.constraint(equalTo: iconView.topAnchor).isActive = true
        icon.leadingAnchor.constraint(equalTo: iconView.leadingAnchor).isActive = true
        icon.trailingAnchor.constraint(equalTo: iconView.trailingAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: iconView.bottomAnchor).isActive = true
        
        iconView.layoutIfNeeded()
        
        return UIBarButtonItem(customView: iconView)
    }
        
    class func generate_message(_ target: AnyObject, isHasNewMessage:Bool, messageSelector:Selector) -> [UIBarButtonItem]?  {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceFix.width = -15
        
        let width:CGFloat = 30
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: barHeight))
        let imv = UIImageView(frame: CGRect(x: 0, y: 5, width: 30, height: 30))
        imv.contentMode = .scaleAspectFit
        imv.image = UIImage(named: "img_navbar_icon_noti_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        view.addSubview(imv)

        if isHasNewMessage {
            
            let size = CGSize(width: 20, height: 20)
            let origin = CGPoint(x: 15, y: 13)
            let inboxBadge = UILabel(frame: CGRect(origin: origin, size: size))
            inboxBadge.textAlignment = .center
            inboxBadge.backgroundColor = UIColor(red: 250.0 / 255.0, green: 62.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
            inboxBadge.textColor = UIColor.white
            inboxBadge.font = UIFont.mainFont(FontSize.xsmall)
            inboxBadge.text = "N"
            inboxBadge.cornerRadius(corner: 10.0)
            
            view.addSubview(inboxBadge)
        }

        let btn = UIButton(frame: view.frame)
        btn.addTarget(target, action: messageSelector, for: UIControl.Event.touchUpInside)
        view.addSubview(btn)

        return [spaceFix, UIBarButtonItem(customView: view)]
    }
    
    class func generate_back(_ target: AnyObject, selector: Selector, isWhiteIcon:Bool = false) -> [UIBarButtonItem]?  {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceFix.width = -15
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: barHeight))
        let imv = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 22))
        imv.contentMode = .scaleAspectFit
        imv.image = UIImage(named: isWhiteIcon ? "img_navbar_icon_backwhite" : "img_navbar_icon_back", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        view.addSubview(imv)
        let btnMenu: UIButton = UIButton(type: .custom)
        btnMenu.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btnMenu.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        view.addSubview(btnMenu)
        
        return [spaceFix, UIBarButtonItem(customView: view)]
    }
    
    
    class func generate_map(_ target: AnyObject, selector: Selector) -> [UIBarButtonItem]?  {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceFix.width = -15
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: barHeight))
        let imv = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 22))
        imv.contentMode = .scaleAspectFill
        imv.image = UIImage(named: "img_search_icon_map", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        view.addSubview(imv)
        let btnMenu: UIButton = UIButton(type: .custom)
        btnMenu.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btnMenu.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        view.addSubview(btnMenu)
        
        return [spaceFix, UIBarButtonItem(customView: view)]
    }
    
    class func generate_nearby(_ target: AnyObject, selector: Selector) -> [UIBarButtonItem]?  {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceFix.width = -15
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: barHeight))
        let imv = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 22))
        imv.contentMode = .scaleAspectFit
        imv.image = UIImage(named: "img_icon_list", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        view.addSubview(imv)
        let btnMenu: UIButton = UIButton(type: .custom)
        btnMenu.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btnMenu.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        view.addSubview(btnMenu)
        
        return [spaceFix, UIBarButtonItem(customView: view)]
    }
    
    class func generate_like_share(_ target: AnyObject, isFavorite:Bool, favSelector: Selector, shareSelector:Selector) -> [UIBarButtonItem]?  {
        let spaceFix: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceFix.width = -15
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: barHeight))
        let favImv = UIImageView(frame: CGRect(x: 20, y: 10, width: 20, height: 22))
        favImv.contentMode = .scaleAspectFit
        favImv.image = UIImage(named: isFavorite ?  "img_navbar_icon_fav_active" : "img_navbar_icon_fav_unactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        view.addSubview(favImv)
        let btnFavMenu: UIButton = UIButton(type: .custom)
        btnFavMenu.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btnFavMenu.addTarget(target, action: favSelector, for: UIControl.Event.touchUpInside)
        view.addSubview(btnFavMenu)
        
        let shareImv = UIImageView(frame: CGRect(x: 60, y: 10, width: 20, height: 22))
        shareImv.contentMode = .scaleAspectFit
        shareImv.image = UIImage(named: "img_navbar_icon_share_ios", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        
        view.addSubview(shareImv)
        let btnShareMenu: UIButton = UIButton(type: .custom)
        btnShareMenu.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
        btnShareMenu.addTarget(target, action: shareSelector, for: UIControl.Event.touchUpInside)
        view.addSubview(btnShareMenu)
        
        return [spaceFix, UIBarButtonItem(customView: view)]
    }
}
