//
//  ButtonSoundService.swift
//  StickyMemo
//
//  Created by alex on 2018/1/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import Foundation

class ButtonSoundSerive{
    
    static let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    static let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
//    static let buttonSoundDao:ButtonSound = ButtonSound(type: .dao)
//    static let buttonSoundRuai:ButtonSound = ButtonSound(type: .ruai)
//    static let buttonSoundMi:ButtonSound = ButtonSound(type: .mi)
//    static let buttonSoundFa:ButtonSound = ButtonSound(type: .fa)
//    static let buttonSoundSao:ButtonSound = ButtonSound(type: .sao)
//    static let buttonSoundLa:ButtonSound = ButtonSound(type: .la)
//    static let buttonSoundXi:ButtonSound = ButtonSound(type: .xi)
    
    
    static let pianoSoundList:[ButtonSound] = [
        ButtonSound(type:.dao),
        ButtonSound(type:.ruai),
        ButtonSound(type:.mi),
        ButtonSound(type:.fa),
        ButtonSound(type:.sao),
        ButtonSound(type:.la),
        ButtonSound(type:.xi),
        ButtonSound(type:.highDao)
    ]
    
    static func playDing() {
        buttonSoundDing.play()
    }
    static func playSoso() {
        buttonSoundSoso.play()
    }
    static func playPiano(_ index: Int) {
        let newIndex = index % pianoSoundList.count
        pianoSoundList[newIndex].play()
        
    }
    static func playPianoFirst() {
        pianoSoundList[0].play()
    }
    static func playPianoLast() {
        pianoSoundList[pianoSoundList.count - 1].play()
    }
    
    static func playAlwaysRandomPiano(){
        let randomNum = Int(arc4random_uniform(UInt32(7)))
        pianoSoundList[randomNum].playAlways()
    }
}
