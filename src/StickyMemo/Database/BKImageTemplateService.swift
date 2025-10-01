//
//  BKImageTemplateService.swift
//  StickyMemo
//
//  Created by alex on 2018/1/10.
//  Copyright © 2018年 alix. All rights reserved.
//

import CoreData
import UIKit

class BKImageTemplateService {

    func queryBKImageCatalog() -> [CDBKImageCatalog]? {
        let fetchRequest:NSFetchRequest<CDBKImageCatalog> = NSFetchRequest(entityName: "CDBKImageCatalog")
//        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "isLocked", ascending: true)]
//        NSSortDescriptor(key: "order", ascending: true)
        do {
            let catalog = try DBManager.managedObjectContext.fetch(fetchRequest)
            return catalog
        }catch{
            Util.printLog("queryBKImageCatalog error:\(error)")
            Util.saveAccessLog("queryBKImageCatalog*error",memo:"Error:\(error) \(#function)-\(#line)")
            return nil
        }
    }
    
    
    
    
    //init data if current build != default build
    func initBKImageData() {
        guard let catalog = self.queryBKImageCatalog() else {
            Util.printLog("===catalog is nil")
            return
        }
        let debug = false
        if debug {
            //for debug image data, todo remove before release
            for c in catalog {
                DBManager.managedObjectContext.delete(c)
                DBManager.saveContext()
            }
        }
        
        guard let defaults = DefaultService.getDefault() else {
            Util.printLog("===defaults is nil")
            return
        }
        
        guard let cdCatalog = self.queryBKImageCatalog() else {
            return
        }
        
        if cdCatalog.count == 0 {
            //init insert data
            Util.printLog("========init catalog and image template=======")
            insertAllCatalogAndImages()
        }else{
            //todo just debug
//            self.insertOrUpdate(cdCatalog)
            if defaults.versionBuild != Util.getVerionAndBuild() {
                //insert new version data
                Util.printLog("========upgrade catalog and image template=======")
                self.insertNewVersionImages(cdCatalog)
            }else{
                //no northing
            }
        }
        
        DefaultService.saveVersion(Util.getVerionAndBuild())
        
    }
    
    
    func insertAllCatalogAndImages() {
        guard let imageCatalog = self.getImageCatalogFromJson() else {
            Util.printLog("faile to getImageCatalogFromJson! ")
            return
        }
        for imagecat in imageCatalog {
            self.insertCatalogAndImages(imagecat)
        }
    }
    
    func insertCatalogAndImages(_ imageCatalog: JSONBKImageCatalog) {
        Util.printLog("======creating image catalog:\(imageCatalog.name)")
        let cdcatalog = NSEntityDescription.insertNewObject(forEntityName: "CDBKImageCatalog", into: DBManager.managedObjectContext) as! CDBKImageCatalog
        
        cdcatalog.name = imageCatalog.name
        cdcatalog.order = imageCatalog.order
        cdcatalog.isLocked = imageCatalog.isLocked
        
        if let uimg = UIImage(named: imageCatalog.name) {
            let imgData =  uimg.pngData()  //UIImageJPEGRepresentation(img, 1)
            cdcatalog.imageData =  imgData
            //                let filename = Util.applicationDocumentsDirectory.appendingPathComponent(image.name)
            //                try? imgData?.write(to: filename)
            //                Util.printLog("========Write file to \(filename)")
        }else{
            Util.printLog("========need attention, not found image by name:\(imageCatalog.name)")
            Util.saveAccessLog("insertCatalogAndImages*error",memo:"Error: not found \(imageCatalog.name) \(#function)-\(#line)")

        }
        
        for image in imageCatalog.bkImageTemplates {
            Util.printLog("======creating imagetemplate:\(image.name)")
            let cdimage = NSEntityDescription.insertNewObject(forEntityName: "CDBKImageTemplate", into: DBManager.managedObjectContext) as! CDBKImageTemplate
            
            cdimage.edgeBottom = Float(imageCatalog.edgeBottom)
            cdimage.edgeTop = Float(imageCatalog.edgeTop)
            cdimage.edgeLeft = Float(imageCatalog.edgeLeft)
            cdimage.edgeRight = Float(imageCatalog.edgeRight)
            cdimage.tintColorHex = image.tintColorHex
            cdimage.name = image.name
            cdimage.order = image.order
            
            if let img = UIImage(named: image.name) {
                let imgData =  img.pngData()  //UIImageJPEGRepresentation(img, 1)
                cdimage.imageData =  imgData
//                let filename = Util.applicationDocumentsDirectory.appendingPathComponent(image.name)
//                try? imgData?.write(to: filename)
//                Util.printLog("========Write file to \(filename)")
            }
            //create reference
            cdimage.catalog = cdcatalog
        }
        
        DBManager.saveContext()
    }
    
