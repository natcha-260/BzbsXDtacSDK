//
//  HistoryViewController.swift
//  Pods
//
//  Created by macbookpro on 1/10/2562 BE.
//

class HistoryViewController: BaseListController {

    // MARK:- Property
    // MARK:-

    var _itemBzbsHistory: BzbsHistory!
    //    let controller = BuzzebeesHistory()
    let controller = BuzzebeesCampaign()
    var isHideNav = false
    var catId:Int?{
        didSet{
            _intSkip = 0
            _isEnd = false
            getApi()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        initUI()
        getApi()
        
        addPullToRefresh(on: tableView)
        // Do any additional setup after loading the view.
    }
    
    private let refreshControl = UIRefreshControl()
    func addPullToRefresh(on tableView: UITableView) {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSelector), for: .valueChanged)
    }
    
    @objc func refreshSelector() {
        self.resetList()
        self.getApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func resetList() {
        _intSkip = 0
        _isEnd = false
    }
    
    // MARK:- Init
    // MARK:-
    func initNavigation()
    {
        self.navigationController?.isNavigationBarHidden = isHideNav
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "history_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "history_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
    }
    
    func initUI()
    {
       registerNib()
    }
    
    override func updateUI() {
        super.updateUI()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "history_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "history_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        resetList()
        getApi()
        tableView.reloadData()
    }
    
    func registerNib()
    {
        tableView.register(HistoryCell.getNib(), forCellReuseIdentifier: "historyCell")
        tableView.register(EmptyTVCell.getNib(), forCellReuseIdentifier: "emptyCell")
        tableView.register(BlankTVCell.getNib(), forCellReuseIdentifier: "blankCell")
    }
    
    // MARK:- API
    // MARK:-
    var customConfig : String?
    func getConfig() -> String{
        return customConfig ?? "campaign_dtac"//  Bzbs.shared.userLogin?.dtacLevel.campaignConfig ?? "campaign_dtac_guest"
    }
    
    let _intTop = 6
    override func getApi() {
        guard let token = Bzbs.shared.userLogin?.token else {
            loadedData()
            return
        }
        if _isCallApi || _isEnd {
            if _isEnd {
                loadedData()
            }
            return
        }
        
        showLoader()
        _isCallApi = true
        BuzzebeesHistory().list(config: BzbsConfig.historyPurchase, token:token , skip: _intSkip, successCallback: { (tmpHistory) in
            if self._intSkip == 0 {
                self._arrDataShow = tmpHistory
            } else {
                self._arrDataShow.append(contentsOf: tmpHistory)
            }
            self._isEnd = tmpHistory.count < self._intTop
            self._intSkip += self._intTop
            self.loadedData()
        }) { (error) in
            self._isEnd = true
            self.loadedData()
        }
    }
    
    override func loadedData() {
        self.hideLoader()
        self._isCallApi = false
        self.tableView.reloadData()
        self.tableView.stopPullToRefresh()
    }

    override func refreshApi() {
        _intSkip = 0
        _isEnd = false
        getApi()
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
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if _arrDataShow.count == 0 { return 1 }
        
        return _arrDataShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if _arrDataShow.count == 0
        {
            if _isCallApi {
                return tableView.dequeueReusableCell(withIdentifier: "blankCell", for: indexPath)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTVCell
            cell.imv.image = UIImage(named: "ic_reward_history", in: Bzbs.shared.currentBundle, compatibleWith: nil)
            cell.lbl.text = "history_empty".localized()
            return cell
        }
        let item = _arrDataShow[indexPath.row] as! BzbsHistory
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        cell.setupWith(item)
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
        if _arrDataShow.count == 0
        {
            return
        }
        
        let item = _arrDataShow[indexPath.row] as! BzbsHistory
        //แสดงหน้า expired ก่อน หน้าอื่นยังไม่มี จริงๆต้องเป็น history
//        if let _ = item.arrangedDate { return } else
//            if let expireIn = item.expireIn, expireIn <= 0 { return }
        
        guard let _ = item.redeemKey else { return }
        guard let _ = Bzbs.shared.userLogin?.token else { return }

        delay(0.33) {
            PopupManager.serialPopup(onView: self,
                                     purchase: item,
                                     isNeedUpdate: true,
                                     parentCategoryName: nil,
                                     parentSubCategoryName: nil,
                                     gaIndex: indexPath.row)
        }
    }
    
}

extension HistoryViewController: PopupSerialDelegate
{
    func didClosePopup() {
        resetList()
        getApi()
    }
}
