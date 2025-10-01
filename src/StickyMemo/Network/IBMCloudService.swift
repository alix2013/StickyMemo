//
//  AccessLog.swift
//  StickyMemo
//
//  Created by alex on 2018/1/4.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation

class IBMCloudService {
    
    func saveAccessLog(_ moduleName:String, memo:String = "", completeHandler:@escaping (_ result: HTTPResult) -> Void ) {
        let device = Device()
        let timeZone =  NSTimeZone.local.abbreviation(for: Date()) ?? ""
        let dateID = Date()
        //let timeID = dateID.timeIntervalSince1970
        //let timeID =
        //let deviceName = device.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss" 
        let timeID = dateFormatter.string(from: dateID)
        
        let deviceName = (device.name).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        
        var uuidPrefix = ""
        if (device.uuid).count < 8 {
            uuidPrefix = device.uuid
        }else {
            let index = device.uuid.index((device.uuid).startIndex, offsetBy: 8)
            //uuidPrefix = device.uuid.substring(to: index)
            uuidPrefix = String(device.uuid[..<index])
        }
        
        let params = [
            "_id" : "\(timeID)-\(moduleName)-\(deviceName)-\(uuidPrefix)-\(Locale.current.identifier)",
            "accessTime" : "\( dateID )",
            "moduleName": "\(moduleName)",
            "uuid" : "\(device.uuid)",
            "name" : "\(device.name)",
            "model": "\(device.model)",
            "modelName" : "\(device.modelName)",
            "systemName" : "\(device.systemName)",
            "systemVersion" : "\(device.systemVersion)",
            "localeIdentifier" : "\(Locale.current.identifier)",
            "timeZone" : "\(timeZone)",
            "memo" : "\(memo)"
        ]
        CloudantRestAPI().saveAccessLog(params as Dictionary<String, AnyObject>, completeHandler: completeHandler)
    }
    
    
    func saveTransLog(_ productId:String, transId:String, memo:String = "", completeHandler:@escaping (_ result: HTTPResult) -> Void ) {
        let dateID = Date() //utc time
        // --get locale time string( non_UTC)
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyyMMddHHmmss"
        //localFormatter.timeZone =
        let timeID =  localFormatter.string(from: dateID)
        
        let device = Device()
        let name = device.name.map{ return String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "")
        
        let timeZone =  NSTimeZone.local.abbreviation(for: Date()) ?? ""
        let params = [
            "_id" : "\(timeID)-\(memo)-\(name)",
//            "username" : "\(userName)",
            "uuid" : "\(device.uuid)",
            "name" : "\(device.name)",
            "transtime" : "\( dateID )",
            "productid" : "\( productId )",
            "transid" : "\(transId)",
            "localeIdentifier" : "\(Locale.current.identifier)",
            "timeZone" : "\(timeZone)",
            "memo" : "\(memo)"
        ]
        
        CloudantRestAPI().saveTransLog(params as Dictionary<String, AnyObject>, completeHandler: completeHandler)

    }
    
    
}
