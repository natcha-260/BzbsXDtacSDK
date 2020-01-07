//
//  BaseListController.swift
//  BPoint
//
//  Created by Phagcartorn Suwansee on 12/6/16.
//  Copyright © 2016 buzzebees. All rights reserved.
//

import UIKit
import ESPullToRefresh

open class BaseListController: BzbsXDtacBaseViewController
{
    // MARK:- Property
    // MARK:-
    
    var strConfig: String!
    var strFolderCache: String!
    var strCache: String!
    var strTitle: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Life cycle
    // MARK:-
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        strConfig = "campaign_bzbs"
        strCache = strConfig + ".txt"
        strFolderCache = "Campaign"
        strTitle = ""
//        addPullToRefresh()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if _arrDataShow.count == 0
        {
            getCache()
        }
        //        self.title = language(strMessage: strTitle)
        
        //        navigationItem.leftBarButtonItems = BarItem.generate_blank()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Call api
    // MARK:-
    var _arrDataShow = [AnyObject]()
    var _intSkip = 0
    var _isCallApi = false
    var _isEnd = false
    var _isLoadData = false
    
    func getApi()
    {
        // Override this
    }
    
    func getCache()
    {
        //        CacheCore.shared.loadCacheData(strFolderCache
        //            , fileName: strCache
        //            , successCallback: { (result) in
        //                if let arrJSON = result as? [Dictionary<String, AnyObject>]
        //                {
        //                    self.assignUI(arrJSON: arrJSON)
        //                }
        //
        //                self.getApi()
        //        }
        //            , failCallback: { () in
        //                self.getApi()
        //        })
    }
    
    func cacheGetCampaign() {
        
    }
    
    func assignUI(arrJSON: [Dictionary<String, AnyObject>])
    {
        // Override this
    }
    
    // MARK:- Override base
    // MARK:-
    
    //    override func updateUI() {
    //        super.updateUI()
    
    //        if let itemTitle = strTitle
    //        {
    //            title = language(strMessage: itemTitle)
    //        }
    //
    //        if strCache != nil
    //        {
    //            _intSkip = 0
    //            getCache()
    //        }
    //
    //        tableView.reloadData()
    //    }
    
    // MARK:- Pull To Refresh
    // MARK:-
    func createPullToRefresh(_ target: UIView, textColor: UIColor = UIColor.white, width: CGFloat = UIScreen.main.bounds.width, callBack: @escaping () -> Void)
    {
        //        let beatAnimator = BeatAnimator(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        //        beatAnimator.textColor = textColor
        //
        if let tableTarget = target as? UITableView
        {
            tableTarget.es.addPullToRefresh {
                OperationQueue().addOperation {
                    sleep(1)
                    callBack()
                }
            }
        }

        if let collectionTarget = target as? UICollectionView
        {
            collectionTarget.es.addPullToRefresh {
                OperationQueue().addOperation {
                    sleep(1)
                    callBack()
                }
            }
        }
    }
    
    // MARK:- Util
    // MARK:-
    
    func addPullToRefresh()
    {
        if tableView != nil {
            createPullToRefresh(tableView){
                OperationQueue().addOperation {
                    self.resetList()
                }
            }
        }
    }
    
    func resetList()
    {
        self._intSkip = 0
        self._isEnd = false
        self._isCallApi = false
        self.getApi()
    }
    
    func clearForFavourite() {
        self._intSkip = 0
        self._isEnd = false
        self._isCallApi = false
    }
    
    func loadedData()
    {
        _isCallApi = false
        _isLoadData = true
        self.hideLoader()
        if tableView != nil {
            tableView.reloadData()
        }
        //        tableView.stopPullToRefresh()
    }
}
