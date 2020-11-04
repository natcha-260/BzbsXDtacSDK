//
//  CampaignDetailRotateCell.swift
//  BzbsXDtacSDK
//
//  Created by macbookpro on 1/10/2562 BE.
//

import UIKit
import Alamofire
import AlamofireImage

class CampaignDetailRotateCell: UICollectionViewCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    class func getNib() -> UINib{
        return UINib(nibName: "CampaignRotateCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    var campaignItem = BzbsCampaign(){
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
            collectionView.isPagingEnabled = true
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let nib = UINib(nibName: "CampaignBigRotateCVCell", bundle: Bzbs.shared.currentBundle)
            collectionView.register(nib, forCellWithReuseIdentifier: "campaignBigRotateCVCell")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = campaignItem.pictures[indexPath.row]
        return generateCellRotate(item, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return campaignItem.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = width / 3 * 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Do nothing
    }
    
    // MARK:- Generate Cell
    func generateCellRotate(_ item: BzbsPictureCampaign, indexPath:IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "campaignBigRotateCVCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CampaignBigRotateCVCell
        cell.imvCampaign.bzbsSetImage(withURL: item.fullImageUrl, isUsePlaceholder: true, completionHandler: nil)
        
        return cell
    }
    
}
