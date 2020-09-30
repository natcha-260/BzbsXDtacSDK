//
//  TokenSelectViewController.swift
//  
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import UIKit
import BzbsXDtacSDK

class TokenSelectViewController: UIViewController {
    
    // MARK:- Properties
    // MARK:- Outlet

    @IBOutlet weak var segmentLang: UISegmentedControl!
    @IBOutlet weak var lblEnv: UILabel!
    
    @IBOutlet weak var btnNoLevel: UIButton!
    @IBOutlet weak var btnCustomer: UIButton!
    @IBOutlet weak var btnSilver: UIButton!
    @IBOutlet weak var btnGold: UIButton!
    @IBOutlet weak var btnBlue: UIButton!
    @IBOutlet weak var txtCampaignId: UITextField!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    @IBOutlet weak var segmentTelType: UISegmentedControl!
    @IBOutlet weak var segmentVersion: UISegmentedControl! {
        didSet{
            segmentVersion.removeAllSegments()
            for i in 0..<versionList.count {
                let title = versionList[i]
                segmentVersion.insertSegment(withTitle: title, at: i, animated: true)
            }
        }
    }
    
    // MARK:- Variable
    var isDev:Bool {
        return strVersion == "2.0.1"
    }
    var isStg:Bool {
        return strVersion == "1.0.2" || strVersion == "2.0.2"
    }
    var isPrd:Bool {
        return !(isStg || isDev)
    }
    var language:String{
        return segmentLang.selectedSegmentIndex == 0 ? "en" : "th"
    }
    var versionList = ["1.0.3", "1.0.2" ,"2.0.3","2.0.2","2.0.1"]
    //  0.0.3 = PRD. DtacApp:9.0.1
    //  0.0.4 = PRD. DtacApp:9.0.2
    //  1.0.3 = PRD.
    //  1.0.2 = STG.
    //  1.0.1 = DEV.
    // 20200810
    
    var strVersion:String {
        segmentVersion.titleForSegment(at: segmentVersion.selectedSegmentIndex) ?? versionList.first!
    }
    
    var TelType = "T" // T = Postpaid , P = Prepaid
    
    var ticket :String?
    var token :String?
    var langauge :String?
    var segment :String?

    // MARK:- View life cycle
    // MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        segmentVersion.selectedSegmentIndex = 3
        didChangeVersion(segmentVersion)
        lblEnv.textColor = .black

