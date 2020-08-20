//
//  EmptyHistoryCell.swift
//  BzbsXDtacSDK
//
//  Created by Buzzebees iMac on 19/8/2563 BE.
//

import UIKit

class EmptyHistoryCell: EmptyTVCell {
    
    override class func getNib() -> UINib {
            return UINib(nibName: "EmptyHistoryCell", bundle: Bzbs.shared.currentBundle)
        }

}
