//
//  DefaultService.swift
//  StickyMemo
//
//  Created by alex on 2017/12/4.
//  Copyright © 2017年 alix. All rights reserved.
//

import CoreData
import UIKit
class DefaultService {
    
    static let defaultFontSize:CGFloat = 16
//    static let defaultFontName:String = "Avenir-Roman" //"Helvetica"
    static let defaultFontName:String = {
//        let fontNames = ["AmericanTypewriter","ChalkboardSE-Regular","Avenir-Roman"]
//        let fontNames = ["Baskerville","ChalkboardSE-Regular","Avenir-Roman"]
//        let fontNames = ["ChalkboardSE-Regular","Avenir-Roman"]
//
//        for fname in fontNames {
//            if let _ = UIFont(name: fname, size: 16) {
//                return fname
//            }
//        }
//        return "Avenir-Roman"
        let name = "Avenir-Roman"
        if let _ = UIFont(name: name, size: 16) {
            return name
        }else{
            let font = UIFont.systemFont(ofSize: 16)
            return font.fontName
        }
    }()
    
    static let defaultTextColorHex:String = "000000"       //black
    
    static var cdDefault: CDDefault?
//    static var currentDesktop:CDDesktop?
    
    static func getDefault() -> CDDefault? {
        if let defaults = DefaultService.cdDefault  {
            return defaults
        } else {
            let d = queryDefault()
            DefaultService.cdDefault = d
            return d
        }
        
    }
    
    static func saveDefaultDesktop(_ cdDesktop:CDDesktop) {
        if let defaults = DefaultService.getDefault() {
            defaults.desktop = cdDesktop
            DBManager.saveContext()
        }
    }
    
    static func getSystemDefaultDesktop() -> CDDesktop? {
        let fetchRequest:NSFetchRequest<CDDesktop> = NSFetchRequest(entityName: "CDDesktop")
        fetchRequest.predicate = NSPredicate(format: "id == 1")
        do {
            let cdDesktops = try DBManager.managedObjectContext.fetch(fetchRequest)
            if let cdDesktop = cdDesktops.first {
                    return cdDesktop
            }
        }catch{
            Util.printLog("getSystemDefaultDesktop error:\(error)")
            Util.saveAccessLog("getSystemDefaultDesktop*error",memo:"Error:\(error) \(#function)-\(#line)")
            return nil
        }
        return nil
    }
    
    private static func queryDefault() -> CDDefault? {
        let fetchRequest:NSFetchRequest<CDDefault> = NSFetchRequest(entityName: "CDDefault")
        do {
            let cdDefaults = try DBManager.managedObjectContext.fetch(fetchRequest)
            if cdDefaults.count == 0 {
                return DefaultService.initDefaultValues()
            }else{
                if let d = cdDefaults.first {
                    Util.printLog("=====Query defaults:\(d)======")
                    Util.printLog("=====Default desktop name:\(String(describing: d.desktop?.name))======")
                    // init currentDe
//                    DefaultService.currentDesktop = getCurrentDesktop(desktopId: d.desktopId)
                    return d
                }
            }
            
        }catch{
            Util.printLog("queryDefault error:\(error)")
            Util.saveAccessLog("queryDefault*error",memo:"Error:\(error) \(#function)-\(#line)")
            return nil
        }
        return nil
        
    }
    
    /*
    static func getCurrentDesktop(desktopId: Int64) -> CDDesktop?  {
        let fetchRequest:NSFetchRequest<CDDesktop> = NSFetchRequest(entityName: "CDDesktop")
//        fetchRequest.predicate = NSPredicate(
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//            fetchRequest.predicate = NSPredicate(format: "id == %@", desktopId)
            fetchRequest.predicate = NSPredicate(format: "id == \(desktopId)")
            let cdDesktops = try DBManager.managedObjectContext.fetch(fetchRequest)

            Util.printLog("=======fetched current desktop:\(String(describing: cdDesktops.first?.name))===========")
            return cdDesktops.first
            
        }catch {
            Util.printLog("fetch Current Desktop error:\(error)")
        }
        return nil
        
    }
 */
    private static func initDefaultValues() -> CDDefault {
        Util.printLog("=====fist call initDefaultValues====" )
        
        let cdDefault = NSEntityDescription.insertNewObject(forEntityName: "CDDefault", into: DBManager.managedObjectContext) as! CDDefault
        
        
        //init first desktop
        let cdDesktop = NSEntityDescription.insertNewObject(forEntityName: "CDDesktop", into: DBManager.managedObjectContext) as! CDDesktop
        cdDesktop.id = "1"
        //todo i18n
        var deskName = Appi18n.i18n_defaultDesktopName //NSLocalizedString("DefaultDesktopName", comment: "DefaultDesktopName")
        if deskName.isEmpty || deskName == "" {
            deskName = "Default"
        }
        cdDesktop.name = deskName
        let currentDate  = Date()
        cdDesktop.createAt = currentDate
        cdDesktop.updateAt = currentDate
        
        let imgName = AppDefault.defaultDesktopBackgroundImageName
        if let img = UIImage(named:imgName) {
            let imgData = img.jpegData(compressionQuality: 1)
             cdDesktop.backImageContent =  imgData
        }
    
    
//        cdDefault.desktopId = 1
        cdDefault.bkImageTop = 10
        cdDefault.bkImageLeft = 10
        cdDefault.bkImageRight = 10
        cdDefault.bkImageBottom = 10
        cdDefault.bkImageName =  AppDefault.defaultBackgoundImageName
        cdDefault.bkImageColorHex = AppDefault.defaultBackgoundImageColorHex   //"FFFF8B"  //yellow
        cdDefault.desktop = cdDesktop
        cdDefault.isSoundEnabled = true
        //not set default fontSize,fontname and textColor
//        cdDefault.textFontSize =
//        cdDefault.textColorHex = "000000"
        
        DBManager.saveContext()
        return cdDefault
    }
    
