//
//  Util.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import Foundation

class Util {
    
    static func getVerionAndBuild() -> String {
        if let version  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            var versionBuild = "\(version)"
            if let build  = Bundle.main.infoDictionary?["CFBundleVersion"] {
                versionBuild = "\(version)b\(build)"
                return versionBuild
            }
        }
        return "1"
    }
    
    static func saveAccessLog(_ module:String, memo:String) {
        IBMCloudService().saveAccessLog(module, memo:memo) { result in
            if result.isSuccess {
                Util.printLog("Success to save log")
            }else{
                Util.printLog("failed to save log:\(String(describing: result.error))")
            }
        }
    }
    
    static func saveTransLog(_ productId:String, transId:String,memo:String) {
        IBMCloudService().saveTransLog(productId, transId: transId, memo:memo,completeHandler: { result in
            if result.isSuccess {
                Util.printLog("Success to save trans log")
            }else{
                Util.printLog("failed to save log:\(String(describing: result.error))")
            }
        })
    }
    
    static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        Util.printLog("directory:\(urls)")
        return urls[urls.count-1]
    }()
    
    class func printLog<T>(_ message: T,
                           file: String = #file,
                           method: String = #function,
                           line: Int = #line)
    {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)]:\(method): \(message)")
        #endif
    }
    
    class func printError<T>(_ message: T,
                           file: String = #file,
                           method: String = #function,
                           line: Int = #line)
    {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)]:\(method): \(message)")
        #else
            saveAccessLog("Error@\(method)", memo: "\((file as NSString).lastPathComponent)[\(line)]:\(method): \(message)")
        #endif
    }
}

