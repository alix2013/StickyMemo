//
//  NetworkManager.swift
//  StickyMemo
//
//  Created by alex on 2018/1/4.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation

//example:
//let urlString = "https://168.1.141.95:32199/api/v1/user/login"
//let body = ["username":"test","password":"vpn123456"] as [String : Any]
//NetworkManager().post(urlString, body: body,bodyType: .form) { (result) in
//    if result.isSuccess,let data = result.data, let statusCode = result.response?.statusCode, (statusCode >= 200 && statusCode <= 299 ) {
//        print(String(data: data, encoding: .utf8) ?? "no response")
//        //do json decode if data is json...
//    }else{
//        if let error = result.error {
//            print(error)
//        }
//    }
//}

struct HTTPResult{
    var isSuccess:Bool = true
    //    var statusCode:Int?
    //    var errorMessage:String?
    var error:Error?
    var data:Data?
    var response: HTTPURLResponse?
    init(_ isSuccess:Bool,data:Data? = nil,response:HTTPURLResponse? = nil,error:Error? = nil) {
        self.isSuccess = isSuccess
        //        self.statusCode = statusCode
        //        self.errorMessage = errorMessage
        self.error =  error
        self.data = data
        self.response = response
    }
    
    var responseJSON: Any? {
        guard let data = data else { return nil}
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json
        }catch {
            return nil
        }
    }
    
    var responseString: String? {
        guard let data = data else { return nil }
        if let string = String(data: data, encoding: .utf8) {
            return string
        }else{
            return nil
        }
    }
    var isHttpSuccess:Bool {
        guard let httpResponse = response else { return false }
        if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
            return true
        }
        return false
    }
    
}

enum BodyType{
    case json
    case form
}

class NetworkManager: NSObject,URLSessionDelegate {
    
