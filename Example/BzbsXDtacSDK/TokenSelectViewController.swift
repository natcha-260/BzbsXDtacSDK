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
    @IBOutlet weak var txtCatName: UITextField!
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
    
    let dtacAppVersion = "9.0.1"
    
    var isChangeUser = false
    
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
        
        if let campaignId = UserDefaults.standard.value(forKey: "campaignId") as? String, campaignId != ""
        {
            txtCampaignId.text = campaignId
        } else {
            txtCampaignId.text = "573114"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        Bzbs.shared.isDebugLog = true
        isChangeUser = true
        
        resetBtn()
        token = nil
        ticket = nil
    }
    
    @IBAction func didChangeTelType(_ sender: Any) {
        TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
        isChangeUser = true
    }
    
    @IBAction func clickShowCampaignDetail(_ sender: Any) {
        self.view.endEditing(true)
        guard  let nav = self.navigationController else { return }
        guard let txtId = txtCampaignId.text, txtId != "" else { return }
        
        if isChangeUser {
            guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
            TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
            Bzbs.shared.logout()
            isChangeUser = false
            UserDefaults.standard.set(txtId, forKey: "campaignId")
            if let nav = self.navigationController
            {
                delay(0.5) {
                    DispatchQueue.main.async {
                        Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                        nav.pushViewController(CampaignDetailViewController.getView(campaignId: txtId), animated: true)
                    }
                }
            }
        } else {
            nav.pushViewController(CampaignDetailViewController.getView(campaignId: txtId), animated: true)
        }
    }
    
    @IBAction func clickShowPointHistory(_ sender: Any) {
        self.view.endEditing(true)
        guard  let nav = self.navigationController else { return }
        
        if isChangeUser {
            guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
            TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
            Bzbs.shared.logout()
            isChangeUser = false
            delay(0.5) {
                DispatchQueue.main.async {
                    Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                    nav.pushViewController(PointHistoryViewController.getView(), animated: true)
                }
            }
        } else {
            nav.pushViewController(PointHistoryViewController.getView(), animated: true)
        }
    }
    
    @IBAction func clickGotoFavorite(_ sender: Any) {
        self.view.endEditing(true)
        guard  let nav = self.navigationController else { return }
        
        if isChangeUser {
            guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
            TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
            Bzbs.shared.logout()
            isChangeUser = false
            delay(0.5) {
                DispatchQueue.main.async {
                    Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                    nav.pushViewController(FavoriteViewController.getViewController(), animated: true)
                }
            }
        } else {
            nav.pushViewController(FavoriteViewController.getViewController(), animated: true)
        }
    }
    
    @IBAction func clickGotoCategory(_ sender: Any) {
        guard  let nav = self.navigationController else { return }
        
        if let tmpCat = txtCatName.text {
            let rawCat = tmpCat.split(separator: ",")
            let catName = String(rawCat.first ?? "")
            var subCatName:String?
            if rawCat.count > 1 {
                subCatName = String(rawCat[1])
            }
            if isChangeUser {
                guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
                TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
                Bzbs.shared.logout()
                isChangeUser = false
                delay(0.5) {
                    DispatchQueue.main.async {
                        Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                        nav.pushViewController(CampaignByCatViewController.getView(category: catName, subCategory: subCatName), animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    nav.pushViewController(CampaignByCatViewController.getView(category: catName, subCategory: subCatName), animated: true)
                }
            }
        }
    }
    
    @IBAction func clickGoToMain(_ sender: Any) {
        view.endEditing(true)
        if isChangeUser {
            guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
            TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
            Bzbs.shared.logout()
            isChangeUser = false
            delay(0.5) {
                DispatchQueue.main.async {
                    Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                    self.gotoMain()
                }
            }
        } else {
            self.gotoMain()
        }
    }
    
    @IBAction func clickGoToMainWithBack(_ sender: Any) {
        view.endEditing(true)
        if isChangeUser {
            guard let _ = self.token, let _ = self.ticket, let _ = self.segment else {return}
            TelType = segmentTelType.selectedSegmentIndex == 0 ? "P" : "T"
            Bzbs.shared.logout()
            isChangeUser = false
            delay(0.5) {
                DispatchQueue.main.async {
                    Bzbs.shared.setup(token: self.token!, ticket: self.ticket!, language: self.language, DTACSegment: self.segment!, TelType: self.TelType, appVersion: self.dtacAppVersion)
                    self.gotoMainWithBack()
                }
            }
        } else {
            self.gotoMainWithBack()
        }
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        resetBtn()
        Bzbs.shared.logout()
        isChangeUser = true
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        Bzbs.shared.setup(token: token!, ticket: ticket!, language: language, DTACSegment: segment!, TelType: TelType, appVersion: dtacAppVersion)
    }
    
    @IBAction func clickNoToken(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "Jfoex0iU8URI86Ly3d7Yt2w3z2e3D81j7b5H72kK9wwlBpq0We72xFZidFYY4G2GTvXEBZKxacU="
            ticket = "FgM9fHbSOF7apRtVTFcSVwFtTZl1U9o1xlJgIATH54LL2mFtwoYu93sBO/M="
        }
        
        if isPrd {
            token = "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc="
            ticket = "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU="
        }
        segment = "0000"
        token = ""
        ticket = ""
        segment = ""
        isChangeUser = true
    }
    
    @IBAction func clickCustomer(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxqPRR5G8XlhiHA+65JbklZ9kGj7dmo5XyY="
            ticket = "1QF39OSA+F19HcQDU3JwhQWeznT0vF7VnBrIj1HoWclwa9RZ6VZPiEXNolM="
            
//            token = "auB55gmxyG5qNny65t2HVj9gU8w9MvQYocfqExQ9ILYQgqO+5A0TCS1BAYI0wOUWqV+coBAgDbs="
//            ticket = "rAF4+rR7SF8rgDwzX+/yvNkdQVoSua0RYbZznjeI2gg2S8RFAE4IVo8CY2o="
        }
        
        if isPrd {
            token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxoH1KiSmJ6WvfESsSSBNfz94XtJABzCNG4="
            ticket = "AgN3VXKvpl2a9BVRZgx8SpkaLjWQuKc7h/nMZAJdoGaE4MKLPAvJPPVMU5c="
        }
        
        segment = "4000"
        isChangeUser = true
        //        gotoMain()
    }
    
    @IBAction func clickSilver(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "6SjkaciPnsVcxjSQsgJJ3jaKF48+uteT37l/Rhh01xxg8zlK5dP1hB7HQRkLZ+3aHEqDusyKx28="
            ticket = "iwKES6Dn4l9IanWO5ICqFt6RJNUNYgz8+YTGbT86gHziI/2u4ysATb4WzdI="
        }
        
        if isPrd {
            token = "ecTRUtHv6HxkdJJ4h2KpOs1vGEd8NPmy95FUzj7RpzqwhNGkzRBJi7Z3/Z0MxnOEj7hyj2ovEG4="
            ticket = "zABxi7c6310ZoxU8etbjI84fOsNBp3tCku3aNKb8TdryP93K54b0jLVCghw="
        }
        
        segment = "3000"
        isChangeUser = true
    }
    
    @IBAction func clickGold(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ9g8zlK5dP1hMOxWSS5czz2anEnkpfnKJs="
            ticket = "RQJOAlC1El69TXrhg0xyIS7uvhL4Euy/nKuzyfwMzu9Vb9es7Q7vAGw1cgA="
        }
        
        if isPrd {
            token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ8H1KiSmJ6WvfESsSSBNfz9ELcMZ6lm4hY="
            ticket = "IQEcGD5nrV1bwWvTVzaoYAEnRbw0aPwTVLzIZQ3jZlTiZ6qxDfojfAw0RNs="
        }
        segment = "2000"
        isChangeUser = true
    }
    
    @IBAction func clickBlueMember(_ sender: Any) {
        view.endEditing(true)
        resetBtn()
        (sender as! UIButton).isSelected = true
        
        if isDev || isStg {
            
            token = "Z9unF9axmM0f+socL4lG8BtMNQOA28Kr4sjlQ9yiYx2PRR5G8XlhiHA+65JbklZ9avsy2/TdrI8="
            ticket = "WAPJ9liA+F0XhSdWw0nvkDNVS+xtGOpSFevxSYmZELtuXruXsGf1SgKsOQQ="
            
//            token = "x6RFt1Fb/8w19ZhR2aISNG9Q7PA7CAkXJAHLbuCy2h2boxk6dSqZdsAoDgBlOv6h1k0gXHEWq4k="
//            ticket = "DAMiifVb4F9I9S/W7OohE7Nz6wwD9i0Lwu3z5g/3N683rmlZMuAjFzQDBr8="
//            segment = "1000"
        }
        
        if isPrd {
            
//            token = "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc="
//            ticket = "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU="
//
            //เบอร์ Production -------- dtacId : cd0e30fc90eea2856055d1119c4e9511 -----------
//            token = "om4KPcpdtLskR40YrbQmboJSvCCqSgk908fDJBmKg1XGZbE0djiOprnHSuLRltgsdEi05NIY8iU="
//            ticket = "rABKI6lBkV+auzNXGrCACkH97R8ZMAAnd6ie2fUoknM+A8g+ZAXLJvbWQ2E="
            // -----------------------------------------------------------------------------
            
//            // Android 15012021 --- DTW_e2f352dae54f5751b88674f5ac7eac16
//            token = "Z9unF9axmM0f+socL4lG8BtMNQOA28Kr4sjlQ9yiYx2PRR5G8XlhiHA+65JbklZ9avsy2/TdrI8="
//            ticket = "WAPJ9liA+F0XhSdWw0nvkDNVS+xtGOpSFevxSYmZELtuXruXsGf1SgKsOQQ="
            
//            // Dtac 19012021
//            token = "IfGdWXyuVnaFblTRM2REHWIuc1AvzmoONcN7Ctjr8xMs6VUjbNYcFqkFn9suCogkNS4G7b2viOY="
//            ticket = "JAE3bLZRBmCUBjh3Ya6097FraUod3djjyG68QToxT/RvQoNRiKgdvk1HD00="

            token = "9a3WHd0Q2nBpAEaY3OT5YWhiQmgjLsB0mEKA3OAOJAjdIzIQgkgjdhIl4+0T2bzzXelUU+pW3fU="
            ticket = "cwKNgRz9KWD3knMwxdv6PbpT2Q8IOFai11Sh8nKRIF4B9186UZGbUwpGXHg="
        }
        segment = "1000"
        isChangeUser = true
        
    }
    
    func gotoMain()
    {
        tabBarController?.selectedIndex = 2
    }
    
    func gotoMainWithBack()
    {
        if let nav = self.navigationController {
            nav.pushViewController(BzbsMainViewController.getView(), animated: true)
        }
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
