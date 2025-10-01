//
//  Memo.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class Memo{
    var desktopName:String = ""
    var subject:String = ""
    var body:String = ""
    
    var updateAt:Date? {
        get {
            guard let update = cdMemo?.updateAt else {
                return nil
            }
            return update
        }
    }
    var isFavorited: Bool
    
    var htmlBody:String {
        get {
            let stringBody = "<p style=\"background-color:#\(self.backgroundImage.tintColorHex)\">\(body)</p>"
            let htmlBody = stringBody.replacingOccurrences(of: "\n", with: "<br>")
            return htmlBody
        }
    }
    
    var updateDateAttributedText:NSAttributedString {
        get{
            let attributedText = NSMutableAttributedString()
            if let updateAt = self.cdMemo?.updateAt {
//                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm:ss"
                let localDate = dateFormatter.string(from: updateAt)
//                attributedText.append(NSAttributedString(string: "\(Appi18n.i18n_timeUpdateAt)\(localDate)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.gray]))
                
                attributedText.append(NSAttributedString(string: "\(Appi18n.i18n_timeUpdateAt)\(localDate)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            }
            
            if let createAt = self.cdMemo?.createAt {
                //                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm:ss"
                let localDate = dateFormatter.string(from: createAt)
//                attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeCreateAt) \(localDate)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.gray]))
                attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeCreateAt)\(localDate)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.gray]))

            }
            
            if let reminderAt = self.cdMemo?.reminderTime, let isReminderEnabled =  self.cdMemo?.isReminderEnabled, let repeatOptionStr =  self.cdMemo?.reminderRepeat  {
                //                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
                
                if isReminderEnabled {
                    let reminderString = ReminderService().getFormatedDateString(reminderAt, repeatOptionString: repeatOptionStr)
//                    attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeReminderAt) \(reminderString)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.gray]))
                    attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeReminderAt) \(reminderString)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.gray]))
                }
            }
            if let images = self.cdMemo?.images { //, let imageArray = Array(images) as? [CDMemo]  {
                let count = images.count
                attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_photoCount)\(count)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            }
            
            if let audios = self.cdMemo?.audios {
                let count = audios.count
                attributedText.append(NSAttributedString(string: "\t \(Appi18n.i18n_soundCount)\(count)", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            }
            
            
            return attributedText
        }
    }
    
    var descriptionAttributedText:NSAttributedString {
        get{
            let attributedText = NSMutableAttributedString()
            if let updateAt = self.cdMemo?.updateAt {
                //                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm:ss"
                let localDate = dateFormatter.string(from: updateAt)
                attributedText.append(NSAttributedString(string: "\(Appi18n.i18n_timeUpdateAt)\(localDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]))
            }
            
            if let createAt = self.cdMemo?.createAt {
                //                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm:ss"
                let localDate = dateFormatter.string(from: createAt)
                attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeCreateAt) \(localDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]))
            }
            
//            if let reminderAt = self.cdMemo?.reminderTime, let isReminderEnabled =  self.cdMemo?.isReminderEnabled, let repeatOptionStr =  self.cdMemo?.reminderRepeat  {
//                //                let localDate = DateFormatter.localizedString(from: updateAt, dateStyle: .full, timeStyle: .full)
//
//                if isReminderEnabled {
//                    let reminderString = ReminderService().getFormatedDateString(reminderAt, repeatOptionString: repeatOptionStr)
//                    attributedText.append(NSAttributedString(string: "\n\(Appi18n.i18n_timeReminderAt) \(reminderString)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black]))
//                }
//
//
//            }
            
            
            return attributedText
        }
    }
    
    
    
    var contentAttributedText:NSAttributedString {
        get {
            let fontName = self.displayStyle.fontName
            let fontSize = self.displayStyle.fontSize
            let  bodyFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: 16)
            
            let subjectFont = UIFont(name: fontName, size: CGFloat(fontSize + 2)) ?? UIFont.systemFont(ofSize: 18)
            
            let textColor = self.displayStyle.textColor ?? UIColor.black
            //            Util.printLog("fontName:\(fontName)")
            //            Util.printLog("fontSize:\(fontSize)")
            //            Util.printLog("textColor:\(textColor?.toHex)")
            
            
            //            let attributedText = NSMutableAttributedString(string:self.subject, attributes: [NSAttributedStringKey.font: subjectFont,NSAttributedStringKey.foregroundColor:textColor])
            let attributedText = NSMutableAttributedString()
            
            //            if let updateAt = self.updateAt {
            //                attributedText.append(NSAttributedString(string: "\(updateAt)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            //            }
            
            attributedText.append(NSAttributedString(string:"\(self.subject)", attributes: [NSAttributedString.Key.font: subjectFont,NSAttributedString.Key.foregroundColor:textColor]))
            
            //            let usernameString = "  \(tweet.user.username)\n"
            //            let attributedText = NSAttributedString(string: memo.subject, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            //            let paragraphStyle = NSMutableParagraphStyle()
            //            paragraphStyle.lineSpacing = 20
            //            let range = NSMakeRange(0, attributedText.string.characters.count)
            //            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
            
            var body =  Appi18n.i18n_noContent //NSLocalizedString("No content", comment: "Write something")
            if !self.body.isEmpty {
                body = self.body
                attributedText.append(NSAttributedString(string: "\n\(body)", attributes: [NSAttributedString.Key.font: bodyFont,NSAttributedString.Key.foregroundColor:textColor]))
            }else{
                attributedText.append(NSAttributedString(string: "\n\(body)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor.gray]))
            }
            return attributedText
        }
    }
    
    var briefContentAttributedText:NSAttributedString {
        get {
            let fontName = self.displayStyle.fontName
            let fontSize = self.displayStyle.fontSize
            let  bodyFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: 16)
            
            let subjectFont = UIFont(name: fontName, size: CGFloat(fontSize + 2)) ?? UIFont.systemFont(ofSize: 18)
            
            let textColor = self.displayStyle.textColor ?? UIColor.black
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string:"\(self.subject)", attributes: [NSAttributedString.Key.font: subjectFont,NSAttributedString.Key.foregroundColor:textColor]))
            //            let paragraphStyle = NSMutableParagraphStyle()
            //            paragraphStyle.lineSpacing = 20
            //            let range = NSMakeRange(0, attributedText.string.characters.count)
            //            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: range)
            
            var body =  Appi18n.i18n_noContent //NSLocalizedString("No content", comment: "Write something")
            if !self.body.isEmpty {
                if self.body.count > 50 {
                    body = "\(self.body.mySubstring(fromIndex: 0, toIndex: 50))..."
                }else{
                    body = self.body
                }
                attributedText.append(NSAttributedString(string: "\n\(body)", attributes: [NSAttributedString.Key.font: bodyFont,NSAttributedString.Key.foregroundColor:textColor]))
            }else{
                attributedText.append(NSAttributedString(string: "\n\(body)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor.gray]))
            }
            return attributedText
        }
    }
    
    var position: Position
    
