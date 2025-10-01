//
//  ShortcutKeyService.swift
//  StickyMemo
//
//  Created by alex on 2018/1/18.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation
import CoreData

class ShortcutkeyService {
    
//    static let share = ShortcutService()
    //todo save to db then query from db
    static let initialShortcutKeyList:[String] = [ "☒","☑︎","✗","✓","☞","☛","➢","➤","☆","★"] //☆✭⭐︎✯✓✕"●","◆","◼︎""✭"
    
    static var currentCDShortcutKeys:[CDShortcutkey] = []
    
    static func getShortcutKeyList() -> [String] {
        let sorted = ShortcutkeyService.currentCDShortcutKeys.sorted { $0.order < $1.order
        }
        //remove nil using flatMap
//        let stringKey = sorted.flatMap{ $0.key }
        let stringKey = sorted.compactMap{ $0.key }
        return stringKey
//        return initialShortcutKeyList
    }
    
    
    public static func initOrFreshShortcutkeyCache()  {
        
        let fetchRequest:NSFetchRequest<CDShortcutkey> = NSFetchRequest(entityName: "CDShortcutkey")
        do {
            let keys = try DBManager.managedObjectContext.fetch(fetchRequest)
            
            //for debug
//            let debug:Bool = true
//            if debug {
//            keys.forEach({ (key) in
//                DBManager.managedObjectContext.delete(key)
//                DBManager.saveContext()
//            })
//            }
            if keys.count == 0 {
                ShortcutkeyService.initDefaultValues()
            }else{
                ShortcutkeyService.currentCDShortcutKeys = keys
            }
        }catch{
            Util.printLog("initOrFreshShortcutkeyCache error:\(error)")
            Util.saveAccessLog("initOrFreshShortcutkeyCache*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
    }
//
    
    private static func initDefaultValues()  {
        Util.printLog("=====init shortcut keys DefaultValues====" )
        currentCDShortcutKeys.removeAll()
        for (index,key) in ShortcutkeyService.initialShortcutKeyList.enumerated() {
//             let cdShortcurtkey = NSEntityDescription.insertNewObject(forEntityName: "CDShortcutkey", into: DBManager.managedObjectContext) as! CDShortcutkey
//            cdShortcurtkey.order = Int32(index)
//            cdShortcurtkey.key = key
            let  cdShortcurtkey = insertShortcutkey(index, key: key)
            currentCDShortcutKeys.append(cdShortcurtkey)
        }
        DBManager.saveContext()
    }
    
    static func deleteShortcutkey(_ cdKey:CDShortcutkey) {
        DBManager.managedObjectContext.delete(cdKey)
        DBManager.saveContext()
    }
    
    static func updateShortcutkey(_ cdKey:CDShortcutkey) {
        DBManager.saveContext()
    }
    
    static func insertShortcutkey(_ order:Int, key:String) -> CDShortcutkey {
        let cdShortcurtkey = NSEntityDescription.insertNewObject(forEntityName: "CDShortcutkey", into: DBManager.managedObjectContext) as! CDShortcutkey
        cdShortcurtkey.order = Int32(order)
        cdShortcurtkey.key = key
//        DBManager.managedObjectContext.delete(cdShortcurtkey)
        DBManager.saveContext()
        return cdShortcurtkey
    }
}
