//
//  CampaignRotateCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 24/9/2562 BE.
//

import UIKit
import Alamofire
import AlamofireImage
import ImageSlideshow

protocol CampaignRotateCVDelegate {
    func didSelectDashboard(_ item:BzbsDashboard)
}

class CampaignRotateCVCell: UICollectionViewCell {
//    var frameSize :CGSize {
//        return customSize ?? collectionView.frame.size
//    }
    var customSize:CGSize? {
        didSet{
            layoutIfNeeded()
        }
    }
    
    var numberOfItems: Int{
        showDashboardItems.count
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "CampaignRotateCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    // MARK:- Properties
    // MARK:- Outlet
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK:- Variable
    var delegate:CampaignRotateCVDelegate?
    var dashboardItems = [BzbsDashboard](){
        didSet {
            if let first = dashboardItems.first {
                showDashboardItems = first.subCampaignDetails.filter(CampaignRotateCVCell.filterDashboard(dashboard:))
            } else {
                showDashboardItems.removeAll()
            }
        }
    }
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    private var showDashboardItems = [BzbsDashboard](){
        didSet{
            if imageSlideShow != nil
            {
                var imageList = [InputSource]()
                for item in showDashboardItems {
                    if let imageUrl = item.imageUrl ,
                    let url = URL(string: imageUrl)?.convertCDNAddTime()
                    {
                        imageList.append(AlamofireSource(url: url))
                    }
                }
                imageSlideShow.contentScaleMode = .scaleAspectFill
                imageSlideShow.setImageInputs(imageList)
//                imageSlideShow.delegate = self
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didSelect))
                imageSlideShow.addGestureRecognizer(gestureRecognizer)
            }
        }
    }
    
    class func filterDashboard(dashboard:BzbsDashboard) -> Bool{
        if let dashboardLevel = dashboard.level
        {
            let userLevel = Bzbs.shared.userLogin?.userLevel ?? 1 // Default as customer level === 1
            return userLevel & dashboardLevel != 0
        }
        return true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.isUserInteractionEnabled = false
    }
    
    @objc func didSelect()
    {
        let index = imageSlideShow.currentPage
        if showDashboardItems.count == 0 {
            return
        }
        
        let item = showDashboardItems[index]
        delegate?.didSelectDashboard(item)
    }
//
//    func carouselCollectionView(_ carouselCollectionView: CarouselCollectionView, didSelectItemAt index: Int) {
//        if showDashboardItems.count == 0 {
//            return
//        }
//
//        let item = showDashboardItems[index]
//        delegate?.didSelectDashboard(item)
//    }
//
//    func carouselCollectionView(_ carouselCollectionView: CarouselCollectionView, didDisplayItemAt index: Int) {
//       pageControl.currentPage = index
//    }
//
//    func carouselCollectionView(_ carouselCollectionView: CarouselCollectionView, cellForItemAt index: Int, fakeIndexPath: IndexPath) -> UICollectionViewCell {
//        let item = showDashboardItems[index]
//        return generateCellRotate(item, indexPath: fakeIndexPath)
//    }
    
//    // MARK:- Generate Cell
//    func generateCellRotate(_ item:BzbsDashboard, indexPath:IndexPath) -> UICollectionViewCell {
//
//        let cellIdentifier = "campaignBigRotateCVCell"
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CampaignBigRotateCVCell
//        if let strUrl = item.imageUrl
//        {
//            cell.imvCampaign.bzbsSetImage(withURL: strUrl)
//        }
//        return cell
//    }

}
