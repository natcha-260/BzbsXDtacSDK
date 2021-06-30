//
//  NewTokenSelectViewController.swift
//  BzbsXDtacSDK_Example
//
//  Created by Natcha Arunchay on 20/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import BzbsXDtacSDK

class NewTokenSelectViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    
    var isShowBzbsPicker = false
    var isShowDtacPicker = false
    
    var lblBzbs: UILabel?
    
    var bzbsSegment: UISegmentedControl?
    
    var bzbsVersionList = [("2.0.3","prd"),("2.0.2","stg"),("2.0.1","dev")]
    
    var bzbsVersion :(String,String)?
    var dtacVersion :String = "9.0.3"
    
    var lang = Language.tha{
        didSet {
            
        }
    }
    var langSegment: UISegmentedControl?
    var level = DtacLevel.blue
    var levelSegment: UISegmentedControl?
    var userType = UserType.pre
    
    var txtCampaign: UITextField?
    var txtCategory: UITextField?
    var txtDtacVersion: UITextField?
    
    let cellList = ["usertype","bzbsversion","dtacversion","lang","level","actions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bzbsVersion = bzbsVersionList[1]
        if let str = UserDefaults.standard.string(forKey: "dtacAppVersion") {
            dtacVersion = str
        }
        
        tableView.reloadData()
        
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
    
    
    func gotoMain()
    {
        tabBarController?.selectedIndex = 2
    }
    
    func delay(_ afterDelay: Double = 0.01, callBack: @escaping () -> Void)
    {
        let delay = afterDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            callBack()
        })
    }
    
    func getTicketToken() -> (ticket:String, token:String){
        var ticket = ""
        var token = ""
        if level == .none {
            if bzbsVersion?.1 == "prd" {
                token = "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc="
                ticket = "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU="
            } else {
                token = "Jfoex0iU8URI86Ly3d7Yt2w3z2e3D81j7b5H72kK9wwlBpq0We72xFZidFYY4G2GTvXEBZKxacU="
                ticket = "FgM9fHbSOF7apRtVTFcSVwFtTZl1U9o1xlJgIATH54LL2mFtwoYu93sBO/M="
            }
        }
        else if level == .customer {
            if bzbsVersion?.1 == "prd" {
                token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxoH1KiSmJ6WvfESsSSBNfz94XtJABzCNG4="
                ticket = "AgN3VXKvpl2a9BVRZgx8SpkaLjWQuKc7h/nMZAJdoGaE4MKLPAvJPPVMU5c="
            } else {
                token = "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxqPRR5G8XlhiHA+65JbklZ9kGj7dmo5XyY="
                ticket = "1QF39OSA+F19HcQDU3JwhQWeznT0vF7VnBrIj1HoWclwa9RZ6VZPiEXNolM="
                
                //            token = "auB55gmxyG5qNny65t2HVj9gU8w9MvQYocfqExQ9ILYQgqO+5A0TCS1BAYI0wOUWqV+coBAgDbs="
                //            ticket = "rAF4+rR7SF8rgDwzX+/yvNkdQVoSua0RYbZznjeI2gg2S8RFAE4IVo8CY2o="
            }
        }
        else if level == .silver {
            if bzbsVersion?.1 == "prd" {
                token = "ecTRUtHv6HxkdJJ4h2KpOs1vGEd8NPmy95FUzj7RpzqwhNGkzRBJi7Z3/Z0MxnOEj7hyj2ovEG4="
                ticket = "zABxi7c6310ZoxU8etbjI84fOsNBp3tCku3aNKb8TdryP93K54b0jLVCghw="
            } else {
                token = "6SjkaciPnsVcxjSQsgJJ3jaKF48+uteT37l/Rhh01xxg8zlK5dP1hB7HQRkLZ+3aHEqDusyKx28="
                ticket = "iwKES6Dn4l9IanWO5ICqFt6RJNUNYgz8+YTGbT86gHziI/2u4ysATb4WzdI="
            }
        }
        else if level == .gold {
            
            if bzbsVersion?.1 == "prd" {
                token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ8H1KiSmJ6WvfESsSSBNfz9ELcMZ6lm4hY="
                ticket = "IQEcGD5nrV1bwWvTVzaoYAEnRbw0aPwTVLzIZQ3jZlTiZ6qxDfojfAw0RNs="
            } else {
                token = "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ9g8zlK5dP1hMOxWSS5czz2anEnkpfnKJs="
                ticket = "RQJOAlC1El69TXrhg0xyIS7uvhL4Euy/nKuzyfwMzu9Vb9es7Q7vAGw1cgA="
            }
        }
        else if level == .blue {
            if bzbsVersion?.1 == "prd" {
                
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
            } else {
                token = "Z9unF9axmM0f+socL4lG8BtMNQOA28Kr4sjlQ9yiYx2PRR5G8XlhiHA+65JbklZ9avsy2/TdrI8="
                ticket = "WAPJ9liA+F0XhSdWw0nvkDNVS+xtGOpSFevxSYmZELtuXruXsGf1SgKsOQQ="
                
                //            token = "x6RFt1Fb/8w19ZhR2aISNG9Q7PA7CAkXJAHLbuCy2h2boxk6dSqZdsAoDgBlOv6h1k0gXHEWq4k="
                //            ticket = "DAMiifVb4F9I9S/W7OohE7Nz6wwD9i0Lwu3z5g/3N683rmlZMuAjFzQDBr8="
                //            segment = "1000"
            }
            
        }
        return (ticket,token)
    }
    
    @IBAction func didSelectLanguage(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            lang = .tha
        } else if sender.selectedSegmentIndex == 1 {
            lang = .eng
        } else if sender.selectedSegmentIndex == 2 {
            lang = .mm
        }
    }
    
    @IBAction func didSelectLevel(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            level = .blue
            break
        case 1:
            level = .gold
            break
        case 2:
            level = .silver
            break
        case 3:
            level = .customer
            break
        case 4:
            level = .none
            break
        default:
            level = .none
        }
    }
    
    @IBAction func didSelectUserType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            userType = .pre
        } else {
            userType = .post
        }
    }
    
    @IBAction func didSelectBzbsVersion(_ sender: UISegmentedControl) {
        bzbsVersion = bzbsVersionList[sender.selectedSegmentIndex]
        lblBzbs?.text = "\(bzbsVersion!.0) : \(bzbsVersion!.1)"
    }
    
    @IBAction func clickShowCampaignDetail(_ sender: Any) {
        guard let nav = self.navigationController else { return }
        guard let txtId = txtCampaign?.text, !txtId.isEmpty else { return }
        UserDefaults.standard.set(txtId, forKey: "campaignId")
        setupSDK {
            nav.pushViewController(CampaignDetailViewController.getView(campaignId: txtId), animated: true)
        }
    }
    
    @IBAction func clickShowPointHistory(_ sender: Any) {
        guard let nav = self.navigationController else { return }
        setupSDK {
            nav.pushViewController(PointHistoryViewController.getView(), animated: true)
        }
    }
    
    @IBAction func clickGotoFavorite(_ sender: Any) {
        guard let nav = self.navigationController else { return }
        setupSDK {
            nav.pushViewController(FavoriteViewController.getViewController(), animated: true)
        }
    }
    
    @IBAction func clickGotoCategory(_ sender: Any) {
        guard let nav = self.navigationController else { return }
        if let tmpCat = txtCategory?.text {
            UserDefaults.standard.set(tmpCat, forKey: "categoryIds")
            let rawCat = tmpCat.split(separator: ",")
            let catName = String(rawCat.first ?? "")
            var subCatName:String?
            if rawCat.count > 1 {
                subCatName = String(rawCat[1])
            }
            setupSDK {
                nav.pushViewController(CampaignByCatViewController.getView(category: catName, subCategory: subCatName), animated: true)
            }
        }
    }
    
    @IBAction func clickGoToMain(_ sender: Any) {
        setupSDK {
            self.gotoMain()
        }
    }
    
    func setupSDK(successHandler:@escaping () -> Void)
    {
        view.endEditing(true)
        Bzbs.shared.versionString = bzbsVersion!.0
        Bzbs.shared.isDebugLog = true
        let token = getTicketToken().token
        let ticket = getTicketToken().ticket
        let segment = level.rawValue
        let telType = userType.rawValue
        let language = lang.rawValue
        let dtacAppVersion = dtacVersion
        UserDefaults.standard.set(dtacAppVersion, forKey: "dtacAppVersion")
        Bzbs.shared.logout()
        delay(0.5) {
            DispatchQueue.main.async {
                Bzbs.shared.setup(token: token, ticket: ticket, language: language, DTACSegment: segment, TelType: telType, appVersion: dtacAppVersion)
                successHandler()
            }
        }
    }
    
    @IBAction func clickGoToMainWithBack(_ sender: Any) {
        guard  let nav = self.navigationController else { return }
        setupSDK {
            nav.pushViewController(BzbsMainViewController.getView(), animated: true)
        }
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        Bzbs.shared.logout()
    }
    
    @IBAction func clickLogin(_ sender: Any) {
    }
}

