//
//  RecommendCVCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 17/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit

class CampaignCVCell: UICollectionViewCell {
    
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var vwShadow: UIView!
    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    class func getNib() -> UINib{
        return UINib(nibName: "CampaignCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    class func getSize(_ collectionView:UICollectionView) -> CGSize
    {
        let paddingWidth = ((collectionView.frame.size.width) / 2) - 8
        let imgHeight = paddingWidth * 2 / 3
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: CGFloat.leastNonzeroMagnitude))
        lbl.font = UIFont.mainFont()
        lbl.numberOfLines = 0
        lbl.text = "\n"
        lbl.sizeToFit()
        
        let collectionCellHeight = 16 + imgHeight + 8 + lbl.bounds.size.height + 16
        return CGSize(width: paddingWidth, height: collectionCellHeight)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imv.contentMode = .scaleAspectFit
        vwContent.cornerRadius()
        vwShadow.addShadow()
        self.clipsToBounds = true
        
        lblTitle.font = UIFont.mainFont()
        lblAgency.font = UIFont.mainFont(FontSize.small)
        lblDistance.font = UIFont.mainFont(FontSize.small)
        
        lblAgency.textColor = .gray
        lblDistance.textColor = .gray
    }
    
    func setupWith(_ item:BzbsCampaign, isShowDistance:Bool = false){
        // wordaround odd collection list count
        if item.ID == -1 {
            self.isHidden = true
            return
        }
        self.isHidden = false
        //------
        
        if let strUrl = item.fullImageUrl {
            imv.bzbsSetImage(withURL: strUrl)
        }
        imv.contentMode = .scaleAspectFit
        lblTitle.text = item.name
        if lblTitle.numberOfVisibleLines == 1 {
            lblTitle.text = item.name + "\n"
        }
        
        lblAgency.text = item.agencyName
        
        lblAgency.isHidden = item.type == 16

        if isShowDistance && LocationManager.shared.authorizationStatus == .authorizedWhenInUse
        {
            if let first = item.places.first ,
                let lon = first.longitude ,
                let lat = first.latitude
                {
                if let distance = LocationManager.shared.distanceFrom(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                {
                    item.distance = Double(distance)!
                }
            }
            
            if let distance =  item.distance, distance > 0
            {
                lblDistance.isHidden = distance <= 0
                let distanceKm = distance / 1000
                let distanceFormat = Double(round(100 * distanceKm) / 100)

                lblDistance.text = "\(distanceFormat.withCommas()) " + "util_km".localized()
            } else {
                lblDistance.isHidden = true
            }
        } else {
            lblDistance.isHidden = true
        }
        
    }
    
    
    func setupWith(_ item:BzbsDashboard, isShowDistance:Bool = false){
        // wordaround odd collection list count
        if item.id == "-1" {
            self.isHidden = true
            return
        }
        self.isHidden = false
        //----
        
        if let strUrl = item.imageUrl {
            imv.bzbsSetImage(withURL: strUrl)
        }
        imv.contentMode = .scaleAspectFit
        var name = item.line1
        if LocaleCore.shared.getUserLocale() == 1033
        {
            name = item.line2
        }
        
        if name == nil {
            name = item.line1 ?? item.line2 ?? "-"
        }
        lblTitle.text = name
        if lblTitle.numberOfVisibleLines == 1 {
            lblTitle.text = (name ?? "-") + "\n"
        }
        
        var agencyName = item.line3
        if LocaleCore.shared.getUserLocale() == 1033
        {
            agencyName = item.line4
        }
        if agencyName == nil {
            agencyName = item.line3 ?? item.line4 ?? "-"
        }
        lblAgency.text = agencyName
        
//        lblAgency.isHidden = item.type == 16

        lblDistance.isHidden = !(isShowDistance && LocationManager.shared.authorizationStatus == .authorizedWhenInUse)
        if isShowDistance && LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
            if let distance = BuzzebeesConvert.DoubleFromObjectNull(item.line2 as AnyObject?), distance > 0
            {
                lblDistance.isHidden = distance <= 0
                let distanceKm = distance / 1000
                let distanceFormat = Double(round(100 * distanceKm) / 100)
                
                lblDistance.text = "\(distanceFormat.withCommas()) " + "util_km".localized()
            } else {
                lblDistance.text = "- Km."
            }
        }
    }

}

extension UILabel {
    var numberOfVisibleLines: Int {
        let zone = CGSize(width: intrinsicContentSize.width, height: CGFloat(MAXFLOAT))
        let fittingHeight = Float(self.sizeThatFits(zone).height)
        return lroundf(fittingHeight / Float(font.lineHeight))
    }
}
