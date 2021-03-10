//
//  LineHistoryViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 14/10/2563 BE.
//

import UIKit
import FirebaseAnalytics

class LineHistoryViewController: BzbsXDtacBaseViewController {

    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblLineName: UILabel!
    @IBOutlet weak var vwBtnDownload: UIView!
    @IBOutlet weak var lblBtnDownload: UILabel!
    @IBOutlet weak var lblBack: UILabel!
    
    // MARK:- Variable
    var isFromHistory:Bool!
    var lineCampaign:LineStickerCampaign!
    var bzbsCampaign:BzbsCampaign!
    var contactNumber:String!
    var packageId:String!
    var isNavHidden = false
    var backSelector:(() -> Void)?
    
    // MARK:- View Life cycle
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsSetScreen(screenName: "reward_detail")
        
        view.backgroundColor = .lineBG
        lblTitle.font = UIFont.mainFont(.big)
        lblInfo.font = UIFont.mainFont(.big)
        lblLineName.font = UIFont.mainFont()
        lblBtnDownload.font = UIFont.mainFont(style:.bold)
        lblBack.font = UIFont.mainFont(style:.bold)
        
        lblTitle.textColor = .lineGreen
        lblLineName.textColor = .gray
        lblBtnDownload.textColor = .white
        lblBack.textColor = .lineGreen
        
        vwBtnDownload.backgroundColor = .lineGreen
        
        lblTitle.text = "line_history_redeem_success".localized()
        lblInfo.text = String(format: "line_history_info_format".localized(), contactNumber.getContactFormat())
        lblLineName.text = lineCampaign.stickerTitle
        lblBtnDownload.text = "line_history_download_now".localized()
        lblBack.text = isFromHistory ? "line_history_back".localized() : "line_history_back_to_campaign".localized()
        
        isNavHidden = self.navigationController?.navigationBar.isHidden ?? false
        self.navigationController?.navigationBar.isHidden = true
        
        imv.bzbsSetImage(withURL: lineCampaign.logoUrl ?? "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = isNavHidden
    }
    
    override func updateUI() {
        super.updateUI()
        lblTitle.text = "line_history_redeem_success".localized()
        lblInfo.text = String(format: "line_history_info_format".localized(), contactNumber.getContactFormat())
        lblLineName.text = lineCampaign.stickerTitle
        lblBtnDownload.text = "line_history_download_now".localized()
        lblBack.text = "line_history_back".localized()
    }
    
    // MARK:- Event
    // MARK:- Click
    @IBAction func clickDownload(_ sender: Any) {
        sendGADownload()
        let strUrl = "https://line.me/R/shop/sticker/detail/\(packageId!)"
        guard let url = URL(string: strUrl) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func clickBack(_ sender: Any) {
        if backSelector != nil {
            backSelector?()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- GA
    // FIXME:GA#47
    func sendGADownload() {
        Bzbs.shared.delegate?.analyticsEvent(event: "event_app", category: "reward", action: "touch_button", label: "download_line_sticker | \(bzbsCampaign.ID ?? 0) | \(bzbsCampaign.pointPerUnit ?? 0)")
    }
}