    func insertNewVersionImages(_ cdBKImageCatalog: [CDBKImageCatalog]) {
        
        guard let imageCatalog = self.getImageCatalogFromJson() else {
            Util.printLog("faile to getImageCatalogFromJson! ")
            return
        }
        Util.printLog("=======insert or upgrade .......")
        for imagecat in imageCatalog {
            let searchResult = cdBKImageCatalog.filter({ (cdImgCat) -> Bool in
                return cdImgCat.name == imagecat.name
            })

//            self.insertCatalogAndImages(imagecat)
            if searchResult.count == 0 { //not found catlog
                // insert
                Util.printLog("=======insert new image catlog .......")
                self.insertCatalogAndImages(imagecat)
            }else{
                //do northing
            }
        }
    
    }
    

    func getImageCatalogFromJson() -> [JSONBKImageCatalog]? {
        if let filePath = Bundle.main.path(forResource: "imagetemplate", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .alwaysMapped)
                Util.printLog("=======json content \(data)===========")
                let catalog = try JSONDecoder().decode([JSONBKImageCatalog].self, from: data)
                return catalog
            } catch let error {
                Util.printLog(error)
                Util.saveAccessLog("getImageCatalogFromJson*error",memo:"Error:\(error) \(#function)-\(#line)")
                
            }
        }
        return nil
    }
    
    func getAllBKImageCatalogs() -> [BKImageCatalog] {
        var cataList:[BKImageCatalog] = []
        let fetchRequest:NSFetchRequest<CDBKImageCatalog> = NSFetchRequest(entityName: "CDBKImageCatalog")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isLocked", ascending: true),NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let catalogs = try DBManager.managedObjectContext.fetch(fetchRequest)
            for catalog in catalogs {
                cataList.append(BKImageCatalog(catalog))
            }
            return cataList
            }catch{
                Util.printLog("getAllBKImageCatalogs error:\(error)")
                Util.saveAccessLog("getAllBKImageCatalogs*error",memo:"Error:\(error) \(#function)-\(#line)")
                return []
            }
    }
    
    func unlockImageCatalog(_ catalogName: String) {
        let fetchRequest:NSFetchRequest<CDBKImageCatalog> = NSFetchRequest(entityName: "CDBKImageCatalog")
//        fetchRequest.predicate = NSPredicate(format: "isLocked == true && name == \(catalogName)")
//        fetchRequest.predicate = NSPredicate(format: "name == \(catalogName)")
        Util.printLog("=====unlock catalog:\(catalogName)")
        fetchRequest.predicate = NSPredicate(format: "name == %@", catalogName)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            let catalogs = try DBManager.managedObjectContext.fetch(fetchRequest)
            if let cata = catalogs.first {
                cata.isLocked = false
                DBManager.saveContext()
            }
        }catch{
            Util.printLog("unlockImageCatalog error:\(error)")
            Util.saveAccessLog("unlockImageCatalog*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
        
    }
    
    func queryLockedImageCatalogs()  -> [BKImageCatalog]  {
        var result:[BKImageCatalog] = []
        let fetchRequest:NSFetchRequest<CDBKImageCatalog> = NSFetchRequest(entityName: "CDBKImageCatalog")
        fetchRequest.predicate = NSPredicate(format: "isLocked == true")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            let cdCatalog = try DBManager.managedObjectContext.fetch(fetchRequest)
            result = cdCatalog.map{ return BKImageCatalog($0) }
        }catch{
            Util.printLog("queryLockedImageCatalogs error:\(error)")
            Util.saveAccessLog("queryLockedImageCatalogs*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
        return result
        
    }
    
    
}