        if let campaignId = UserDefaults.standard.value(forKey: "campaignId") as? String
        {
            txtCampaignId.text = campaignId
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- Keyboard
    @objc func keyboardWillShow(_ notification: Notification)
    {
        let keyboardSize = ((notification.userInfo! as NSDictionary).object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as AnyObject).cgRectValue.size
        
        UIView.animate(withDuration: 0.33) {
            self.cstBottom.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.33) {
            self.cstBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func clickView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func resetBtn()
    {
        btnNoLevel.isSelected = false
        btnCustomer.isSelected = false
        btnSilver.isSelected = false
        btnGold.isSelected = false
        btnBlue.isSelected = false
        
    }
    
    @IBAction func didChangeVersion(_ sender: UISegmentedControl) {
        var strLabel = ""
        if isDev {
            strLabel = "DEV : "
        } else if isStg {
            strLabel = "STG : "
        } else if isPrd {
            strLabel = "PRD : "
        }
        strLabel = strLabel + strVersion
        lblEnv.text = strLabel
        Bzbs.shared.versionString = strVersion
        Bzbs.shared.isDebugMode = !isPrd
    }
    
    @IBAction func didChangeTelType(_ sender: Any) {
        TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
    }
    
    @IBAction func clickShowCampaignDetail(_ sender: Any) {
        self.view.endEditing(true)
        guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
        TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
        Bzbs.shared.logout()
        if let txtId = txtCampaignId.text, txtId != ""
        {
            UserDefaults.standard.set(txtId, forKey: "campaignId")
            if let nav = self.navigationController
            {
                delay(0.5) {
                    DispatchQueue.main.async {
                        Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType)
                        nav.pushViewController(CampaignDetailViewController.getView(campaignId: txtId), animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func clickShowPointHistory(_ sender: Any) {
        self.view.endEditing(true)
        guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
        TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
        Bzbs.shared.logout()
        if let nav = self.navigationController
        {
            delay(0.5) {
                DispatchQueue.main.async {
                    Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType)
                    nav.pushViewController(PointHistoryViewController.getView(), animated: true)
                }
            }
        }
    }
    
    @IBAction func clickGoToMain(_ sender: Any) {
        view.endEditing(true)
        guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
        TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
        Bzbs.shared.logout()
        delay(0.5) {
            DispatchQueue.main.async {
                Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType)
                self.gotoMain()
            }
        }
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        resetBtn()
        Bzbs.shared.logout()
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        Bzbs.shared.setup(token: token!, ticket: ticket!, language: language, DTACSegment: segment!, TelType: TelType)
    }
    
    @IBAction func clickNoToken(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "Jfoex0iU8URI86Ly3d7Yt2w3z2e3D81j7b5H72kK9wwlBpq0We72xFZidFYY4G2GTvXEBZKxacU="
            ticket = "FgM9fHbSOF7apRtVTFcSVwFtTZl1U9o1xlJgIATH54LL2mFtwoYu93sBO/M="
            segment = "0000"
        }
        
        if isPrd {
            token = "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc="
            ticket = "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU="
            segment = "0000"
        }
    }
    
    @IBAction func clickCustomer(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev {
            token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxqPRR5G8XlhiHA+65JbklZ9kGj7dmo5XyY="
            ticket = "1QF39OSA+F19HcQDU3JwhQWeznT0vF7VnBrIj1HoWclwa9RZ6VZPiEXNolM="
            segment = "4000"
        }
        
        if isStg {
            token = "auB55gmxyG5qNny65t2HVj9gU8w9MvQYocfqExQ9ILYQgqO+5A0TCS1BAYI0wOUWqV+coBAgDbs="
            ticket = "rAF4+rR7SF8rgDwzX+/yvNkdQVoSua0RYbZznjeI2gg2S8RFAE4IVo8CY2o="
            segment = "4000"
        }
        
        if isPrd {
            token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxoH1KiSmJ6WvfESsSSBNfz94XtJABzCNG4="
            ticket = "AgN3VXKvpl2a9BVRZgx8SpkaLjWQuKc7h/nMZAJdoGaE4MKLPAvJPPVMU5c="
            segment = "4000"
        }
//        gotoMain()
    }
    
    @IBAction func clickSilver(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "6SjkaciPnsVcxjSQsgJJ3jaKF48+uteT37l/Rhh01xxg8zlK5dP1hB7HQRkLZ+3aHEqDusyKx28="
            ticket = "1QKNrsS2El4Eu5PDEIVs/1boJiOWTyH1ZC3EOZiXtI5KlD7uFRpm55srYSY="
            segment = "3000"
        }
        
        if isPrd {
            token = "ecTRUtHv6HxkdJJ4h2KpOs1vGEd8NPmy95FUzj7RpzqwhNGkzRBJi7Z3/Z0MxnOEj7hyj2ovEG4="
            ticket = "zABxi7c6310ZoxU8etbjI84fOsNBp3tCku3aNKb8TdryP93K54b0jLVCghw="
            segment = "3000"
        }
    }
    
    @IBAction func clickGold(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ9g8zlK5dP1hMOxWSS5czz2anEnkpfnKJs="
            ticket = "RQJOAlC1El69TXrhg0xyIS7uvhL4Euy/nKuzyfwMzu9Vb9es7Q7vAGw1cgA="
            segment = "2000"
        }
        
        if isPrd {
            token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ8H1KiSmJ6WvfESsSSBNfz9ELcMZ6lm4hY="
            ticket = "IQEcGD5nrV1bwWvTVzaoYAEnRbw0aPwTVLzIZQ3jZlTiZ6qxDfojfAw0RNs="
            segment = "2000"
        }
    }
    
    @IBAction func clickBlueMember(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "Z9unF9axmM0f+socL4lG8BtMNQOA28Kr4sjlQ9yiYx2PRR5G8XlhiHA+65JbklZ9avsy2/TdrI8="
            ticket = "WAPJ9liA+F0XhSdWw0nvkDNVS+xtGOpSFevxSYmZELtuXruXsGf1SgKsOQQ="
            segment = "1000"
        }
        
        if isPrd {
            token = "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc="
            ticket = "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU="
            segment = "1000"
        }
        
    }
    
    func gotoMain()
    {
        tabBarController?.selectedIndex = 2
    }
    
    
    // MARK:- Util
    // MARK:-
    func delay(_ afterDelay: Double = 0.01, callBack: @escaping () -> Void)
    {
        let delay = afterDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            callBack()
        })
    }
}

extension TokenSelectViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
