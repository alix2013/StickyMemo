//
//  MoveMemoViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/31.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

//class DesktopSelectCell:DesktopCell{

//    var selectedImageView:UIImageView = {
//       let v = UIImageView()
//        v.image = UIImage(named:"button_selected")
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
////        setupSelectImage()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

//    func setupSelectImage() {
//        self.addSubview(self.selectedImageView)
//
////        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0(20)]|", options: [], metrics: nil, views: ["v0":selectImageView]))
////        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0(20)]|", options: [], metrics: nil, views: ["v0":selectImageView]))
//        selectedImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        selectedImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
//
//        selectedImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        selectedImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//    }
    
//}

class MoveMemoViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout  {
    
    var cdDesktopList:[CDDesktop]?
    let cellId = "cellId"
    
    var selectedIndexPath:IndexPath?
    var boardViewController: BoardViewController?
    var memoBaseTVController: MemoBaseTVContoller?
    var memo:Memo?
    
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupNavButtomItems()
        setupCollectionView()
        freshData()
    }
    
    func setupNavButtomItems() {
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDesktop) )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeViewController) )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doMoveAction) )
        
    }
    
    
    func setupCollectionView(){
        self.collectionView?.register(DesktopCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.backgroundColor = .white
    }
    
    func freshData() {
        self.cdDesktopList  = DesktopService().queryUndeletedDesktop()
        
        if let desktopList = self.cdDesktopList,  let currentDesktop = memo?.cdMemo?.desktop{
            for (index, desktop ) in desktopList.enumerated() {
                if desktop == currentDesktop {
                    self.cdDesktopList?.remove(at: index)
                }
            }
        }
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
            cell.cdDesktop = desktopList[indexPath.item]
        }
        
        if let selectedIndexPath = self.selectedIndexPath {
            if selectedIndexPath == indexPath {
                cell.selectedImageView.isHidden = false
            }else{
                cell.selectedImageView.isHidden = true
            }
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        collectionView.reloadData()
    }
    
    @objc func closeViewController(){
        buttonSoundSoso.play()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doMoveAction() {
        
        guard let memo = memo else { return }
        guard let selectedIndex = self.selectedIndexPath else {
            let msg = Appi18n.i18n_choiceTargetDesktop //NSLocalizedString("Choice target desktop", comment: "Choice target desktop")
            UIUtil.displayToastMessage(msg, completeHandler: nil)
            return }
        guard let cdDesktopList = self.cdDesktopList else { return }
        
        let sourceDesktop = memo.cdMemo?.desktop
        let targetDesktop = cdDesktopList[selectedIndex.item]
        
        memo.moveDesktop(targetDesktop)
        if let boardVC = self.boardViewController {
            if sourceDesktop == boardVC.currentDesktop || targetDesktop == boardVC.currentDesktop  {
                boardVC.freshMemoView()
            }
        }
        if let memoVC = self.memoBaseTVController {
            memoVC.freshTableData()
        }
        buttonSoundSoso.play()
        self.dismiss(animated: true, completion: nil)
    }
}
