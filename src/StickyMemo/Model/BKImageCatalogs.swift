//
//  BKImageCatalogs.swift
//  StickyMemo
//
//  Created by alex on 2018/2/6.
//  Copyright © 2018年 alix. All rights reserved.
//

//
//  BKImageCatalog.swift
//  StickyMemo
//
//  Created by alex on 2018/1/10.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation
import UIKit

//View Module for image template
class BKImageTemplate {
    var name:String
    var order:Int64 = 0
    var isLocked:Bool = false
    var edgeTop:CGFloat =  35
    var edgeLeft:CGFloat = 35
    var edgeBottom:CGFloat = 35
    var edgeRight: CGFloat = 35
    var tintColorHex:String = "FFFF8B"
    
    var imageData:Data?
    //
    //    var resisedUIImage: UIImage?{
    //        get {
    //            if let data = imageData, let uiimage = UIImage(data: data) {
    //
    ////                img.resizableImage(withCapInsets: UIEdgeInsets(top: bkTemplate.edgeTop, left: bkTemplate.edgeLeft, bottom: bkTemplate.edgeBottom, right: bkTemplate.edgeRight))
    ////                Util.printLog("=============ui image data found, top:\(self.edgeTop), right:\(self.edgeRight) left:\(self.edgeLeft)")
    //
    //                return uiimage.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop, left: self.edgeLeft, bottom: self.edgeBottom, right: self.edgeRight))
    //            } else {
    //                if let uiimageFromName = UIImage(named:self.name) {
    //                    Util.printLog("==========need attention, uimage come from named")
    //                    return uiimageFromName.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop, left: self.edgeLeft, bottom: self.edgeBottom, right: self.edgeRight))
    //                } else {
    //                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
    //                    return nil
    //                }
    //            }
    //        }
    //    }
    
    var uiImage: UIImage?{
        get {
            if let data = imageData, let uiimage = UIImage(data: data) {
                
                //                img.resizableImage(withCapInsets: UIEdgeInsets(top: bkTemplate.edgeTop, left: bkTemplate.edgeLeft, bottom: bkTemplate.edgeBottom, right: bkTemplate.edgeRight))
                //                Util.printLog("=============ui image data found, top:\(self.edgeTop), right:\(self.edgeRight) left:\(self.edgeLeft)")
                
                return uiimage
            } else {
                if let uiimageFromName = UIImage(named:self.name) {
                    Util.printLog("==========need attention, uimage come from named")
                    
                    Util.saveAccessLog("BKImageTemplate*error",memo:"Error:image come from local named \(#function)-\(#line)")
                    return uiimageFromName
                } else {
                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
                    Util.saveAccessLog("BKImageTemplate*error",memo:"Error:not found image from db or locale name for \(self.name) \(#function)-\(#line)")
                    return nil
                }
            }
        }
    }
    
    
    init(_ cdBKImageTemplate:CDBKImageTemplate) {
        self.name = cdBKImageTemplate.name ?? ""
        self.order = cdBKImageTemplate.order
        if let lock = cdBKImageTemplate.catalog?.isLocked {
            self.isLocked = lock
        }
        self.edgeBottom = CGFloat(cdBKImageTemplate.edgeBottom)
        self.edgeTop = CGFloat(cdBKImageTemplate.edgeTop)
        self.edgeRight = CGFloat(cdBKImageTemplate.edgeRight)
        self.edgeLeft = CGFloat(cdBKImageTemplate.edgeLeft)
        if let hex = cdBKImageTemplate.tintColorHex {
            self.tintColorHex = hex
        }
        
        self.imageData = cdBKImageTemplate.imageData
    }
}


class BKImageCatalog {
    var name:String
    var order:Int64 = 0
    var isLocked:Bool = false
    var edgeTop:CGFloat =  35
    var edgeLeft:CGFloat = 35
    var edgeBottom:CGFloat = 35
    var edgeRight: CGFloat = 35
    
    var tintColorHex:String = "FFFF8B"
    
    
    var imageTemplate:[BKImageTemplate]?
    
    var imageData:Data?
    
