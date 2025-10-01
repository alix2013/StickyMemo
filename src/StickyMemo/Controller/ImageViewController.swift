//
//  ImageViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/12.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit


class ImageCell: UICollectionViewCell {
    
    var cdImage: CDImage? {
        didSet {
            guard let cdImage = cdImage else {
                return
            }

            if let imgData = cdImage.imageContent {
                imageView.image  = UIImage(data: imgData)
            } else {
//                // set default img
//                imageView.image = UIImage(named:"desktop_background1")
            }
        }
    }
    
    
    var imageView:UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(imageView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":imageView]))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: nil, views: ["v0":imageView]))
    }
    
}



class ImageViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout {

    let buttonSongSound:ButtonSound = ButtonSound(type: .soso)
    
    var memoView:MemoView?
    
    var cdMemo:CDMemo? {
        didSet {
            guard let images = cdMemo?.images else { return }
            self.imageList = Array(images) as? [CDImage]
        }
    }
    var photoQuickView: PhotoFullScreenView?
    var imageList: [CDImage]?
    
    let cellId:String = "CellID"
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        freshData()
        setupNavButtomItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let imgList = self.imageList  else { return }
        if imgList.count == 0 {
            self.addPhoto()
        }
    }
    func freshData() {
//        self.cdDesktopList = DesktopService().queryUndeletedDesktop()
        self.collectionView?.reloadData()
    }
    
    func setupViews() {
        self.view.backgroundColor = .white
        //        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupNavButtomItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto) )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeViewController) )
    }
    
    
    @objc func addPhoto() {
        
        let camera = CameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //adaptive iPad
//        optionMenu.popoverPresentationController?.sourceView = self.navigationItem.rightBarButtonItem.
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
//        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 1, height: 1)
//        optionMenu.popoverPresentationController?.arrowDirection = .
//        if let popoverPresentationController = optionMenu.popoverPresentationController, let indexPath = self.selectedIndexPath {
//            if let cell = collectionView?.cellForItem(at: indexPath)  {
//                popoverPresentationController.sourceView = cell
//                //                popoverPresentationController.sourceRect = cell.bounds
//                // arrow point to cell center
//                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
//                popoverPresentationController.permittedArrowDirections = .up
//                //popoverPresentationController.preferredContentSize
//                //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
//            }
//
//        }
        
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
    
    @objc func closeViewController() {
        if let memoView = self.memoView {
            memoView.setPhotoCount()
        }
        buttonSongSound.play()
        dismiss(animated: true, completion:{self.memoView?.restoreButtonLocation()})
    }
    
}

