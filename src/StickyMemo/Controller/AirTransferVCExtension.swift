//
//  AirTransferVCExtension.swift
//  StickyMemo
//
//  Created by alex on 2018/2/23.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

extension AirTransferVC:UIGestureRecognizerDelegate{
    

    //for UITextView may response customized gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap2gesture(_ :)))
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
        
        //longtap call tap2gesture
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(tap2gesture(_ :)))
        self.view.addGestureRecognizer(longTapGesture)
    }
    
    @objc func tap2gesture(_ sender:UITapGestureRecognizer) {
        Util.printLog("tap2gesture called")
        if self.isFullScreenTextViewShowing {
            Util.printLog("FullscreenView showing")
            return
        }
        self.isFullScreenTextViewShowing = true
        let loc = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: loc) else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
//        let memo = self.memoTableList[indexPath.section].memoList[indexPath.row]
        let memo = self.memoList[indexPath.row].memo
        animateCellAtDoubleTap(memo,cell:cell)
    }
    
    func animateCellAtDoubleTap(_ memo: Memo, cell:UITableViewCell) {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(fullScreenTextView)
            //            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":fullScreenTextView]))
            //            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":fullScreenTextView]))
            
            fullScreenTextView.attributedText = memo.contentAttributedText
            fullScreenTextView.backgroundColor = memo.backgroundImage.tintColor
            
            let fontSize = max( memo.displayStyle.fontSize, 40)
            let fontName = memo.displayStyle.fontName
            
            fullScreenTextView.font = UIFont(name: fontName, size: fontSize)
            
            fullScreenTextView.isSelectable = true
            
            //to avoid horizon scroll
            fullScreenTextView.contentSize = fullScreenTextView.bounds.size
            
            //            fullScreenTextView.contentInset =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            self.fullScreenTextView.frame = keyWindow.frame
            let startFrame = keyWindow.convert(cell.frame, from: cell.superview)
            fullScreenTextView.frame = startFrame
            self.fullScreenTextViewStartFrame = startFrame
            UIView.animate(withDuration: 0.75, animations: {
                self.fullScreenTextView.frame = keyWindow.frame
                //for vertical center textview
                self.fullScreenTextView.alignTextVerticallyInContainer()
            })
        }
    }
    
    //dismiss fullscreenTextView
    @objc func textViewTap2Guesture(_ sender:UITapGestureRecognizer) {
        print("textViewTap2Guesture called")
        //to dismiss black selected popup memu
        fullScreenTextView.isSelectable = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenTextView.frame = self.fullScreenTextViewStartFrame
        }, completion: { b in
            if b {
                self.fullScreenTextView.removeFromSuperview()
                self.isFullScreenTextViewShowing = false
            }
        })
    }
    
    
}
