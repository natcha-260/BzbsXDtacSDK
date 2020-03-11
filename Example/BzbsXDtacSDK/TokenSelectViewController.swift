//
//  TokenSelectViewController.swift
//  
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import UIKit
import BzbsXDtacSDK

class TokenSelectViewController: UIViewController {

    @IBOutlet weak var segmentEndpoint: UISegmentedControl!
    @IBOutlet weak var segmentLang: UISegmentedControl!
    var isDev:Bool {
        return segmentEndpoint.selectedSegmentIndex == 0
    }
    var isStg:Bool {
        return segmentEndpoint.selectedSegmentIndex == 1
    }
    var isPrd:Bool {
        return segmentEndpoint.selectedSegmentIndex == 2
    }
    var language:String{
        return segmentLang.selectedSegmentIndex == 0 ? "en" : "th"
    }
    var versionList = ["0.0.3","0.0.4","0.0.5","0.0.6"]
    var strVersion:String {
        segmentVersion.titleForSegment(at: segmentVersion.selectedSegmentIndex) ?? versionList.first!
    }
    
    @IBOutlet weak var segmentVersion: UISegmentedControl! {
        didSet{
            segmentVersion.removeAllSegments()
            for i in 0..<versionList.count {
                let title = versionList[i]
                segmentVersion.insertSegment(withTitle: title, at: i, animated: true)
            }
        }
    }
    
    //    ver. 0.0.3 = PRD. DtacApp:9.0.1
//    ver. 0.0.4 = PRD.
//    ver. 0.0.5 = STG.
//    ver. 0.0.6 = DEV.
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentEndpoint.selectedSegmentIndex = 2
        segmentVersion.selectedSegmentIndex = 1
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didChangeEndpoint(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            segmentVersion.selectedSegmentIndex = 3
        }
        
        if sender.selectedSegmentIndex == 1
        {
            segmentVersion.selectedSegmentIndex = 2
        }
        
        if sender.selectedSegmentIndex == 2
        {
            segmentVersion.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func didChangeVersion(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func clickSkipLogin(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        Bzbs.shared.setup(token: "", ticket: "", language: language, DTACSegment: "")
        gotoMain()
    }
    
    @IBAction func clickNoToken(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        Bzbs.shared.setup(token: "", ticket: "", language: language, DTACSegment: "")
        gotoMain()
    }
    
    @IBAction func clickCustomer(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        if isDev {
            Bzbs.shared.setup(token: "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxqPRR5G8XlhiHA+65JbklZ9kGj7dmo5XyY=", ticket: "1QF39OSA+F19HcQDU3JwhQWeznT0vF7VnBrIj1HoWclwa9RZ6VZPiEXNolM=", language: language, DTACSegment: "4000")
        }
        
        if isStg {
            Bzbs.shared.setup(token: "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxqPRR5G8XlhiHA+65JbklZ9kGj7dmo5XyY=", ticket: "1QF39OSA+F19HcQDU3JwhQWeznT0vF7VnBrIj1HoWclwa9RZ6VZPiEXNolM=", language: language, DTACSegment: "4000")
        }
        
        if isPrd {
            Bzbs.shared.setup(token: "vKmKza5IX9mZLXbQcShMZmdvShCrtw+7RgskBhLRvxoH1KiSmJ6WvfESsSSBNfz94XtJABzCNG4=", ticket: "AgN3VXKvpl2a9BVRZgx8SpkaLjWQuKc7h/nMZAJdoGaE4MKLPAvJPPVMU5c=", language: language, DTACSegment: "4000")
        }
        gotoMain()
    }
    
    @IBAction func clickSilver(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        if isDev || isStg {
            Bzbs.shared.setup(token: "6SjkaciPnsVcxjSQsgJJ3jaKF48+uteT37l/Rhh01xxg8zlK5dP1hB7HQRkLZ+3aHEqDusyKx28=", ticket: "1QKNrsS2El4Eu5PDEIVs/1boJiOWTyH1ZC3EOZiXtI5KlD7uFRpm55srYSY=", language: language, DTACSegment: "3000")
        }
        
        if isPrd {
            Bzbs.shared.setup(token: "ecTRUtHv6HxkdJJ4h2KpOs1vGEd8NPmy95FUzj7RpzqwhNGkzRBJi7Z3/Z0MxnOEj7hyj2ovEG4=", ticket: "zABxi7c6310ZoxU8etbjI84fOsNBp3tCku3aNKb8TdryP93K54b0jLVCghw=", language: language, DTACSegment: "3000")
        }
        gotoMain()
    }
    
    @IBAction func clickGold(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        
        if isDev || isStg {
            Bzbs.shared.setup(token: "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ9g8zlK5dP1hMOxWSS5czz2anEnkpfnKJs=", ticket: "RQJOAlC1El69TXrhg0xyIS7uvhL4Euy/nKuzyfwMzu9Vb9es7Q7vAGw1cgA=", language: language, DTACSegment: "2000")
        }
        
        if isPrd {
            Bzbs.shared.setup(token: "ImypiEXvH008mncu3eiT+6tNhrRi8HqvR2S8rIHvrJ8H1KiSmJ6WvfESsSSBNfz9ELcMZ6lm4hY=", ticket: "IQEcGD5nrV1bwWvTVzaoYAEnRbw0aPwTVLzIZQ3jZlTiZ6qxDfojfAw0RNs=", language: language, DTACSegment: "2000")
        }
        gotoMain()
    }
    
    @IBAction func clickBlueMember(_ sender: Any) {
        view.endEditing(true)
        Bzbs.shared.versionString = strVersion
        
        if isDev || isStg {
            Bzbs.shared.setup(token: "Z9unF9axmM0f+socL4lG8BtMNQOA28Kr4sjlQ9yiYx2PRR5G8XlhiHA+65JbklZ9avsy2/TdrI8=", ticket: "WAPJ9liA+F0XhSdWw0nvkDNVS+xtGOpSFevxSYmZELtuXruXsGf1SgKsOQQ=", language: language, DTACSegment: "1000")
        }
        
        if isPrd {
            Bzbs.shared.setup(token: "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc=", ticket: "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU=", language: language, DTACSegment: "1000")
        }
        
        gotoMain()
    }
    
    var dtacReward : UIViewController!
    func gotoMain()
    {
        Bzbs.shared.isDebugMode = true
        if UIDevice.current.model == "iPad"
        {
            let storyboard = UIStoryboard(name: "Main_iPad", bundle: nil)
            let tabbar = storyboard.instantiateViewController(withIdentifier: "main_view")
            self.present(tabbar, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbar = storyboard.instantiateViewController(withIdentifier: "tabbar")
            tabbar.modalPresentationStyle = .fullScreen
            self.present(tabbar, animated: true, completion: nil)
        }
//        delay(10) {
//            Bzbs.shared.isHasNewMessage = true
//            self.delay(2) {
//                Bzbs.shared.isHasNewMessage = true
//            }
//        }
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
