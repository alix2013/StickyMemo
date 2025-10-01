//
//  MemoService.swift
//  StickyMemo
//
//  Created by alex on 2017/12/4.
//  Copyright © 2017年 alix. All rights reserved.
//

import CoreData

class MemoService {
    
//    func queryMemo() -> [Memo] {
//        var memoList:[Memo] = []
//        var cdMemoList:[CDMemo] = []
//        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
//        do {
//            cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
//            for cdMemo in cdMemoList {
//                let memo = Memo(cdMemo)
//                memoList.append(memo)
//            }
//
//        }catch{
//            Util.printLog("Fetch memo error:\(error)")
//        }
//
//        return memoList
//
//    }
    
    func queryCurrentDesktopUndeletedMemos(_ currentDesktop: CDDesktop) -> [Memo] {
            var memoList:[Memo] = []
//            var cdMemoList:[CDMemo] = []
        
        var tempCdMemos : [CDMemo] = []
        if let cdMemos =  currentDesktop.memos {
            
            for (_,cdMemo) in cdMemos.enumerated() {
//                let memo = Memo(cdMemo as! CDMemo)
                let cMemo = cdMemo as! CDMemo
                if !cMemo.deleteTag {
                    tempCdMemos.append(cMemo)
//                    let memo = Memo(cMemo)
//                    memoList.append(memo)
                }
            }
        }
        let list = tempCdMemos.sorted( by: {
            if let a = $0.updateAt, let b = $1.updateAt {
                return a < b
            } else {
                return true // is above one or both are nil
            }
//            $0.updateAt! < $1.updateAt!
            
        } )
        memoList = list.map{ Memo($0) }
//            let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
//            do {
//                cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
//                for cdMemo in cdMemoList {
//                    let memo = Memo(cdMemo)
//                    memoList.append(memo)
//                }
//
//            }catch{
//                Util.printLog("Fetch memo error:\(error)")
//            }
        return memoList
    
        }

    
    
