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
    func didViewDashboard(_ item:BzbsDashboard, index:Int)
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
                showDashboardItems = first.subCampaignDetails.filter(BzbsDashboard.filterDashboard(dashboard:))
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
                if let first = showDashboardItems.first {
                    delegate?.didViewDashboard(first, index: 0)
                }
                
                var imageList = [InputSource]()
                for item in showDashboardItems {
                    if let imageUrl = item.imageUrl ,
                    let url = URL(string: imageUrl)?.convertCDNAddTime()
                    {
                        let placeholderImage = UIImage(named: "img_placeholder", in: Bzbs.shared.currentBundle, compatibleWith: nil)
                        imageList.append(AlamofireSource(url: url, placeholder: placeholderImage))
                    }
                }
                imageSlideShow.slideshowInterval = 5
                imageSlideShow.contentScaleMode = .scaleAspectFill
                imageSlideShow.setImageInputs(imageList)
                imageSlideShow.delegate = self
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didSelect))
                imageSlideShow.addGestureRecognizer(gestureRecognizer)
            }
        }
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

}

extension CampaignRotateCVCell :ImageSlideshowDelegate{
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        let item = showDashboardItems[page]
        delegate?.didViewDashboard(item, index: page)
    }
}
