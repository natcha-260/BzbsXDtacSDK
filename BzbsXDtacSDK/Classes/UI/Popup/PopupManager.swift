//
//  PopupConfirmRedeemViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 3/10/2562 BE.
//

import UIKit

class PopupManager :NSObject
{
    class func confirmPopup(_ target:UIViewController, isWithImage:Bool = false, title:String? = nil, message:String, strConfirm:String? = nil, strClose:String? = nil  ,confirm: @escaping (() -> Void),cancel:  (() -> Void)?){
        
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: isWithImage ? "popup_confirm_image" : "popup_confirm") as! PopupConfirmViewController
        vc.view.backgroundColor = .clear
        vc.strTitle = title
        vc.strMessage = message
        if let str = strConfirm {
            vc.strConfirm = str
        }
        if let str = strClose {
            vc.strClose = str
        }
        vc.confirmSelector = confirm
        vc.closeSelector = cancel
        present(view: vc, on: target)
        
    }
    
    class func informationPopup(_ target:UIViewController, title:String? = nil, message:String, strClose:String? = nil ,close: (() -> Void)?){
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_information") as! PopupInformationViewController
        vc.view.backgroundColor = .clear
        vc.strTitle = title
        if let str = strClose {
            vc.strClose = str
        }
        vc.strMessage = message
        vc.closeSelector = close
        present(view: vc, on: target)
    }

        
    class func scanQrFailPopup(_ target:UIViewController ,close: (() -> Void)?){
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_scan_fail") as! PopupScanFailViewController
        vc.closeSelector = close
        present(view: vc, on: target)
    }
    
    class func serialPopup(onView target:UIViewController!, purchase:BzbsHistory, isNeedUpdate:Bool = false, parentCategoryName:String?, parentSubCategoryName:String?, gaIndex:Int)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_serial") as! PopupSerialViewController
        vc.purchase = purchase
        vc.delegate = target as? PopupSerialDelegate
        vc.isNeedUpdate = isNeedUpdate
        vc.gaIndex = gaIndex
        vc.parentCategoryName = parentCategoryName ?? BzbsAnalyticDefault.category.rawValue
        vc.parentSubCategoryName = parentSubCategoryName ?? BzbsAnalyticDefault.category.rawValue
        vc.previousScreenName = (target as? BzbsXDtacBaseViewController)?.screenName
        present(view: vc, on: target)
    }
    
    class func pointHistoryPopup(onView target:UIViewController!, pointlog:PointLog)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_point_history_detail") as! PopupPointHistoryDetailViewController
        vc.pointLog = pointlog
        present(view: vc, on: target)
    }
    
    class func pointHistoryPopup(onView target:UIViewController!, purchase:BzbsHistory)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_point_history_detail") as! PopupPointHistoryDetailViewController
        vc.pointLog = PointLog()
        vc.purchase = purchase
        present(view: vc, on: target)
    }
    
    class func subscriptionPopup(onView target:UIViewController!, purchase:BzbsHistory, parentCategoryName:String?, parentSubCategoryName: String?, gaIndex:Int)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_subscription") as! PopupSubscriptionViewController
        vc.history = purchase
        vc.parentCategoryName = parentCategoryName ?? BzbsAnalyticDefault.category.rawValue
        vc.parentSubCategoryName = parentSubCategoryName ?? BzbsAnalyticDefault.category.rawValue
        vc.gaIndex = gaIndex
        present(view: vc, on: target)
    }
    
    class func lineErrorPopup(onView target:UIViewController!, strMessage:String, strInfo:String)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_line_error") as! PopupLineErrorViewController
        vc.strMessage = strMessage
        vc.strInfo = strInfo
        present(view: vc, on: target)
    }
    
    class func lineConfirmPopup(onView target:UIViewController!, strContactNumber:String, campaign:LineStickerCampaign, pointPerUnit: Int ,confirm: @escaping (() -> Void),cancel:  (() -> Void)?)
    {
        let storboard = UIStoryboard(name: "Popup", bundle: Bzbs.shared.currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "popup_line_confirm") as! PopupLineConfirmViewController
        vc.strContactNumber = strContactNumber
        vc.pointPerUnit = pointPerUnit
        vc.campaign = campaign
        vc.confirm = confirm
        vc.cancel = cancel
        present(view: vc, on: target)
    }
    
    private class func present(view vc:UIViewController,on target:UIViewController)
    {
//        Bzbs.shared.delay(0.66) {
            DispatchQueue.main.async {
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    vc.modalPresentationStyle = .overCurrentContext
                } else {
                    vc.modalPresentationStyle = .overFullScreen
                }
                vc.modalTransitionStyle = .crossDissolve
                vc.popoverPresentationController?.sourceView = target.view
                target.present(vc, animated: true, completion: nil)
            }
//        }
//        let targetView = target.view!
//        var targetFrame = targetView.frame
//        targetFrame.origin = CGPoint.zero
//        vc.view.frame = targetFrame
//        target.addChild(vc)
//        vc.didMove(toParent: target)
//        targetView.addSubview(vc.view)
//        targetView.bringSubviewToFront(vc.view)
    }
}


