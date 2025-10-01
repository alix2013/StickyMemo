//
//  SpeechSettingVC.swift
//  StickyMemo
//
//  Created by alex on 2018/2/18.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

class SpeechSettingVC: UIViewController {
    
    var speechRecViewController:SpeechRecViewController?
    
    var totalDuration:Int64 = 0 {
        didSet {
            self.endTime = totalDuration
            self.labelEndTimeValue.text = self.formatedTimeString(TimeInterval(totalDuration))
        }
    }
    
    var pickerData:[Int] = [5,10,15,20,25,30,35,40,45,50,55]
    var startTime:Int64 = 0 {
        didSet{
            self.labelStartTimeValue.text = self.formatedTimeString(Double(startTime))
            let v = ( Double(startTime) / Double(totalDuration ))
            self.sliderStart.value = Float(v)
        }
    }
    var endTime:Int64 = 0 {
        didSet{
            self.labelEndTimeValue.text = self.formatedTimeString(Double(endTime))
            self.sliderEnd.value = Float( Double(endTime) / Double(totalDuration ))
        }
    }
    
    var segmentSeconds:Int = 10 {
        didSet{
            print("segmentSeconds didset:\(segmentSeconds)")
            for (index,v) in self.pickerData.enumerated() {
                if v == segmentSeconds {
                    self.segmentPicker.selectRow(index, inComponent: 0, animated: false)
                    break
                }
            }
        }
    }
    
