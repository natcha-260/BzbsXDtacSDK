//
//  LineStickerDetail.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 5/10/2563 BE.
//

import UIKit

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
    
    // MARK:- View life cycle
    // MARK:-
    override func loadView() {
        super.loadView()
        initNav()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblAgency.font = UIFont.mainFont()
        lblName.font = UIFont.mainFont(.big, style: .bold)
        lblExpireDate.font = UIFont.mainFont()
        lblCoins.font = UIFont.mainFont()
        lblMyCoin.font = UIFont.mainFont()
        lblChoose.font = UIFont.mainFont(style:.bold)
        lblDescription.font = UIFont.mainFont()
        lblInfo.font = UIFont.mainFont()
        
        lblExpireDate.textColor = .gray
        lblMyCoin.textColor = .gray
        lblDescription.textColor = .gray
        lblInfo.textColor = .gray
        
        lblAgency.text = bzbsCampaign.agencyName ?? " "
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
        lblTitle.font = UIFont.mainFont(.big)
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
        showLoader()
        let token = ".NbJc5KA8JVnsUDYgmav4FeAlaSXGIwosUgdJmwiRwe3WnDdE6OtVbYzCTyx_4Z0FaZDT7X8-ElCu_Vy3rEEHOlVMXZqmOowzXw7_auPTgwQfQ23J38WdqCSLKueBfGAKvipGirWzxmRf7gkINZ5OokxUgu51Vpq6jX0NuKFhanOUeSr7mL_zTOttOSYt0YXX"
        bzbsCoreApi.getLineDetail(token: token
                                  , campaignId: campaignId
                                  , packageId: packageId)
        { (objLine) in
            self.lineCampaign = objLine
            self.setupUI()
            self.apiGetPreview()
        } failCallback: { (error) in
            self.hideLoader()
        }
        
    }
    
    func apiGetPreview() {
        let token = ".NbJc5KA8JVnsUDYgmav4FeAlaSXGIwosUgdJmwiRwe3WnDdE6OtVbYzCTyx_4Z0FaZDT7X8-ElCu_Vy3rEEHOlVMXZqmOowzXw7_auPTgwQfQ23J38WdqCSLKueBfGAKvipGirWzxmRf7gkINZ5OokxUgu51Vpq6jX0NuKFhanOUeSr7mL_zTOttOSYt0YXX"
        bzbsCoreApi.getLineImageList(token: token, campaignId: campaignId, packageId: packageId) { (tmpImageList) in
            self.lineImageList = tmpImageList
            self.collectionView.reloadData()
            self.hideLoader()
        } failCallback: { (error) in
            self.hideLoader()
        }
    }
    
    func setupUI() {
        imvLogo.bzbsSetImage(withURL: lineCampaign?.logoUrl ?? "")
        lblName.text = lineCampaign?.stickerTitle
        lblCoins.text = String(format: "line_detail_coin_format".localized(), (lineCampaign?.points ?? 0).withCommas())
        lblDescription.text = lineCampaign?.stickerDescription
        let collectionHeight = collectionView.bounds.height
        UIView.animate(withDuration: 0.1, delay: 0.33, options: UIView.AnimationOptions.curveEaseIn) {
            self.cstCollectionHeight.constant = collectionHeight
        } completion: { (_) in
            
        }
    }
    
    // MARK:- Event click
    // MARK:-
    @IBAction func clickChoose(_ sender: Any) {
        
        GotoPage.gotoLineRedeem(self.navigationController!, campaignId : campaignId, packageId: packageId, campaign: lineCampaign!)
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
        let item = lineImageList[indexPath.row]
    }
    
}
