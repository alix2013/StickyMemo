//
//  MemoExtension.swift
//  StickyMemo
//
//  Created by alex on 2018/2/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

extension Memo {
    
    func save() {
        if let cdMemo = cdMemo {
            cdMemo.subject = self.subject
            cdMemo.body = self.body
            
            cdMemo.position?.x = Float(self.position.x)
            cdMemo.position?.y = Float(self.position.y)
            cdMemo.position?.width = Float(self.position.width)
            cdMemo.position?.height = Float(self.position.height)
            cdMemo.displayStyle?.fontName = self.displayStyle.fontName
            cdMemo.displayStyle?.fontSize =  Float(self.displayStyle.fontSize)
            cdMemo.displayStyle?.colorHex = self.displayStyle.textColorHex
            
            cdMemo.backgroundImage?.name = self.backgroundImage.name
            cdMemo.backgroundImage?.edgeLeft = Float(self.backgroundImage.edgeLeft)
            cdMemo.backgroundImage?.edgeTop = Float(self.backgroundImage.edgeTop)
            cdMemo.backgroundImage?.edgeRight = Float(self.backgroundImage.edgeRight)
            cdMemo.backgroundImage?.edgeBottom = Float(self.backgroundImage.edgeBottom)
            cdMemo.backgroundImage?.tintColorHex = self.backgroundImage.tintColorHex
            cdMemo.backgroundImage?.imageData = self.backgroundImage.imageData
            
            cdMemo.updateAt = Date()
            cdMemo.isFavorited = self.isFavorited
            
            DBManager.saveContext()
        }
    }
    
    func savePosition() {
        if let cdMemo = self.cdMemo {
            cdMemo.position?.x = Float(self.position.x)
            cdMemo.position?.y = Float(self.position.y)
            cdMemo.position?.width = Float(self.position.width)
            cdMemo.position?.height = Float(self.position.height)
            //            cdMemo.updateAt = Date()
            DBManager.saveContext()
        }
    }
    
    func fadeDelete() {
        if let cdMemo = cdMemo {
            cdMemo.deleteTag = true
            //                cdMemo.updateAt = Date()
            if cdMemo.isReminderEnabled {
                cdMemo.isReminderEnabled = false
                if let id = cdMemo.id {
                    NotificationHelper.removePendingNotificationRequests([id])
                }
                
            }
            DBManager.saveContext()
        }
    }
    
    func finalDelete() {
        if let cdMemo = cdMemo, let desktop = cdMemo.desktop, let count = desktop.memos?.count  {
            //final delete desktop if desktop have been deleted
            if desktop.deleteTag && count <= 1 {
                Util.printLog("Final Delete desktop :\(String(describing: desktop.name)) ")
                DBManager.managedObjectContext.delete(cdMemo)
                DBManager.managedObjectContext.delete(desktop)
            }else{
                DBManager.managedObjectContext.delete(cdMemo)
            }
            
            DBManager.saveContext()
        }
    }
    
    func restoreDeleted() {
        if let cdMemo = cdMemo, let desktop = cdMemo.desktop {
            cdMemo.deleteTag = false
            if desktop.deleteTag {
                Util.printLog("Undelete desktop:\(String(describing: desktop.name)) ")
                desktop.deleteTag = false
            }
            DBManager.saveContext()
        }
    }
    
    func getPhotoUIImageList() -> [UIImage]? {
        var uiImageList:[UIImage] = []
        if self.cdMemo?.images?.count == 0  {
            return nil
        } else {
            if let images = self.cdMemo?.images,let imageArray = Array(images) as? [CDImage] {
                let sortedImages = imageArray.sorted{
                    //                return $0.id < $1.id
                    if let createAt1 = $0.createAt, let createAt2 = $1.createAt {
                        return createAt1 < createAt2
                    }else{
                        return false
                    }
                }
                let imageDataList = sortedImages.map{
                    return $0.imageContent
                }
                for imageData in imageDataList {
                    if let imageData = imageData,let image = UIImage(data: imageData) {
                        uiImageList.append(image)
                    }
                }
            }
        }
        return uiImageList
    }
    
    func getObjectsForShare() -> [Any] {
        var shareObjects:[Any] = []
        let shareText = "\(self.subject)\n\(self.body)"
        shareObjects.append(shareText)
        
        if let audios = self.cdMemo?.audios, let cdAudioList = Array(audios) as? [CDAudio] {
            for audio in cdAudioList {
                //
                let objs = audio.getObjectsForShare()
                shareObjects.append(objs)
            }
        }
        if let uiImages = self.getPhotoUIImageList() {
            for uiimage in uiImages {
                shareObjects.append(uiimage)
            }
        }
        
        return shareObjects
    }
    
    func moveDesktop(_ cdDesktop: CDDesktop){
        if let cdMemo = self.cdMemo {
            cdMemo.desktop = cdDesktop
            DBManager.saveContext()
        }
    }
}
