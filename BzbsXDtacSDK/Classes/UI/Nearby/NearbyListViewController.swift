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
            collectionView.register(CampaignRotateCVCell.getNib(), forCellWithReuseIdentifier: "campaignRotateCell")
            collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
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
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "nearby_map_title".localized()
        self.navigationItem.titleView = lblTitle
//        //self.title = "nearby_map_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        self.navigationItem.rightBarButtonItems = BarItem.generate_map(self, selector: #selector(clickMaps))
        collectionView.es.addPullToRefresh {
            self.currentCenter = LocationManager.shared.getCurrentCoorndate()
            self._intSkip = 0
            self._isEnd = false
            self.getApi()
        }
        if LocationManager.shared.authorizationStatus == .denied {
            _isEnd = true
            return
        }
        analyticsSetScreen(screenName: "dtac_reward_nearby")
        getApi()
    }
    override func updateUI() {
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "nearby_map_title".localized()
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
            self.collectionView.es.stopPullToRefresh()
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        cell.setupWith(item, isShowDistance: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if _arrDataShow.count == 0 {
            let width = collectionView.frame.size.width
            let height = collectionView.frame.size.height
            return CGSize(width: width, height: height)
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