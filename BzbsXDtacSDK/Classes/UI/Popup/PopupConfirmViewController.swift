//
//  PopupConfirmViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/10/2562 BE.
//

import UIKit

class PopupConfirmViewController: UIViewController {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblClose: UILabel!
    @IBOutlet weak var vwConfirm: UIView!
    @IBOutlet weak var lblConfirm: UILabel!
    
    @IBOutlet weak var cstWidthPhone: NSLayoutConstraint!
    @IBOutlet weak var cstWidthPad: NSLayoutConstraint!
    
    var closeSelector:(() -> Void)?
    var confirmSelector:(() -> Void)?
    
    var strTitle:String?
    var strMessage:String?
    var strClose:String = "popup_cancel".localized()
    var strConfirm:String = "popup_confirm".localized()
    
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
        
        vwContainer.cornerRadius()
        lblTitle.font = UIFont.mainFont(FontSize.xbig, style:.bold)
        lblMessage.font = UIFont.mainFont()
        lblClose.font = UIFont.mainFont()
        lblClose.textColor = .black
        vwClose.cornerRadius(borderColor: UIColor.mainGray, borderWidth: 1)
        lblConfirm.font = UIFont.mainFont()
        lblConfirm.textColor = .white
        vwClose.backgroundColor = .white
        vwConfirm.backgroundColor = .dtacBlue
        vwConfirm.cornerRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblTitle.text = strTitle
        lblMessage.text = strMessage
        lblClose.text = strClose
        lblConfirm.text = strConfirm
    }
    
    @IBAction func clickClose(_ sender: Any) {
//        self.view.removeFromSuperview()
//        closeSelector?()
//        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true) {
            self.closeSelector?()
        }
    }
    
    @IBAction func clickConfirm(_ sender: Any) {
//        self.view.removeFromSuperview()
//        self.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true) {
            self.confirmSelector?()
        }
    }
}

