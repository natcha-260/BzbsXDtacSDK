//
//  GotoPage.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 11/30/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//


import UIKit

class GotoPage: NSObject
{
    
    class var currentBundle :Bundle {
        return Bzbs.shared.currentBundle
    }
    
    class func gotoCategory(_ nav:UINavigationController, cat:BzbsCategory, subCat:BzbsCategory? = nil, arrCategory:[BzbsCategory]) {
        let storboard = UIStoryboard(name: "Category", bundle: currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "campaign_by_category_view") as! CampaignByCatViewController
        vc.hidesBottomBarWhenPushed = true
        vc.currentCat = cat
        if let newSubcat = subCat ?? cat.subCat.first {
            vc.currentSubCat = newSubcat
        }
        vc.arrCategory = arrCategory
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoCampaignDetail(_ nav:UINavigationController, campaign: BzbsCampaign, target: UIViewController) {
        if !ReachabilityManager.shared.isConnectedToInternet() {
            ReachabilityManager.shared.showPopupInternet(target: target)
            return
        }
        let storboard = UIStoryboard(name: "Campaign", bundle: currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "scene_campaign_detail") as! CampaignDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.campaign = campaign
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoSearch(_ nav:UINavigationController) {
        let storboard = UIStoryboard(name: "Util", bundle: currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "search_view") as! SearchViewController
        vc.hidesBottomBarWhenPushed = true
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoNearby(_ nav:UINavigationController) {
        let storyboard = UIStoryboard(name: "Nearby", bundle: currentBundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "nearby_view") as! NearbyListViewController
        vc.hidesBottomBarWhenPushed = true
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoMap(_ nav:UINavigationController, campaigns :[BzbsCampaign], customHeader:String? = nil, isShowBackToList:Bool = true,gotoPin currentPlace:BzbsPlace? = nil) -> MapsViewController {
        let storyboard = UIStoryboard(name: "Nearby", bundle: currentBundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "map_view") as! MapsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.isShowBackToList = isShowBackToList
        vc.campaigns = campaigns
        vc.customHeader = customHeader
        if let place = currentPlace{
            vc.currentPlace = place
        }
        nav.pushViewController(vc, animated: true)
        return vc
    }
    
    class func gotoWebSite(_ nav:UINavigationController, strUrl: String, strTitle: String = "")
    {
        if let _ = URL(string: strUrl ) {
            let vc = WebViewController.getViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.strUrl = strUrl
            vc.strTitle = strTitle
            
            nav.pushViewController(vc, animated: true)
        }
    }
    
    class func gotoScanQR(_ nav:UINavigationController, target:ScanQRViewControllerDelegate)
    {
        let storboard = UIStoryboard(name: "Util", bundle: currentBundle)
        let qrScanner = storboard.instantiateViewController(withIdentifier: "qr_scanner_view") as! ScanQRViewController
        qrScanner.hidesBottomBarWhenPushed = true
        qrScanner.delegate = target
        nav.pushViewController(qrScanner, animated: true)
    }
    
    class func gotoFavorite(_ nav:UINavigationController) {
        let storboard = UIStoryboard(name: "Favorite", bundle: currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "scene_favorite_list") as! FavoriteViewController
        vc.hidesBottomBarWhenPushed = true
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoHistory(_ nav:UINavigationController) {
        let storboard = UIStoryboard(name: "History", bundle: currentBundle)
        let vc = storboard.instantiateViewController(withIdentifier: "scene_history_list") as! HistoryViewController
        vc.hidesBottomBarWhenPushed = true
        nav.pushViewController(vc, animated: true)
    }
    
    class func gotoHistoryPopupExpired(_ nav: UINavigationController, item: BzbsHistory) {
//        let storboard = UIStoryboard(name: "History", bundle: currentBundle)
//        let vc = storboard.instantiateViewController(withIdentifier: "scene_popup_history_expired") as! HistoryViewPopupExpiredController
//        vc.itemHistory = item
////        let nav = UINavigationController(rootViewController: vc)
////        nav.isNavigationBarHidden = true
////        nav.modalPresentationStyle = UIModalPresentationStyle.custom
//        nav.pushViewController(vc, animated: true)
    }
}
