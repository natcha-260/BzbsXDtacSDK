//
//  CoinHistoryMockupDataViewController.swift
//  BzbsXDtacSDK_Example
//
//  Created by Buzzebees iMac on 25/8/2563 BE.
//  Copyright © 2563 CocoaPods. All rights reserved.
//

import UIKit
import BzbsXDtacSDK

protocol MockupDataDelegate {
    func didAddData(data : PointLog, date:String)
}

class CoinHistoryMockupDataViewController: UIViewController {

    var delegate :MockupDataDelegate?
    var date = ""
    @IBOutlet weak var productType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func clickAdd(_ sender: Any) {
//        let productType = productType.
        let data = PointLog()
//        data.productType =
//        delegate?.didAddData(data: , date: date)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

