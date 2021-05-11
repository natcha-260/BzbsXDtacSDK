//
//  PopupSubscriptionViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2563 BE.
//

import UIKit

class PopupSubscriptionViewController: UIViewController {
    
    @IBOutlet weak var lblThankyou: UILabel!
    @IBOutlet weak var vwProduct: UIView!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblClose: UILabel!
    
    var history : BzbsHistory!
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.locale = LocaleCore.shared.getLocaleAndCalendar().locale
        formatter.calendar = LocaleCore.shared.getLocaleAndCalendar().calendar
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm, dd MMM yyyy"
        lblThankyou.font = UIFont.mainFont(.big, style: .bold)
        lblProduct.font = UIFont.mainFont(style: .bold)
        lblDate.font = UIFont.mainFont(style: .bold)
        lblProductName.font = UIFont.mainFont(style: .bold)
        lblClose.font = UIFont.mainFont(style: .bold)
        
        lblThankyou.textColor = .white
        lblDate.textColor = .lightGray
        
        vwProduct.backgroundColor = .mainBlueSubscription
        vwClose.backgroundColor = .dtacBlue
        vwClose.cornerRadius()
        
        Bzbs.shared.delegate?.analyticsScreen(screenName: "reward_detail")
        setupUI()
    }
    
    func setupUI() {
        
        lblThankyou.text = "popup_voice_net_thank_you".localized()
        lblProduct.text = "popup_voice_net_detail".localized()
        var date = Date()
        if let period = history.redeemDate
        {
            date = Date(timeIntervalSince1970: period)
        }
        formatter.dateFormat = "HH:mm, d MMM yyyy"
        
        lblDate.text = formatter.string(from: date)
        lblProductName.text = history.name
        lblClose.text = "popup_done".localized()
        
    }
    
    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
