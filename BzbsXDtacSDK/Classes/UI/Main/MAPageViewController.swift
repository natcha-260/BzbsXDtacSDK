//
//  MAPageViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 16/10/2562 BE.
//

import UIKit

protocol MAPageDelegate {
    func didReload()
}

class MAPageViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwBtn: UIView!
    @IBOutlet weak var lblRetry: UILabel!
    
    var delegate :MAPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwBtn.cornerRadius(borderColor: UIColor.lightGray, borderWidth: 1)
        lblRetry.font = UIFont.mainFont()
        lblMessage.font = UIFont.mainFont()
        lblRetry.textColor = .mainGray
        lblMessage.textColor = .mainGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblRetry.text = "popup_retry".localized()
        lblMessage.text = "ma_message".localized()
    }
    
    @IBAction func clickRetry(_ sender: Any) {
        delegate?.didReload()
    }
    
}
