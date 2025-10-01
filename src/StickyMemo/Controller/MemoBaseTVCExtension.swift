//
//  MemoBaseTVCExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/12/22.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import MessageUI
//extension for cell button clicks
extension MemoBaseTVContoller:MFMailComposeViewControllerDelegate {


    func getButtonTapedMemo(_ sender: UIButton) -> Memo?{
        guard let indexPath = getParentCellIndexPath(sender) else {
            return nil
        }
        
        let section = indexPath.section
        let row = indexPath.row
        if self.searchController.isActive {
            if section < self.searchResults.count && row < self.searchResults[section].memoList.count{
                let memo = self.searchResults[section].memoList[row]
                return memo
            }else{
                Util.printLog("Button Cell indexPath out of scope!")
                return nil
            }
        }else{
            if section < self.memoTableList.count && row < self.memoTableList[section].memoList.count{
                let memo = self.memoTableList[section].memoList[row]
                return memo
            }else{
                Util.printLog("Button Cell indexPath out of scope!")
                return nil
            }
        }
        
        
    }
    
    func getButtonTapedMemoAndDesktop(_ sender: UIButton) -> (Memo?,CDDesktop?){
        guard let indexPath = getParentCellIndexPath(sender) else {
            return (nil,nil)
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        if self.searchController.isActive {
            if section < self.searchResults.count && row < self.searchResults[section].memoList.count{
                let memo = self.searchResults[section].memoList[row]
                let desktop = self.searchResults[section].cdDesktop
                return (memo, desktop)
            }else{
                Util.printLog("Button Cell indexPath out of scope!")
                return (nil,nil)
            }
            
        }else{
            if section < self.memoTableList.count && row < self.memoTableList[section].memoList.count{
                let memo = self.memoTableList[section].memoList[row]
                let desktop = self.memoTableList[section].cdDesktop
                return (memo, desktop)
            }else{
                Util.printLog("Button Cell indexPath out of scope!")
                return (nil,nil)
            }
        }
        
        
    }
    
    @objc func buttonEditMemoTap(sender:UIButton){
        self.buttonSoundDing.play()
        
        UIUtil.animateButton(sender)
        
        let (memo,desktop) = self.getButtonTapedMemoAndDesktop(sender)
        
        
        if let board = self.boardViewController,let memo = memo,let selectedDesktop = desktop  {
//            Util.printLog("buttonEditMemoTaped, \(memo.body) \(selectedDesktop.name)")
            //if current desktop no selected, fresh first, tehn edit
            if self.searchController.isActive {
                self.searchController.isActive = false
            }
            if board.currentDesktop != selectedDesktop {
                board.currentDesktop = selectedDesktop
                board.freshMemoView()
            }
            self.dismiss(animated: true, completion:{
                board.editMemo(memo)
            })
        }
        
        
//        guard let indexPath = getParentCellIndexPath(sender) else {
//            return
//        }
//
//        Util.printLog("button index path:\(indexPath)")
//
//        if let board = self.boardViewController {
//            let section = indexPath.section
//            let row = indexPath.row
//            let selectedDesktop = self.memoTableList[section].cdDesktop
//            let memo = self.memoTableList[section].memoList[row]
//
//            if board.currentDesktop != selectedDesktop {
//                board.currentDesktop = selectedDesktop
//                board.freshMemoView()
//            }else{
//
//            }
//
//            self.dismiss(animated: true, completion:{
//                board.editMemo(memo)
//            })
//        }
        
    }
    
    func freshCurrentDesktop(_ memo:Memo) {
        if let boardVC = self.boardViewController {
            if memo.cdMemo?.desktop?.id == boardVC.currentDesktop?.id {
                boardVC.freshMemoView()
            }
        }
    }
    @objc func buttonDeleteTap(_ sender: UIButton) {
        self.buttonSoundDing.play()
        
        UIUtil.animateButton(sender)
        self.animateDeleteCell(sender)
        
//        let alert = UIAlertController(title: Appi18n.i18n_confirmDeleteMemo, message: nil, preferredStyle: .alert)
//
//        let deleteOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
//            // confirm delete
//            self.animateDeleteCell(sender)
//
//        }
//        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(deleteOK)
//        alert.addAction(deleteCancel)
//        present(alert, animated: true, completion: nil)
        
    }
    
    func animateDeleteCell(_ sender: UIButton) {
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        if let cell = self.getParentCell(sender) {
            self.buttonSoundSoso.play()
            UIView.animate(withDuration: 0.2, animations: {
                cell.frame.origin.x +=  UIScreen.main.bounds.width + 10 //cell.frame.width + 10
                //                    cell.transform = CGAffineTransform(translationX: self.view.frame.width + 10, y: 0)
                //                    let targetRect = CGRect(x: cell.frame.width - 30 , y: cell.frame.height - 30, width: 30, height: 30)
                //                    cell.frame = targetRect
            }, completion: { b in
                memo.fadeDelete()
                self.freshTableData()
                //fresh current opened desktop memoView for new changes to avoid dismiss see old value
                self.freshCurrentDesktop(memo)
                
            })
        }
    }
//    func animateDeleteCell(_ sender:UIButton) {
////        guard let memo = self.getButtonTapedMemo(sender) else { return }
//        guard let indexPath = self.getParentCellIndexPath(sender) else { return }
//        let section = indexPath.section
//        let row = indexPath.row
//        self.memoTableList[section].memoList.remove(at: row)
//        self.tableView.deleteRows(at: [indexPath], with: .right)
//
//    }
    @objc func buttonFavoriedTap(_ sender: UIButton) {
        self.buttonSoundDing.play()
        
//        Util.printLog("buttonFavoritedTap")
        UIUtil.animateButton(sender)
        
        if let memo = self.getButtonTapedMemo(sender) {
            memo.isFavorited = !memo.isFavorited
            memo.save()
            sender.tintColor = memo.isFavorited ? .red : .lightGray
            
            //fresh current opened desktop memoView for new changes to avoid dismiss see old value
            self.freshCurrentDesktop(memo)
            if self.isFavoritedTableView {
                self.freshTableData()
            }
        }
    }
    
    @objc func buttonMailTap(_ sender: UIButton) {
        self.buttonSoundDing.play()
        
        Util.printLog("buttonMailTap")
        UIUtil.animateButton(sender)
        
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self

//            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
            composer.setSubject("\(memo.subject)")
//            let body = "\(memo.body)"
//            Util.printLog("background color:\(memo.backgroundImage.tintColorHex)")
//            let stringBody = "<p style=\"background-color:#\(memo.backgroundImage.tintColorHex)\">\(body)</p>"
////            composer.setMessageBody(body, isHTML: false)
//            let htmlBody = stringBody.replacingOccurrences(of: "\n", with: "<br>")
            composer.setMessageBody(memo.htmlBody, isHTML: true)
            //composer.navigationBar.tintColor = UIColor.whiteColor()
//            composer.navigationBar.barTintColor = memo.backgroundImage.tintColor
            present(composer, animated: true, completion: nil)
            //presentViewController(composer, animated: true, completion: {
            //UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
            //   })
        }
        
        
    }
    
