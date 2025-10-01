//
//  AudioUtil.swift
//  StickyMemo
//
//  Created by alex on 2017/12/29.
//  Copyright © 2017年 alix. All rights reserved.
//

import AVFoundation

enum SoundType {
    case ding
    case soso
    case dao
    case ruai
    case mi
    case fa
    case sao
    case la
    case xi
    case highDao
}

class ButtonSound {
// fix crash for swift 5.1 (2020/09)
//    var audioPlayer = AVAudioPlayer()
    var audioPlayer: AVAudioPlayer!
    init(type: SoundType) {
        switch type {
        case .ding:
            if let filePath = Bundle.main.path(forResource: "buttonsound1", ofType: "wav") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                    Util.saveAccessLog("ButtonSoundload*error",memo:"Error:\(error) \(#function)-\(#line)")
                }
            }
           
        case .soso:
            if let filePath = Bundle.main.path(forResource: "buttonsound2", ofType: "wav") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .dao:
            if let filePath = Bundle.main.path(forResource: "dao", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .ruai:
            if let filePath = Bundle.main.path(forResource: "ruai", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .mi:
            if let filePath = Bundle.main.path(forResource: "mi", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .fa:
            if let filePath = Bundle.main.path(forResource: "fa", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .sao:
            if let filePath = Bundle.main.path(forResource: "sao", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .la:
                if let filePath = Bundle.main.path(forResource: "la", ofType: "mp3") {
                    do {
                        let soundURL = URL(fileURLWithPath: filePath)
                        try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                    }catch{
                        Util.printLog("load sound file error:")
                        Util.printLog(error)
                    }
            }
        case .xi:
            if let filePath = Bundle.main.path(forResource: "xi", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        case .highDao:
            if let filePath = Bundle.main.path(forResource: "dao2", ofType: "mp3") {
                do {
                    let soundURL = URL(fileURLWithPath: filePath)
                    try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
                }catch{
                    Util.printLog("load sound file error:")
                    Util.printLog(error)
                }
            }
        }
        audioPlayer.prepareToPlay()
    }
    
    
    func play() {
        if DefaultService.isSoundEnabled() {
            audioPlayer.play()
        }
    }
    
    func playAlways() {
        audioPlayer.play()
    }
    
}
