//
//  SearchViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import UIKit
import FirebaseAnalytics

class SearchViewController: BaseListController {
    
    //MARK:- Properties
    //MARK:- Outlet
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var vwCancel: UIView!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var cstWidth: NSLayoutConstraint!
    @IBOutlet weak var vwAutoComplete: UIView!
    @IBOutlet weak var vwSearchResuilt: UIView!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    @IBOutlet weak var cstAutoCompleteHeight: NSLayoutConstraint!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    
    //MARK:- Variable
    var isSearchShowing = false
    var searchResult : [String]{
        return searchResultCampaign.compactMap({ (campaign) -> String in
            return campaign.name
        })
    }
    var searchResultCampaign = [BzbsCampaign]()
    var autoCompleteResult = [String]()
    var searchHistory = [String](){
        didSet{
            saveSearchHistory()
        }
    }
    var strSearch = ""
    var strAutoCompleteSearch = ""
    var campaignAPI = BuzzebeesCampaign()
    var searchResultVC : SearchResultListController?
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.delegate = self
        txtSearch.font = UIFont.mainFont()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
        vwAutoComplete.alpha = 0
        vwAutoComplete.cornerRadius(borderColor: UIColor.mainLightGray, borderWidth: 1)
        autoCompleteReload()
        vwSearchResuilt.alpha = 0
        autoCompleteTableView.register(AutoCompleteTVCell.getNib(), forCellReuseIdentifier: "autoCompleteCell")
        tableView.register(SearchTableViewCell.getNib(), forCellReuseIdentifier: "searchCell")
        tableView.register(CategoryTableViewCell.getNib(), forCellReuseIdentifier: "categoryCell")

        viewSearch.cornerRadius(borderColor: UIColor.lightGray.withAlphaComponent(0.6), borderWidth: 1)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
//        //self.title = "search_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        lblCancel.font = UIFont.mainFont()
        lblCancel.text = "popup_cancel".localized()
        lblCancel.textColor = .dtacBlue
        closeCancel()
        loadSearchHistory()
        analyticsSetScreen(screenName: "reward_search")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func updateUI() {
        super.updateUI()
        
        txtSearch.attributedPlaceholder = NSAttributedString(string: "search_placholder".localized(), attributes: [NSAttributedString.Key.font : UIFont.mainFont(.big), NSAttributedString.Key.foregroundColor:UIColor.mainGray])
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "search_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        //        //self.title = "search_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
        lblCancel.text = "popup_cancel".localized()
        getApi()
        tableView.reloadData()
    }
    
