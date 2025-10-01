//
//  AudioService.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/13.
//  Copyright © 2018年 alix. All rights reserved.
//

import CoreData

class AudioService {
    
    
//    func queryAudio() -> [CDAudio] {
//        var audioList:[CDAudio] = []
//        let fetchRequest:NSFetchRequest<CDAudio> = NSFetchRequest(entityName: "CDAudio")
//        
//        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "createAt", ascending: false) ]
////        fetchRequest.predicate = NSPredicate(format: "deleteTag == true")
//        do {
//            let cdAudioList = try DBManager.managedObjectContext.fetch(fetchRequest)
//            audioList = Array(cdAudioList)
//            
//        }catch{
//            Util.printLog("queryAudio  error:\(error)")
//        }
//        return audioList
//    }
    
    func createCDAudio(_ cdMemo:CDMemo, createAt:Date,content:Data, comment:String) -> CDAudio{
        let cdAudio = NSEntityDescription.insertNewObject(forEntityName: "CDAudio", into: DBManager.managedObjectContext) as! CDAudio
        
        //        Util.printLog("date:\(Date().timeIntervalSince1970)")
        cdAudio.id = String(Int64((createAt.timeIntervalSince1970) * 100000))
        cdAudio.createAt = createAt
        cdAudio.content = content
        cdAudio.comment = comment
        cdAudio.memo = cdMemo
        DBManager.saveContext()
        return cdAudio
    }
    
    func saveComment(_ cdAudio:CDAudio, comment:String) {
        cdAudio.comment = comment
        DBManager.saveContext()
    }
    
    func deleteCDAudio(_ cdAudio:CDAudio){
        DBManager.managedObjectContext.delete(cdAudio)
        DBManager.saveContext()
    }
    
}
