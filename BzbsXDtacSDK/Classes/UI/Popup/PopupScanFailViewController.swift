//
//  PopupScanFailViewController.swift
//  Pods
//
//  Created by ICBZ0840 on 30/10/2562 BE.
//

import UIKit

class PopupScanFailViewController: UIViewController {
    
    var closeSelector:(() -> Void)?

    @IBOutlet weak var lblMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } 
        lblMessage.font = UIFont.mainFont()
        // Do any additional setup after loading the view
        lblMessage.text = "popup_scan_not_found".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblMessage.text = "popup_scan_not_found".localized()
    }
    
    @IBAction func clickClose(_ sender: Any) {
//        self.view.removeFromSuperview()
        closeSelector?()
        self.dismiss(animated: true, completion: nil)
    }
    
}