    var labelSegmentTitle:UILabel = {
        let v = UILabel()
        v.text = Appi18n.i18n_audioSegmentDuration
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelStartTimeTitle:UILabel = {
        let v = UILabel()
        v.text = Appi18n.i18n_audioStartTime
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelStartTimeValue:UILabel = {
        let v = UILabel()
        v.text = "00:00"
        v.textAlignment = .right
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelEndTimeTitle:UILabel = {
        let v = UILabel()
        v.text = Appi18n.i18n_audioEndTime //"End Time"
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelEndTimeValue:UILabel = {
        let v = UILabel()
        v.text = "00:00"
        v.textAlignment = .right
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var sliderStart:UISlider = {
        let v = UISlider()
        v.value = 0
        v.addTarget(self, action: #selector(startSliderValueChanged), for: .valueChanged)
        v.addTarget(self, action: #selector(startSliderTouchUp), for: .touchUpInside)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.maximumTrackTintColor =  .red
        return v
    }()
    
    lazy var sliderEnd:UISlider = {
        let v = UISlider()
        v.value = 1
        v.addTarget(self, action: #selector(endSliderValueChanged), for: .valueChanged)
        v.addTarget(self, action: #selector(endSliderTouchUp), for: .touchUpInside)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.maximumTrackTintColor =  .red
        return v
    }()
    
    lazy var segmentPicker:UIPickerView = {
        let v = UIPickerView()
        v.delegate =  self
        v.dataSource = self
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        self.view.addSubview(self.labelStartTimeTitle)
        self.view.addSubview(self.labelStartTimeValue)
        self.view.addSubview(self.sliderStart)
        
        self.view.addSubview(self.labelEndTimeTitle)
        self.view.addSubview(self.labelEndTimeValue)
        self.view.addSubview(self.sliderEnd)
        
        let lineView1 = UIView()
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        lineView1.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.view.addSubview(lineView1)
        
        let lineView2 = UIView()
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        lineView2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.view.addSubview(lineView2)
        
        self.view.addSubview(self.labelSegmentTitle)
        self.view.addSubview(self.segmentPicker)
        
        
        let lineView3 = UIView()
        lineView3.translatesAutoresizingMaskIntoConstraints = false
        lineView3.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.view.addSubview(lineView3)
        
        
        [
        labelStartTimeTitle.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        labelStartTimeTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
        labelStartTimeTitle.heightAnchor.constraint(equalToConstant: 50),
        labelStartTimeTitle.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
        
        labelStartTimeValue.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10),
        labelStartTimeValue.bottomAnchor.constraint(equalTo: labelStartTimeTitle.bottomAnchor, constant: 0),
        labelStartTimeValue.heightAnchor.constraint(equalToConstant: 50),
        labelStartTimeValue.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
        
        sliderStart.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        sliderStart.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10),
        sliderStart.topAnchor.constraint(equalTo: labelStartTimeTitle.bottomAnchor, constant: 0),
        
        lineView1.topAnchor.constraint(equalTo: sliderStart.bottomAnchor, constant: 20),
        lineView1.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        lineView1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        lineView1.heightAnchor.constraint(equalToConstant: 1),
        
        
        labelEndTimeTitle.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        labelEndTimeTitle.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 10),
        labelEndTimeTitle.heightAnchor.constraint(equalToConstant: 50),
        labelEndTimeTitle.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
        
        labelEndTimeValue.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10),
        labelEndTimeValue.topAnchor.constraint(equalTo: labelEndTimeTitle.topAnchor, constant: 0),
        labelEndTimeValue.heightAnchor.constraint(equalToConstant: 50),
        labelEndTimeValue.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
        
        sliderEnd.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        sliderEnd.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10),
        sliderEnd.topAnchor.constraint(equalTo: labelEndTimeValue.bottomAnchor, constant: 0),
        
        lineView2.topAnchor.constraint(equalTo: sliderEnd.bottomAnchor, constant: 20),
        lineView2.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        lineView2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        lineView2.heightAnchor.constraint(equalToConstant: 1),
        
        labelSegmentTitle.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        labelSegmentTitle.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 15),

        segmentPicker.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        segmentPicker.topAnchor.constraint(equalTo: labelSegmentTitle.bottomAnchor, constant: 0),
        segmentPicker.heightAnchor.constraint(equalToConstant:100),
        
        lineView3.topAnchor.constraint(equalTo: segmentPicker.bottomAnchor, constant: 15),
        lineView3.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 15),
        lineView3.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        lineView3.heightAnchor.constraint(equalToConstant: 1),
   
            ].forEach { $0.isActive = true }
        
    }
    
    
    @objc func endSliderTouchUp(sender:UISlider) {
        var value = Double(self.totalDuration) * Double(sender.value)
        
        if Double(self.totalDuration) * Double(sender.value)  <=  Double(self.totalDuration) * Double(self.sliderStart.value ) + 5 {
            sender.value = 1
            value = Double(self.totalDuration)
//            self.labelEndTimeValue.text = self.formatedTimeString(self.totalDuration)
        }
        
        self.endTime = Int64(value)
        
//        if Double(sender.value) <=  Double(self.sliderStart.value) {
//            sender.value = 1
//            self.labelEndTimeValue.text = self.formatedTimeString(self.totalDuration)
//        }else {
//            self.labelEndTimeValue.text = self.formatedTimeString(value)
//        }
    }
    
    @objc func startSliderTouchUp(sender:UISlider) {
        var value = Double(self.totalDuration) * Double(sender.value)
        
        if Double(self.totalDuration) * Double(sender.value) + 5   >= Double(self.sliderEnd.value) * Double(self.totalDuration) {
            sender.value  = 0
            value = 0
        }
        self.startTime = Int64(value)
//        if Double(sender.value) >= Double(self.sliderEnd.value) {
//            sender.value  = 0
//            self.labelStartTimeValue.text = "00:00"
//        }else{
//            self.labelStartTimeValue.text = self.formatedTimeString(value)
//        }
    }
    
    
    
    @objc func startSliderValueChanged(sender:UISlider){
        if DefaultService.isvip() {
            let value = Double(self.totalDuration) * Double(sender.value)
            self.labelStartTimeValue.text = self.formatedTimeString(value)
        }else{
            UIUtil.goPurchaseVIP(self)
            sender.value = 0
        }
    }
    
    @objc func endSliderValueChanged(sender:UISlider){
        if DefaultService.isvip() {
        let value = Double(self.totalDuration) * Double(sender.value)
        self.labelEndTimeValue.text = self.formatedTimeString(value)
        }else{
            UIUtil.goPurchaseVIP(self)
            sender.value = 1
        }
    }
    
    func formatedTimeString(_ time:TimeInterval) -> String {
        if time >= 3600 {
            let hours = Int(time) / 3600
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }else{
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i",  minutes, seconds)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        Util.printLog("startTime:\(self.startTime)")
        Util.printLog("endTime:\(self.endTime)")
        Util.printLog("segmentSeconds:\(self.segmentSeconds)")
        if DefaultService.isvip() {
            speechRecViewController?.startTime =  self.startTime
            speechRecViewController?.endTime =  self.endTime
            speechRecViewController?.segmentSeconds =  self.segmentSeconds
        }
        
    }
}

extension SpeechSettingVC:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
//    func goVIP() {
//        if DefaultService.isvip() {
//        }else{
//            UIUtil.goPurchaseVIP(self)
//        }
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if DefaultService.isvip() {
            self.segmentSeconds = self.pickerData[row]
        }else{
            UIUtil.goPurchaseVIP(self)
        }
        
    }
    
}