    lazy var fetchedResultController: NSFetchedResultsController<CDMemo> = { () -> NSFetchedResultsController<CDMemo> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDMemo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "desktop.name", ascending: true),NSSortDescriptor(key: "updateAt", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DBManager.managedObjectContext, sectionNameKeyPath: #keyPath(CDDesktop.name), cacheName: nil)
        //        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: #keyPath(catalog), cacheName: nil)
        //                let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        frc.delegate = self
        return frc as! NSFetchedResultsController<CDMemo>
    }()
    
//    func queryAllUndeletedMemos() -> [SectionMemoTable] {
//
//        var memoTableList:[SectionMemoTable] = []
//
//        for section in self.fetchedResultController.sections! {
//            let name = section.name
//            var memoList:[Memo] = []
//            for obj in section.objects! {
//                let cdMemo = obj as! CDMemo
//                let memo = Memo(cdMemo)
//                memoList.append(memo)
//            }
//            memoTableList.append(SectionMemoTable(sectionName: name, memoList: memoList, isExtended: true))
//        }
//
////        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
////        do {
////            cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
////            for cdMemo in cdMemoList {
////                let memo = Memo(cdMemo)
////                memoList.append(memo)
////            }
////
////        }catch{
////            Util.printLog("Fetch memo error:\(error)")
////        }
////
//
//
//        return memoTableList
//
//    }

    
    func queryAllUndeletedMemos() -> [Memo] {
        
        var memoList:[Memo] = []
        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
        
        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "updateAt", ascending: false) ]
        fetchRequest.predicate = NSPredicate(format: "deleteTag == false")
        do {
            let cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
            for cdMemo in cdMemoList {
                let memo = Memo(cdMemo)
                memoList.append(memo)
            }
            
        }catch{
            Util.printLog("queryAllUndeletedMemos  error:\(error)")
            Util.saveAccessLog("queryAllUndeletedMemos*error",memo:"Error:\(error) \(#function)-\(#line)")

        }
        return memoList
        
    }
    
    func queryFavoritedUndeletedMemos() -> [Memo] {
        
        var memoList:[Memo] = []
        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
        
        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "updateAt", ascending: false) ]
        fetchRequest.predicate = NSPredicate(format: "deleteTag == false && isFavorited == true")
        do {
            let cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
            for cdMemo in cdMemoList {
                let memo = Memo(cdMemo)
                memoList.append(memo)
            }
            
        }catch{
            Util.printLog("queryFavoritedUndeletedMemos  error:\(error)")
            Util.saveAccessLog("queryFavoritedUndeletedMemos*error",memo:"Error:\(error) \(#function)-\(#line)")

        }
        return memoList
        
    }
    
    
    func queryTrashMemos() -> [Memo] {
        
        var memoList:[Memo] = []
        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
        
        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "updateAt", ascending: false) ]
        fetchRequest.predicate = NSPredicate(format: "deleteTag == true")
        do {
            let cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
            for cdMemo in cdMemoList {
                let memo = Memo(cdMemo)
                memoList.append(memo)
            }
            
        }catch{
            Util.printLog("queryTrashMemos  error:\(error)")
            Util.saveAccessLog("queryTrashMemos*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
        return memoList
        
    }
    
    
    
//    func saveMemo(memo: Memo) {
//        do {
//            try DBManager.managedObjectContext.save()
//        }catch{
//            Util.printLog("Save memo error:\(error)")
//        }
//        
//        
//    }
    
    func createMemo(_ cdDesktop: CDDesktop) -> Memo {
        
        let cdPosition = NSEntityDescription.insertNewObject(forEntityName: "CDPosition", into: DBManager.managedObjectContext) as! CDPosition
        //get default position ...
        
        let cdDisplayStyle = NSEntityDescription.insertNewObject(forEntityName: "CDDisplayStyle", into: DBManager.managedObjectContext) as! CDDisplayStyle
        //get set default style
        
        let cdBackgroundImage = NSEntityDescription.insertNewObject(forEntityName: "CDBackgroundImage", into: DBManager.managedObjectContext) as! CDBackgroundImage
        
        let cdMemo = NSEntityDescription.insertNewObject(forEntityName: "CDMemo", into: DBManager.managedObjectContext) as! CDMemo
        cdMemo.position = cdPosition
        cdMemo.displayStyle = cdDisplayStyle
        cdMemo.backgroundImage = cdBackgroundImage
//        Util.printLog("date:\(Date().timeIntervalSince1970)")
        cdMemo.id = String(Int64((Date().timeIntervalSince1970) * 100000))
        let currentDate = Date()
        cdMemo.createAt = currentDate
        cdMemo.updateAt = currentDate
        cdMemo.deleteTag = false
        cdMemo.isFavorited = false
        //save pasteboard string to cdmemo.body
        if DefaultService.isAutoPasteEnabled(), let boardStr = UIUtil.getPasteBoardString() {
            cdMemo.body = boardStr
        }
        cdMemo.desktop = cdDesktop
        //        let memoEntityDesc = NSEntityDescription.entity(forEntityName: "Memo", in: DBManager.managedObjectContext)
//        let cdMemo = CDMemo(entity: memoEntityDesc!, insertInto: DBManager.managedObjectContext)
        
        let memo = Memo(cdMemo)
        return memo
        
    }
    
   
    func queryCDMemoByID(_ id:String) -> CDMemo? {
        
        
        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
        
//        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "updateAt", ascending: false) ]
        fetchRequest.predicate = NSPredicate(format: "id == %@",id)
        do {
            let cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
            return cdMemoList.first
            
        }catch{
            Util.printLog("queryCDMemoByID  error:\(error)")
            Util.saveAccessLog("queryCDMemoByID*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
        return nil
    }
    
    
    func createCDMemo(_ cdDesktop:CDDesktop, jsonMemo:JSONMemo) -> CDMemo?{
        
        let cdPosition = NSEntityDescription.insertNewObject(forEntityName: "CDPosition", into: DBManager.managedObjectContext) as! CDPosition
        
        
        let cdDisplayStyle = NSEntityDescription.insertNewObject(forEntityName: "CDDisplayStyle", into: DBManager.managedObjectContext) as! CDDisplayStyle
        
        let cdBackgroundImage = NSEntityDescription.insertNewObject(forEntityName: "CDBackgroundImage", into: DBManager.managedObjectContext) as! CDBackgroundImage
        
        let cdMemo = NSEntityDescription.insertNewObject(forEntityName: "CDMemo", into: DBManager.managedObjectContext) as! CDMemo
        
        cdPosition.x = jsonMemo.position.x
        cdPosition.y = jsonMemo.position.y
        cdPosition.width = jsonMemo.position.width
        cdPosition.height = jsonMemo.position.height
        
        cdDisplayStyle.fontName = jsonMemo.displayStyle.fontName
        cdDisplayStyle.fontSize = jsonMemo.displayStyle.fontSize //?? 18
        cdDisplayStyle.colorHex = jsonMemo.displayStyle.colorHex
        
        cdBackgroundImage.edgeLeft = jsonMemo.backgroundImage.edgeLeft //?? 40
        cdBackgroundImage.edgeTop = jsonMemo.backgroundImage.edgeTop //?? 40
        cdBackgroundImage.edgeRight = jsonMemo.backgroundImage.edgeRight //? 40
        cdBackgroundImage.edgeBottom = jsonMemo.backgroundImage.edgeBottom //?? 40
        cdBackgroundImage.name = jsonMemo.backgroundImage.name
        cdBackgroundImage.imageData = jsonMemo.backgroundImage.imageData
        cdBackgroundImage.tintColorHex = jsonMemo.backgroundImage.tintColorHex
        
        if let images = jsonMemo.images, images.count > 0 {
            for image in images {
                let cdImage = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: DBManager.managedObjectContext) as! CDImage
                cdImage.id = image.id
                cdImage.imageContent = image.imageContent
                cdImage.createAt = image.createAt
                cdImage.memo = cdMemo
//                cdMemo.images?.adding(cdImage)
                
            }
        }
        
        //for audios
        if let audios = jsonMemo.audios, audios.count > 0 {
            for audio in audios {
                let cdAudio = NSEntityDescription.insertNewObject(forEntityName: "CDAudio", into: DBManager.managedObjectContext) as! CDAudio
                cdAudio.id = audio.id
                cdAudio.createAt = audio.createAt
                cdAudio.comment = audio.comment
                cdAudio.content = audio.content
                cdAudio.memo = cdMemo
            }
        }
        
        cdMemo.position = cdPosition
        cdMemo.displayStyle = cdDisplayStyle
        cdMemo.backgroundImage = cdBackgroundImage
        cdMemo.desktop = cdDesktop
       
        
        cdMemo.id =  jsonMemo.id //String(Int64((Date().timeIntervalSince1970) * 100000))
        cdMemo.body = jsonMemo.body
        cdMemo.subject = jsonMemo.subject
        let currentDate = Date()
        cdMemo.createAt = jsonMemo.createAt
        cdMemo.updateAt = currentDate
        
        cdMemo.deleteTag = jsonMemo.deleteTag
        cdMemo.isFavorited = jsonMemo.isFavorited
        
        
//        var isReminderEnabled:Bool
//        var reminderTime:Date
//        var reminderRepeat:String
     
        DBManager.saveContext()
        return cdMemo
        
        
    }
    
    func updateCDMemo(_ cdMemo:CDMemo, jsonMemo:JSONMemo){
        
        cdMemo.position?.x = jsonMemo.position.x
        cdMemo.position?.y = jsonMemo.position.y
        cdMemo.position?.width = jsonMemo.position.width
        cdMemo.position?.height = jsonMemo.position.height
        
        cdMemo.displayStyle?.fontName = jsonMemo.displayStyle.fontName
        cdMemo.displayStyle?.fontSize = jsonMemo.displayStyle.fontSize //?? 18
        cdMemo.displayStyle?.colorHex = jsonMemo.displayStyle.colorHex
        
        cdMemo.backgroundImage?.edgeLeft = jsonMemo.backgroundImage.edgeLeft //?? 40
        cdMemo.backgroundImage?.edgeTop = jsonMemo.backgroundImage.edgeTop //?? 40
        cdMemo.backgroundImage?.edgeRight = jsonMemo.backgroundImage.edgeRight //? 40
        cdMemo.backgroundImage?.edgeBottom = jsonMemo.backgroundImage.edgeBottom //?? 40
        cdMemo.backgroundImage?.name = jsonMemo.backgroundImage.name
        cdMemo.backgroundImage?.imageData = jsonMemo.backgroundImage.imageData
        cdMemo.backgroundImage?.tintColorHex = jsonMemo.backgroundImage.tintColorHex
        
        //delete old images then insert
        if let cdImages = cdMemo.images {
            for cdImage in cdImages {
                if let obj = cdImage as? CDImage {
                    DBManager.managedObjectContext.delete(obj)
                }
            }
        }
        
        if let images = jsonMemo.images, images.count > 0 {
            for image in images {
                let cdImage = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: DBManager.managedObjectContext) as! CDImage
                cdImage.id = image.id
                cdImage.imageContent = image.imageContent
                cdImage.createAt = image.createAt
                cdImage.memo = cdMemo
            }
        }
        
        //for audios delete the re-insert
        if let cdAudios = cdMemo.audios {
            for cdAudio in cdAudios {
                if let obj = cdAudio as? CDAudio {
                    DBManager.managedObjectContext.delete(obj)
                }
            }
        }
        
        if let audios = jsonMemo.audios, audios.count > 0 {
            for audio in audios {
                let cdAudio = NSEntityDescription.insertNewObject(forEntityName: "CDAudio", into: DBManager.managedObjectContext) as! CDAudio
                cdAudio.id = audio.id
                cdAudio.createAt = audio.createAt
                cdAudio.comment = audio.comment
                cdAudio.content = audio.content
                cdAudio.memo = cdMemo
            }
        }
        
        cdMemo.id =  jsonMemo.id //String(Int64((Date().timeIntervalSince1970) * 100000))
        cdMemo.body = jsonMemo.body
        cdMemo.subject = jsonMemo.subject
        let currentDate = Date()
        cdMemo.createAt = jsonMemo.createAt
        cdMemo.updateAt = currentDate
        
        cdMemo.deleteTag = jsonMemo.deleteTag
        cdMemo.isFavorited = jsonMemo.isFavorited
        
        //        var isReminderEnabled:Bool
        //        var reminderTime:Date
        //        var reminderRepeat:String
        
        DBManager.saveContext()
        
    }
}
