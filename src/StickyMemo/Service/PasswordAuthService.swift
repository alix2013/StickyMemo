//
//  PasswordAuthService.swift
//  StickyMemo
//
//  Created by alex on 2018/1/31.
//  Copyright © 2018年 alix. All rights reserved.
//


import UIKit

class PasswordAuthService:PasswordViewDelegate { //,PasswordViewAuthCompleteDelegate {
    
//    var currentPassword:String {
//        didSet{
//            print("password changed to :\(currentPassword)")
//        }
//    }
    
    func setPassword(_ password: String) {
//        currentPassword = password
        DefaultService.saveAccessPassword(password)
    }
    
    static let shared = PasswordAuthService()
    
    static let passwordView:PasswordView = {
        var passwordView = PasswordView(.authPassword,isFingerprintEnabled:DefaultService.isTouchIDEnabled())
        passwordView.delegate = shared
        return passwordView
    }()
    
    
    static let setPasswordView:PasswordView = {
        var passwordView = PasswordView(.setPassword)
        passwordView.delegate = shared
        return passwordView
    }()
    
    static func showPassword(){
        if DefaultService.isPasswordEnabled() {
            let touchIDEnabled = DefaultService.isTouchIDEnabled()
            passwordView.show(touchIDEnabled)
        }
    }
    
    static func showSetPassword(){
        setPasswordView.show(false)
    }
    
    func authPassword(_ password: String) -> Bool {
        print("password is:\(password)")
        if (password == DefaultService.getAccessPassword() ) {
            return true
        } else {
            return false
        }
    }
    
    
}


