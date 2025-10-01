//
//  NotificationHelper.swift
//  StickyMemo
//
//  Created by alex on 2018/2/2.
//  Copyright © 2018年 alix. All rights reserved.
//


import UserNotifications
import UIKit
enum ReminderRepeatOption:String{
    case never = "N"
    case hourly = "H"
    case daily = "D"
    case weekly = "W"
    case monthly = "M"
}

struct MemoNotificationConstant{
    static let categoryID:String = "StickyMemo"
    static let viewActionID:String = "StickyMemo.view"
    static let reminder10MinuteActionID:String = "StickyMemo.reminder10minute"
    static let reminder30MinuteActionID:String = "StickyMemo.reminder30minute"
    static let reminder1hourActionID:String = "StickyMemo.reminder1hour"
    static let markAsCompleteActionID:String = "StickyMemo.markascomplete"
    static let cancelActionID:String = "StickyMemo.cancel"
}


class NotificationHelper{
    
    static func removePendingNotificationRequests(_ identifiers:[String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
    }
    
    static func requestNotificationAuthz(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                Util.printLog("Notification access denied!")
            }
        }
        
    }
    
    static func displayNotificationsDisabled(_ parentViewController:UIViewController) {
        let alertController = UIAlertController(
            title: Appi18n.i18n_notifyEnableTitle,
            message: Appi18n.i18n_notifyEnableSteps,
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(
            title: Appi18n.i18n_ok,
            style: UIAlertAction.Style.default,
            handler: nil))
        
        parentViewController.present(alertController, animated: true, completion: nil)
    }
    

    static func checkNotificationAuthz(_ parentViewController:UIViewController) {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                //
            }else{
                displayNotificationsDisabled(parentViewController)
            }
        }
        
    }
    
    static func setNotificationCataActions() -> String{
        
        let categoryIdentifer = MemoNotificationConstant.categoryID
        
        let viewAction = UNNotificationAction(identifier:
            MemoNotificationConstant.viewActionID, title: Appi18n.i18n_notifyViewAction, options: [.foreground])
        
        let markCompleteAction = UNNotificationAction(identifier: MemoNotificationConstant.markAsCompleteActionID, title:
            Appi18n.i18n_notifyMarkCompleteAction, options: [])
        
        let reminder10mAction = UNNotificationAction(identifier: MemoNotificationConstant.reminder10MinuteActionID, title:
            Appi18n.i18n_notifyReminder10Action, options: [])
        
        let reminder30mAction = UNNotificationAction(identifier: MemoNotificationConstant.reminder30MinuteActionID, title:
            Appi18n.i18n_notifyReminder30Action, options: [])
        
        let reminder1HourAction = UNNotificationAction(identifier: MemoNotificationConstant.reminder1hourActionID, title:
            Appi18n.i18n_notifyReminder1hourAction, options: [])
        
        let cancelAction = UNNotificationAction(identifier: MemoNotificationConstant.cancelActionID, title:Appi18n.i18n_notifyCancelAction
            , options: [])
        
        
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions:
            [viewAction,markCompleteAction,reminder10mAction,reminder30mAction,reminder1HourAction,cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return categoryIdentifer
    }
    
    
    static func scheduleNotification(id:String,title:String,subtitle:String="",body:String, at date: Date,repeatBy:ReminderRepeatOption, userInfo:[AnyHashable : Any]) {
        
        let cataId = setNotificationCataActions()
        
        //        let calendar = Calendar(identifier: .gregorian)
        //        let components = calendar.dateComponents(in: .current, from: date)
        //        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        //
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        var isRepeat:Bool = true
        
        switch repeatBy {
        case .never:
            isRepeat = false
            
        case .hourly:
            triggerDate = Calendar.current.dateComponents([.minute,.second], from: date)
//            triggerDate = Calendar.current.dateComponents([.second], from: date)
        case .daily:
            triggerDate = Calendar.current.dateComponents([.hour,.minute,.second], from: date)
            
        case .weekly:
            triggerDate = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)
            
        case .monthly:
            triggerDate = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: date)
            break
        }
        
        print("======trigger date:\(triggerDate)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: isRepeat)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = userInfo
        
        content.categoryIdentifier = cataId
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    
}

