//
//  AnalyticDebugViewController.swift
//  BzbsXDtacSDK_Example
//
//  Created by Buzzebees iMac on 8/11/2562 BE.
//  Copyright © 2562 CocoaPods. All rights reserved.
//

import UIKit

class AnalyticDebugViewController: UIViewController {

    @IBOutlet weak var txtFilter: UITextField!
    @IBOutlet weak var txtView: UITextView!
    var strLog = ""
    var strFilter : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.isEditable = false
    }
    
    @IBAction func clickTrash(_ sender: Any) {
        strLog = ""
        strFilter = nil
        applyFilter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtView.text = strLog
    }
    
    func applyFilter()
    {
        if let str = strFilter, str != ""
        {
            var tmpLog = ""
            let list = strLog.split(separator: "\n")
            for item in list
            {
                if String(item).contains(str) {
                    tmpLog = tmpLog + String(item) + "\n"
                }
            }
            txtView.text = tmpLog
        } else {
            txtView.text = strLog
        }
    }
    
    func printLog(_ string:String)
    {
        strLog = strLog + string
    }

}

extension AnalyticDebugViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        strFilter = textField.text
        applyFilter()
        view.endEditing(true)
        return true
    }
}
