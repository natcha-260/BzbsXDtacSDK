//
//  CampaignCoinCVCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 15/9/2563 BE.
//

import UIKit

class CampaignCoinCVCell: CampaignCVCell {
    
    @IBOutlet weak var lblCoinTitle: UILabel!
    
    override class func getNib() -> UINib {
        return UINib(nibName: "CampaignCoinCVCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblCoinTitle.textColor = .orange
        lblDistance.textColor = .orange
        lblCoinTitle.font = UIFont.mainFont()
    }
    
    override class func getSize(_ collectionView: UICollectionView) -> CGSize {
        
        let paddingWidth = ((collectionView.frame.size.width) / 2) - 8
        let imgHeight = paddingWidth * 2 / 3
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: CGFloat.leastNonzeroMagnitude))
        lbl.font = UIFont.mainFont()
        lbl.numberOfLines = 0
        lbl.text = "\n\n"
        lbl.sizeToFit()
        
        let collectionCellHeight = 16 + imgHeight + 8 + lbl.bounds.size.height + 16
        return CGSize(width: paddingWidth, height: collectionCellHeight)
        
    }
    
    override func setupWith(_ item: BzbsCampaign, isShowDistance: Bool = false) {
        // wordaround odd collection list count
        if item.ID == -1 {
            self.isHidden = true
            return
        }
        self.isHidden = false
        //---
        
        if let strUrl = item.fullImageUrl {
            imv.bzbsSetImage(withURL: strUrl)
        }
        imv.contentMode = .scaleAspectFit
        lblTitle.text = item.name
        if lblTitle.numberOfVisibleLines == 1 {
            lblTitle.text = item.name + "\n"
        }
        
        lblAgency.text = item.agencyName
        lblCoinTitle.text = "coin_campaign_use".localized()
        
        let pointPerUnit = item.pointPerUnit ?? 0
        lblDistance.text = pointPerUnit.withCommas()
        
        if let originalPrice = item.originalPrice, originalPrice > 0 {
            let font = lblDistance.font ?? UIFont.mainFont()
            let attrString = NSMutableAttributedString(string: Int(originalPrice).withCommas(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.strikethroughStyle: 1])
            attrString.append(NSAttributedString(string: " " + pointPerUnit.withCommas(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.orange]))
            lblDistance.attributedText = attrString
        }
    }
    
    override func setupWith(_ item:BzbsDashboard, isShowDistance:Bool = false){
        // wordaround odd collection list count
        if item.id == "-1" {
            self.isHidden = true
            return
        }
        self.isHidden = false
        // ----
        
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
        
        lblCoinTitle.text = "coin_campaign_use".localized()
        let dict = item.dict
        if let pointPerUnit = Convert.IntFromObject(dict?["pointperunit"]) {
            lblDistance.text = pointPerUnit.withCommas()
            if let originalPrice = Convert.IntFromObject(dict?["originalprice"]) , originalPrice > 0{
                let font = lblDistance.font ?? UIFont.mainFont()
                let attrString = NSMutableAttributedString(string: originalPrice.withCommas(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.strikethroughStyle: 1])
                attrString.append(NSAttributedString(string: " " + pointPerUnit.withCommas(), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.orange]))
                lblDistance.attributedText = attrString
            }
        } else {
            let pointPerUnit = 0
            lblDistance.text = pointPerUnit.withCommas()
        }
    }
    
    
}
