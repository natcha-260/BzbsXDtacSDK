//
//  CategoryTableViewCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 25/9/2562 BE.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class CategoryTableViewCell: UITableViewCell {
        
    @IBOutlet weak var collectionView: UICollectionView!
    var customContentInset : UIEdgeInsets?
    var delegate: CategoryCVCellDelegate?
    var arrCategory: [BzbsCategory]! = [BzbsCategory]()
    {
        didSet{
            if collectionView != nil {
                if let inset = customContentInset{
                    self.collectionView.contentInset = inset
                }
                collectionView.reloadData()
            }
        }
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "CategoryTableViewCell", bundle: Bzbs.shared.currentBundle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isScrollEnabled = false
        self.collectionView.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: Bzbs.shared.currentBundle), forCellWithReuseIdentifier: "cellCollectionCategory")
    }
    
    func settingCell(listCategory: [BzbsCategory]) {
        arrCategory = listCategory
        collectionView.reloadData()
    }
    
}

// MARK:- Extension
// MARK:- UICollectionViewDelegateFlowLayout
extension CategoryTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView
        , layout collectionViewLayout: UICollectionViewLayout
        , sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 4.5
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.leastNonzeroMagnitude))
        lbl.font = UIFont.mainFont(.small)
        lbl.text = "\n"
        lbl.sizeToFit()
        let height = (width / 2) + lbl.frame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollectionCategory", for: indexPath as IndexPath) as! CategoryCollectionViewCell
        let item = arrCategory[indexPath.row]
        cell.setupCell(item)
        cell.setActive(false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectedItem(index: indexPath.row)
    }
}

