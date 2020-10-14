//
//  LineStickerRedeemViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 6/10/2563 BE.
//

import UIKit

class LineStickerRedeemViewController: BzbsXDtacBaseViewController {
    
    //MARK:- Properties
    //MARK:- Outlet
    @IBOutlet weak var lblYouChoose: UILabel!
    @IBOutlet weak var imvSticker: UIImageView!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPointUse: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblMobileTitle: UILabel!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var lblMobileInfo: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var imvTerm: UIImageView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    @IBOutlet weak var vwBtn: UIView!
    
    //MARK:- Variable
    var campaignId : String!
    var packageId : String!
    var lineCampaign : LineStickerCampaign!
    var bzbsCampaign : BzbsCampaign!
    var isCheckTerm = false
    
    //MARK:- View life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        lblYouChoose.font = UIFont.mainFont()
        lblAgency.font = UIFont.mainFont()
        lblName.font = UIFont.mainFont()
        lblPointUse.font = UIFont.mainFont()
        lblPoints.font = UIFont.mainFont()
        lblMobileTitle.font = UIFont.mainFont()
        lblMobileInfo.font = UIFont.mainFont()
        txtMobile.font = UIFont.mainFont()
        lblTerm.font = UIFont.mainFont()
        lblContinue.font = UIFont.mainFont()
        
        lblAgency.textColor = .gray
        lblMobileInfo.textColor = .gray
        
        lblYouChoose.text = "line_redeem_you_choose".localized()
        lblAgency.text = "Agency"
        lblName.text = lineCampaign.stickerTitle
        lblPointUse.text = "line_redeem_point_use".localized()
        lblPoints.text = bzbsCampaign.pointPerUnit!.withCommas() + " Coins"
        lblMobileTitle.text = "line_redeem_mobile_title".localized()
        txtMobile.placeholder = "08X-XXX-XXXX"
        lblMobileInfo.text = "line_redeem_mobile_info".localized()
        lblTerm.text = "line_redeem_term".localized()
        lblContinue.text = "line_redeem_continue".localized()
        imvSticker.bzbsSetImage(withURL: lineCampaign.logoUrl ?? "")
        
        imvTerm.tintColor = .lineGreen
        self.view.backgroundColor = .lineBG
        initNav()
        
        imvTerm.image = UIImage(named: "checkbox_inactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        updateButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification :)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func initNav() {
        super.initNav()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont(.big, style: .bold)
        lblTitle.textColor = .white
        lblTitle.numberOfLines = 0
        lblTitle.text = "line_detail_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step), isWhiteIcon: true)
        self.navigationController?.navigationBar.tintColor = .lineNav
        self.navigationController?.navigationBar.backgroundColor = .lineNav
        self.navigationController?.navigationBar.barTintColor = .lineNav
    }
    
    
    // MARK:- Notification
    // MARK:- Resign Keyboard
    @objc func keyboardWillShow(notification: NSNotification)
    {
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue ?? 0.33
        
        UIView.animate(withDuration: keyboardDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            if let heightKeyBoard = keyboardFrame?.size.height
            {
                self.cstBottom.constant = heightKeyBoard
            }
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        // Expanding size of table
        //        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        UIView.animate(withDuration: keyboardDuration!, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.cstBottom.constant = 0
            self.view.layoutIfNeeded()
        }, completion:  { (finished: Bool) in
        })
    }
    
    
    //MARK:- Event
    //MARK:-
    @IBAction func clickView(_ sender: Any) {
        self.view.endEditing(true)
        updateButton()
    }
    
    @IBAction func clickTerm(_ sender: Any) {
        isCheckTerm.toggle()
        imvTerm.image = isCheckTerm
            ? UIImage(named: "checkbox_active", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            : UIImage(named: "checkbox_inactive", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        updateButton()
    }
    
    @IBAction func clickContinue(_ sender: Any) {
        if validate() {
            apiValidateLineSticker()
        }
    }
    
    func apiValidateLineSticker() {
        guard let token = Bzbs.shared.userLogin?.token,
              let contactNumber = txtMobile.text
              else {
            return
        }
        showLoader()
        BzbsCoreApi().getValidateLineSticker(token: token, campaignId: campaignId, packageId: packageId, contactNumber: contactNumber) { (dict) in
            self.hideLoader()
            if let refId = dict["refID"] as? String {
                PopupManager.lineConfirmPopup(onView: self, strContactNumber: contactNumber, campaign: self.lineCampaign) {
                    self.apiRedeemLineSticker(refId)
                } cancel: {
                    
                }

            }
        } failCallback: { (error) in
            self.hideLoader()
            print(error.description())
            PopupManager.lineErrorPopup(onView: self, strMessage: "line_error_msg_not_found".localized(), strInfo: "line_error_msg_not_found_info".localized())
        }
    }
    
    func apiRedeemLineSticker(_ refID:String){
        guard let token = Bzbs.shared.userLogin?.token,
              let contactNumber = txtMobile.text
              else {
            return
        }
        showLoader()
        BzbsCoreApi().getRedeemLineSticker(token: token, refId: refID, campaignId: campaignId, packageId: packageId, contactNumber: contactNumber) { (_) in
            self.hideLoader()
            GotoPage.gotoLineHistory(self.navigationController!, campaign: self.lineCampaign) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        } failCallback: { (error) in
            self.hideLoader()
            print(error.description())
            PopupManager.lineErrorPopup(onView: self, strMessage: "line_error_msg_not_found".localized(), strInfo: "line_error_msg_not_found_info".localized())
        }
    }
    
    func validate() -> Bool {
        if !isCheckTerm { return false}
        guard let mobile = txtMobile.text else { return false }
        if let first = mobile.first, first != "0" { return false}
        if mobile.count < 10 { return false }
        return true
    }

    func updateButton() {
        vwBtn.backgroundColor = validate() ? .lineGreen : .gray
    }
    
}

extension LineStickerRedeemViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateButton()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let intNewLength = textField.text!.length - range.length + string.length
        
        if txtMobile == textField {
            
            // check first text
            if textField.text!.count == 0 && string != "0" {
                return false
            }
            
            if intNewLength > 10 { return false }
            if intNewLength == 10 {
                Bzbs.shared.delay(0.2) {
                    DispatchQueue.main.async {
                        self.view.endEditing(true)
                    }
                }
                return true
            }
        }
        
        return true
    }
}
