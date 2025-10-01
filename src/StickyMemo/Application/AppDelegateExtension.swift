//
//  AppDelegateExtension.swift
//  StickyMemo
//
//  Created by alex on 2018/2/2.
//  Copyright © 2018年 alix. All rights reserved.
//

import UserNotifications

extension AppDelegate:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Util.printLog("=====didReceive called: action id:\(response.actionIdentifier)")
        Util.printLog("request identifier:\(response.notification.request.identifier)")
        
        switch response.actionIdentifier {
            
        case MemoNotificationConstant.markAsCompleteActionID:
            let id = response.notification.request.identifier//response.notification.request.content.userInfo["id"] as? String{
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            //todo turnoff alert in db
            if let cdMemo = MemoService().queryCDMemoByID(id) {
                ReminderService().updateReminderTurnoff(cdMemo)
            }
            
        case UNNotificationDefaultActionIdentifier,MemoNotificationConstant.viewActionID:
            Util.printLog("==========UNNotificationDefaultActionIdentifier or viewActionID called")
            
            let id = response.notification.request.identifier
            if let cdMemo = MemoService().queryCDMemoByID(id) {
                Util.printLog("userNotificationCenter get cdMemo desktop name:\(String(describing: cdMemo.desktop?.name))")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myNotificationViewMemo"), object: nil,userInfo: ["CDMemo":cdMemo])
                
            }

        case  MemoNotificationConstant.reminder10MinuteActionID,MemoNotificationConstant.reminder30MinuteActionID,MemoNotificationConstant.reminder1hourActionID:
            
            var multipler:Double = 10
            if response.actionIdentifier == MemoNotificationConstant.reminder30MinuteActionID {
                multipler = 30
            }
            
            if response.actionIdentifier == MemoNotificationConstant.reminder1hourActionID {
                multipler = 60
            }
            
            let id = response.notification.request.identifier
//            let rescheduleId = id   //to avoid change original notification freqency
            let title = response.notification.request.content.title
            let body = response.notification.request.content.body
            
            let date = Date(timeInterval: (multipler * 60), since: Date())
            //get original repeat options
            if let repeatOption = response.notification.request.content.userInfo["repeatOption"] as? String, let repeatReminder = ReminderRepeatOption(rawValue: repeatOption){
                Util.printLog("======repeatOption string:\(repeatOption)")
                NotificationHelper.scheduleNotification(id: id, title: title, body: body, at: date, repeatBy:repeatReminder ,userInfo:["id":id,"repeatOption":repeatOption])
                
            }else{
                
                Util.printLog("======need attention:response.notification.request.content.userInfo repeatOption]  is nil")
                Util.saveAccessLog("userNotificationCenter*error",memo:"Error:response.notification.request.content.userInfo repeatOption]  is nil \(#function)-\(#line)")
            }
        
        default:
            break
        }
        
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Util.printLog("======willPresent called")
        Util.printLog("content:\(notification.request.content)")
        //        processUserInfo(response)
        
        //        if notification.action
        //            .actionIdentifier == MemoNotificationConstant.markCompleteActionID {
        //            if let id = notification.request.content.userInfo["id"] as? String{
        //                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        //                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        //            }
        //
        //        }
        
        completionHandler([.alert,.badge,.sound])
    }
    
//    func processUserInfo(_ response: UNNotificationResponse) {
//
//        if let id = response.notification.request.content.userInfo["id"] {
//            Util.printLog("memoID:\(id)")
//        }
//
//
//    }

}


