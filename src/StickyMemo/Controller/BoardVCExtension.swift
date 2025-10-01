//
//  BoardVCExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import MessageUI

extension BoardViewController:FloatButtonDelegate,MFMailComposeViewControllerDelegate{ //SlideMenuTableDelegate {
   
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func doShareAction(_ memoView: MemoView) {
        let memo = memoView.memo
        let shareObjects = memo.getObjectsForShare()  //self.getShareObjects(memo)
        let activityViewController = UIActivityViewController(activityItems: shareObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = memoView // so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceRect = memoView.bounds
        activityViewController.popoverPresentationController?.permittedArrowDirections = []
        // exclude some activity types from the list (optional)
        //        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func doMailAction(_ memo:Memo) {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
//            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
            composer.setSubject("\(memo.subject)")
//            let body = "\(memo.body)"
//            Util.printLog("background color:\(memo.backgroundImage.tintColorHex)")
//            let stringBody = "<p style=\"background-color:#\(memo.backgroundImage.tintColorHex)\">\(body)</p>"
//            let htmlBody = stringBody.replacingOccurrences(of: "\n", with: "<br>")
            composer.setMessageBody(memo.htmlBody, isHTML: true)
//            composer.navigationBar.tintColor = memo.backgroundImage.tintColor
            present(composer, animated: true, completion: nil)
            
            //todo i18n
//            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
//            let body = "\(memo.body)"
//            composer.setMessageBody(body, isHTML: false)
//            //composer.navigationBar.tintColor = UIColor.whiteColor()
//            present(composer, animated: true, completion: nil)
            //presentViewController(composer, animated: true, completion: {
            //UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
            //   })
        }
        
    }
    
    func doMailAllAction(_ memo:Memo) {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            //            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
            guard let cdDesktop  = self.currentDesktop, let cdMemos = cdDesktop.memos, let cdMemoArray:[CDMemo] = Array(cdMemos) as? [CDMemo] else {
                return }
            
            composer.setSubject("\(memo.desktopName)")
            let memos:[Memo] = cdMemoArray.map{ return Memo($0) }
            
            let htmlBody = memos.reduce("", { (result, memo) -> String in
                return "\(result)\(memo.htmlBody)\n"
            })
            
            
            composer.setMessageBody(htmlBody, isHTML: true)
            //            composer.navigationBar.tintColor = memo.backgroundImage.tintColor
            present(composer, animated: true, completion: nil)
            
            //todo i18n
            //            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
            //            let body = "\(memo.body)"
            //            composer.setMessageBody(body, isHTML: false)
            //            //composer.navigationBar.tintColor = UIColor.whiteColor()
            //            present(composer, animated: true, completion: nil)
            //presentViewController(composer, animated: true, completion: {
            //UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
            //   })
        }
        
    }
    
    
    func doMoveAction(_ memo:Memo) {
        
        if let desktop = DesktopService().queryUndeletedDesktop() {
            if desktop.count == 1 {
                UIUtil.displayToastMessage(Appi18n.i18n_noMoreDesktop, completeHandler: nil)
                self.mainFloatButton.show()
                return
            }
        
        }
        self.buttonSoundSoso.play()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //            layout.minimumLineSpacing = 5
        //            layout.minimumInteritemSpacing = 5
        
        let deskVC = MoveMemoViewController(collectionViewLayout: layout)
        deskVC.boardViewController = self
//        deskVC.memoBaseTVController = self
        deskVC.memo = memo
        let nav = UINavigationController(rootViewController: deskVC)
        
        //        nav.modalTransitionStyle = .flipHorizontal
        present(nav, animated: true, completion: nil)
        
        
    }
    
    func floatButtonClicked(_ button: FloatButton, index: Int) {
        Util.printLog("selectedButton:\(index)")
        
        if index >= 1 {
            self.buttonSoundSoso.play()
        }
        switch index {
        case 0:
            createMemo()
        case 1:
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
//            layout.minimumLineSpacing = 5
//            layout.minimumInteritemSpacing = 5
            
            let deskVC = DesktopViewController(collectionViewLayout: layout)
            deskVC.boardViewController = self
            let nav = UINavigationController(rootViewController: deskVC)
            
            nav.modalTransitionStyle = .flipHorizontal
            present(nav, animated: true, completion: nil)
            
        case 2:
//            let vc = MainContainerViewController()
//            vc.boardViewController = self
//            vc.memoList =  fetchMemo()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalTransitionStyle = .flipHorizontal
//            present(nav, animated: true, completion: nil)
            
            let vc = HomeTabViewController(self)
            vc.modalTransitionStyle = .flipHorizontal
            present(vc, animated: true, completion: nil)
        case 3:
            goSettings()
        default :
            break
        }
    }
    
    func goSettings() {
        let vc = HomeTabViewController(self)
        vc.modalTransitionStyle = .flipHorizontal
        vc.selectedIndex = 2
        present(vc, animated: true, completion: nil)
    }
}
