//
//  SetNotificationViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/2/2.
//  Copyright © 2018年 alix. All rights reserved.
//


import UIKit
//import UserNotifications


class SetNotificationViewController:ViewController {
    var cdMemo:CDMemo? {
        didSet{
            if let time = self.cdMemo?.reminderTime, let isReminderEnabled = self.cdMemo?.isReminderEnabled, let repeatOptionString = self.cdMemo?.reminderRepeat {
                if isReminderEnabled {
                    self.switchTurnoff.isOn = true
                    self.datePick.date = time
                    self.labelText.text = ReminderService().getFormatedDateString(time,repeatOptionString:repeatOptionString)
                    
                    if let repeatEnum:ReminderRepeatOption = ReminderRepeatOption(rawValue: repeatOptionString) {
                        switch repeatEnum {
                        case .never:
                            self.segmentRepeat.selectedSegmentIndex = 0
                        case .hourly:
                            self.segmentRepeat.selectedSegmentIndex = 1
                        case .daily:
                            self.segmentRepeat.selectedSegmentIndex = 2
                        case .weekly:
                            self.segmentRepeat.selectedSegmentIndex = 3
                        case .monthly:
                            self.segmentRepeat.selectedSegmentIndex = 4
                        }
                    }
                    
                }else{
                    self.switchTurnoff.isOn = false
                    let date = Date()
                    self.datePick.date = date
//                    self.labelText.text = self.getFormatedDateString(date)
                }
            }
    
//            self.switchTurnoff.isOn = false
////            self.switchTurnoff.isEnabled = false
//
//            if let isRepeatEnabled = self.cdMemo?.isReminderEnabled {
//                if isRepeatEnabled {
////                    self.switchTurnoff.isHidden = false
//                    self.switchTurnoff.isOn = true
//                }
//            }
        }
    }
    
    var memoView:MemoView?

//    let segmentTitleList:[String] = ["None","Hourly","Daily","Weekly","Monthly"]
    let segmentTitleList:[String] = [Appi18n.i18n_notifyRepeatNever,Appi18n.i18n_notifyRepeatHourly,Appi18n.i18n_notifyRepeatDaily,Appi18n.i18n_notifyRepeatWeekly,Appi18n.i18n_notifyRepeatMonthly]
    
    let labelText:UILabel = {
        let v = UILabel(frame:CGRect(x: 0, y: 0, width: 300, height: 50))
        //        v.backgroundColor = .blue
        v.textColor =  AppDefault.themeColor //.blue
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var switchTurnoff:UISwitch = {
        let v = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        v.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)

        return v
    }()
    
    lazy var datePick:UIDatePicker = {
        let v = UIDatePicker()
        v.minuteInterval = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        
        v.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        return v
    }()
    
    lazy var segmentRepeat:UISegmentedControl = {
        let v = UISegmentedControl(items: segmentTitleList)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.selectedSegmentIndex = 0
        v.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
        setupNavBarItems()

        
        //set switchTurnoff view
        self.navigationItem.titleView =  self.switchTurnoff
        NotificationHelper.checkNotificationAuthz(self)
    }
    
    
    func setupNavBarItems(){
        let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionTap))
        
        let cancelAction = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelActionTap))
        
        self.navigationItem.rightBarButtonItems = [doneAction]
        self.navigationItem.leftBarButtonItems = [cancelAction]
        
    }
    
    @objc func switchValueChanged(sender:UISwitch){
        self.segmentRepeat.isEnabled = sender.isOn
        self.datePick.isEnabled = sender.isOn

    }
    
    @objc func cancelActionTap(){
        self.memoView?.restoreButtonLocation()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneActionTap(){
        Util.printLog(self.datePick.date)
        
        let date = self.datePick.date
        
        let repeatReminder = self.getRepeatOptionFromSegment()
        if let cdMemo = self.cdMemo,let id = self.cdMemo?.id, let title = self.cdMemo?.subject, let body = self.cdMemo?.body {
//            NotificationHelper.scheduleNotification(id: id, title: title, body: body, at: date, repeatBy: repeatReminder,userInfo:["id":id,"repeatOption":repeatReminder.rawValue])

            Util.printLog("=========success set notification Scheduled id:\(id)")
            if self.switchTurnoff.isOn {
                NotificationHelper.scheduleNotification(id: id, title: title, body: body, at: date, repeatBy: repeatReminder,userInfo:["id":id,"repeatOption":repeatReminder.rawValue])

                ReminderService().saveReminder(cdMemo, isReminderEnabled: true, reminderTime: date, reminderRepeat: repeatReminder.rawValue)
            }else{
                ReminderService().saveReminder(cdMemo, isReminderEnabled: false, reminderTime: date, reminderRepeat: repeatReminder.rawValue)
                NotificationHelper.removePendingNotificationRequests([id])
            }
        }
        
        self.memoView?.setReminderButtonImage()
        self.dismiss(animated: true, completion: {self.memoView?.restoreButtonLocation()})
        
    }
    
    private func getRepeatOptionFromSegment() -> ReminderRepeatOption {
        var repeatReminder:ReminderRepeatOption = .never
        
        switch self.segmentRepeat.selectedSegmentIndex{
        case 0:
            repeatReminder = .never
        case 1:
            repeatReminder = .hourly
        case 2:
            repeatReminder = .daily
        case 3:
            repeatReminder = .weekly
        case 4:
            repeatReminder = .monthly
        default:
            repeatReminder = .never
            break
        }
        return repeatReminder
    }
    @objc func segmentValueChanged(_ sender:UISegmentedControl){
        self.switchTurnoff.isOn = true
        let time = self.datePick.date
        self.labelText.text = ReminderService().getFormatedDateString(time,repeatOptionString:self.getRepeatOptionFromSegment().rawValue)
    }
    
    @objc func datePickerChanged(_ sender:UIDatePicker){
        //        let format = DateFormatter()
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm"
//        let localDate = dateFormatter.string(from: sender.date)
//
//        self.labelText.text = localDate
        self.labelText.text = ReminderService().getFormatedDateString(sender.date,repeatOptionString: self.getRepeatOptionFromSegment().rawValue)
        self.switchTurnoff.isOn = true
        
    }
    
//    func getFormatedDateString(_ date:Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy HH:mm"
//        let localDate = dateFormatter.string(from: date)
//        return localDate
//    }
    
    
    func setupViews() {
        
        view.addSubview(self.labelText)
        //        view.addSubview(self.buttonStackView)
        view.addSubview(self.datePick)
        //        view.addSubview(self.fullStackView)
        
        view.addSubview(self.segmentRepeat)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[v0(50)]-[v1(50)]-[v2]|", options: [], metrics: nil, views: ["v0":labelText,"v1":segmentRepeat,"v2":self.datePick]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":labelText]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":segmentRepeat]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":datePick]))
        
        
        
    }
}

