//
//  PopupLineConfirmViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 7/10/2563 BE.
//

import UIKit

class PopupLineConfirmViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblBack: UILabel!
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var lblConfirm: UILabel!
    @IBOutlet weak var vwConfirm: UIView!
    
    var campaign:LineStickerCampaign!
    var strContactNumber = ""
    var confirm: (() -> Void)?
    var cancel:  (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblMessage.font = UIFont.mainFont()
        lblInfo.font = UIFont.mainFont()
        lblBack.font = UIFont.mainFont()
        
        lblMessage.textColor = .lineGreen
        lblBack.textColor = .white
        lblConfirm.textColor = .white
        vwBack.backgroundColor = .lightGray
        vwConfirm.backgroundColor = .lineGreen
        
        lblMessage.text = String(format: "line_popup_use_point_format".localized(), campaign.points?.withCommas() ?? "0", campaign.stickerTitle ?? "-")
        lblInfo.text = String(format: "line_popup_info_contact_format".localized(), strContactNumber)
        lblBack.text = "line_popup_back".localized()
    }
    

    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true, completion: cancel)
    }
    @IBAction func clickConfirm(_ sender: Any) {
        self.dismiss(animated: true, completion: confirm)
    }
}
