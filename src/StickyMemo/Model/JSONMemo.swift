//
//  JSONMemo.swift
//  StickyMemo
//
//  Created by alex on 2018/2/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation
import CoreData
struct JSONDesktop:Codable {
    
    var id,name:String?
    var deleteTag:Bool
    var createAt,updateAt:Date?
//    var backImageContent:Data?
    
    var memos:[JSONMemo]?
    init(_ cdDesktop:CDDesktop){
        self.id = cdDesktop.id
        self.name = cdDesktop.name
        self.deleteTag = cdDesktop.deleteTag
        self.createAt = cdDesktop.createAt
        self.updateAt = cdDesktop.updateAt
//        self.backImageContent = cdDesktop.backImageContent
        if let memos = cdDesktop.memos, let memoArray = Array(memos) as? [CDMemo] {
//            self.memos = memoArray.flatMap{
            self.memos = memoArray.compactMap{
                return JSONMemo($0)
            }
        }
    }
}

struct JSONPosition:Codable{
    var x,y,width,height:Float
    
    init(_ cdPosition: CDPosition?) {
        guard let cdPosition = cdPosition else {
            self.x = 0
            self.y = 0
            self.width = 200
            self.height = 200
            return
        }
        self.x = (cdPosition.x)
        self.y = (cdPosition.y)
        self.width = (cdPosition.width)
        self.height = (cdPosition.height)
    }
}

struct JSONDisplayStyle:Codable {
    var fontName:String?
    var fontSize:Float = 18
    var colorHex:String?
    init(_ cdDisplayStyle: CDDisplayStyle?) {
        self.fontName = cdDisplayStyle?.fontName //?? ""
        self.fontSize = cdDisplayStyle?.fontSize ?? 18
        self.colorHex = cdDisplayStyle?.colorHex //?? "FFFF8B"
    }
}

struct JSONBackgroundImage:Codable {
    var name: String?
    var edgeTop:Float
    var edgeLeft:Float
    var edgeBottom:Float
    var edgeRight: Float
    var tintColorHex: String? //= "FFFFFF"
    var imageData: Data?
    
    init(_ cdBackgroundImage: CDBackgroundImage?) {
        self.name = cdBackgroundImage?.name //?? ""
        self.edgeTop = cdBackgroundImage?.edgeTop ?? 40
        self.edgeLeft = cdBackgroundImage?.edgeLeft ?? 40
        self.edgeRight = cdBackgroundImage?.edgeRight ?? 40
        self.edgeBottom = cdBackgroundImage?.edgeBottom ?? 40
        self.tintColorHex = cdBackgroundImage?.tintColorHex //?? "FFFF8B"
        self.imageData = cdBackgroundImage?.imageData
    }
    
}

struct JSONImage:Codable{
    var id:String?
    var imageContent:Data?
    var createAt:Date?
    
    init(_ cdImage: CDImage?){
        self.id = cdImage?.id
        self.imageContent = cdImage?.imageContent
        self.createAt = cdImage?.createAt
    }
}

struct JSONAudio:Codable {
    var id:String?
    var createAt:Date?
    var content:Data?
    var comment:String?
    
    init(_ cdAudio:CDAudio) {
        self.id = cdAudio.id
        self.createAt = cdAudio.createAt
        self.content = cdAudio.content
        self.comment = cdAudio.comment
    }
}
struct JSONMemo:Codable{
    var id:String
    var subject:String
    var body:String
    var createAt:Date
    var updateAt:Date
    var deleteTag:Bool
    var isFavorited:Bool
    var isReminderEnabled:Bool
    var reminderTime:Date
    var reminderRepeat:String
    
    var position:JSONPosition
    var displayStyle:JSONDisplayStyle
    
    var backgroundImage: JSONBackgroundImage
    var images:[JSONImage]?
    var audios:[JSONAudio]?
    
    init(_ cdMemo:CDMemo){
        self.id = cdMemo.id ?? ""
        self.subject = cdMemo.subject ?? ""
        self.body = cdMemo.body ?? ""
        self.createAt = cdMemo.createAt ?? Date()
        self.updateAt = cdMemo.updateAt ?? Date()

        self.deleteTag = cdMemo.deleteTag
        self.isFavorited = cdMemo.isFavorited
        
        self.isReminderEnabled = cdMemo.isReminderEnabled
        self.reminderTime = cdMemo.reminderTime ?? Date()
        self.reminderRepeat = cdMemo.reminderRepeat ?? ""
        
        
        self.position = JSONPosition(cdMemo.position)
        self.displayStyle = JSONDisplayStyle(cdMemo.displayStyle)
        self.backgroundImage = JSONBackgroundImage(cdMemo.backgroundImage)
        
        if let cdImages = cdMemo.images, let imageList = Array(cdImages) as? [CDImage] {
            self.images = imageList.map{ return JSONImage($0) }
        }
        
        if let cdAudios = cdMemo.audios, let audioList = Array(cdAudios) as? [CDAudio] {
//            print("****audio count:\(audioList.count)")
            self.audios = audioList.map{ return JSONAudio($0) }
        }
    }
    
    func insertOrUpdate(_ cdDesktop:CDDesktop){
        
        if let cdMemo = MemoService().queryCDMemoByID(self.id), let updateAt = cdMemo.updateAt { //found
            if self.updateAt > updateAt { //update memo
                MemoService().updateCDMemo(cdMemo, jsonMemo:self)
            }
        }else{ //insert a new entry
            let _ = MemoService().createCDMemo(cdDesktop, jsonMemo: self)
        }
    }
    
    
//    enum CodingKeys: String, CodingKey {
//        case firstName
//        case lastName
//    }
    
//    func jsonString() -> String {
//        let jsonData = try? JSONEncoder().encode(self)
//        if let str = String(data: jsonData!, encoding: .utf8) {
//            return str
//        }else{
//            return ""
//        }
//    }
}
