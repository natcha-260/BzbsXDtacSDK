//
//  Barcode.swift
//  Pods
//
//  Created by SOMBASS 's iMAC on 2/10/2562 BE.
//

import UIKit
import Foundation

open class Barcode
{
    /**
     สร้างแท่งบาร์โค๊ดด้วยข้อความ
     */
    open class func barcodeFromString(_ string : String, width: CGFloat, height: CGFloat) -> UIImage?
    {
        let data = string.data(using: String.Encoding.ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage
        {
            let scaleX = width / outputImage.extent.size.width
            let scaleY = height / outputImage.extent.size.height
            let scale = max(scaleX, scaleY)
            
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            return UIImage(ciImage: transformedImage)
        }
        return UIImage()
    }
    
    /**
     สร้างแท่งQRด้วยข้อความ
     */
    open class func qrcodeFromString(_ string : String, width: CGFloat, height: CGFloat) -> UIImage?
    {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        var scalingWidth = width
        if width > height
        {
            scalingWidth = height
        }
        
        let scale = scalingWidth / filter.outputImage!.extent.size.width
        
        let transformedImage = filter.outputImage!.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        return UIImage(ciImage: transformedImage)
    }
}
