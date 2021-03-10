//
//  NearbyListViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 27/9/2562 BE.
//

import UIKit

class NearbyListViewController: BaseListController {

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(CampaignCVCell.getNib(), forCellWithReuseIdentifier: "recommendCell")
            collectionView.register(CampaignCoinCVCell.getNib(), forCellWithReuseIdentifier: "recommendCoinCell")
            collectionView.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "campaignRotateCell")
            collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
            collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4)
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
    var currentCenter = LocationManager.shared.getCurrentCoorndate()
    let _intTop = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "nearby_map_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
//        //self.title = "nearby_map_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        self.navigationItem.rightBarButtonItems = BarItem.generate_map(self, selector: #selector(clickMaps))

        if LocationManager.shared.authorizationStatus == .denied {
            _isEnd = true
            return
        }
        analyticsSetScreen(screenName: "dtac_reward_nearby")
        getApi()
        
        addPullToRefresh(on: collectionView)
        // Do any additional setup after loading the view.
    }
    
    private let refreshControl = UIRefreshControl()
    func addPullToRefresh(on tableView: UICollectionView) {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSelector), for: .valueChanged)
    }
    
    @objc func refreshSelector() {
        self.currentCenter = LocationManager.shared.getCurrentCoorndate()
        self._intSkip = 0
        self._isEnd = false
        self.getApi()
    }
    
    override func updateUI() {
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "nearby_map_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "nearby_map_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        getApi()
    }
    
    var mapViewcontroller : MapsViewController?
    @objc func clickMaps()
    {
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        let tmpCampaignList = _arrDataShow as! [BzbsCampaign]
        for item in tmpCampaignList
        {
            if item.places.count == 0 {
                if let latitude = item.latitude, let longitude = item.longitude
                {
                    let place = BzbsPlace()
                    place.name = item.agencyName ?? "-"
                    place.latitude = latitude
                    place.longitude = longitude
                    place.locationId = item.locationAgencyId
                    item.places.append(place)
                }
            }
        }
        
        guard let mapVc = mapViewcontroller else {
            mapViewcontroller = GotoPage.gotoMap(self.navigationController!, campaigns: tmpCampaignList)
            mapViewcontroller?.backSelector = {
                self.mapViewcontroller = nil
            }
            return
        }
        
        mapVc.campaigns = tmpCampaignList
        self.navigationController?.pushViewController(mapVc, animated: true)
        
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
        return customConfig ?? "campaign_dtac"// Bzbs.shared.userLogin?.dtacLevel.campaignConfig ?? "campaign_dtac_guest"
    }
    
    override func getApi() {
        
        if LocationManager.shared.authorizationStatus == .denied {
            _isEnd = true
        }
        
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        
        if _isCallApi || _isEnd
        {
            self.loadedData()
            return
        }

        self._isCallApi = true
        showLoader()
        BuzzebeesCampaign().list(config: "campaign_dtac_nearby"
            , top: _intTop
            , skip: _intSkip
            , search: ""
            , catId: nil
            , hashTag: nil
            , token: Bzbs.shared.userLogin?.token
            , center: currentCenter
            , successCallback: { (tmpCampaignList) in
            self._isCallApi = false
                if self._intSkip ==  0 {
                    self._arrDataShow = tmpCampaignList
                } else {
                    self._arrDataShow.append(contentsOf: tmpCampaignList)
                }
                
                self._isEnd = tmpCampaignList.count < self._intTop
                self._intSkip += self._intTop
                self.loadedData()
        }, failCallback: { (error) in
            self._isEnd = true
            self._isCallApi = false
            self.loadedData()
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    override func loadedData() {
        DispatchQueue.main.async {
            self.collectionView.stopPullToRefresh()
            self.collectionView.reloadData()
            self.hideLoader()
        }
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApi()
    }
}


// MARK:- Extension
// MARK:- UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension NearbyListViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._arrDataShow.count == 0 ? 1 : self._arrDataShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if _arrDataShow.count == 0 {
            if _isCallApi
            {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCell", for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptyCVCell
            cell.imv.image = UIImage(named: "ic_reward_location", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            cell.lbl.text = "nearby_empty".localized()
            return cell
        }
        
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        if item.parentCategoryID == BuzzebeesCore.catIdCoin {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCoinCell", for: indexPath) as! CampaignCoinCVCell
            cell.setupWith(item, isShowDistance: false)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        cell.setupWith(item, isShowDistance: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if _arrDataShow.count == 0 {
            let width = collectionView.frame.size.width
            let height = collectionView.frame.size.height
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if _arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
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