    @objc func buttonShareTap(_ sender: UIButton) {
//        UIUtil.animateButton(sender)
        
        Util.printLog("buttonShareTap")
        self.buttonSoundDing.play()
        
//        let shareText = "Hello, world!"
//        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
//        present(vc, animated: true)
//        let image = UIImage(named: "home")
//        let image1 = UIImage(named: "button_trash")
//        // set up activity view controller
//        let imageToShare:[Any] = [shareText,image!,image1!]
    
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        //animate
        
        self.animateButtonShare(sender)
        
        let shareObjects = memo.getObjectsForShare()  //self.getShareObjects(memo)
        let activityViewController = UIActivityViewController(activityItems: shareObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @objc func buttonMoveTap(_ sender:UIButton) {
        Util.printLog("buttonMovetap called")
        if let desktop = DesktopService().queryUndeletedDesktop() {
            if desktop.count == 1 {
                UIUtil.displayToastMessage(Appi18n.i18n_noMoreDesktop, completeHandler: nil)
                return
            }
        }
        
        self.buttonSoundSoso.play()
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //            layout.minimumLineSpacing = 5
        //            layout.minimumInteritemSpacing = 5
        
        let deskVC = MoveMemoViewController(collectionViewLayout: layout)
        deskVC.boardViewController = self.boardViewController
        deskVC.memoBaseTVController = self
        deskVC.memo = memo
        let nav = UINavigationController(rootViewController: deskVC)
        
//        nav.modalTransitionStyle = .flipHorizontal
        present(nav, animated: true, completion: nil)
        
        
    }
    func animateButtonShare(_ sender:UIButton) {
        
        //        if let cell = self.getParentCell(sender) {
        //            let cellRect = self.view.convert(cell.frame, from: cell.superview)
        //            let cellLocationView = UIView(frame:cellRect)
        //            self.view.addSubview(cellLocationView)
        //            cellLocationView.backgroundColor = .red
        // add imageView to self.view, location at original location
        let buttonRect = self.view.convert(sender.frame, from: sender.superview)
        let imageView = UIImageView(frame:buttonRect)
        imageView.image = UIImage(named:"button_share_small")
        self.view.addSubview(imageView)
        //            imageView.backgroundColor = .red
        sender.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options:.curveEaseInOut, animations: {
            //scale 3 multiple
            imageView.transform = CGAffineTransform(scaleX: 3, y: 3)
            
            }, completion: { completed in
                if completed {
                    self.buttonSoundSoso.play()
                    UIView.animate(withDuration: 3, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        imageView.transform = CGAffineTransform(scaleX: 10, y: 10)
                        imageView.frame.origin.y = -120
                        imageView.frame.origin.x = self.view.frame.width + 100
                    }, completion: { b in
                        if b {
                            sender.alpha = 1
                            imageView.removeFromSuperview()
                        }
                        
                    })
                }
        })

    }
    
//    func getShareObjects(_ memo:Memo) -> [Any] {
//        var shareObjects:[Any] = []
//        let shareText = "\(memo.subject)\n\(memo.body)"
//        shareObjects.append(shareText)
//
//        if let images = memo.cdMemo?.images,let imageArray = Array(images) as? [CDImage] {
//            let sortedImages = imageArray.sorted{
////                return $0.id < $1.id
//                if let createAt1 = $0.createAt, let createAt2 = $1.createAt {
//                    return createAt1 < createAt2
//                }else{
//                    return false
//                }
//
//            }
//            let imageDataList = sortedImages.map{
//                return $0.imageContent
//            }
//            for imageData in imageDataList {
//                if let imageData = imageData,let image = UIImage(data: imageData) {
//                    shareObjects.append(image)
//                }
//            }
//        }
//        return shareObjects
//    }
    
