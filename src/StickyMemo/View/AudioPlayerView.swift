//
//  AudioPlayerView.swift
//  myAudioRecord
//
//  Created by alex on 2018/2/10.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import AVFoundation

struct AudioFile {
    var url: URL
    var displayName:String
}


class AudioPlayerLaunch:NSObject{
    var audioFile: AudioFile
    init(audioFile: AudioFile) {
        self.audioFile = audioFile
    }
    
    lazy var backView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white:0, alpha: 0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.numberOfTapsRequired = 1
        v.gestureRecognizers = [tapGesture]
        return v
    }()
    
    var audioPlayerView: AudioPlayerView = {
        let v = AudioPlayerView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
//        let v = AudioPlayerView(frame:.zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    @objc func tapGestureHandler() {
        self.dismiss()
    }
    
    func dismiss() {
        
        do {//todo check
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            Util.printLog("failed to setCategory,\(error)")
        }
        
        self.audioPlayerView.stop()
        self.audioPlayerView.removeFromSuperview()
        self.backView.removeFromSuperview()
    }
    
    func show(locationY:CGFloat){
        
        do { //todo check
            try  AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Util.printLog("failed to setSession cat:\(error)")
        }
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(backView)
            backView.frame = keyWindow.frame
            backView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            keyWindow.addSubview((audioPlayerView))
            
            audioPlayerView.audioFile = self.audioFile
            
            //avoid bellow window
            let y = min(locationY, keyWindow.frame.height - 100 )
            
//            audioPlayerView.translatesAutoresizingMaskIntoConstraints = false
            [
            audioPlayerView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: y),
            audioPlayerView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 0),
            audioPlayerView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: 0),
            audioPlayerView.heightAnchor.constraint(equalToConstant: 100)
                ].forEach{ $0.isActive = true}
            
        }
    }
}

class AudioPlayerView:UIView{
    // = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
    
    var timer:Timer = Timer()
    var audioPlayer:AVAudioPlayer?
    
    deinit {
        Util.printLog("deinit called")
//        audioPlayer?.stop()
    }
    var isPlaying :Bool = false {
        didSet{
            if isPlaying {
//                self.buttonPlayPause.setImage(UIImage(named:"button_pause"), for: .normal)
                self.buttonPlayPause.setImage(UIImage(named:"button_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
                
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,   selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            }else{
//                self.buttonPlayPause.setImage(UIImage(named:"button_play"), for: .normal)
                self.buttonPlayPause.setImage(UIImage(named:"button_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.timer.invalidate()
            }
        }
    }
    
    var audioFile:AudioFile?{
        didSet{
            guard let audioFile = audioFile else {
                return
            }
            Util.printLog("Sound URL:\(audioFile.url)")
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf:audioFile.url)
            }catch{
                Util.printLog("AVAudioPlayer init failed, url:\(audioFile.url), error:\(error)")
            }
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
            
            if let duration = self.audioPlayer?.duration {
                self.labelDuration.text = self.formatedTimeString(duration)
            }
            
            labelName.text = audioFile.displayName
            //auto adjust labelName height
//            if audioFile.displayName == "" {
//                for constraint in labelName.constraints {
//                    if constraint.firstAttribute == .height {
//                        constraint.constant = 0
//                    }
//                }
//            }
        }
    }
    
    
    lazy var labelName:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.text = "name"
        v.textColor = .white
        v.backgroundColor = self.backgroundColor
        return v
    }()
    
    lazy var labelCurrentTime:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "00:00"
        v.textColor = .white
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.adjustsFontSizeToFitWidth = true
        v.backgroundColor = self.backgroundColor
        return v
    }()
    
