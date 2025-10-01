//
//  DesktopVCExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/12/8.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

extension DesktopViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't recognize a single tap until a double-tap fails.
        if gestureRecognizer == self.tapGesture &&
            otherGestureRecognizer == self.tap2Gesture {
            return true
        }
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let desktopList = self.cdDesktopList {
            return desktopList.count
        }
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DesktopCell
        
        if let desktopList = self.cdDesktopList{
            let desktop = desktopList[indexPath.item]
            cell.cdDesktop = desktop
            
            if self.boardViewController?.currentDesktop == desktop {
                cell.selectedImageView.isHidden = false
            }else{
                cell.selectedImageView.isHidden = true
            }
        }
        
        
        //        cell.backgroundColor = .red
//        collectionView.canCancelContentTouches = false
//        let tap2Gesture = UITapGestureRecognizer()
//        tap2Gesture.numberOfTapsRequired = 2
//        tap2Gesture.addTarget(self, action: #selector(tap2GestureHandler(_ :)))
//        cell.addGestureRecognizer(tap2Gesture)
        
        return cell
    }
    
//    @objc func tap2GestureHandler(_ sender: UITapGestureRecognizer) {
//        Util.printLog("tap2GestureHandler called")
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width = min(self.view.frame.width / 2, 150)
        let width = self.view.frame.width / 2  - 2
        let height = width * 1.2
        return CGSize(width: width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
    func openDesktop(_ desktop:CDDesktop) {
        if let board = self.boardViewController {
            let selectedDesktop = desktop
            if selectedDesktop != board.currentDesktop {
                board.currentDesktop = selectedDesktop
                board.freshMemoView()
            }
            
            self.dismiss(animated: true, completion:{
                
            })
        }
    }
    @objc func tap2GestureHandler(sender: UITapGestureRecognizer){
        Util.printLog("tap2GestureHandler called")
        guard let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) else { return }
        if let desktopList = self.cdDesktopList {
            let desktop = desktopList[indexPath.item]
            self.openDesktop(desktop)
        }
    }
    
    @objc func longTapGestureHandler(sender:UILongPressGestureRecognizer) {
        if self.isInLongTap {
            return
        }
        if sender.state == .began {
            self.isInLongTap = true
        }
        if sender.state == .ended {
            self.isInLongTap = false
        }
        Util.printLog("longTapGestureHandler called")
        guard let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) else { return }
        Util.printLog("indexPath:\(indexPath)")
        if let desktopList = self.cdDesktopList {
            let desktop = desktopList[indexPath.item]
            
            self.openDesktop(desktop)
//            self.isInLongTap = false
        }
        
    }
    @objc func tapGestureHandler(sender: UITapGestureRecognizer){
        guard let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) else { return }
        
        guard let desktopList = self.cdDesktopList,let desktopName = desktopList[indexPath.item].name  else { return }
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return }
        
        let tapPoint = sender.location(in: cell)
        let sourcRect = CGRect(x: tapPoint.x, y: tapPoint.y, width: 1, height: 1)
        Util.printLog("source rect:\(sourcRect)")
        
        self.selectedIndexPath = indexPath
        
        let actionSheet = UIAlertController(title: "\(Appi18n.i18n_choiceActionTitle) \(desktopName) ", message: nil, preferredStyle: .actionSheet)
        
        let actionOpen = UIAlertAction(title:Appi18n.i18n_open, style: .default) { (_) in
            
            if let desktopList = self.cdDesktopList {
                let desktop = desktopList[indexPath.item]
                self.openDesktop(desktop)
            }
            
        }
        let actionDelete = UIAlertAction(title:Appi18n.i18n_delete, style: .destructive) { (_) in
            if let cdDesktopList = self.cdDesktopList{
                let cdDesktop = cdDesktopList[indexPath.item]
                self.confirmDelete(cdDesktop)
            }
            
        }
        
        let actionRename = UIAlertAction(title: Appi18n.i18n_renameDesktop, style: .default) { (_) in
            if let cdDesktopList = self.cdDesktopList{
                let cdDesktop = cdDesktopList[indexPath.item]
                self.renameDesktop(cdDesktop)
            }
        }
        
        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            
        }
        
        let actionSetBGImage = UIAlertAction(title: Appi18n.i18n_setDesktopBackground, style: .default) { (_) in
            
            self.choiceBackgroundImage(sourcRect)
        }
        
        actionSheet.addAction(actionOpen)
        actionSheet.addAction(actionRename)
        
        // system default desktop id = 1, no delete
        if desktopList[indexPath.item].id != "1" {
            actionSheet.addAction(actionDelete)
        }
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSetBGImage)
        
        // adaptive iPad
        if let popoverPresentationController = actionSheet.popoverPresentationController {
//            if let cell = collectionView?.cellForItem(at: indexPath)  {
                popoverPresentationController.sourceView = cell
                let tapPoint = sender.location(in: cell)
                let sourcRect = CGRect(x: tapPoint.x, y: tapPoint.y, width: 1, height: 1)
//                popoverPresentationController.sourceRect = cell.bounds
                popoverPresentationController.sourceRect = sourcRect
                // arrow point to cell center
                //                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
                popoverPresentationController.permittedArrowDirections = .any
                //popoverPresentationController.preferredContentSize
                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
//            }
            //            else {
            //                popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
            //            }
        }
        
        present(actionSheet, animated: true, completion: nil)
        
            
