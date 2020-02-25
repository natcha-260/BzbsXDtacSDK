//
//  PopupInformationViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/10/2562 BE.
//

import UIKit

class PopupInformationViewController: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblClose: UILabel!
    
    @IBOutlet weak var cstWidthPhone: NSLayoutConstraint!
    @IBOutlet weak var cstWidthPad: NSLayoutConstraint!
    
    var closeSelector:(() -> Void)?
    
    var strTitle:String?
    var strMessage:String?
    var strClose:String = "popup_close".localized()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } 
        if UIDevice.current.userInterfaceIdiom == .pad {
            if cstWidthPhone != nil && cstWidthPhone.isActive {
                cstWidthPhone.isActive = false
            }
        } else {
            if cstWidthPad != nil && cstWidthPad.isActive {
                cstWidthPad.isActive = false
            }
        }
        
        imvIcon.image = UIImage(named: "ic_sorry", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        vwContainer.cornerRadius()
        lblTitle.font = UIFont.mainFont(FontSize.xbig, style:.bold)
        lblMessage.font = UIFont.mainFont()
        lblClose.font = UIFont.mainFont()
        lblClose.textColor = .white
        vwClose.backgroundColor = .dtacBlue
        vwClose.cornerRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblTitle.text = strTitle
        lblMessage.text = strMessage
        lblClose.text = strClose
        
    }
    
    @IBAction func clickClose(_ sender: Any) {
//        self.view.removeFromSuperview()
        closeSelector?()
        self.dismiss(animated: true, completion: nil)
    }
    
}
