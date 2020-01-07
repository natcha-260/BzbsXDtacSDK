//
//  SearchResultListController.swift
//  Pods
//
//  Created by Buzzebees iMac on 26/9/2562 BE.
//

import UIKit

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
        collectionView.register(EmptyCVCell.getNib(), forCellWithReuseIdentifier: "emptyCell")
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 8, right: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
        self.navigationItem.titleView = lblTitle
        //self.title = "search_title".localized()
        lblSearchResults.font = UIFont.mainFont()
        lblSearchResults.text = "About 0 results"
        getApi()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = !isHideNav
    }
    
    override func updateUI() {
        super.updateUI()
//        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNormalMagnitude, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
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
        if _isCallApi || _isEnd { return }
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
                self.loadedData()
        }) { (error) in
            self._isEnd = true
            self.loadedData()
        }
    }
    
    override func loadedData() {
        self.collectionView.es.stopPullToRefresh()
        self.collectionView.reloadData()
        self._isCallApi = false
        self.hideLoader()
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
            return collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCell", for: indexPath) as! CampaignCVCell
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        cell.setupWith(item, isShowDistance: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self._arrDataShow.count == 0 {
            let width = collectionView.frame.size.width - 16
            let height = collectionView.frame.size.height * 0.9
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._arrDataShow.count == 0 { return }
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
