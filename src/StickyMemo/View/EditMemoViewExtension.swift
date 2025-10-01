//
//  EditMemoViewExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
extension EditMemoView:  KeyboardButtonViewDelegate {
    
    func onKeyboardButtonSelected(_ keyboardButtonView: KeyboardButtonView, sender: UIButton, selectedIndex: Int) {
        if let memoView = self.memoView,let title = sender.titleLabel?.text { //, var body = memoView.body {
//            body = "\(body)\(title)"
//            memoView.body = body
            memoView.textView.insertText(title)
        }
    }
    
}

