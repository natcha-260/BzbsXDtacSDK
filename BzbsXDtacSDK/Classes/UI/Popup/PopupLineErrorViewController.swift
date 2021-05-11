//
//  PopupLineErrorViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 7/10/2563 BE.
//

import UIKit

class PopupLineErrorViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblBack: UILabel!
    @IBOutlet weak var vwBack: UIView!
    
    var strMessage = ""
    var strInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imv.image = UIImage(named: "img_error_round", in: Bzbs.shared.currentBundle, compatibleWith: nil)

        lblMessage.font = UIFont.mainFont()
        lblInfo.font = UIFont.mainFont()
        lblBack.font = UIFont.mainFont()
        
        lblMessage.textColor = .lineGreen
        lblBack.textColor = .lineGreen
        vwBack.cornerRadius(corner: 0, borderColor: .lineGreen, borderWidth: 1)
        
        lblMessage.text = strMessage
        lblInfo.text = strInfo
        lblBack.text = "line_popup_back".localized()
    }
    

    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}
