//
//  UIViewExtension.swift
//  BzbsXDtacSDK
//
//  Created by apple on 17/9/2562 BE.
//  Copyright © 2562 Buzzebees. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func cornerRadius(corner: CGFloat = 3, borderColor: UIColor = UIColor.clear, borderWidth: CGFloat = 0.0)
    {
        self.layer.cornerRadius = corner
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    func addShadow(shadowOpacity: Float = 0.3, shadowColor: UIColor = UIColor.black, shadowRadius: CGFloat = 1, shadowOffset: CGSize = CGSize.zero)
    {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}


class SectionLineView : UIView{
    var shadowLayer : CAGradientLayer!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(hexString: "E4E4E4")
        drawShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawShadow()
    }
    
    func drawShadow() {
        if shadowLayer != nil
        {
            shadowLayer.removeFromSuperlayer()
            shadowLayer = nil
        }
        
        shadowLayer = CAGradientLayer()
        shadowLayer.cornerRadius = layer.cornerRadius
        shadowLayer.frame = bounds
        shadowLayer.frame.size.height = self.bounds.size.height
        shadowLayer.colors = [
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        layer.addSublayer(shadowLayer)
    }
}

class DashedVerticalView :UIView{

    let shapeLayer = CAShapeLayer()
    override func awakeFromNib() {
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [10, 10] // 7 is the length of dash, 3 is length of the gap.
        let p0 = CGPoint(x:0 ,y:0)
        let p1 = CGPoint(x:0 ,y:frame.size.height)
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}

class DashedHorizontalView :UIView{
    
    var shapeLayer :CAShapeLayer!
    override func awakeFromNib() {
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [5, 5] // 7 is the length of dash, 3 is length of the gap.
        let p0 = CGPoint(x:0 ,y:0)
        let p1 = CGPoint(x:frame.size.width, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.removeFromSuperlayer()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineDashPattern = [5, 7] // 7 is the length of dash, 3 is length of the gap.
        let p0 = CGPoint(x:0 ,y:0)
        let p1 = CGPoint(x:frame.size.width, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}

extension UICollectionView {
    func stopPullToRefresh() {
        self.refreshControl?.endRefreshing()
    }
}

extension UITableView {
    func stopPullToRefresh() {
        self.refreshControl?.endRefreshing()
    }
}

