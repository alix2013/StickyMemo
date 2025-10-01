//
//  JSONMemoService.swift
//  StickyMemo
//
//  Created by alex on 2018/2/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation

class JSONMemoService {
    
//    fileprivate func getAllJSONMemos() -> [JSONMemo] {
//        var jsonMemos = [JSONMemo]()
//        let memoList = MemoService().queryAllUndeletedMemos()
//
//        jsonMemos = (memoList.flatMap{
//            return JSONMemo($0.cdMemo!)
//        })
//        return jsonMemos
//    }
//
//
//    func getAllJSONMemosString() -> String {
//        let jsonMemoList = self.getAllJSONMemos()
//        let jsonData = try? JSONEncoder().encode(jsonMemoList)
//        return String(data: jsonData!, encoding: .utf8)!
//    }
//
    
    func getAllDesktopJSON() -> String? {
        if let cdDesktops = DesktopService().queryUndeletedDesktop() {
//            let jsonDesktops = cdDesktops.flatMap{
            let jsonDesktops = cdDesktops.compactMap{
                return JSONDesktop($0)
            }
            let jsonData = try? JSONEncoder().encode(jsonDesktops)
            return String(data: jsonData!, encoding: .utf8)
        }else{
            return nil
        }
    }

}
