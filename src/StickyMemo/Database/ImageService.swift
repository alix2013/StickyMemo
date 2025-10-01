//
//  ImageService.swift
//  StickyMemo
//
//  Created by alex on 2017/12/12.
//  Copyright © 2017年 alix. All rights reserved.
//

import CoreData
class ImageService {
    
    func addImage(_ cdMemo: CDMemo,imageContent:Data?)-> CDImage{

        let cdImage = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: DBManager.managedObjectContext) as! CDImage
//        cdImage.id = Int64(Date().timeIntervalSince1970)
        cdImage.id = String(Int64((Date().timeIntervalSince1970) * 100000))
        
        cdImage.createAt = Date()
        cdImage.imageContent = imageContent
        cdImage.memo = cdMemo
        DBManager.saveContext()
        return cdImage
    }
    
    func deleteImage(_ cdImage:CDImage) {
        
        DBManager.managedObjectContext.delete(cdImage)
        DBManager.saveContext()
        
    }
    
}
