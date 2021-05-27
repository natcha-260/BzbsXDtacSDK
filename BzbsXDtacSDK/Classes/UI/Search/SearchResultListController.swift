//
//  SearchResultListController.swift
//  Pods
//
//  Created by Buzzebees iMac on 26/9/2562 BE.
//

import UIKit
import FirebaseAnalytics

class SearchResultListController: BaseListController {

    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var lblSearchResults: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    // MARK:- Variable
    let controller = BuzzebeesCampaign()
    var strSearch = ""{
        didSet{
            if strSearch == ""{
                self._arrDataShow.removeAll()
            } else {
                if strSearch != oldValue{
                    self.lblSearchResults.isHidden = true
                    self._arrDataShow.removeAll()
                    self.collectionView.reloadData()
                    self._isEnd = false
                    self._intSkip = 0
                    getApi()
                }
            }
        }
    }
    
    // MARK:- View Life cycle
    // MARK:-
    
    override func loadView() {
        super.loadView()
        collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "recommendCell")
        collectionView.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "recommendCoinCell")
        collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
        collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 8, right: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        //self.title = "search_title".localized()
        lblSearchResults.font = UIFont.mainFont()
        lblSearchResults.text = "About 0 results"
        analyticsSetScreen(screenName: "reward_search")
        getApi()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = !isHideNav
    }
    
    override func updateUI() {
        super.updateUI()
//
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        //self.title = "search_title".localized()
        self._isEnd = false
        self._intSkip = 0
        getApi()
    }
    
    // MARK:- API
    // MARK:-
    func getConfig() -> String{
        return "campaign_dtac"// Bzbs.shared.userLogin?.dtacLevel.campaignConfig ?? "campaign_dtac_guest"
    }
    
    let _intTop = 1000
    override func getApi() {
        if _isCallApi || _isEnd || strSearch.isEmpty { return }
        showLoader()
        _isCallApi = true
        controller.list(config: getConfig()
            , top : _intTop
            , skip: _intSkip
            , search: strSearch
            , catId: nil
            , token: Bzbs.shared.userLogin?.token
            , center : LocationManager.shared?.getCurrentCoorndate()
            , successCallback: { (tmpList) in

                self._arrDataShow = tmpList
                if self._intSkip == 0 {
                    self._arrDataShow = tmpList
                } else {
                    self._arrDataShow.append(contentsOf: tmpList)
                }

                self._intSkip += self._intTop
                self._isEnd = tmpList.count < self._intTop
                self.lblSearchResults.text = String(format: "search_result_format".localized(), "\(tmpList.count)")
                self.lblSearchResults.isHidden = tmpList.count <= 0
                self.analyticsSearchResult(text: self.strSearch, numberOfPrivileges: tmpList.count)
                self.loadedData()
        }) { (error) in
            self._isEnd = true
            self.loadedData()
        }
    }
    
    override func loadedData() {
        self.collectionView.stopPullToRefresh()
        self.collectionView.reloadData()
        self._isCallApi = false
        self.hideLoader()
    }
    
    // FIXME:GA#39
    func analyticsSearchResult(text: String, numberOfPrivileges: Int) {
        let label = "search_result | \(text) | \(numberOfPrivileges)"
        analyticsSetEvent(event: "event_app", category: "reward", action: "seen_text", label: label)
    }
    
    // FIXME:GA#40
    func analyticsImpressionItemResult(_ item:BzbsCampaign) {
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(item.ID ?? -1)" as NSString,
            AnalyticsParameterItemName: "\(item.name ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterItemCategory: "reward/\(BzbsAnalyticDefault.category.rawValue)/\(item.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue)" as NSString,
            AnalyticsParameterItemBrand: "\(item.categoryName ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterIndex: 1 as NSNumber,
            "metric1" : (item.pointPerUnit ?? 0) as NSNumber,
        ]
        
        let ecommerce : [String:AnyObject] = [
            "items" : [reward1] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " impression_list" as NSString,
            "eventLabel" : "search_result" as NSString,
            AnalyticsParameterItemListName: "reward_search" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventViewItemList, params: ecommerce)
    }
    
    //FIXME:GA#41
    func analyticsSelectItemResult(_ item:BzbsCampaign, indexPath:IndexPath) {
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(item.ID ?? -1)" as NSString,
            AnalyticsParameterItemName: "\(item.name ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterItemCategory: "reward/\(BzbsAnalyticDefault.category.rawValue)/\(item.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue)" as NSString,
            AnalyticsParameterItemBrand: "\(item.categoryName ?? BzbsAnalyticDefault.name.rawValue)" as NSString,
            AnalyticsParameterIndex: (indexPath.row + 1) as NSNumber,
            "metric1" : (item.pointPerUnit ?? 0) as NSNumber,
        ]
        
        let ecommerce : [String:AnyObject] = [
            "items" : [reward1] as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : " touch_list" as NSString,
            "eventLabel" : "search_result | \(BzbsAnalyticDefault.category.rawValue) | \(item.categoryName ?? BzbsAnalyticDefault.subCategory.rawValue) | \(indexPath.row + 1) | \(item.ID ?? -1)" as NSString,
            AnalyticsParameterItemListName: "reward_search" as NSString
        ]
        
        // Log select_content event with ecommerce dictionary.
        analyticsSetEventEcommerce(eventName: AnalyticsEventSelectItem, params: ecommerce)
    }
    
}


// MARK:- Extension
// MARK:- UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension SearchResultListController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._arrDataShow.count == 0 ? 1 : self._arrDataShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self._arrDataShow.count == 0 {
            if _isCallApi
            {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
            cell.imv.image = UIImage(named: "ic_reward_document", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            cell.lbl.text = "major_empty".localized()
            return cell
        }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        analyticsImpressionItemResult(item)
        if item.parentCategoryID == BuzzebeesCore.catIdCoin {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCoinCell", for: indexPath) as! CampaignCoinCVCell
            cell.setupWith(item, isShowDistance: false)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        cell.setupWith(item, isShowDistance: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self._arrDataShow.count == 0 {
            let width = collectionView.frame.size.width - 16
            let height = collectionView.frame.size.height * 0.9
            return CGSize(width: width, height: height)
        }
        let row = indexPath.row
        let item = _arrDataShow[row] as! BzbsCampaign
        var sideItem : BzbsCampaign?
        var sideRow = row
        
        if row % 2 == 0 {
            sideRow = row + 1
        } else {
            sideRow = row - 1
        }
        
        if !(sideRow > (_arrDataShow.count - 1) || sideRow < 0) {
            sideItem = _arrDataShow[sideRow] as? BzbsCampaign
        }
        
        if item.parentCategoryID == BuzzebeesCore.catIdCoin || (sideItem != nil && sideItem?.parentCategoryID == BuzzebeesCore.catIdCoin) {
            return CampaignCoinCVCell.getSize(collectionView)
        }
        return CampaignCVCell.getSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        analyticsSelectItemResult(item, indexPath: indexPath)
        if let nav = self.navigationController
        {
            GotoPage.gotoCampaignDetail(nav, campaign: item, target: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMore(indexPath)
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
