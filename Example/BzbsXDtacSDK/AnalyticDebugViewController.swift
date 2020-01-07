//
//  AnalyticDebugViewController.swift
//  BzbsXDtacSDK_Example
//
//  Created by Buzzebees iMac on 8/11/2562 BE.
//  Copyright © 2562 CocoaPods. All rights reserved.
//

import UIKit

class AnalyticDebugViewController: UIViewController {

    @IBOutlet weak var txtView: UITextView!
    var strLog = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.isEditable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtView.text = strLog
    }
    
    func printLog(_ string:String)
    {
        strLog = strLog + string
    }

}
