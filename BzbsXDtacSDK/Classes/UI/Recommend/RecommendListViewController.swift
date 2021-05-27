//
//  RecommendListViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class RecommendListViewController: BaseListController {
    
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK:- Variable
    let controller = BuzzebeesCampaign()
    var isHideNav = false
    var catId:Int?{
        didSet{
            _intSkip = 0
            _isEnd = false
            getApi()
        }
    }
    var customNav:UINavigationController?
    var currentCenter = LocationManager.shared.getCurrentCoorndate()
    
    // MARK:- Class function
    // MARK:-
    open class func getViewController(isHideNav:Bool = false, customNav:UINavigationController? = nil) -> RecommendListViewController {
        
        let storyboard = UIStoryboard(name: "Recommend", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "recommend_list_view") as! RecommendListViewController
        controller.customNav = customNav
        controller.isHideNav = isHideNav
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    // MARK:- View Life cycle
    // MARK:-
    
    override func loadView() {
        super.loadView()
        collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "recommendCell")
        collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 2, bottom: 8, right: 2)
        collectionView.alwaysBounceVertical = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = isHideNav
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "recommend_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        //self.title = "recommend_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        analyticsSetScreen(screenName: "reward_recommend")
//        getApi()
    }
    
    override func updateUI() {
        super.updateUI()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "recommend_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        //self.title = "recommend_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        _intSkip = 0
        _isEnd = false
        getApi()
    }
    
    // MARK:- API
    // MARK:-
    var customConfig : String?
    func getConfig() -> String{
        return customConfig ?? Bzbs.shared.userLogin?.telType.configRecommend ?? "campaign_dtac_guest"
    }
    
    let _intTop = 25
    override func getApi() {
        getApiDashboard()
    }
    
    func getAllDashboardConfig() -> String {
        
        if let userLogin = Bzbs.shared.userLogin {

            switch userLogin.dtacLevel {
                case .blue:
                    return "dtac_bi_blue_member"
                case .gold:
                    return "dtac_bi_gold"
                case .silver:
                    return "dtac_bi_silver"
                case .customer:
                    return "dtac_bi_dtac_customer"
                case .no_level:
                    return "dtac_bi_dtac_customer"
            }
        }
        return "dtac_bi_dtac_customer"
    }
    
    func getApiDashboard() {
        
        if _isCallApi {
            return
        }
        _isCallApi = true
        
        showLoader()
        BuzzebeesDashboard().sub(dashboardName: getAllDashboardConfig(),
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    self._arrDataShow = dashboard
//                                    if let first = dashboard.first {
//                                        self._arrDataShow = first.subCampaignDetails
//                                    }
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                 self._arrDataShow.removeAll()
                                 self.loadedData()
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApi()
    }
    
    override func loadedData() {
        super.loadedData()
        collectionView.reloadData()
    }
    
    //MARK:- GA
    //MARK:-
    // FIXME:GA#20
    func sendGAImpression(_ item:BzbsDashboard) {
        if item.id == "-1" {
            return
        }
        
        var name = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if !item.line1.isEmpty {
                name = item.line1
            }
        } else {
            if !item.line1.isEmpty {
                name = item.line2
            }
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if !item.line3.isEmpty {
                agencyName = item.line3
            }
        } else {
            if !item.line4.isEmpty {
                agencyName = item.line4
            }
        }
        
        var categoryName: String! = item.categoryName ?? ""
        if categoryName.isEmpty {
            categoryName = BzbsAnalyticDefault.category.rawValue
        }
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(item.id ?? "0")" as NSString,
            AnalyticsParameterItemName: name as NSString,
            AnalyticsParameterItemCategory: "reward/\(categoryName ?? "")/recommended" as NSString,
            AnalyticsParameterItemBrand: "\(agencyName)" as NSString,
            AnalyticsParameterIndex: 1 as NSNumber,
            "metric1" : 0 as NSNumber,
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "impression_list" as NSString,
            "eventLabel" : "recommended_for_you | all" as NSString,
            AnalyticsParameterItemListName: "reward_recommend" as NSString
        ]
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewItemList, params: ecommerce)
    }
    
    // FIXME:GA#21
    func sendGATouchItem(_ item:BzbsDashboard, index:Int) {
        if item.id == "-1" {
            return
        }
        
        var name = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if !item.line1.isEmpty {
                name = item.line1
            }
        } else {
            if !item.line1.isEmpty {
                name = item.line2
            }
        }
        
        var agencyName = BzbsAnalyticDefault.name.rawValue
        if LocaleCore.shared.getUserLocale() == 1054
        {
            if !item.line3.isEmpty {
                agencyName = item.line3
            }
        } else {
            if !item.line4.isEmpty {
                agencyName = item.line4
            }
        }
        
        var categoryName: String! = item.categoryName ?? ""
        if categoryName.isEmpty {
            categoryName = BzbsAnalyticDefault.category.rawValue
        }
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(item.id ?? "0")" as NSString,
            AnalyticsParameterItemName: name as NSString,
            AnalyticsParameterItemCategory: "reward/\(categoryName ?? "")/recommended" as NSString,
            AnalyticsParameterItemBrand: "\(agencyName)" as NSString,
            AnalyticsParameterIndex: 1 as NSNumber,
            "metric1" : 0 as NSNumber,
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_list" as NSString,
            "eventLabel" : "recommended_for_you | \(categoryName ?? "") | recommended | \(index) | \(item.id ?? "0")" as NSString,
            AnalyticsParameterItemListName: "reward_recommend" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventSelectItem, params: ecommerce)
    }
}


// MARK:- Extension
// MARK:- UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension RecommendListViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._arrDataShow.count == 0 ? 1 : _arrDataShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if _arrDataShow.count == 0 {
            if _isCallApi
            {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
            cell.imv.image = UIImage(named: "ic_reward_document", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            cell.lbl.text = "major_empty".localized()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        let item = _arrDataShow[indexPath.row] as! BzbsDashboard
        sendGAImpression(item)
        cell.setupWith(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if _arrDataShow.count == 0 {
            var size = collectionView.frame.size
            size.height -= 10
            return size
        }
        return CampaignCVCell.getSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if _arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsDashboard
        sendGATouchItem(item, index: indexPath.row)
        let campaign = item.toCampaign()
        if let nav = self.navigationController
        {
            GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
        } else if let nav = customNav
        {
            GotoPage.gotoCampaignDetail(nav, campaign: campaign, target: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        loadMore(indexPath)
    }
    
    func loadMore(_ indexPath:IndexPath? = nil)
    {
        if _isCallApi || _isEnd { return }
        if indexPath != nil
        {
            if indexPath!.row > _arrDataShow.count - 2 {
                getApi()
            }
        } else {
            getApi()
        }
    }
    
}