    //MARK:- Util
    //MARK:-
    override func getApi() {
        if strSearch != ""
        {
            sendGASearch()
            UIView.animate(withDuration: 0.22) {
                self.vwSearchResuilt.alpha = 1
            }
            searchResultVC?.strSearch = strSearch
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search_result",
            let vc = segue.destination as? SearchResultListController
        {
            searchResultVC = vc
            searchResultVC?.strSearch = ""
        }
    }
    
    //MARK:- Util
    //MARK:-
    
    func closeCancel()
    {
        isSearchShowing = false
        tableView.reloadData()
        UIView.animate(withDuration: 0.22) {
            self.vwAutoComplete.alpha = 0
            self.vwCancel.isHidden = true
            self.cstWidth.constant = 0
            self.vwCancel.layoutIfNeeded()
        }
    }
    
    func showCancel()
    {
        isSearchShowing = true
        tableView.reloadData()
        UIView.animate(withDuration: 0.22) {
//            self.vwAutoComplete.alpha = 1
            self.vwCancel.isHidden = false
            self.cstWidth.constant = 80
            self.vwCancel.layoutIfNeeded()
        }
    }
    let maxNumberAutocompleteResult = 10
    func autoCompleteReload()
    {
        let count = autoCompleteResult.count
        UIView.animate(withDuration: 0.1) {
            self.cstAutoCompleteHeight.constant = 40 * CGFloat(count)
        }

        autoCompleteTableView.reloadData()
    }
    
    func apiAutoComplete(_ q:String)
    {
        strAutoCompleteSearch = q
        if strAutoCompleteSearch != "" {
            self.vwAutoComplete.alpha = 1
        } else {
            self.vwAutoComplete.alpha = 0
        }
        BzbsCoreApi().searchAutoComplete(Bzbs.shared.userLogin?.token
            , keyword: q, successCallback: { (arrKeyword) in
                self.autoCompleteResult.removeAll()
                if arrKeyword.count > 10 {
                    for i in 0..<10 {
                        self.autoCompleteResult.append(arrKeyword[i])
                    }
                } else {
                    self.autoCompleteResult = arrKeyword
                }
                self.autoCompleteReload()
        }) { (error) in
            self.autoCompleteResult.removeAll()
            self.autoCompleteReload()
        }
    }
    
    // MARK:-  Load/Save History
    func loadSearchHistory()
    {
        let userDefault = UserDefaults.standard
        if let tmpSearchHistory = userDefault.array(forKey: "searchHistory") as? [String]
        {
            searchHistory = tmpSearchHistory
        }
    }
    
    func saveSearchHistory()
    {
        if searchHistory.count > 5 {
            searchHistory.removeFirst()
        }
        let userDefault = UserDefaults.standard
        userDefault.set(searchHistory, forKey: "searchHistory")
    }
    
    @objc func clearHistory()
    {
        searchHistory.removeAll()
        saveSearchHistory()
        tableView.reloadData()
    }
    
    // MARK:- Event
    // MARK:- Click
    @IBAction func clickCancel(_ sender: Any) {
        closeCancel()
        strSearch = ""
        txtSearch.text = ""
        vwAutoComplete.alpha = 0
        vwSearchResuilt.alpha = 0
        autoCompleteResult.removeAll()
        self.view.endEditing(true)
    }
    
    // MARK:- Keyboard
    @objc func keyboardWillBeShown(noti: Notification) {
        let userInfo = noti.userInfo
        if let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        {
            let height = keyboardFrame.size.height
            UIView.animate(withDuration: 0.33) {
                self.cstBottom.constant = height
            }
        }
    }
    
    @objc func keyboardWillBeHidden(noti: Notification) {
        UIView.animate(withDuration: 0.33) {
            self.cstBottom.constant = 0
        }
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == autoCompleteTableView{
            return 1
        }
        return isSearchShowing ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoCompleteTableView{
            return autoCompleteResult.count
        }
        if section == 0 {
            return isSearchShowing ? searchHistory.count : 2
        }
        if section == 1 {
            return isSearchShowing ? 0 : 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        
        if tableView == autoCompleteTableView{
            let item = autoCompleteResult[row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell", for: indexPath) as! AutoCompleteTVCell
            cell.setText(item, hilightText: strAutoCompleteSearch)
            return cell
        }
        
        if section == 0 {
            if isSearchShowing {
                let item = searchHistory[(searchHistory.count - 1) - row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
                cell.setupSearchCell(image: UIImage(named: "img_search_icon_search", in: Bzbs.shared.currentBundle, compatibleWith: nil)!
                    , title: item, isShowClosure: false)
                return cell
            }
            
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
                cell.setupSearchCell(image: UIImage(named: "img_search_icon_map", in: Bzbs.shared.currentBundle, compatibleWith: nil)!
                    , title: "search_map".localized(), isShowClosure: true)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
            cell.setupSearchCell(image: UIImage(named: "img_search_icon_fav", in: Bzbs.shared.currentBundle, compatibleWith: nil)!
                , title: "favorite_title".localized(), isShowClosure: true)
            return cell
        }
        if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
            cell.customContentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            cell.delegate = self
            if let arrCat = Bzbs.shared.arrCategory {
                cell.arrCategory = arrCat
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "cellBlank", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == autoCompleteTableView{
            return 40
        }
        
        let section = indexPath.section
        if section == 0 {
            return 50
        }
        if section == 1 {
            if let arr = Bzbs.shared.arrCategory
            {

                let width = tableView.frame.size.width / 4.5
                
                let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.leastNonzeroMagnitude))
                lbl.font = UIFont.mainFont(.small)
                lbl.text = "\n"
                lbl.sizeToFit()
                let height = (width / 2) + lbl.frame.size.height
                
                return height * ceil(CGFloat(arr.count) / CGFloat(4)) + 14
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == autoCompleteTableView{
            let item = autoCompleteResult[indexPath.row]
            sendGAClickHistorySearch(string: item)
            txtSearch.text = item
            self.view.endEditing(true)
            vwAutoComplete.alpha = 0
            return
        }
        let row = indexPath.row
        let section = indexPath.section
        if tableView == autoCompleteTableView {
            return
        }
        
        if section == 0 {
            if isSearchShowing {
                let item = searchHistory[(searchHistory.count - 1) - indexPath.row]
                txtSearch.text = item
                view.endEditing(true)
//                closeCancel()
//                getApi()
                return
            }
            if row == 0 {
                sendGAClickMap()
                if LocationManager.shared.authorizationStatus == .denied  {
                    PopupManager.confirmPopup(self, message: "popup_location_denied".localized(), strConfirm: "popup_setting".localized(), strClose: "popup_deny".localized(), confirm: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                            UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                UIApplication.shared.openURL(settingsUrl)
                            }
                        }
                    }) {
                        self.gotoMap()
                    }
                } else {
                    gotoMap()
                }
                
                return
            }
            sendGAClickFavour()
            GotoPage.gotoFavourite(self.navigationController!)
        }
    }
    
    func gotoMap()
    {
        showLoader()
        BuzzebeesCampaign().list(config: "campaign_dtac_nearby"
            , top: 25
            , skip: 0
            , search: ""
            , catId: nil
            , hashTag: nil
            , token: Bzbs.shared.userLogin?.token
            , center: LocationManager.shared.getCurrentCoorndate()
            , successCallback: { (tmpCampaignList) in
                
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
                self.hideLoader()
                DispatchQueue.main.async {
                    let _ = GotoPage.gotoMap(self.navigationController! ,campaigns: tmpCampaignList, customHeader:"search_map".localized(), isShowBackToList:false)
                }
        }, failCallback: { (error) in
            self.hideLoader()
            DispatchQueue.main.async {
                let _ = GotoPage.gotoMap(self.navigationController!, campaigns: [BzbsCampaign]())
            }
            if self.isDtacError(Int(error.id)!, code:Int(error.code)!,  message: error.message) { return }
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == autoCompleteTableView{
            return UIView()
        }
        
        if section == 0 && isSearchShowing
        {
            let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
            vw.backgroundColor = .white
            let lbl = UILabel(frame: CGRect(x: 32, y: 16, width: tableView.bounds.size.width - 32 - 32, height:  44 - 8 - 8))
            lbl.font = UIFont.mainFont()
            lbl.textColor = .gray
            lbl.text = "search_history_title".localized()
            vw.addSubview(lbl)
            if searchHistory.count > 0 {
                let lblClear = UILabel(frame: CGRect(x: tableView.bounds.size.width - 80 - 15, y: 16, width: 80, height: 44 - 8 - 8))
                lblClear.font = UIFont.mainFont()
                lblClear.textColor = .dtacBlue
                lblClear.text = "search_clear".localized()
                lblClear.textAlignment = .center
                vw.addSubview(lblClear)
                let btn = UIButton(frame: lblClear.frame)
                btn.addTarget(self, action: #selector(clearHistory), for: UIControl.Event.touchUpInside)
                vw.addSubview(btn)
            }
            return vw
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == autoCompleteTableView{
            return 0
        }
        return (section == 0 && isSearchShowing) ? 44 : 0
    }
    
}

// MARK:- UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate
{
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        vwAutoComplete.alpha = 0
        autoCompleteResult.removeAll()
        autoCompleteTableView.reloadData()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showCancel()
        autoCompleteReload()
        if strAutoCompleteSearch != "" {
            self.vwAutoComplete.alpha = 1
        } else {
            self.vwAutoComplete.alpha = 0
        }
        
        self.vwSearchResuilt.alpha = 0
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !string.isAllowedCharacter() {
            return false
        }
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        print(txtAfterUpdate)
        apiAutoComplete(txtAfterUpdate as String)
        
        self.vwSearchResuilt.alpha = 0
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vwAutoComplete.alpha = 0
        if let text = textField.text {
            if text != strSearch{
                _intSkip = 0
                _isEnd = false
                strSearch = text
                getApi()
            }
            if text != "" {
                if searchHistory.contains(text)
                {
                    searchHistory.removeAll { (str) -> Bool in
                        return str == text
                    }
                }
                searchHistory.append(text)
                tableView.reloadData()
            }
        }
        if textField.text == ""{
            closeCancel()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// MARK:- CategoryCVCellDelegate
extension SearchViewController : CategoryCVCellDelegate
{
    func didSelectedItem(index: Int) {
        self.view.endEditing(true)
        if !isConnectedToInternet() {
            showPopupInternet()
            return
        }
        if let arrCategory = Bzbs.shared.arrCategory
        {
            let item = arrCategory[index]
            sendGAClickCategory(item)
            if let nav = self.navigationController
            {
                if item.mode == "near_by"
                {
                    if LocationManager.shared.authorizationStatus == .denied  {
                        PopupManager.confirmPopup(self, message: "popup_location_denied".localized(), strConfirm: "popup_setting".localized(), strClose: "popup_deny".localized(), confirm: {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                UIApplication.shared.canOpenURL(settingsUrl) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                } else {
                                    UIApplication.shared.openURL(settingsUrl)
                                }
                            }
                        }) {
                            GotoPage.gotoNearby(nav)
                        }
                    } else {
                        GotoPage.gotoNearby(nav)
                    }
                }else {
                    GotoPage.gotoCategory(nav, cat: item, arrCategory: arrCategory)
                }
            }
        }
    }
}

extension SearchViewController : UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK:- GA
// MARK:-
extension SearchViewController {
    
    // FIXME:GA#34
    func sendGAClickMap() {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search | map")
    }
    
    // FIXME:GA#35
    func sendGAClickFavour() {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search | favorites")
    }
    
    // FIXME:GA#36
    func sendGAClickCategory(_ item:BzbsCategory) {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search | \(item.name ?? BzbsAnalyticDefault.subCategory.rawValue)")
    }
    
    // FIXME:GA#37
    func sendGAClickHistorySearch(string:String) {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search_history | \(string)")
    }
    
    // FIXME:GA#38
    func sendGASearch()
    {
        analyticsSetEvent(event: "event_app", category: "reward", action: "touch_button", label: "search_text | \(strSearch)")
    }
    
    
}

extension String {

    func isAllowedCharacter() -> Bool {
        
        var characterset = CharacterSet.letters.union(CharacterSet.alphanumerics)
        characterset.insert("\'")
        characterset.insert(" ")
        
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        return true
    }
}

