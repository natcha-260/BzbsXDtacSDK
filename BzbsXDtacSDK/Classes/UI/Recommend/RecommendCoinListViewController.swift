//
//  RecommendCoinListViewController.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 16/9/2563 BE.
//

import UIKit
import FirebaseAnalytics

class RecommendCoinListViewController: RecommendListViewController {
    
    override func loadView() {
        super.loadView()
        
        collectionView.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "recommendCoinCell")
    }
    
    override  class func getViewController(isHideNav:Bool = false, customNav:UINavigationController? = nil) -> RecommendCoinListViewController {
        
        let storyboard = UIStoryboard(name: "Recommend", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "recommend_coin_list_view") as! RecommendCoinListViewController
        controller.customNav = customNav
        controller.isHideNav = isHideNav
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = isHideNav
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "recommend_coin_title".localized()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        getApi()
    }
    
    override func getApi() {
        showLoader()
        BuzzebeesDashboard().sub(dashboardName: Bzbs.shared.userLogin?.telType.configRecommendAll ?? DTACTelType.postpaid.configRecommendAll,
                                 deviceLocale: String(LocaleCore.shared.getUserLocale()),
                                 successCallback: { (dashboard) in
                                    let tmpDashboard = dashboard.filter(BzbsDashboard.filterDashboardWithTelType(dashboard:))
                                    self._arrDataShow = tmpDashboard
                                    self.sendImpressionCoinItems(impressionItems: tmpDashboard)
                                        // wordaround odd collection list count
                                    if self._arrDataShow.count % 2 != 0 {
                                        let dummyCampaign = BzbsDashboard()
                                        dummyCampaign.id = "-1"
                                        self._arrDataShow.append(dummyCampaign as AnyObject)
                                    }
                                    // -------
                                    self.loadedData()
        },
                                 failCallback: { (error) in
                                 self._arrDataShow.removeAll()
                                 self.loadedData()
                                 if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCoinCell", for: indexPath) as! CampaignCoinCVCell
        let item = _arrDataShow[indexPath.row] as! BzbsDashboard
        cell.setupWith(item)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if _arrDataShow.count == 0 {
            var size = collectionView.frame.size
            size.height -= 10
            return size
        }
        return CampaignCoinCVCell.getSize(collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = _arrDataShow[indexPath.row] as! BzbsDashboard
        sendCoinGATouchEvent(item, indexPath: indexPath)
        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    func sendImpressionCoinItems(impressionItems:[BzbsDashboard])
    {
        var items = [[String:AnyObject]]()
        var i = 1
        for item in impressionItems
        {
            var name = item.line1
            if LocaleCore.shared.getUserLocale() == 1033
            {
                name = item.line2
            }
    
            if name == nil {
                name = item.line1 ?? item.line2 ?? "-"
            }
            
            
            var agencyName = item.line3
            if LocaleCore.shared.getUserLocale() == 1033
            {
                agencyName = item.line4
            }
            if agencyName == nil {
                agencyName = item.line3 ?? item.line4 ?? "-"
            }
            
            var intPointPerUnit = 0
            if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
                intPointPerUnit = pointPerUnit
            }
            
            var reward = [String:AnyObject]()
            reward[AnalyticsParameterItemID] = item.id! as AnyObject
            reward[AnalyticsParameterItemName] = name as AnyObject
            reward[AnalyticsParameterItemCategory] = "reward/coins/{reward_filter}" as AnyObject
            reward[AnalyticsParameterItemBrand] = agencyName as AnyObject
            reward[AnalyticsParameterIndex] = i as AnyObject
            reward[AnalyticsParameterItemVariant] = "{code_duration}" as AnyObject
            reward["metric1"] = intPointPerUnit as AnyObject
            
            i += 1
            items.append(reward)
        }
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " impression_list" as NSString,
            "eventLabel" : "recommend_coin_reward" as NSString,
            AnalyticsParameterItemListName: "dtac_coin_reward" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: ecommerce)
    }
    
    
    func sendCoinGATouchEvent(_ item:BzbsDashboard, indexPath:IndexPath)
    {
        if item.id == "-1" {
            return
        }
        var name = item.line1
        if LocaleCore.shared.getUserLocale() == 1033
        {
            name = item.line2
        }
        
        if name == nil {
            name = item.line1 ?? item.line2 ?? "-"
        }
        
        
        var agencyName = item.line3
        if LocaleCore.shared.getUserLocale() == 1033
        {
            agencyName = item.line4
        }
        if agencyName == nil {
            agencyName = item.line3 ?? item.line4 ?? "-"
        }
        
        var intPointPerUnit = 0
        if let pointPerUnit = Convert.IntFromObject(item.dict?["pointperunit"]) {
            intPointPerUnit = pointPerUnit
        }
        let index = indexPath.row
        
        var reward = [String:AnyObject]()
        reward[AnalyticsParameterItemID] = item.id! as AnyObject
        reward[AnalyticsParameterItemName] = name as AnyObject
        reward[AnalyticsParameterItemCategory] = "reward/coins/{reward_filter}" as AnyObject
        reward[AnalyticsParameterItemBrand] = agencyName as AnyObject
        reward[AnalyticsParameterIndex] = index as AnyObject
        reward[AnalyticsParameterItemVariant] = "{code_duration}" as AnyObject
        reward["metric1"] = intPointPerUnit as AnyObject
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward]
        
        let ecommerce : [String:Any] = [
            "items" : items,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_list" as NSString,
            "eventLabel" : "recommend_coin_reward | \(index) | \(item.id!) | \(intPointPerUnit)" as NSString,
            AnalyticsParameterItemListName: "dtac_coin_reward" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: ecommerce)
    }
}