    //to avoid self cert error
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!) )
    }
    
    //session config
    var sessionConfig:URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        // Some headers that are common to all reqeuests.
        // Eg my backend needs to be explicitly asked for JSON.
        config.httpAdditionalHeaders = ["ResponseType": "JSON"]
        // Eg we want to use pipelining.
        //        config.httpShouldUsePipelining = true
        return config
    }()
    
    override init(){
        super.init()
    }
    
    func get(_ urlString:String, completion:@escaping( HTTPResult ) -> Void ){
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -80000, userInfo: [NSLocalizedDescriptionKey : "invalidurl"]) as Error
            completion(HTTPResult(false,error : error))
            //            print("Error: cannot create URL")
            return
        }
        let request = URLRequest(url: url)
        sessionDataTask(request: request, completion: completion)
    }
    
    //
    //    func post(_ urlString:String, body:[String:Any] ,completion:@escaping( HTTPResult ) -> Void ){
    //        guard let url = URL(string: urlString) else {
    //            print("Error: cannot create URL")
    //            return
    //        }
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //        // Make sure that we include headers specifying that our request's HTTP body
    //        // will be JSON encoded
    //        var headers = request.allHTTPHeaderFields ?? [:]
    //        headers["Content-Type"] = "application/json"
    //        request.allHTTPHeaderFields = headers
    //
    //        //how to use JSONEncoder encode [String:Any]???
    //        //        let encoder = JSONEncoder()
    //        //        do {
    //        //            let jsonData = try encoder.encode(body)
    //        //            // ... and set our request's HTTP body
    //        //            request.httpBody = jsonData
    //        ////            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
    //        //        } catch {
    //        //            completion(HTTPResult(false,error:error))
    //        //        }
    //
    //        do {
    //            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
    //            request.httpBody = jsonData
    //        } catch {
    //            completion(HTTPResult(false,error:error))
    //        }
    //
    //
    //        sessionDatatask(request: request, completion: completion)
    //    }
    //
    
    func post(_ urlString:String,body:[String:Any],bodyType: BodyType = .json, header:[String:String]? = nil,completion:@escaping( HTTPResult ) -> Void ){
        guard let url = URL(string: urlString) else {
            //            print("Error: cannot create URL")
            let error = NSError(domain: "InvalidURL", code: -80000, userInfo: [NSLocalizedDescriptionKey : "invalidurl"]) as Error
            completion(HTTPResult(false,error : error))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        
        if let header = header {
            for ( k , v) in header {
                headers[k] = v
            }
        }
        
        if bodyType == .json {
            headers["Content-Type"] = "application/json"
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = jsonData
            } catch {
                completion(HTTPResult(false,error:error))
            }
        } else {
            headers["Content-Type"] = "application/x-www-form-urlencoded"
            var postBody = ""
            for (k, v) in body {
                postBody += "\(k)=\(v)&"
            }
//            for (k, v) in body {
//                if let vString = v as? String {
//                    let escapedKey = k.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//                    let escapedValue = vString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//                    postBody += "\(String(describing: escapedKey))=\(String(describing: escapedValue))&"
//                } else {
//                    postBody += "\(k)=\(v)&"
//                }
//            }
            Util.printLog("=====Debug application/x-www-form-urlencoded form post body==>\(postBody)")
            request.httpBody = postBody.data(using: .utf8)
        }
//        request.setValue(<#T##value: String?##String?#>, forHTTPHeaderField: <#T##String#>)
//        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = headers
        
        //how to use JSONEncoder encode [String:Any] for multiple layer json format???
        //        let encoder = JSONEncoder()
        //        do {
        //            let jsonData = try encoder.encode(body)
        //            // ... and set our request's HTTP body
        //            request.httpBody = jsonData
        ////            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        //        } catch {
        //            completion(HTTPResult(false,error:error))
        //        }
        
        sessionDataTask(request: request, completion: completion)
    }
    
    func delete(_ urlString:String, header:[String:String]? = nil,completion:@escaping( HTTPResult ) -> Void ){
        guard let url = URL(string: urlString) else {
            //            print("Error: cannot create URL")
            let error = NSError(domain: "InvalidURL", code: -80000, userInfo: [NSLocalizedDescriptionKey : "invalidurl"]) as Error
            completion(HTTPResult(false,error : error))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        sessionDataTask(request: request, completion: completion)
    }
    
    
    func sessionDataTask(request: URLRequest, completion:@escaping( HTTPResult ) -> Void ) {
        let startTime = Date()
        if let urlString = request.url?.absoluteString {
            Util.printLog("=====>\(startTime) Begin request:\(urlString)")
            Util.printLog("=====Debug request headers:\(String(describing: request.allHTTPHeaderFields)) ")
        }
        //        let session = URLSession(configuration: URLSessionConfiguration.default)
        //        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let session = URLSession(configuration: self.sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let error =  error {
                let result = HTTPResult(false, error: error)
                completion(result)
            }else{
                if let response = response as? HTTPURLResponse {
                    let result = HTTPResult(true,data: data, response:response )
                    completion(result)
                }else {
                    let error = NSError(domain: "HTTPURLResponseNUL", code: -80001, userInfo: [NSLocalizedDescriptionKey : "HTTPURLResponse is nil"]) as Error
                    completion(HTTPResult(false,error : error))
                }
            }
            //for debug
            let duration = Date().timeIntervalSince(startTime)
            if let urlString = request.url?.absoluteString {
                Util.printLog("<=====\(Date()) DurationSecs:\(duration) End request:\(urlString)")
            }
            }.resume()
    }
    
    // this is a basic http get for URLSession, just for test
    func get(_ urlString:String, completion:@escaping( Data?,URLResponse?, Error?) -> Void ){
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -80000, userInfo: [NSLocalizedDescriptionKey : "invalidurl"]) as Error
            completion(nil,nil,error)
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            //            DispatchQueue.main.async {
            completion(data, response, error)
            //            }
            }.resume()
    }
    
    //    func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping ( _ success: Bool, _ object: AnyObject?) -> () ) {
    //        request.httpMethod = method
    //
    //        let session = URLSession(configuration: URLSessionConfiguration.default)
    //
    //        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
    //            if let data = data {
    //                let json = try? JSONSerialization.jsonObject(with: data, options: [])
    //                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
    //                    completion(true, json as AnyObject)
    //                } else {
    //                    completion(false, json as AnyObject)
    //                }
    //            }
    //            }.resume()
    //    }
    
}

