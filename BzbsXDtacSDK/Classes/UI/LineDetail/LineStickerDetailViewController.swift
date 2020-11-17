//
//  LineStickerDetail.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 5/10/2563 BE.
//

import UIKit
import FirebaseAnalytics

class LineStickerDetailViewController: BzbsXDtacBaseViewController {
    
    @IBOutlet weak var imvLogo: UIImageView!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblCoins: UILabel!
    @IBOutlet weak var lblMyCoin: UILabel!
    @IBOutlet weak var vwChoose: UIView!
    @IBOutlet weak var lblChoose: UILabel!
    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var cstCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.alwaysBounceVertical = true
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
            
            collectionView.register(BlankCVCell.getNib(), forCellWithReuseIdentifier: "blankCell")
            collectionView.register(LineStickerCollectionViewCell.getNib(), forCellWithReuseIdentifier: "imageCell")
        }
    }
    var campaignId : String!
    var packageId : String!
    var bzbsCampaign : BzbsCampaign!
    var lineCampaign : LineStickerCampaign?
    var lineImageList = [LineStickerImage]()
    let bzbsCoreApi = BzbsCoreApi()
    var selectedImage : LineStickerImage?
    var resetCellTimer : Timer?
    
    // MARK:- View life cycle
    // MARK:-
    override func loadView() {
        super.loadView()
        initNav()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analyticsSetScreen(screenName: "reward_detail")
        
        lblAgency.font = UIFont.mainFont(.small)
        lblName.font = UIFont.mainFont(.big)
        lblExpireDate.font = UIFont.mainFont(.small)
        lblCoins.font = UIFont.mainFont(.small)
        lblMyCoin.font = UIFont.mainFont(.small)
        lblChoose.font = UIFont.mainFont(style:.bold)
        lblDescription.font = UIFont.mainFont(.small)
        lblInfo.font = UIFont.mainFont(.small)
        
        lblExpireDate.textColor = .gray
        lblMyCoin.textColor = .gray
        lblDescription.textColor = .gray
        lblInfo.textColor = .gray
        
        lblAgency.text = (bzbsCampaign.agencyName ?? " ")
        lblName.text = bzbsCampaign.name ?? " "
        lblExpireDate.text = "line_detail_no_expire_date".localized()
        lblCoins.text = String(format: "line_detail_coin_format".localized(), (bzbsCampaign.pointPerUnit ?? 0).withCommas())
        lblMyCoin.text = String(format: "line_detail_your_coin_format".localized(), (Bzbs.shared.userLogin?.bzbsPoints ?? 0).withCommas())
        lblChoose.text = "line_detail_choose".localized()
        lblDescription.text = " "
        lblInfo.text = "line_detail_preview".localized()
        vwBackground.backgroundColor = .lineBG
        initNav()
        apiGetCampaignDetail()
    }
    
    override func initNav() {
        super.initNav()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont(.big, style: .bold)
        lblTitle.textColor = .white
        lblTitle.numberOfLines = 0
        lblTitle.text = "line_detail_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step), isWhiteIcon: true)
        self.navigationController?.navigationBar.tintColor = .lineNav
        self.navigationController?.navigationBar.backgroundColor = .lineNav
        self.navigationController?.navigationBar.barTintColor = .lineNav
    }
    
    // MARK:- API
    // MARK:-
    func apiGetCampaignDetail() {
        if let strDictLineDetail = bzbsCampaign.deliveryJson {
            do {
                if let data = strDictLineDetail.data(using: String.Encoding.utf8) ,
                    let dictJson = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, AnyObject>
                {
                    if let detailDict = dictJson["detail"] as? Dictionary<String, AnyObject>{
                        self.lineCampaign = LineStickerCampaign(dict: detailDict)
                    }
                    
                    if let arrLineImage = dictJson["image"] as? [Dictionary<String, AnyObject>] {
                        self.lineImageList = [LineStickerImage]()
                        for item in arrLineImage {
                            self.lineImageList.append(LineStickerImage(item))
                        }
                    }
                    self.setupUI()
                } else {
                    PopupManager.informationPopup(self, message: "Please try again") {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } catch _ {
                PopupManager.informationPopup(self, message: "Please try again") {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func apiGetPreview() {
        guard let token = Bzbs.shared.userLogin?.token else {
            PopupManager.informationPopup(self, message: "Login before use") {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            return
        }
        bzbsCoreApi.getLineImageList(token: token, campaignId: campaignId, packageId: packageId) { (tmpImageList) in
            self.lineImageList = tmpImageList
            self.collectionView.reloadData()
            self.hideLoader()
        } failCallback: { (error) in
            self.hideLoader()
            self.collectionView.reloadData()
        }
    }
    
    func setupUI() {
        self.collectionView.reloadData()
        imvLogo.bzbsSetImage(withURL: lineCampaign?.logoUrl ?? "")
        lblName.text = lineCampaign?.stickerTitle
//        lblCoins.text = String(format: "line_detail_coin_format".localized(), (lineCampaign?.points ?? 0).withCommas())
        lblDescription.text = lineCampaign?.stickerDescription
        UIView.animate(withDuration: 0.33, delay: 0.33, options: UIView.AnimationOptions.curveEaseIn) {
            self.cstCollectionHeight.constant = self.collectionView.contentSize.height
        } completion: { (_) in
            self.cstCollectionHeight.constant = self.collectionView.contentSize.height
        }
    }
    
    // MARK:- Event click
    // MARK:-
    @IBAction func clickChoose(_ sender: Any) {
        sendGA()
        GotoPage.gotoLineRedeem(self.navigationController!, campaignId : campaignId, packageId: packageId, bzbsCampaign: bzbsCampaign, lineCampaign: lineCampaign!)
    }
    
    func sendGA() {
        
        let reward1 : [String:Any] = [
            AnalyticsParameterItemID: "\(campaignId ?? "0")" as NSString,
            AnalyticsParameterItemName: "\(bzbsCampaign.name ?? "")" as NSString,
            AnalyticsParameterItemCategory: "reward/coins/\(bzbsCampaign.categoryName ?? "")" as NSString,
            AnalyticsParameterItemBrand: "\(bzbsCampaign.agencyName ?? "")" as NSString,
            AnalyticsParameterPrice: 0 as NSNumber,
            AnalyticsParameterCurrency: "THB" as NSString,
            AnalyticsParameterQuantity: 1 as NSNumber,
            AnalyticsParameterIndex: 1 as NSNumber,
            AnalyticsParameterItemVariant: "\(bzbsCampaign.expireIn ?? 0)" as NSString,
            "metric1" : (bzbsCampaign.pointPerUnit ?? 0) as NSNumber
        ]
        
        // Prepare ecommerce dictionary.
        let items : [Any] = [reward1]
        
        let ecommerce : [String:AnyObject] = [
            "items" : items as AnyObject,
            "eventCategory" : "reward" as NSString,
            "eventAction" : "touch_button" as NSString,
            "eventLabel" : "choose_line_sticker | \(campaignId ?? "0")" as NSString,
            AnalyticsParameterItemListName: "reward_detail" as NSString,
        ]
        
        // Log select_content event with ecommerce dictionary.
        Bzbs.shared.delegate?.analyticsEventEcommerce(eventName: AnalyticsEventBeginCheckout, params: ecommerce)
        
        Bzbs.shared.delegate?.analyticsEvent(event: AnalyticsEventBeginCheckout, category: "reward", action: "touch_button", label: "choose_line_sticker | \(campaignId ?? "0") | \(bzbsCampaign.pointPerUnit ?? 0)")
        
    }
}

extension LineStickerDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lineImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! LineStickerCollectionViewCell
        let item = lineImageList[indexPath.row]
        cell.imvCampaign.bzbsSetImage(withURL: item.imageUrl ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width / 5)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 16, right: 8)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 4).left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = lineImageList[indexPath.row]
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? LineStickerCollectionViewCell {
            selectedCell.setAction(.selected)
            for cell in collectionView.visibleCells
            {
                if cell == selectedCell { continue }
                (cell as! LineStickerCollectionViewCell).setAction(.deselected)
            }
        }
        setTimer()
    }
    
    func setTimer() {
        if resetCellTimer == nil {
            resetCellTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(resetCell), userInfo: nil, repeats: false)
        } else {
            resetCellTimer?.invalidate()
            resetCellTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(resetCell), userInfo: nil, repeats: false)
        }
    }
    
    @objc func resetCell(){
        resetCellTimer?.invalidate()
        for cell in collectionView.visibleCells
        {
            (cell as! LineStickerCollectionViewCell).setAction(.unselected)
        }
    }
    
}
