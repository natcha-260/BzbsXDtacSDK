//
//  MajorViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 26/9/2562 BE.
//

import UIKit

@objc open class MajorCampaignListViewController: BaseListController {
    
    // MARK:- Class function
    // MARK:-
    @objc open class func getViewController(isHideNav:Bool = false) -> MajorCampaignListViewController {
        
        let storyboard = UIStoryboard(name: "Util", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "major_list_view") as! MajorCampaignListViewController
        return controller
    }
    
    @objc open class func getViewControllerWithNav(isHideNav:Bool = false, hashtag:String) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Util", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "major_list_view") as! MajorCampaignListViewController
        let item = BzbsDashboard()
        item.hashtag = hashtag
        controller.dashboard = item
        controller.hidesBottomBarWhenPushed = true
        let nav = UINavigationController(rootViewController: controller)
        return nav
    }
    
    
    @objc open class func getViewController(isHideNav:Bool = false, hashtag:String) -> MajorCampaignListViewController {
        let storyboard = UIStoryboard(name: "Util", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "major_list_view") as! MajorCampaignListViewController
        let item = BzbsDashboard()
        item.hashtag = hashtag
        controller.dashboard = item
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "campaignCell")
            collectionView.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "campaignCoinCell")
            collectionView.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "campaignRotateCell")
            collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
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
    var dashboard : BzbsDashboard!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
        vwSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        self.getApi()
        if dashboard.imageUrl == nil || dashboard.imageUrl == "" {
            getMajorImage()
        }
        
        addPullToRefresh(on: collectionView)
        // Do any additional setup after loading the view.
    }
    
    private let refreshControl = UIRefreshControl()
    func addPullToRefresh(on tableView: UICollectionView) {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSelector), for: .valueChanged)
    }
    
    @objc func refreshSelector() {
        self._isEnd = false
        self._intSkip = 0
        self.getApi()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK:- View Life cycle
    // MARK:-
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = !isHideNav
    }
    
    // MARK:- API
    // MARK:-
    var customConfig : String?
    func getConfig() -> String{
        return customConfig ?? BzbsConfig.campaignDefault
    }
    
    let _intTop = 6
    override func getApi() {
        if _isCallApi || _isEnd { return }
        _isCallApi = true
        collectionView.reloadData()
        showLoader()
        controller.list(config: getConfig()
            , top : _intTop
            , skip: _intSkip
            , search: ""
            , catId: nil
            , hashTag: hashTag
            , token: Bzbs.shared.userLogin?.token
            , center : LocationManager.shared.getCurrentCoorndate()
            , successCallback: { (tmpList) in
                
                if self._intSkip == 0 {
                    self._arrDataShow = tmpList
                } else {
                    self._arrDataShow.append(contentsOf: tmpList)
                }
                
                // wordaround odd collection list count
                if self._arrDataShow.count % 2 != 0 {
                    let dummyCampaign = BzbsCampaign()
                    dummyCampaign.ID = -1
                    self._arrDataShow.append(dummyCampaign)
                }
                //------
                self._isEnd = tmpList.count < self._intTop
                self._intSkip += self._intTop
                self.loadedData()
        }) { (error) in
            self._isEnd = true
            self.loadedData()
        }
    }
    
    func getMajorImage()
    {
        guard let key = hashTag else { return }
        BzbsCoreApi().getMajorInfo(key, successCallback: { (dict) in
            self.dashboard.line1 = dict["line1"] as? String
            self.dashboard.line2 = dict["line2"] as? String
            self.dashboard.imageUrl = dict["image_url"] as? String
            self.collectionView.reloadData()
        }) { (error) in
            self.collectionView.reloadData()
            print(error.description())
        }
    }
    
    override func loadedData() {
        self.hideLoader()
        collectionView.stopPullToRefresh()
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
extension MajorCampaignListViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return self._arrDataShow.count == 0 ? (_isCallApi ? 0 : 1)  : self._arrDataShow.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if  dashboard.imageUrl == nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBannerDefault", for: indexPath)
                let imv = cell.viewWithTag(20) as! UIImageView
                imv.image = UIImage(named: "img_placeholder", in: Bzbs.shared.currentBundle, compatibleWith: nil)
                return cell
            }
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
        if item.parentCategoryID == BuzzebeesCore.catIdCoin {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCoinCell", for: indexPath) as! CampaignCoinCVCell
            cell.setupWith(item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaignCell", for: indexPath) as! CampaignCVCell
            cell.setupWith(item)
            return cell
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let width = collectionView.frame.size.width
            return CGSize(width: width, height: width * 2 / 3)
        }
        if self._arrDataShow.count == 0
        {
            let width = collectionView.frame.size.width
            return CGSize(width: width, height: (collectionView.frame.size.height * 0.9) - (width * 2 / 3))
        }
        
        let row = indexPath.row
        if _arrDataShow.count - 1  < row { return CampaignCVCell.getSize(collectionView) }
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
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets.zero
        }
        return UIEdgeInsets(top: 8, left: 6, bottom: 0, right: 6)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 || _arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        if item.ID == -1 { return }
        if let nav = self.navigationController
        {
            GotoPage.gotoCampaignDetail(nav, campaign: item, target: self, gaIndex: indexPath.row + 1)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 || _arrDataShow.count == 0 { return }
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


extension MajorCampaignListViewController : UITextFieldDelegate
{
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        GotoPage.gotoSearch(self.navigationController!)
        return false
    }
}
