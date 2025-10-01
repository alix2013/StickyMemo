//
//  ReminderService.swift
//  StickyMemo
//
//  Created by alex on 2018/2/2.
//  Copyright © 2018年 alix. All rights reserved.
//

import CoreData

class ReminderService {
    
    func saveReminder(_ cdMemo:CDMemo, isReminderEnabled:Bool,reminderTime:Date, reminderRepeat:String) {
        cdMemo.isReminderEnabled = isReminderEnabled
        cdMemo.reminderTime = reminderTime
        cdMemo.reminderRepeat = reminderRepeat
        DBManager.saveContext()
    }
    
    func updateReminderTurnoff(_ cdMemo:CDMemo) {
        cdMemo.isReminderEnabled = false
        DBManager.saveContext()
    }
    
    
    func queryReminderMemos() -> [Memo] {
        
        var memoList:[Memo] = []
        let fetchRequest:NSFetchRequest<CDMemo> = NSFetchRequest(entityName: "CDMemo")
        
        fetchRequest.sortDescriptors =  [ NSSortDescriptor(key: "updateAt", ascending: false) ]
        fetchRequest.predicate = NSPredicate(format: "deleteTag == false && isReminderEnabled == true")
        do {
            let cdMemoList = try DBManager.managedObjectContext.fetch(fetchRequest)
            for cdMemo in cdMemoList {
                let memo = Memo(cdMemo)
                memoList.append(memo)
            }
            
        }catch{
            Util.printLog("queryReminderMemos  error:\(error)")
            Util.saveAccessLog("queryReminderMemos*error",memo:"Error:\(error) \(#function)-\(#line)")
        }
        return memoList
        
    }
    
    
    func getFormatedDateString(_ date:Date, repeatOptionString:String) -> String {
        
        let dateFormatter = DateFormatter()
        guard  let repeatOption:ReminderRepeatOption = ReminderRepeatOption(rawValue:repeatOptionString)  else {
            
            dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm"
            let localDate = dateFormatter.string(from: date)
            return localDate
        }
        
        
        //todo i18n
        var retString:String = Appi18n.i18n_notifyRepeatString
        switch repeatOption {
        case .never:
            retString = "\(retString)\(Appi18n.i18n_notifyRepeatNever)"
            dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm"
            let localDate = dateFormatter.string(from: date)
            retString = "\(retString)  \(localDate)"
        case .hourly:
            retString = "\(retString)\(Appi18n.i18n_notifyRepeatHourly)"
            dateFormatter.dateFormat = "mm th"
            let localDate = dateFormatter.string(from: date)
            retString = "\(retString)  \(localDate)" //" \(Appi18n.i18n_notifyRepeatMinute)"
        case .daily:
            retString = "\(retString)\(Appi18n.i18n_notifyRepeatDaily)"
            dateFormatter.dateFormat = "HH:mm"
            let localDate = dateFormatter.string(from: date)
            retString = "\(retString)  \(localDate)"
            
        case .weekly:
            retString = "\(retString)\(Appi18n.i18n_notifyRepeatWeekly)"
            dateFormatter.dateFormat = "EEEE HH:mm"
            let localDate = dateFormatter.string(from: date)
            retString = "\(retString)  \(localDate)"
            
        case .monthly:
            retString = "\(retString)\(Appi18n.i18n_notifyRepeatMonthly)"
            dateFormatter.dateFormat = "dd HH:mm"
            let localDate = dateFormatter.string(from: date)
            
            retString = "\(retString)  \(localDate)"
            
        }
        
        
        //        return localDate
        return retString
    }
    
    
}