    static func saveStyleAsDefault(_ memo: Memo) {
        if let defaults = DefaultService.getDefault() {
           defaults.bkImageName = memo.backgroundImage.name
            defaults.bkImageTop = Float(memo.backgroundImage.edgeTop)
            defaults.bkImageRight = Float(memo.backgroundImage.edgeRight)
            defaults.bkImageBottom = Float(memo.backgroundImage.edgeBottom)
            defaults.bkImageLeft = Float(memo.backgroundImage.edgeLeft)
            defaults.bkImageColorHex = memo.backgroundImage.tintColorHex
            defaults.bkImageData = memo.backgroundImage.imageData
            
            defaults.textColorHex = memo.displayStyle.textColorHex
            defaults.textFontName = memo.displayStyle.fontName
            defaults.textFontSize = Float(memo.displayStyle.fontSize)
            DBManager.saveContext()
        }
    }
    
    
    static func saveSoundEnable(_ enabled:Bool) {
        if let defaults = DefaultService.getDefault() {
            defaults.isSoundEnabled = enabled
            DBManager.saveContext()
        }
    }
    
    static func isSoundEnabled() -> Bool {
        if let defaults = DefaultService.getDefault() {
            return defaults.isSoundEnabled
        }
        return true
    }
    
    static func isvip() -> Bool {
        
        //2020 modify disable VIP conditions for self usage
//        if let defaults = DefaultService.getDefault() {
//            return defaults.isvip
//        }
//        return false
        return true
    }
    
    static func purchaseVIP() {
        if let defaults = DefaultService.getDefault() {
            defaults.isvip = true
            DBManager.saveContext()
        }
    }
    
    static func isAutoPasteEnabled() -> Bool {
        
        if let defaults = DefaultService.getDefault() {
            return defaults.isAutoPasteEnabled
        }
        return false
    }
    
    static func saveAutoPasteEnable(_ enabled:Bool) {
        if let defaults = DefaultService.getDefault() {
            defaults.isAutoPasteEnabled = enabled
            DBManager.saveContext()
        }
    }
    
    static func saveVersion(_ versionBuild:String ) {
        if let defaults = DefaultService.getDefault() {
            defaults.versionBuild = versionBuild
            DBManager.saveContext()
        }
    }
    
    static func isFirstStart() -> Bool {
        if let defaults = DefaultService.getDefault() {
            return defaults.isFirstStart
        }
        return true
    }
    
    static func saveFirstStartStatus() {
        if let defaults = DefaultService.getDefault() {
            defaults.isFirstStart = false
            DBManager.saveContext()
        }
    }
    
    
    static func isPasswordEnabled() -> Bool {
        
        if let defaults = DefaultService.getDefault() {
            return defaults.isPasswordEnabled
        }
        return false
    }
    
    static func savePasswordEnable(_ enabled:Bool) {
        if let defaults = DefaultService.getDefault() {
            defaults.isPasswordEnabled = enabled
            DBManager.saveContext()
        }
    }
    
    static func isTouchIDEnabled() -> Bool {
        if let defaults = DefaultService.getDefault() {
            return defaults.isTouchIDEnabled
        }
        return false
    }
    
    static func saveTouchIDEnable(_ enabled:Bool) {
        if let defaults = DefaultService.getDefault() {
            defaults.isTouchIDEnabled = enabled
            DBManager.saveContext()
        }
    }
    
    static func getAccessPassword() -> String {
        if let defaults = DefaultService.getDefault(),let pass = defaults.accessPassword {
            return pass
        }
        return ""
    }
    
    static func saveAccessPassword(_ password:String)  {
        if let defaults = DefaultService.getDefault() {
            defaults.accessPassword = password
            DBManager.saveContext()
        }
    }
    
}
