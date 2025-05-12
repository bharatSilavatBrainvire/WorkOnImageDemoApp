//
//  Extensions.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//

import Foundation
import UIKit

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let newSize = CGRect(origin: .zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians)).integral.size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2,
                             width: size.width, height: size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage ?? self
    }
    
    func flip(horizontal: Bool) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.saveGState()
        
        if horizontal {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1.0, y: 1.0)
        } else {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
        }
        
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))
        context.restoreGState()
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage ?? self
    }
    
}

func cropCenterSquare(_ image: UIImage) -> UIImage {
    let side = min(image.size.width, image.size.height)
    let origin = CGPoint(x: (image.size.width - side) / 2,
                         y: (image.size.height - side) / 2)
    let cropRect = CGRect(origin: origin, size: CGSize(width: side, height: side))
    
    guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
}