//    var position: Position {
//        didSet{
//            if let pos = cdMemo?.position  {
//                pos.x = Float(position.x)
//                pos.y = Float(position.y)
//                pos.width = Float(position.width)
//                pos.height = Float(position.height)
//            }
//        }
//    }
    var backgroundImage: BackgroundImage
//    var backgroundImage: BackgroundImage {
//        didSet {
//            if let backImg = cdMemo?.backgroundImage {
//                backImg.name = backgroundImage.name
//                backImg.edgeLeft = Float(backgroundImage.edgeLeft)
//                backImg.edgeTop = Float(backgroundImage.edgeTop)
//                backImg.edgeRight = Float(backgroundImage.edgeRight)
//                backImg.edgeBottom = Float(backgroundImage.edgeBottom)
//                backImg.tintColorHex = backgroundImage.tintColorHex
//            }
//        }
//    }
    var displayStyle: DisplayStyle
//    var displayStyle: DisplayStyle {
//        didSet {
//            if let style = cdMemo?.displayStyle {
//                style.fontName = displayStyle.fontName
//                style.fontSize = Float(displayStyle.fontSize)
//                style.colorHex = displayStyle.textColorHex
//            }
//        }
//    }
//
    var cdMemo: CDMemo?
    /*? {
        didSet {
            guard let cdmemo = cdMemo else {
                return
            }
            if let s = cdmemo.subject {
                self.subject = s
            }
            if let s = cdmemo.body {
                self.body = s
            }
            
            self.position.cdPosistion = cdmemo.position
            
        }
    }*/
//    init(_ subject:String, body:String, position: Position, backgroundImage:BackgroundImage,displayStyle: DisplayStyle ) {
//        self.subject = subject
//        self.body = body
//        self.position = position
//        self.backgroundImage = backgroundImage
//        self.displayStyle = displayStyle
//    }
    
    init(_ cdMemo: CDMemo) {
        if let s = cdMemo.desktop?.name {
            self.desktopName = s
        }
        if let s = cdMemo.subject {
            self.subject = s
        } 
        if let s = cdMemo.body {
            self.body = s
        }
        
        if let pos = cdMemo.position {
            let x = pos.x
            let y = pos.y
            let width = pos.width
            let height = pos.height
            let position = Position(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height), rotate: 0)
            self.position = position
        } else {
            self.position = Position(x: 10, y: 10, width: 200, height: 200, rotate: 0)
        }
        if let style = cdMemo.displayStyle, let fontName = style.fontName, let colorHex = style.colorHex {
            
            let display = DisplayStyle(fontName: fontName, fontSize: CGFloat(style.fontSize), textColorHex: colorHex )
            self.displayStyle = display
        } else {
            self.displayStyle = DisplayStyle(fontName: DefaultService.defaultFontName, fontSize: DefaultService.defaultFontSize, textColorHex: DefaultService.defaultTextColorHex)
        }
        
        if let cdImage = cdMemo.backgroundImage, let name = cdImage.name, let colorHex = cdImage.tintColorHex {
            self.backgroundImage = BackgroundImage(name: name, tintColorHex: colorHex, edgeTop: CGFloat(cdImage.edgeTop), edgeLeft: CGFloat(cdImage.edgeLeft), edgeBottom: CGFloat(cdImage.edgeBottom), edgeRight: CGFloat(cdImage.edgeRight),imageData: cdImage.imageData)

        }else{
            let imgName = AppDefault.defaultBackgoundImageName
            let colorHex = AppDefault.defaultBackgoundImageColorHex
            self.backgroundImage = BackgroundImage(name: imgName, tintColorHex:colorHex,  edgeTop: 0, edgeLeft: 0, edgeBottom: 0, edgeRight: 0, imageData: UIImage(named:imgName)!.pngData())
        }
        
        self.isFavorited = cdMemo.isFavorited
        self.cdMemo = cdMemo
    }
    
    
}



