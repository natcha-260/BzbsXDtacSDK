//
//  FavoriteViewController.swift
//  Pods
//
//  Created by macbookpro on 1/10/2562 BE.
//

import UIKit

class FavoriteViewController: BaseListController {
    
    
    // MARK:- Properties
    // MARK:- Outlet
    
    
    
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
    // MARK:- Class function
    // MARK:-
    open class func getViewController(isHideNav:Bool = false) -> FavoriteViewController {
        
        let storyboard = UIStoryboard(name: "Favorite", bundle: Bzbs.shared.currentBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "scene_favorite_list") as! FavoriteViewController
        controller.isHideNav = isHideNav
        return controller
    }
    
    // MARK:- View Life cycle
    // MARK:-
    
    override func loadView() {
        super.loadView()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetList()
        self.getApi()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = isHideNav
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "favorite_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "favorite_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        initUI()
        getApi()
        self.tableView.es.addPullToRefresh {
            self.resetList()
            self.getApi()
        }
    }
    
    override func updateUI() {
        super.updateUI()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "favorite_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "favorite_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self,selector: #selector(back_1_step))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsSetScreen(screenName: "dtac_reward_favorite")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = !isHideNav
    }
    
    override func addPullToRefresh() {
        createPullToRefresh(tableView){
            OperationQueue().addOperation {
                self.resetList()
            }
        }
    }
    
    override func resetList() {
        _intSkip = 0
        _isEnd = false
    }
    
    func initUI()
    {
       registerNib()
    }
    
    func registerNib()
    {
        tableView.register(FavoriteCell.getNib(), forCellReuseIdentifier: "favoriteCell")
        tableView.register(EmptyTVCell.getNib(), forCellReuseIdentifier: "emptyCell")
        tableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
    }
    
    // MARK:- API
    // MARK:-
    var customConfig : String?
    func getConfig() -> String{
        return customConfig ?? "campaign_dtac"// Bzbs.shared.userLogin?.dtacLevel.campaignConfig ?? "campaign_dtac_guest"
    }
    
    let _intTop = 6
    override func getApi() {
        guard let token = Bzbs.shared.userLogin?.token else { return }
        
        if _isCallApi || _isEnd { return }
        _isCallApi = true
        showLoader()
        controller.favoriteList(token: token
            , top : _intTop
            , skip: _intSkip, locale: LocaleCore.shared.getUserLocale()
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
            print("error : \(error.description())")
        }
    }
    
    override func loadedData() {
        self._isCallApi = false
        self.tableView.reloadData()
        self.tableView.es.stopPullToRefresh()
        self.hideLoader()
    }
    
    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApi()
    }
    
    // MARK:- Action
    @IBAction func clickFavourite(_ sender: Any ,forEvent event: UIEvent) {
        
        let touch: UITouch = event.allTouches!.first!
        let point: CGPoint = touch.location(in: tableView)
        
        if let indexPath: IndexPath = tableView.indexPathForRow(at: point)
        {
            let itemCampaign = _arrDataShow[indexPath.row] as! BzbsCampaign
            if let token = Bzbs.shared.userLogin?.token
            {
                showLoader()
                BuzzebeesCampaign().favourite(token: token
                    , campaignId: itemCampaign.ID
                    , isFav: false
                    , successCallback: { (str) in
                    self.hideLoader()
                        
                        if self._arrDataShow.count == 1 {
                            self._arrDataShow.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        }else{
                            self.tableView.beginUpdates()
                            self._arrDataShow.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.tableView.endUpdates()
                        }
                        
                        
                }) { (error) in
                self.hideLoader()
                }
            }
        }
        
        
    }
    
    // MARK:- ScrollView
    @objc override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let location = scrollView.contentOffset
        if location.y > tableView.contentSize.height * 0.7
        {
            if _arrDataShow.count > 0 && _isEnd == false { getApi() }
        }
    }
}


// MARK:- Extension
// MARK:- UITableView DataSource, Delegate
extension FavoriteViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if _arrDataShow.count == 0 { return 1 }
        
        return _arrDataShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if _arrDataShow.count == 0 {
            if _isCallApi {
                return tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTVCell
            cell.imv.image = UIImage(named: "ic_reward_favorite", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            cell.lbl.text = "favorite_empty".localized()
            return cell
        }
        
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        cell.setupWith(item)
        cell.btnFav.addTarget(self, action: #selector(self.clickFavourite), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellHeight(indexPath: indexPath)
    }
    
    func getCellHeight(indexPath: IndexPath) -> CGFloat
    {
        if(_arrDataShow.count == 0 )
        {
            return tableView.frame.height;
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if _arrDataShow.count == 0 { return }
        let item = _arrDataShow[indexPath.row] as! BzbsCampaign
        if item.currentDate > item.expireDate { return }
        if let nav = self.navigationController
        {
            GotoPage.gotoCampaignDetail(nav, campaign: item, target: self)
        }
    }
    
}
