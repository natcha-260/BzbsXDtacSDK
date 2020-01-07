//
//  CellCategory.swift
//  ChildViewDemo
//
//  Created by apple on 16/9/2562 BE.
//  Copyright © 2562 cyts. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

protocol CellCategoryDelegate {
    func didSelectedItem(index: Int)
}

class CellCategory: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: CellCategoryDelegate?
    
    var arrCategory: [BzbsCategory]! = [BzbsCategory]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: Bzbs.shared.currentBundle), forCellWithReuseIdentifier: "cellCollectionCategory")
    }
    
    func settingCell(listCategory: [BzbsCategory]) {
        arrCategory = listCategory
        collectionView.reloadData()
    }
    
}

// MARK:- Extension
// MARK:- UICollectionViewDelegateFlowLayout
extension CellCategory: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView
        , layout collectionViewLayout: UICollectionViewLayout
        , sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 4.5
        let height: CGFloat = 80
        
        return CGSize(width: width, height: height)
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CellCategory: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
