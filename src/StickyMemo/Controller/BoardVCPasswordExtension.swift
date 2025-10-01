//
//  BoardVCPasswordExtension.swift
//  StickyMemo
//
//  Created by alex on 2018/2/1.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

extension BoardViewController:PasswordViewDelegate,PasswordViewAuthCompleteDelegate {
    func authPassword(_ password: String) -> Bool {
        return PasswordAuthService.shared.authPassword(password)
    }
    
    func setPassword(_ password: String) {
        //
    }
    
    func onAuthComplete() {
//        <#code#>
        Util.printLog("onAuthComplete called")
        if DefaultService.isPasswordEnabled() {
            mainFloatButton.show()
        }
    }
    
    func showPasswordView() {
        let isFingerprintEnabled = DefaultService.isTouchIDEnabled()
        if DefaultService.isPasswordEnabled() {
            self.passwordView.show(isFingerprintEnabled)
        }
    }
    
}
