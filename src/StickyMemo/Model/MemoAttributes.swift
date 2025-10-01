//
//  MemoAttributes.swift
//  StickyMemo
//
//  Created by alex on 2018/2/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

class Position{
    var rotate: CGFloat = 0
    var x: CGFloat = 0
    var y: CGFloat = 0
    var width:CGFloat = 100
    var height: CGFloat = 100
    init() {
        
    }
    
    var cdPosistion:CDPosition? {
        didSet {
            guard let cdposition = cdPosistion else {
                return
            }
            self.x = CGFloat(cdposition.x)
            self.y = CGFloat(cdposition.y)
            self.width =  CGFloat(cdposition.width)
            self.height = CGFloat(cdposition.height)
        }
    }
    init(x:CGFloat = 0, y:CGFloat = 0,width:CGFloat = 200, height:CGFloat=200, rotate:CGFloat = 0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rotate = rotate
    }
    
}

class DisplayStyle {
    //    var fontSize:CGFloat = 18
    //    var fontName:String = "Helvetica"
    //    var textColorHex:String = "000000"
    var fontSize:CGFloat
    var fontName:String
    var textColorHex:String
    //    var textColor: UIColor
    var alignment: Int = 0
    var font:UIFont? {
        get{
            return UIFont(name: self.fontName, size: self.fontSize)
        }
    }
    init(fontName:String,fontSize:CGFloat,  textColorHex:String  ) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColorHex = textColorHex
    }
    
    
}
extension Position:CustomStringConvertible {
    var description:String {
        return "x:\(x),y:\(y),width:\(width),heigt:\(height)"
    }
}

extension DisplayStyle {
    var textColor: UIColor? {
        get {
            return UIColor(hex: textColorHex)
        }
        set{
            if let hex = textColor?.toHex {
                textColorHex = hex
            }
        }
    }
    var textAlignment:NSTextAlignment {
        get {
            return NSTextAlignment(rawValue: alignment)!
        }
        set {
            alignment = textAlignment.rawValue
        }
    }
    
}


class BackgroundImage {
    //    var isTin: Bool
    var name: String = ""
    var edgeTop:CGFloat
    var edgeLeft:CGFloat
    var edgeBottom:CGFloat
    var edgeRight: CGFloat
    var tintColorHex: String //= "FFFFFF"
    // for default background color if image is nil or display left indicator color
    var imageData: Data?
    
    
    var uiImage: UIImage?{
        get {
            if let data = imageData, let uiimage = UIImage(data: data) {
                //                img.resizableImage(withCapInsets: UIEdgeInsets(top: bkTemplate.edgeTop, left: bkTemplate.edgeLeft, bottom: bkTemplate.edgeBottom, right: bkTemplate.edgeRight))
                //                Util.printLog("=============ui image data found, top:\(self.edgeTop), right:\(self.edgeRight) left:\(self.edgeLeft)")
                
                return uiimage.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop, left: self.edgeLeft, bottom: self.edgeBottom, right: self.edgeRight))
            } else {
                if let uiimageFromName = UIImage(named:self.name) {
                    Util.printLog("==========need attention, uimage come from named")
                    Util.saveAccessLog("BackgroundImage*error",memo:"Error: uimage come from named \(#function)-\(#line)")
                    return uiimageFromName.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop, left: self.edgeLeft, bottom: self.edgeBottom, right: self.edgeRight))
                } else {
                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
                    Util.saveAccessLog("BackgroundImage*error",memo:"Error:not found image from db or locale name for \(self.name) \(#function)-\(#line)")
                    return nil
                }
            }
        }
    }
    
    var tintColor:UIColor {
        get {
            return UIColor(hex: tintColorHex)!
        }
        set{
            if let hex = tintColor.toHex {
                tintColorHex = hex
            }
        }
    }
    
    
    //    init(name:String,tintColor: UIColor,tintColorHex:String = "FFFFFF",edgeTop:CGFloat = 22 ,edgeLeft:CGFloat = 26 ,edgeBottom:CGFloat = 22 ,edgeRight:CGFloat = 26) {
    //        //        self.isShowImage = isShowImage
    //        self.name = name
    //        self.edgeTop = edgeTop
    //        self.edgeLeft = edgeLeft
    //        self.edgeBottom = edgeBottom
    //        self.edgeRight = edgeRight
    //        //        self.isEnabledTintColor = isEnabledTintColor
    //        self.tintColor = tintColor
    //        self.tintColorHex = tintColorHex
    //    }
    
    init(name:String,tintColorHex:String,edgeTop:CGFloat = 22 ,edgeLeft:CGFloat = 26 ,edgeBottom:CGFloat = 22 ,edgeRight:CGFloat = 26, imageData:Data? ) {
        //        self.isShowImage = isShowImage
        self.name = name
        self.edgeTop = edgeTop
        self.edgeLeft = edgeLeft
        self.edgeBottom = edgeBottom
        self.edgeRight = edgeRight
        //        self.isEnabledTintColor = isEnabledTintColor
        //        self.tintColor = UICtintColor
        self.tintColorHex = tintColorHex
        self.imageData = imageData
    }
    
}