    //    var resizedUIImage: UIImage?{
    //        get {
    //            if let data = imageData, let uiimage = UIImage(data: data) {
    ////                img.resizableImage(withCapInsets: UIEdgeInsets(top: background.edgeTop  , left: background.edgeLeft  , bottom: background.edgeBottom  , right: background.edgeRight  ))
    //
    //                return uiimage.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop  , left: self.edgeLeft  , bottom: self.edgeBottom  , right: self.edgeRight  ))
    //            } else {
    //                if let uiimageFromName = UIImage(named:self.name) {
    //                    Util.printLog("==========need attention, uimage come from named:\(self.name)")
    //                    return uiimageFromName.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop  , left: self.edgeLeft  , bottom: self.edgeBottom  , right: self.edgeRight  ))
    //                } else {
    //                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
    //                    return nil
    //                }
    //            }
    //        }
    //    }
    //
    var uiImage: UIImage?{
        get {
            if let data = imageData, let uiimage = UIImage(data: data) {
                return uiimage
            } else {
                if let uiimageFromName = UIImage(named:self.name) {
                    Util.printLog("==========need attention, uimage come from named:\(self.name)")
                    Util.saveAccessLog("BKImageCatalog*error",memo:"Error:image come from named \(#function)-\(#line)")
                    return uiimageFromName
                } else {
                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
                    Util.saveAccessLog("BKImageCatalog*error",memo:"Error:not found image from db or locale name for \(self.name) \(#function)-\(#line)")
                    return nil
                }
            }
        }
    }
    
    
    //
    //    var uiImage: UIImage?{
    //        get {
    //
    //                if let uiimageFromName = UIImage(named:self.name) {
    //                    Util.printLog("==========need attention, uimage come from named:\(self.name)")
    //                    return uiimageFromName //.resizableImage(withCapInsets: UIEdgeInsets(top: self.edgeTop  , left: self.edgeLeft  , bottom: self.edgeBottom  , right: self.edgeRight  ))
    //                } else {
    //                    Util.printLog("==========need attention, not foud image from db and localname for:\(self.name)")
    //                    return nil
    //                }
    //
    //        }
    //    }
    
    init(_ cdBKImageCatalog: CDBKImageCatalog) {
        self.name = cdBKImageCatalog.name ?? ""
        self.order = cdBKImageCatalog.order
        self.isLocked = cdBKImageCatalog.isLocked
        self.imageData = cdBKImageCatalog.imageData
        
        if let tempOption = cdBKImageCatalog.imageTemplates, let tempList = Array(tempOption) as? [CDBKImageTemplate] {
            self.imageTemplate = tempList.map{ return BKImageTemplate($0)}
            self.imageTemplate?.sort{
                return $0.order < $1.order
            }
            
            //            let foundImageTemplate = self.imageTemplate?.filter({ (imageTemplate) -> Bool in
            //                return imageTemplate.name == self.name
            //            })
            //
            //            if let count =  foundImageTemplate?.count, count >= 0, let imgData = foundImageTemplate?.first?.imageData {
            //                self.imageData = imgData
            //            }else{
            //                Util.printLog("=========need attention at BKImageCatalog.init not found \(self.name)  ")
            //            }
        }else{
            Util.printLog("=========need attention at BKImageCatalog.init, imageTemplates is nil ")
        }
    }
    
}
///for json decode
class JSONBKImageTemplate:Decodable {
    var name: String
    var order: Int64
    var tintColorHex:String
}

class JSONBKImageCatalog: Decodable {
    var name:String
    var order:Int64 = 0
    var isLocked:Bool
    var edgeTop:CGFloat =  35
    var edgeLeft:CGFloat = 35
    var edgeBottom:CGFloat = 35
    var edgeRight: CGFloat = 35
    
    var bkImageTemplates:[JSONBKImageTemplate]
    
    //    init(cdBKImageCatalog: CDBKImageCatalog) {
    //
    //        self.name = cdBKImageCatalog.name ?? ""
    //        self.isLocked = cdBKImageCatalog.isLocked
    //        // for default
    //
    //
    //        if let tempOption = cdBKImageCatalog.imageTemplates, let tempList = Array(tempOption) as? [CDBKImageTemplate] {
    //            self.bkImageTemplates = tempList
    //            for imageTemp in tempList {
    //                if let aname = imageTemp.name, let bname = cdBKImageCatalog.name, aname == bname {
    //                    self.edgeBottom = CGFloat(imageTemp.edgeBottom)
    //                    self.edgeTop = CGFloat(imageTemp.edgeTop)
    //                    self.edgeLeft = CGFloat(imageTemp.edgeLeft)
    //                    self.edgeRight = CGFloat(imageTemp.edgeRight)
    //                    self.order = imageTemp.order
    //                    break
    //                } else {
    //                    self.edgeBottom = 35
    //                    self.edgeTop = 35
    //                    self.edgeLeft = 35
    //                    self.edgeRight = 35
    //                    self.order = 0
    //                }
    //            }
    //        }
    //    }
    
    //    init(name:String,isLocked:Bool, bkImageTemplates:[BKImageTemplate]) {
    //        self.name = name
    //        self.isLocked = isLocked
    //        self.bkImageTemplates = bkImageTemplates
    //    }
    //    enum CodingKeys: String, CodingKey {
    //        case name
    //        case isLocked
    //        case bkImageTemplates
    //    }
    //
}

