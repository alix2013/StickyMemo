//
//  BoardVCMemoViewDelegateExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/12/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
extension BoardViewController:MemoViewDelegate {
    
    func doubleTapActionMemoViewDelegate(_ memoView: MemoView) {
        self.lastDoubleTapTime = Date()
        editMemo(memoView)
    }
    
    //for tableView cell button call edit
    func editMemo(_ memo:Memo) {
        for mview in self.memoViewList {
            //            if mview.memo.cdMemo?.id == memo.cdMemo?.id {
            if mview.memo.cdMemo == memo.cdMemo {
                let memoView = mview
                self.view.bringSubviewToFront(memoView)
                if !memoView.isEditable {
                    //                    mainFloatButton.hide()
                    //                    self.isInEditing = true
                    self.mainFloatButton.hide()
                    showEditMemoView(memoView)
                }
                break
            }
        }
    }
    
    func editMemo(_ memoView:MemoView) {
        if !memoView.isEditable {
            mainFloatButton.hide()
            //            self.isInEditing = true

            showEditMemoView(memoView)
        }
    }
    
    func showEditMemoView(_ memoView: MemoView) {
        
        self.buttonSoundSoso.play()
        self.editMemoView = EditMemoView(frame:.zero)
        self.editMemoView.memoView = memoView
        self.view.addSubview(editMemoView)
        self.editMemoView.show()        
    }
    
