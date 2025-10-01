//
//  CDAudioExtension.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/18.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation

extension CDAudio {
    
    func getObjectsForShare() -> [Any] {
        var shareObjects:[Any] = []
        //        let shareText = "\(self.getAudioFileName() ?? "audio")" + ".m4a"
        if let comment = self.comment {
            shareObjects.append(comment)
        }
        if let fileURL = self.getAudioFileURL() {
            shareObjects.append(fileURL)
        }
        
        return shareObjects
    }
    
    func deleteFile(){
        
        if let fileName = self.getAudioFileName() {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("m4a")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    Util.printLog("delete file:\(fileURL)")
                }catch{
                    Util.printLog("Failed to deleteFile, error:\(error)")
                    Util.saveAccessLog("DeleteFile*error",memo:"Error:\(error) \(#function)-\(#line)")
                }
            }
        }
//        guard let filePath = self.getAudioFileURL() else { return }
//
//        if FileManager.default.fileExists(atPath: filePath.path) {
//            do {
//                try FileManager.default.removeItem(at: filePath)
//            }catch{
//                print("Failed to deleteFile, error:\(error)")
//            }
//        }
    }
    
    func writeContentToFile() -> Bool {
        if let _ = getAudioFileURL() {
            return true
        } else {
            return false
        }
    }
    
    func getAudioFileURL() -> URL? {
        if let fileName = self.getAudioFileName() {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("m4a")
            
            guard let content = self.content else {
                return nil
            }
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                Util.printLog("File not exist:\(fileURL.path)")
                do{
                    try content.write(to: fileURL)
                    Util.printLog("success to write file")
                }catch{
                    Util.printLog("need attention, write file:\(fileURL.path) error:\(error)")
                }
            }
            
            return fileURL
        }
        return nil
    }
    
    func getAudioFileName() -> String?{
        guard let createAt = self.createAt else{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd-HHmmss" //"yyyy-MM-dd-HH_mm_ss"
        let displayName = dateFormatter.string(from: createAt)
        return "REC-\(displayName)"
    }
}


