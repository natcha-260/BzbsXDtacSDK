//
//  ViewController.swift
//  BzbsXDtacSDK
//
//  Created by natchaporing@gmail.com on 09/13/2019.
//  Copyright (c) 2019 natchaporing@gmail.com. All rights reserved.
//

import UIKit
import BzbsXDtacSDK
import FirebaseAnalytics

class MainViewController: UIViewController {
    
    var logAlalytics = ""
    var i = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let dtacReward = BzbsMainViewController.getViewWithNavigationBar()
        self.addChild(dtacReward)
        self.view.addSubview(dtacReward.view)
        dtacReward.didMove(toParent: self)
        Bzbs.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension MainViewController : BzbsDelegate
{
    func clickMission() {
        print("clickMission")
    }
    
    func suspend() {
        print("suspend")
    }
    
    func reLogin() {
        print("reLogin")
        Bzbs.shared.reLogin()
    }
    
    func clickMessage() {
        
    }
    
    func analyticsScreen(screenName: String) {
        printLog("[BzbsAnalytics]\nScreen -> Name : \(screenName)")
        if screenName.contains("log") {
            self.log(screenName)
            return
        }
        Analytics.logEvent(screenName, parameters: [AnalyticsEventScreenView : screenName])
    }
    
    func analyticsEventEcommerce(eventName: String, params: [String : AnyObject]) {
        printLog("[BzbsAnalytics]\nEventEcommerce -> event : \(eventName) ,\n\tparams:\(params)")
        Analytics.logEvent(eventName, parameters: params)
    }
    
    func analyticsEvent(event: String, category: String, action: String, label: String) {
        printLog("[BzbsAnalytics]\nEvent -> event : \(event) ,\n\tcategory:\(category), \n\tevent:\(action), \n\tlabel:\(label)")
        Analytics.logEvent(event, parameters: ["category": category, "action":action, "label":label])
    }
    
    func analyticsSetUserProperty(propertyName: String, value: String) {
        printLog("[BzbsAnalytics]\nsetUserProperty : \n\tlabel:\(propertyName)")
        Analytics.setUserProperty(value, forName: propertyName)
    }
    
    func log(_ strlog:String) {
        printLog(strlog)
    }
    
    func reTokenTicket()
    {
//        Bzbs.shared.setup(token: "QAefS0N6zNq/RyrGUPJ1fR4d4gWcoEjaOCrPWUVh24Zg8zlK5dP1hIj31QyMaePnxhyew+D2tRc=", ticket: "AAK66a/vDl42UyY+gwKVyXtnU9FBhMQFdRCklcJ9kCPxEa6L0C4RuSRIIeU=", language: "th")
    }
    
    func printLog(_ string:String)
    {
        i += 1
        if let tabbar = self.tabBarController
        {
            if let nav = tabbar.viewControllers?[1] as? UINavigationController,
                let vc = nav.viewControllers.first as? AnalyticDebugViewController
            {
                vc.printLog("\(i) => \n \(string) \n<=\n")
            }
        }
    }
    
}