    @objc func buttonOpenDesktap(_ sender:UIButton){
        self.buttonSoundSoso.play()
        UIUtil.animateButton(sender)
        let selectedDesktop = self.memoTableList[sender.tag].cdDesktop
        if let board = self.boardViewController {
            self.dismiss(animated: true, completion:{
                if board.currentDesktop != selectedDesktop {
                    board.currentDesktop = selectedDesktop
                    board.freshMemoView()
                }
            })
        }
        
    }
    
    
    //    @objc func buttonOpenClosTap(_ sender:UIButton){
    //        Util.printLog("sender tag:\(sender.tag)")
    //
    //        let section = sender.tag
    //        self.memoTableList[section].isExtended =  !self.memoTableList[section].isExtended
    //
    //        var reloadIndexPaths:[IndexPath]  = []
    //        for row in self.memoTableList[section].memoList.indices {
    //            let indexPath  = IndexPath(row: row, section: section)
    //            reloadIndexPaths.append(indexPath)
    //        }
    //
    //        if self.memoTableList[section].isExtended {
    ////            tableView.insertRows(at: reloadIndexPaths, with: .left)
    //             tableView.insertRows(at: reloadIndexPaths, with: .automatic)
    //            sender.setTitle("close", for: .normal)
    //        } else {
    //            tableView.deleteRows(at: reloadIndexPaths, with: .automatic)
    //            sender.setTitle("open", for: .normal)
    //        }
    //        tableView.reloadData()
    //    }
    
    @objc func openCloseSectionTap(sender: UIButton) {
        Util.printLog("open close:\(sender.tag)")
        //        let section = sender.tag
        //        self.dataList[section].isOpening = !self.dataList[section].isOpening
        //
        //        var reloadIndexPaths:[IndexPath]  = []
        //        for row in self.dataList[section].data.indices {
        //            let indexPath  = IndexPath(row: row, section: section)
        //            reloadIndexPaths.append(indexPath)
        //        }
        //
        //        if self.dataList[section].isOpening {
        //            tableView.insertRows(at: reloadIndexPaths, with: .left)
        //            sender.setTitle("close", for: .normal)
        //        } else {
        //            tableView.deleteRows(at: reloadIndexPaths, with: .right)
        //            sender.setTitle("open", for: .normal)
        //        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
