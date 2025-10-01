//
//  EditMemoView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

//protocol EditMemoViewDelegate {
//    func onEditCompleteOK(_ editMemoView:EditMemoView)
//    func onEditCompleteCancel(_ editMemoView:EditMemoView)
//
//}

class EditMemoView:UIView {
    
    var borderViewController:BoardViewController?
    
    let minWidthInEditing : CGFloat =  240
    let minHeightInEditing: CGFloat =  260
    var originalLocation:CGRect?
    

    var memoView: MemoView? {
        didSet {
            if let v = memoView {
                originalLocation = v.frame
            }
        }
    }
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
//    var styleView: StyleView = StyleView()
//    var styleView: StyleView = {
//      let v = StyleView(self.boardViewController)
//
//        return v
//    }()
//    
    //for edit short keyboard keys
//    var buttonTitleList = [
////        "●","■", "❖","◆","◇","✦","➤","✓","✗"
//    "☒","☑︎","✗","✓","☞","➤","◆","◼︎","✭" //☆✭⭐︎✯✓✕"●"
//    ]
    var buttonTitleList  = ShortcutkeyService.getShortcutKeyList()
    
    var keyboardButtonBottomConstraint:NSLayoutConstraint?
    lazy var keyboardButton:KeyboardButtonView = {
        let v = KeyboardButtonView(frame: .zero,bottomOffsetWhenKeyboardHide:48,buttonTitleList: buttonTitleList, buttonSpace: 6)
        v.backgroundColor = UIColor.gray
        v.delegate = self
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
        setupTapGuesture()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // for dismis keyboard tap
    func setupTapGuesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGuestureHandler) )
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
//        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(tap2GuestureHandler) )
//        tap2Gesture.numberOfTapsRequired = 2
//        self.addGestureRecognizer(tap2Gesture)

    }
    @objc func tapGuestureHandler() {
        //dismiss keyboard
        self.memoView?.endEditing(true)
    }
    
//    @objc func tap2GuestureHandler() {
////        Util.printLog("edit memo view tap2GuestureHandler")
////        self.memoView?.
//        self.memoView?.endEditing(true)
//        self.memoView?.saveAndClose()
//    }
    
    func setupViews() {
        self.backgroundColor = UIColor(white:0, alpha:0.8)
    }

    func show()  {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics:nil, views: ["v0":self]))
        self.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics:nil, views: ["v0":self]))
        self.superview?.layoutIfNeeded()
        
        //animate show memoView
//        if let memoView = self.memoView, let superViewWidth = self.superview?.frame.width, let superViewHeight = self.superview?.frame.height, let superViewCenter = self.superview?.center {
//
//        UIView.animate(withDuration: 0.5, delay: 0.1, options:  .curveEaseInOut, animations: {
//            self.superview?.bringSubview(toFront: memoView)
//            var width = min(memoView.frame.width * 1.5,(superViewWidth - 100) )
//            var height = min(memoView.frame.height * 1.5, (superViewHeight - 100) )
//            //to avoid to small, it should cover left tool buttons
//            width = max(width, self.minWidthInEditing)
//            height = max(height, self.minHeightInEditing)
//
//            memoView.frame = CGRect(x: 0, y: 0, width: width, height: height)
////            memoView.frame = CGRect(x: 50 , y: 55, width: width, height: height)
//            memoView.center = superViewCenter //self.superview?.center
//
//
//        }, completion:{ finished in
//            if finished {
//                self.memoView?.isEditable = true
//            }
//        })
//        }
        
        if let memoView = self.memoView, let superViewWidth = self.superview?.frame.width { //}, let superViewHeight = self.superview?.frame.height {
            
            //            self.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5, delay: 0.1, options:  .curveEaseInOut, animations: {
                self.superview?.bringSubviewToFront(memoView)
                
//                var width = min(memoView.frame.width * 1.5,(superViewWidth - 100) )
//                var height = min(memoView.frame.height * 1.5, (superViewHeight - 100) )
//                //to avoid to small, it should cover left tool buttons
//                width = max(width, self.minWidthInEditing)
//                height = max(height, self.minHeightInEditing)
                
                let width = min(CGFloat(500), superViewWidth * 0.7 )
//                var height = min(CGFloat(500), superViewHeight * 0.7 )
                var height = width
                if width != 500 {
                    height = width * 1.2
                }
                let x = ( superViewWidth - width ) / 2
                memoView.frame = CGRect(x: x , y: 80, width: width, height: height)
            }, completion:{ finished in
                if finished {
                    self.memoView?.isEditable = true
                    //                self.isUserInteractionEnabled = true
                }
            })
        }

        keyboardButton.show()

    }
    
    @objc func dismiss() {

        self.buttonSoundSoso.play()
        self.keyboardButton.dismiss()
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            if let lastMemoViewLocation = self.originalLocation, let lastMemoView = self.memoView {
                
                lastMemoView.frame = lastMemoViewLocation
                
                // if outside of view bounds due to changed portal or landscape
                if let parentView = lastMemoView.superview {
                    if !lastMemoViewLocation.intersects(parentView.frame) {
                        lastMemoView.center = parentView.center
                    }
                }
//                if let center = lastMemoView.superview?.center {
//                    lastMemoView.center = center
//                }
                lastMemoView.isEditable = false
            }
        },completion:{ b in
            self.isUserInteractionEnabled = true
            self.removeFromSuperview()
        })
        
    }
}

