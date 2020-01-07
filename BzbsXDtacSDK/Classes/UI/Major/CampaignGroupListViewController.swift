//
//  MajorViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 26/9/2562 BE.
//

import UIKit

class CampaignGroupListViewController: BaseListController {
    
    // MARK:- Class function
    // MARK:-
    open class func getViewController(isHideNav:Bool = false) -> CampaignGroupListViewController {
        
        let storyboard = UIStoryboard(name: "Util", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "major_list_view") as! CampaignGroupListViewController
        return controller
    }

    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "recommendCell")
            collectionView.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "campaignRotateCell")
            collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
            collectionView.contentInset = UIEdgeInsets.zero
            collectionView.alwaysBounceVertical = true
        }
    }
    let controller = BuzzebeesCampaign()
    var hashTag:String?
    {
        return dashboard.hashtag
    }
    var dashboard : BzbsDashboard!{
        didSet{
            getApi()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.font : UIFont.mainFont()])
        vwSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        collectionView.es.addPullToRefresh {
            self._isEnd = false
            self._intSkip = 0
            self.getApi()
        }
        getApi()
    }
    
    // MARK:- View Life cycle
    // MARK:-
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = !isHideNav
    }
    
    // MARK:- API
    // MARK:-
    var customConfig : String?
    func getConfig() -> String{
        return customConfig ?? "campaign_dtac"//Bzbs.shared.userLogin?.dtacLevel.campaignConfig ?? "campaign_dtac_guest"
    }
    
    let _intTop = 6
    override func getApi() {
        if _isCallApi || _isEnd { return }
        _isCallApi = true
        showLoader()
        controller.list(config: getConfig()
            , top : _intTop
            , skip: _intSkip
            , search: ""
            , catId: nil
            , hashTag: hashTag
            , token: nil
            , center : LocationManager.shared.getCurrentCoorndate()
            , successCallback: { (tmpList) in
                
                if self._intSkip == 0 {
                    self._arrDataShow = tmpList
                } else {
                    self._arrDataShow.append(contentsOf: tmpList)
                }
                self._isEnd = tmpList.count < self._intTop
                self._intSkip += self._intTop
                self.loadedData()
        }) { (error) in
            self._isEnd = true
            self.loadedData()
        }
    }
    
    override func loadedData() {
        collectionView.es.stopPullToRefresh()
        collectionView.reloadData()
        _isCallApi = false
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApi()
    }
}


// MARK:- Extension
// MARK:- UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CampaignGroupListViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return self._arrDataShow.count == 0 ? 1 : self._arrDataShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignRotateCell", for: indexPath) as! CampaignRotateCVCell
            let mockupDashboard = BzbsDashboard(dict: Dictionary<String, AnyObject>())
            mockupDashboard.subCampaignDetails = [dashboard]
            let width = collectionView.frame.size.width
            cell.customSize = CGSize(width: width, height: width * 2 / 3)
            cell.dashboardItems = [mockupDashboard]
            
            return cell
        }
        if self._arrDataShow.count == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        cell.setupWith(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let width = collectionView.frame.size.width
            return CGSize(width: width, height: width * 2 / 3)
        }
        if self._arrDataShow.count == 0
        {
            let width = collectionView.frame.size.width
            return CGSize(width: width, height: (collectionView.frame.size.height * 0.9) - (width * 2 / 3))
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
        if section == 0 {
            return UIEdgeInsets.zero
        }
        return UIEdgeInsets(top: 8, left: 6, bottom: 0, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 || _arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        if let nav = self.navigationController
        {
            GotoPage.gotoCampaignDetail(nav, campaign: item, target: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
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


extension CampaignGroupListViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        GotoPage.gotoSearch(self.navigationController!)
        return false
    }
}
