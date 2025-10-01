//
//  CloudantRestAPI.swift
//  StickyMemo
//
//  Created by alex on 2018/1/4.
//  Copyright © 2018年 alix. All rights reserved.
//


import Foundation

class CloudantRestAPI {
//    static let CLOUDANT_ACCESS_DBNAME:String = "smv33access"
    static let CLOUDANT_ACCESS_DBNAME:String = "smv34accesstest"
    
    static let CLOUDANT_ENTRY_URL : String = "https://ea3d600e-81cd-4207-8458-4394b43ce7b5-bluemix:649a2372eb17098e4271fc92c4a812167dd2aa961ef2e6b1dd98a6eac3dd4d2a@ea3d600e-81cd-4207-8458-4394b43ce7b5-bluemix.cloudant.com"
    
    //static let CLOUDANT_TRANSLOG_DBNAME:String = "smv33trans"
    static let CLOUDANT_TRANSLOG_DBNAME:String = "smv34transtest"
//    static let CLOUDANT_ERRORLOG_DBNAME:String = "smv10error"
    
    func saveAccessLog(_ body:Dictionary<String,AnyObject> ,completeHandler:@escaping (_ result: HTTPResult) -> Void )  {
        
        let reqestURL = "\(CloudantRestAPI.CLOUDANT_ENTRY_URL)/\(CloudantRestAPI.CLOUDANT_ACCESS_DBNAME)"
        saveToCloud(reqestURL, body: body, completeHandler: completeHandler)
    
        
////        let body = ["username":"test","password":"vpn123456"] as [String : Any]
//        NetworkManager().post(reqURL, body: body) { (result) in
//            if result.isSuccess,let statusCode = result.response?.statusCode, (statusCode >= 200 && statusCode <= 299 ) {
////                if let data = result.data {
////                    Util.printLog(String(data: data, encoding: .utf8) ?? "No response")
////                }
////                print(String(data: data, encoding: .utf8) ?? "no response")
//                //do json decode if data is json...
//            }else{
//                if let error = result.error {
//                    Util.printLog(error)
//                }
//            }
//            completeHandler(result)
//        }
    }
    
    func saveToCloud(_ requestURL:String,body:Dictionary<String,AnyObject> ,completeHandler:@escaping (_ result: HTTPResult) -> Void ){
        //        let body = ["username":"test","password":"vpn123456"] as [String : Any]
        NetworkManager().post(requestURL, body: body) { (result) in
            if result.isSuccess,let statusCode = result.response?.statusCode, (statusCode >= 200 && statusCode <= 299 ) {
                //                if let data = result.data {
                //                    Util.printLog(String(data: data, encoding: .utf8) ?? "No response")
                //                }
                //                print(String(data: data, encoding: .utf8) ?? "no response")
                //do json decode if data is json...
            }else{
                if let error = result.error {
                    Util.printLog(error)
                    completeHandler(HTTPResult(false,error : error))
                }else{
                    //process none network error, such as 404
                    let errCode = result.response?.statusCode ?? -5000
                    let error = NSError(domain: "http code error", code:errCode , userInfo: [NSLocalizedDescriptionKey : "HTTPStatusCodeError"]) as Error
                    completeHandler(HTTPResult(false,error : error))
                    
                }
                
            }
            completeHandler(result)
        }
        
    }

    func saveTransLog(_ body:Dictionary<String,AnyObject> ,completeHandler:@escaping (_ result: HTTPResult) -> Void ) {
        let reqestURL = "\(CloudantRestAPI.CLOUDANT_ENTRY_URL)/\(CloudantRestAPI.CLOUDANT_TRANSLOG_DBNAME)"
        saveToCloud(reqestURL, body: body, completeHandler: completeHandler)
    }
    
}

