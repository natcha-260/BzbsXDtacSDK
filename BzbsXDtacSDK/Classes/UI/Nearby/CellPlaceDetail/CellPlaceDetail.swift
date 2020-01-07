//
//  CellPlaceDetail.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 9/10/2562 BE.
//

import UIKit

class CellPlaceDetail: UICollectionViewCell {

    @IBOutlet weak var imvAgency: UIImageView!
    @IBOutlet weak var lblAgency: UILabel!
    @IBOutlet weak var lblCampaignName: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    class func getNib() -> UINib{
        return UINib(nibName: "CellPlaceDetail", bundle: Bzbs.shared.currentBundle)
    }
    
    class func getClassObject() -> CellPlaceDetail
    {
        return getNib().instantiate(withOwner: nil, options: nil).first as! CellPlaceDetail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblAgency.textColor = .gray
        lblDistance.textColor = .gray
        
        lblCampaignName.font = UIFont.mainFont()
        lblAgency.font = UIFont.mainFont(FontSize.small)
        lblDistance.font = UIFont.mainFont(FontSize.small)
    }

    func updateInfoView(name:String, agencyName:String, locationAgencyId:Int, distance:Double)
    {
        lblCampaignName.text = name
        lblAgency.text = agencyName
        
        lblDistance.text = String(format:"%.2f " + "util_km".localized(),distance)  
//        let location = CLLocationCoordinate2DMake(location.latitude, location.longitude)
//        if let distance = LocationManager.shared.distanceFrom(location)
//        {
//        }
        
        if let blobUrl = Bzbs.shared.blobUrl {
            let imageStrUrl = blobUrl + "/agencies/\(locationAgencyId)"
            imvAgency.bzbsSetImage(withURL: imageStrUrl)
        }
        
    }
    
}
