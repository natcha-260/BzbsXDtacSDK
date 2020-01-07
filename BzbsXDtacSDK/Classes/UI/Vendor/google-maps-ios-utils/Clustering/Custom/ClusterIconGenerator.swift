//
//  ClusterIconGenerator.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 8/10/2562 BE.
//

import Foundation
class ClusterIconGenerator: NSObject, GMUClusterIconGenerator {
    
    private struct IconSize {
        
        private let initialFontSize: CGFloat = 12
        private let fontMultiplier: CGFloat = 0.1
        
        private let initialSize: CGFloat = 25
        private let sizeMultiplier: CGFloat = 0.25
        
        /**
         Rounded cluster sizes  (like 10+, 20+, etc.)
         */
        private let sizes = [10,20,50,100,200,500,1000]
        
        let size: UInt
        
        /**
         Returns scale level based on size index in `sizes`. Returns `1` if size doesn't have rounded representation
         */
        private var scaleLevel: UInt {
            if let index = sizes.lastIndex(where: { $0 <= size }) {
                return UInt(index) + 2
            } else {
                return 1
            }
        }
        
        /**
         Returns designed title from cluster's size
         */
        var designedTitle: String {
            return "\(size)"
//            if let size = sizes.last(where: { $0 <= size }) {
//                return "\(size)+"
//            } else {
//                return "\(size)"
//            }
        }
        
        /**
         Returns initial font size multiplied by recursively created multiplier
         */
        var designedFontSize: CGFloat {
            let multiplier: CGFloat = (1...scaleLevel).reduce(1) { n,_ in n + n * fontMultiplier }
            return initialFontSize * multiplier
        }
        
        /**
         Returns initial `CGSize` multiplied by recursively created multiplier
         */
        var designedSize: CGSize {
            let multiplier: CGFloat = (1...scaleLevel).reduce(1) { n,_ in n + n * sizeMultiplier }
            return CGSize(width: initialSize * multiplier, height: initialSize * multiplier)
        }
        
    }
    
    /**
     Returns image based on current cluster's size
     */
    func icon(forSize size: UInt) -> UIImage! {
        
        let iconSize = IconSize(size: size)
        
        let frame = CGRect(origin: .zero, size: iconSize.designedSize)
        let view = UIView(frame: frame)
        let imgView = UIImageView(frame: frame)
        imgView.image = UIImage(named: "img_pinnum", in: Bzbs.shared.currentBundle, compatibleWith: nil)
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        
        let label = UILabel(frame: frame)
        label.center.y = imgView.center.y - 2
        label.textAlignment = .center
        label.textColor = .white
        label.text = iconSize.designedTitle
        label.font = UIFont.mainFont()
        view.addSubview(label)
        
        return view.asImage
    }
    
}

extension UIView {
    
    var asImage: UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            // Fallback on earlier versions
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
        
    }
    
}