//            let cell = self.collectionView?.cellForItem(at: indexPath)
        
            
        
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let desktopList = self.cdDesktopList,let desktopName = desktopList[indexPath.item].name  else {
//            return
//        }
//
//        self.selectedIndexPath = indexPath
//
//        let actionSheet = UIAlertController(title: "\(Appi18n.i18n_choiceActionTitle) \(desktopName) ", message: nil, preferredStyle: .actionSheet)
//
//        let actionOpen = UIAlertAction(title:Appi18n.i18n_open, style: .default) { (_) in
//
//            if let board = self.boardViewController, let desktopList =  self.cdDesktopList {
//                self.dismiss(animated: true, completion:{
//
//                    let selectedDesktop = desktopList[indexPath.item]
//                    if selectedDesktop != board.currentDesktop {
//                        board.currentDesktop = selectedDesktop
//                        board.freshMemoView()
//                    }
//                    //save defaultDesktop to last opened
////                    DefaultService.saveDefaultDesktop(selectedDesktop)
//
//                })
//            }
//        }
//        let actionDelete = UIAlertAction(title:Appi18n.i18n_delete, style: .default) { (_) in
//            if let cdDesktopList = self.cdDesktopList{
//                let cdDesktop = cdDesktopList[indexPath.item]
//                self.confirmDelete(cdDesktop)
//            }
//
//        }
//
//        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
//
//        }
//
//        let actionSetBGImage = UIAlertAction(title: Appi18n.i18n_setDesktopBackground, style: .default) { (_) in
//
//            self.choiceBackgroundImage()
//        }
//
//        actionSheet.addAction(actionOpen)
//
//        // system default desktop id = 1, no delete
//        if desktopList[indexPath.item].id != "1" {
//            actionSheet.addAction(actionDelete)
//        }
//        actionSheet.addAction(actionCancel)
//        actionSheet.addAction(actionSetBGImage)
//
//        // adaptive iPad
//        if let popoverPresentationController = actionSheet.popoverPresentationController {
//            if let cell = collectionView.cellForItem(at: indexPath)  {
//                popoverPresentationController.sourceView = cell
//                popoverPresentationController.sourceRect = cell.bounds
//
//                // arrow point to cell center
////                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
//                popoverPresentationController.permittedArrowDirections = []
//                //popoverPresentationController.preferredContentSize
//                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
//            }
//            //            else {
//            //                popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
//            //            }
//        }
//
//        present(actionSheet, animated: true, completion: nil)
//
//    }
    
    func confirmDelete(_ cdDesktop:CDDesktop) {
        
        let desktopName = cdDesktop.name
        let alert = UIAlertController(title: "\(Appi18n.i18n_confirmDeleteDesktop) \(desktopName ?? "")", message: nil, preferredStyle: .alert)
        
        let deleteOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            // confirm delete
            self.deleteDesktop(cdDesktop: cdDesktop)
            self.freshData()
        }
        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            
        }
        
        alert.addAction(deleteOK)
        alert.addAction(deleteCancel)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    

    func choiceBackgroundImage(_ popSourceRectForiPad:CGRect) {
        let camera = CameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        optionMenu.popoverPresentationController?.sourceView = self.view
        
        if let popoverPresentationController = optionMenu.popoverPresentationController, let indexPath = self.selectedIndexPath {
            if let cell = collectionView?.cellForItem(at: indexPath)  {
                popoverPresentationController.sourceView = cell
                popoverPresentationController.sourceRect = popSourceRectForiPad //cell.bounds
                // arrow point to cell center
//                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
                popoverPresentationController.permittedArrowDirections = .any
                //popoverPresentationController.preferredContentSize
                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
            }
            
        }
        
        let takePhoto = UIAlertAction(title: Appi18n.i18n_takePhoto, style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: Appi18n.i18n_photoLibrary, style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            Util.printLog("UIImagePickerControllerEditedImage called")
            if let selectedIndexPath  = self.selectedIndexPath {
                let cell = collectionView?.cellForItem(at: selectedIndexPath) as! DesktopCell
                cell.imageView.image = image
                
                updateDesktopImage(selectedIndexPath,image: image)
                
            }
            
            
        }
        
        if let _ = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as?
            UIImage {
            Util.printLog("UIImagePickerControllerOriginalImage called")
//            photoImageView.image = selectedImage
//            photoImageView.contentMode = .scaleAspectFill
//            photoImageView.clipsToBounds = true
        }
        // image is our desired image
        
        picker.dismiss(animated: true, completion: nil)
    }

    func updateDesktopImage(_ indexPath:IndexPath, image:UIImage) {
        guard let cdDesktopList = self.cdDesktopList else {
            return
        }
        
        let data = image.jpegData(compressionQuality: 1)
        let desktop = cdDesktopList[indexPath.item]
        Util.printLog("Save image for:\(String(describing: desktop.name))")
        DesktopService().updateDesktopImage(cdDesktop: desktop, backImageContent: data)
        
        //fresh board image if current upate
        if let boardVC = self.boardViewController, let currentDesktop = boardVC.currentDesktop {
            if currentDesktop.objectID == desktop.objectID {
                boardVC.setupBackgroundImage()
            }
        }
    }
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        Util.printLog("UIDevice.current.orientation.isLandscape")
//        Util.printLog(UIDevice.current.orientation.isLandscape)
//        self.collectionView?.reloadData()
//    }
//
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.reloadData()
    }
    
    func renameDesktop(_ cdDesktop:CDDesktop){
        
        let alert = UIAlertController(title: Appi18n.i18n_inputTitle, message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = Appi18n.i18n_placeHolderDesktopName }
        
        let actionOK = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
            guard let name = alert.textFields?.first?.text, name.count <= 20
                else {
                    let msg = Appi18n.i18n_desktopNameTooLong //NSLocalizedString("Name is too long", comment: "Name is too long")
                    UIUtil.displayToastMessage(msg, completeHandler: nil)
                    return
                    
            }

            Util.printLog("Desktop New name:"+name)
            DesktopService().renameDesktop(cdDesktop: cdDesktop, newName: name)
            self.freshData()
            
//            if let cdDesktopList = self.cdDesktopList {
//                let lastIndexPath = IndexPath(item: cdDesktopList.count - 1, section: 0)
//                self.collectionView?.scrollToItem(at: lastIndexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
//            }
        }
        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            // no actions
        }
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
