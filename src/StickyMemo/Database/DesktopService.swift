//
//  DesktopService.swift
//  StickyMemo
//
//  Created by alex on 2017/12/8.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import CoreData

class DesktopService {
    
    func queryUndeletedDesktop() -> [CDDesktop]? {
        let fetchRequest:NSFetchRequest<CDDesktop> = NSFetchRequest(entityName: "CDDesktop")
        fetchRequest.predicate = NSPredicate(format: "deleteTag == false")
        do {
            let cdDesktops = try DBManager.managedObjectContext.fetch(fetchRequest)
            return cdDesktops
        }catch{
            Util.printLog("queryUndeletedDesktop error:\(error)")
            Util.saveAccessLog("queryUndeletedDesktop*error",memo:"Error:\(error) \(#function)-\(#line)")
            return nil
        }
    }
    
    func createDesktop(name:String, backImageContent:Data?) {
        
        let cdDesktop = NSEntityDescription.insertNewObject(forEntityName: "CDDesktop", into: DBManager.managedObjectContext) as! CDDesktop
        cdDesktop.id = String(Int64((Date().timeIntervalSince1970) * 100000)) //Int64(Date().timeIntervalSince1970)
        cdDesktop.name = name
        cdDesktop.createAt = Date()
        cdDesktop.updateAt = Date()
        cdDesktop.backImageContent = backImageContent
        DBManager.saveContext()
        
    }
    
    func updateDesktopImage(cdDesktop:CDDesktop, backImageContent: Data?) {
        cdDesktop.backImageContent = backImageContent
        cdDesktop.updateAt = Date()
        DBManager.saveContext()
    }
    
//    func deleteDesktop(cdDesktop: CDDesktop) {
//        let context = DBManager.managedObjectContext
//        context.delete(cdDesktop)
//        DBManager.saveContext()
//    }
    
    func fadeDeleteDesktop(cdDesktop: CDDesktop) {
        
        if let memos = cdDesktop.memos {
            for memo in memos {
                if let cdMemo = memo as? CDMemo {
                    cdMemo.deleteTag = true
                }
            }
        }
        cdDesktop.deleteTag = true

        DBManager.saveContext()
    }
    
    func finalDeleteDesktop(cdDesktop: CDDesktop) {
        DBManager.managedObjectContext.delete(cdDesktop)
        DBManager.saveContext()
    }
    
    func renameDesktop(cdDesktop: CDDesktop, newName:String) {
        cdDesktop.name = newName
        DBManager.saveContext()
    }
}
