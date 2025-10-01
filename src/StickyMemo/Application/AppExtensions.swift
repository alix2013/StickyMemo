//
//  AppExtensions.swift
//  StickyMemo
//
//  Created by alex on 2017/12/6.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import StoreKit.SKProduct

//get view's parentViewController
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// for view move outside of parent, response interaction
/* i.e
 //for button move outside of view
 override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
 return overlapHitTest(point: point, withEvent: event)
 }
 */
extension UIView {
    func overlapHitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // 1
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha == 0 {
            return nil
        }
        //2
        var hitView: UIView? = self
        if !self.point(inside: point, with: event) {
            if self.clipsToBounds {
                return nil
            } else {
                hitView = nil
            }
        }
        //3
        for subview in self.subviews.reversed() {
            let insideSubview = self.convert(point, to: subview)
            if let sview = subview.overlapHitTest(point: insideSubview, withEvent: event) {
                return sview
            }
        }
        return hitView
    }
}

// get String height or width by given font
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

// get NSAttributedString width or height
extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

// for text vertical center display in UITextView
extension UITextView {
    
    /// Modifies the top content inset to center the text vertically.
    ///
    /// Use KVO on the UITextView contentSize and call this method inside observeValue(forKeyPath:of:change:context:)
    func alignTextVerticallyInContainer() {
//        print("zoomScale:\(self.zoomScale)")
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 3
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.contentInset.top = topCorrect
    }
}


//for localized price
extension SKProduct {
    func getLocalizedPrice()->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        if let ret = formatter.string(from: self.price) {
            return ret
        }else{
            return "\(self.price)"
        }
    }
}

extension String {
    func mySubstring(fromIndex: Int, toIndex: Int) -> String {
        if self == "" || fromIndex > toIndex || fromIndex >= self.count || fromIndex < 0 {
            return ""
        }else{
            let to = min(toIndex, (self.count - 1))
            let from = max(0, fromIndex)
            let start = self.index(self.startIndex,offsetBy: from)
            let end = self.index(self.startIndex,offsetBy: to)
            return String(self[start...end])
        }
    }
}

/*
extension UIImage {
    class func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        
//        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        
//        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: .zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    /// Returns a image that fills in newSize
    func resizedImage(_ newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
//        self.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
//        let newSize = CGSizeMake(size.width/resizeFactor, size.height/resizeFactor)
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize)
        return resized
    }
    
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(newSize)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}
*/

