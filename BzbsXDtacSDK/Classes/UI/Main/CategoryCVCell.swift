//
//  CategoryCVCell.swift
//  Pods
//
//  Created by Buzzebees iMac on 24/9/2562 BE.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage


protocol CategoryCVCellDelegate {
    func didSelectedItem(index: Int)
}

class CategoryCVCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: CategoryCVCellDelegate?
    var arrCategory: [BzbsCategory]! = [BzbsCategory]()
    {
        didSet{
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    class func getNib() -> UINib{
        return UINib(nibName: "CategoryCVCell", bundle: Bzbs.shared.currentBundle)
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
extension CategoryCVCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView
        , layout collectionViewLayout: UICollectionViewLayout
        , sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 4.5
        let height: CGFloat = 80
        
        return CGSize(width: width, height: height)
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CategoryCVCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