    lazy var labelDuration:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.adjustsFontSizeToFitWidth = true
        v.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
        v.backgroundColor = self.backgroundColor
//        v.text = "11:10:00"
        v.textColor = .white
        return v
    }()
    
    lazy var buttonPlayPause:UIButton = {
        let v = UIButton()
        //        v.setTitle("play", for: .normal)
//        v.setImage(UIImage(named:"button_play"), for: .normal)
        v.setImage(UIImage(named:"button_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(playPauseTap), for: .touchUpInside)
        
        //        v.backgroundColor = .blue
        v.backgroundColor = self.backgroundColor
        return v
    }()
    
    lazy var slider:UISlider = {
        let v = UISlider()
        v.minimumValue = 0
        v.maximumValue = 1
        v.minimumTrackTintColor = .red
        v.maximumTrackTintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = self.backgroundColor
        v.thumbTintColor = .red
//        v.setThumbImage(UIImage(named:"audioslider_thumb"), for: UIControlState.normal)
        v.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        v.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        //        v.thumbImage(for: .normal)
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
//        self.backgroundColor = .gray
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func timerUpdate() {
//        Util.printLog("time update")
        if let currentTime = self.audioPlayer?.currentTime, let duration = self.audioPlayer?.duration {
            
            let formatedTime = self.formatedTimeString(currentTime)
            self.labelCurrentTime.text = formatedTime
            // update slider
            let percent = currentTime / duration
            self.slider.value = Float(percent)
            
            let leftTime = max(0,duration - currentTime)
            self.labelDuration.text = "-\(self.formatedTimeString(leftTime))"
        }
        
    }
    @objc func sliderValueChanged(sender: UISlider) {
//        Util.printLog(sender.value)

        self.pause()
        
        if let duration = self.audioPlayer?.duration {
            let currentTime = duration * Double(sender.value)
            let formatedTime = self.formatedTimeString(currentTime)
            self.labelCurrentTime.text = formatedTime
        }
//        self.isPlaying = false
//        self.audioPlayer?.stop()
    }
    
    @objc func sliderTouchUp(sender:UISlider) {
//        self.audioPlayer?.stop()
        if let duration = self.audioPlayer?.duration {
            self.audioPlayer?.currentTime = duration * Double(sender.value)    //.play(atTime: duration * Double(sender.value))
            self.play()
//            self.audioPlayer?.prepareToPlay()
//            self.audioPlayer?.play()
//            self.isPlaying = true
        }
    }
    func stop(){
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        self.isPlaying = false
        audioPlayer.stop()
        
        self.slider.value = 0
        self.labelCurrentTime.text = "00:00"
        
//        if let duration = self.audioPlayer?.duration {
//            self.labelDuration.text = self.formatedTimeString(duration)
//        }
    }
    
    func play(){
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        self.isPlaying = true
    }

    func pause(){
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        audioPlayer.pause()
        self.isPlaying = false
    }
    
    
    @objc func playPauseTap(){

        guard let audioPlayer = self.audioPlayer else {
            return
        }
        self.isPlaying = !self.isPlaying
        
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            
        }else{
            audioPlayer.play()
        }
    }
    
    func setupViews(){
        let backgroundView = UIView()
        self.addSubview(backgroundView)
        backgroundView.backgroundColor = self.backgroundColor
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
        backgroundView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        self.addSubview(self.labelName)
        self.addSubview(self.buttonPlayPause)
        self.addSubview(self.labelCurrentTime)
        self.addSubview(self.slider)
        self.addSubview(self.labelDuration)
        [
        labelName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
        labelName.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
        labelName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        labelName.heightAnchor.constraint(equalToConstant: 50),
        
        buttonPlayPause.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
        buttonPlayPause.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 0),
        buttonPlayPause.widthAnchor.constraint(equalToConstant: 50),
        buttonPlayPause.heightAnchor.constraint(equalToConstant: 50),
        
        
        labelCurrentTime.leadingAnchor.constraint(equalTo: buttonPlayPause.trailingAnchor, constant: 0),
        labelCurrentTime.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 0),
        labelCurrentTime.widthAnchor.constraint(equalToConstant: 50),
        labelCurrentTime.heightAnchor.constraint(equalToConstant: 50),
        
        
        labelDuration.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        labelDuration.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 0),
        labelDuration.widthAnchor.constraint(equalToConstant: 50),
        labelDuration.heightAnchor.constraint(equalToConstant: 50),
        
        slider.leadingAnchor.constraint(equalTo: labelCurrentTime.trailingAnchor, constant: 5),
        slider.trailingAnchor.constraint(equalTo: labelDuration.leadingAnchor, constant: -5),
//        slider.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 0),
            slider.bottomAnchor.constraint(equalTo:labelCurrentTime.bottomAnchor,constant: -10),
//        slider.heightAnchor.constraint(equalToConstant: 50),
        ].forEach{
            $0.isActive = true
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
}

extension AudioPlayerView:AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Util.printLog("audioPlayerDidFinishPlaying:\(flag)")
        self.isPlaying = false
        self.slider.value = 0
        self.labelCurrentTime.text = "00:00"
        
        if let duration = self.audioPlayer?.duration {
            self.labelDuration.text = self.formatedTimeString(duration)
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