extension NewTokenSelectViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let cellIdent = cellList[row]
        
        if cellIdent == "usertype" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "usertypeCell", for: indexPath)
            return cell
        }
        
        if cellIdent == "bzbsversion" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bzbsVersionCell", for: indexPath)
            lblBzbs = cell.viewWithTag(10) as? UILabel
            lblBzbs?.text = "\(bzbsVersionList[row].0) : \(bzbsVersionList[row].1)"
            let segment = cell.viewWithTag(20) as? UISegmentedControl
            if bzbsSegment != segment {
                bzbsSegment = segment
                bzbsSegment?.removeAllSegments()
                for version in bzbsVersionList.reversed() {
                    bzbsSegment?.insertSegment(withTitle: version.0, at: 0, animated: false)
                }
                bzbsSegment?.selectedSegmentIndex = 1
            }
            return cell
        }
        
        if cellIdent == "dtacversion" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dtacVersionCell", for: indexPath)
            txtDtacVersion = cell.viewWithTag(20) as? UITextField
            txtDtacVersion?.delegate = self
            txtDtacVersion?.text = dtacVersion
            return cell
        }
        
        if cellIdent == "lang" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "langCell", for: indexPath)
            langSegment = cell.viewWithTag(10) as? UISegmentedControl
            return cell
        }
        
        if cellIdent == "level" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath)
            levelSegment = cell.viewWithTag(10) as? UISegmentedControl
            return cell
        }
        
        if cellIdent == "actions" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            if txtCampaign != cell.viewWithTag(10) as? UITextField {
                txtCampaign = cell.viewWithTag(10) as? UITextField
                if let campaignId = UserDefaults.standard.string(forKey: "campaignId"), campaignId != ""
                {
                    txtCampaign?.text = campaignId
                }
                txtCampaign?.delegate = self
            }
            
            if txtCategory != cell.viewWithTag(11) as? UITextField {
                txtCategory = cell.viewWithTag(11) as? UITextField
                if let categoryIds = UserDefaults.standard.string(forKey: "categoryIds"), categoryIds != ""
                {
                    txtCategory?.text = categoryIds
                }
                txtCategory?.delegate = self
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension NewTokenSelectViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtDtacVersion {
            dtacVersion = textField.text ?? ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


enum Language: String{
    case tha = "th"
    case eng = "en"
    case mm = "mm"
    case my = "my"
}

enum DtacLevel: String{
    case none = "0000"
    case customer = "4000"
    case silver = "3000"
    case gold = "2000"
    case blue = "1000"
}

enum UserType:String {
    case pre = "P"
    case post = "T"
}