    func longTapActionMemoViewDelegate(_ memoView: MemoView) {
        Util.printLog("longTapActionInMemoView called")
        
        let memo = memoView.memo
        let actionSheet = UIAlertController(title: Appi18n.i18n_choiceAction, message: nil, preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: Appi18n.i18n_edit, style: .default) { (_) in
            self.editMemo(memoView)
        }
        
        let moveAction = UIAlertAction(title: Appi18n.i18n_move, style: .default) { (_) in
            
            self.doMoveAction(memo)
        }
        
        let shareAction = UIAlertAction(title: Appi18n.i18n_share, style: .default) { (_) in
            self.doShareAction(memoView)
        }
        
        let mailAction = UIAlertAction(title: Appi18n.i18n_mail, style: .default) { (_) in
            self.doMailAction(memo)
        }
        
        let mailAllAction = UIAlertAction(title: Appi18n.i18n_mailDesktop, style: .default) { (_) in
            self.doMailAllAction(memo)
        }
        
        let deleteAction = UIAlertAction(title: Appi18n.i18n_delete, style: .destructive) { (_) in
            self.doDeleteMemoView(memoView)
        }
        
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            self.mainFloatButton.show()
        }
        actionSheet.addAction(editAction)
        actionSheet.addAction(mailAction)
        actionSheet.addAction(mailAllAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(moveAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        
        // adaptive iPad
        //        if let popoverPresentationController = actionSheet.popoverPresentationController {
        ////            if let cell = collectionView.cellForItem(at: indexPath)  {
        ////                popoverPresentationController.sourceView = cell
        ////                //                        popoverPresentationController.sourceRect = cell.bounds
        ////
        ////                // arrow point to cell center
        ////                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
        //                popoverPresentationController.permittedArrowDirections = .any
        //                popoverPresentationController.sourceRect = memoView.bounds
        ////                //popoverPresentationController.preferredContentSize
        ////                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        ////            }
        //            //            else {
        //            //                popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
        //            //            }
        //        }
        
        self.mainFloatButton.hide()
        // self.present(actionSheet, animated: true, completion: nil)
        
        //to avoid  multiple times present
        if presentedViewController == nil {
            self.present(actionSheet, animated: true, completion: nil)
        }
//        else{
//            self.dismissViewControllerAnimated(false) { () -> Void in
//            self.presentViewController(alertController, animated: true, completion: nil)
//            }
//        }
        //        self.slideMenuTable.show()
    }
    
    func closeAndSaveMemoViewDelegate(_ memoView: MemoView) {
        save(memoView)
        exitEditing()
    }
    
    func save(_ memoView: MemoView) {
        memoView.subject = memoView.textFieldView.text
        memoView.body =   memoView.textView.text
        memoView.save()
    }
    
    func exitEditing() {
        editMemoView.dismiss()
        //            self.isInEditing = false
        self.mainFloatButton.show()
    }
    
    func closeWithoutSaveMemoViewDelegate(_ memoView: MemoView) {
        if (memoView.memo.subject == memoView.textFieldView.text) && (memoView.memo.body ==   memoView.textView.text) {
            //no changes, exit directly
            exitEditing()
        } else {
            alertCloseWithoutSave(memoView)
        }
    }
    
    func alertCloseWithoutSave(_ memoView:MemoView) {
        
        let alert = UIAlertController(title: Appi18n.i18n_exitEditing, message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: Appi18n.i18n_saveExit, style: .default) { (_) in
            self.save(memoView)
            self.exitEditing()
        }
        let exitAction = UIAlertAction(title: Appi18n.i18n_exitWithoutSave, style: .default) { (_) in
            self.exitNotSave(memoView)
        }
        
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(exitAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func exitNotSave(_ memoView:MemoView) {
    
        //restore to original settings
        memoView.textView.text  = memoView.memo.body
        memoView.textFieldView.text = memoView.memo.subject
        
        //need test
//        memoView.textFieldView.textColor =  memoView.memo.displayStyle.textColor
//        memoView.textView.textColor = memoView.memo.displayStyle.textColor
//        let fontName = memoView.memo.displayStyle.fontName
//        let fontSize = memoView.memo.displayStyle.fontSize
//        if let font = UIFont(name: fontName, size: fontSize) {
//            memoView.textView.font = font
//        }
//        if let font = UIFont(name: fontName, size: fontSize + 2) {
//            memoView.textFieldView.font = font
//        }
        
        // restore orignal backgroundImage
        //        if let backgroundImage = memoView.backgroundImage {
        //            Util.printLog("=========backgroundImage. not nil===")
        //            Util.printLog("=========backgroundImage\(backgroundImage.name)=")
        //            memoView.memo.backgroundImage = backgroundImage
        ////            memoView.backgroundImageView.image = memoView.getUIImage(backgroundImage)
        //        }
        
        self.exitEditing()
    }
    
    
    func deleteActionMemoViewDelegate(_ memoView: MemoView)  {
        let alert = UIAlertController(title: Appi18n.i18n_deleteMemo, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            self.doDeleteMemoView(memoView)
        }
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            memoView.hideTrash()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func doDeleteMemoView(_ memoView:MemoView) {
        self.buttonSoundSoso.play()
        if self.isInEditing {
            self.editMemoView.dismiss()
            self.mainFloatButton.show()
        }
        memoView.hideTrash()
        //remove from memoviewList
        for (index, mview) in self.memoViewList.enumerated() {
            if mview == memoView {
                self.memoViewList.remove(at: index)
                break
            }
        }
        
        memoView.memo.fadeDelete()
        
        UIView.animate(withDuration: 0.5, animations: {
            //memoView.transform = CGAffineTransform(scaleX: 0, y: 0)
            memoView.alpha = 0
        }, completion: { (b) in
            memoView.removeFromSuperview()
            //                self.mainFloatButton.show()
        })
    }
    
    func positionChangedMemoViewDelegate(_ memoView: MemoView,x: CGFloat?, y:CGFloat?, width: CGFloat?,height:CGFloat?,rotate: CGFloat?) {
        //        print("\(String(describing: x)),\(String(describing: y)),width:\(String(describing: width)),height:\(String(describing: height)),rotate:\(String(describing: rotate))")
        if let x = x {
            memoView.memo.position.x = x
        }
        if let y = y {
            memoView.memo.position.y = y
        }
        if let width = width {
            memoView.memo.position.width = width
        }
        if let height = height {
            memoView.memo.position.height = height
        }
        if let rotate = rotate {
            memoView.memo.position.rotate = rotate
        }
        
        Util.printLog(memoView.memo.position)
        
        //        memoView.save()
        memoView.savePosition()
    }
    
}

