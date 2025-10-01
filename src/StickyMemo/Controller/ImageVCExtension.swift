//
//  ImageVCExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/12/12.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

extension ImageViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = self.imageList {
            return images.count
        }
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
        if let images = self.imageList {
            cell.cdImage = images[indexPath.item]
        }
        //        cell.backgroundColor = .red
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width = min(self.view.frame.width / 2, 150)
        let width = self.view.frame.width - 2
        let height = width * 6 / 9
        return CGSize(width: width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        self.selectedIndexPath = indexPath

        let actionSheet = UIAlertController(title: Appi18n.i18n_choiceActionTitle, message: nil, preferredStyle: .actionSheet)

        let actionDelete = UIAlertAction(title:Appi18n.i18n_delete, style: .default) { (_) in
            if let imageList = self.imageList {
                let cdImage = imageList[indexPath.item]
                self.confirmDelete(cdImage)
            }

        }

        //to do i18n
        let actionView = UIAlertAction(title: Appi18n.i18n_viewPhoto, style: .default) { (_) in
            
            guard let imageDataList = self.imageList else { return }
           
            var images:[UIImage] = []
            for img in imageDataList {
                if let imgData = img.imageContent, let uiimage =  UIImage(data: imgData) {
                    images.append(uiimage)
                }
            }

//            let images = imageDataList.flatMap{ return UIImage(data: $0.imageContent!)}
            if images.count > 0 {
                if let keyWindow = UIApplication.shared.keyWindow,let cell = collectionView.cellForItem(at: indexPath) {
                    
                    let keyframe = keyWindow.convert((cell.frame), from: cell.superview)
                    //            print(keyframe)
                    
                    self.photoQuickView = PhotoFullScreenView(images, currentIndex: indexPath.row, startFrame: keyframe)
                    self.photoQuickView?.show()
                    
                }
            }
            
        }
        
        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in

        }
        actionSheet.addAction(actionDelete)
        actionSheet.addAction(actionView)
        actionSheet.addAction(actionCancel)
        
        
        // adaptive iPad
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            if let cell = collectionView.cellForItem(at: indexPath)  {
                popoverPresentationController.sourceView = cell
                //                        popoverPresentationController.sourceRect = cell.bounds

                // arrow point to cell center
                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
                popoverPresentationController.permittedArrowDirections = .any
                //popoverPresentationController.preferredContentSize
                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
            }
            //            else {
            //                popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
            //            }
        }

        present(actionSheet, animated: true, completion: nil)

    }
    
    func confirmDelete(_ cdImage:CDImage) {

        
        let alert = UIAlertController(title: "\(Appi18n.i18n_confirmDeleteImage)", message: nil, preferredStyle: .alert)

        let deleteOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            // confirm delete
            ImageService().deleteImage(cdImage)
            if let indexPath = self.selectedIndexPath {
                self.imageList?.remove(at: indexPath.row)
            }
            
            self.freshData()
        }
        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in

        }

        alert.addAction(deleteOK)
        alert.addAction(deleteCancel)

        present(alert, animated: true, completion: nil)


    }


    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        guard let cdMemo =  self.cdMemo else {
            return
        }
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            Util.printLog("UIImagePickerControllerEditedImage called")
            let data = image.jpegData(compressionQuality: 1)
            let cdImage = ImageService().addImage(cdMemo, imageContent: data)
            self.imageList?.append(cdImage)
            self.collectionView?.reloadData()
        }
        
        if let _ = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as?
            UIImage {
            Util.printLog("UIImagePickerControllerOriginalImage called")
            
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.reloadData()
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
