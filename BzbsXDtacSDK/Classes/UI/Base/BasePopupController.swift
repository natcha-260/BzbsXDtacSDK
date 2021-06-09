//
//  BasePopupController.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 12/13/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//

import UIKit

class BasePopupController: UIViewController
{
    // MARK:- Private Variables For Class
    // MARK:-
//    let _appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK:- Property
    // MARK:-
//    var dataPopupInformation: DataPopupInformation!
    
    @IBOutlet weak var viewBlur: UIView!
    
    // MARK:- Life cycle
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideViewBlur()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let vc = viewBlur
        {
            UIView.animate(withDuration: 0.11, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
                vc.alpha = 0.8
                self.view.layoutIfNeeded()
            }) { (success) -> Void in
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    // MARK:- Language
//    // MARK:-
//    func language(strMessage: String) -> String
//    {
//        return LocaleCore.shared.language(string: strMessage)
//    }
    
    func userLocale() -> Int
    {
        return LocaleCore.shared.getUserLocale()
    }
    
    // MARK:- Util
    // MARK:-
    func addShadow(viewObject: UIView)
    {
        if viewObject.layer.cornerRadius != 0.5
        {
            viewObject.layer.shadowColor = UIColor.black.cgColor
            viewObject.layer.shadowOpacity = 0.33
            viewObject.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
            viewObject.layer.shadowRadius = 1
            
            viewObject.layer.cornerRadius = 0.5
        }
    }
    
    func hideViewBlur()
    {
        if let vcBlur = viewBlur
        {
            vcBlur.alpha = 0.0
        }
    }
    
    // MARK:- SwiftLoader
    // MARK:-
//    func showLoader(strText: String = LocaleCore.shared.language(string: "util_loading"), animated: Bool = true){
//        SwiftLoader.show(language(strMessage: strText), animated: animated)
//    }
//    
//    func hideLoader(){
//        SwiftLoader.hide()
//    }
//    
//    
//    func gaScreenName(strScreenName : String) {
//        let screenName = strScreenName.trim().lowercased().replace(" ", replacement: "_")
//        let strClassName = String(describing: type(of: self))
//        FirebaseAnalytics.shared.setScreenGA(strScreenName: screenName, strScreenClass: strClassName)
//    }
//    
//    func gaLogEvent(eventName : String , categoryName:String, label : String? = "" ) {
//        let strEvent = eventName.trim().lowercased().replace(" ", replacement: "_")
//        let strCategory = categoryName.trim().lowercased().replace(" ", replacement: "_")
//        FirebaseAnalytics.shared.setLogEventGA(event: strEvent, category: strCategory , label: (label ?? ""))
//    }
    
}
