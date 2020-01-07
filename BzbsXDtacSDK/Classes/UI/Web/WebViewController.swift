//
//  WebViewController.swift
//  BzbsXDtacSDK
//
//  Created by apple on 19/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit

class WebViewController: BzbsXDtacBaseViewController {
    
    var isHideNav = false
    var strUrl :String!
    var strTitle: String!
    @IBOutlet weak var webView: UIWebView!
    
    open class func getViewController(isHideNav:Bool = false) -> WebViewController {
        let storyboard = UIStoryboard(name: "Util", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "web_view") as! WebViewController
        controller.isHideNav = isHideNav
        return controller
    }
    
    // MARK:- Life Cycle
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNav()
        
        if let url = URL(string: strUrl){
            webView.loadRequest(URLRequest(url: url))
        } else {
            back_1_step()
        }
    }
    
    override func initNav() {
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = strTitle
        self.navigationItem.titleView = lblTitle
//        self.title = strTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        self.navigationController?.isNavigationBarHidden = isHideNav
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
}
