//
//  DesktopViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/7.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit


class DesktopCell: UICollectionViewCell {
    
    var cdDesktop: CDDesktop? {
        didSet {
            guard let cdDesktop = cdDesktop else {
                return
            }
            nameLabel.text = cdDesktop.name
            if let imgData = cdDesktop.backImageContent {
                imageView.image  = UIImage(data: imgData)
            } else {
                // set default img
                imageView.image = UIImage(named:AppDefault.defaultDesktopBackgroundImageName)
            }
            
        }
    }
    var nameLabel:UILabel = {
        let v = UILabel()
//        v.backgroundColor = .blue
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
        
    }()
    
    var selectedImageView:UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named:"button_selected")
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var imageView:UIImageView = {
       let v = UIImageView()
//        v.image = UIImage(named:"desktop_default_background")
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.contentMode = .scaleAspectFit
        return v
    }()
    
//    lazy var stackView: UIStackView = {
//       let v = UIStackView(arrangedSubviews: [imageView,nameLabel])
//        v.axis = .vertical
//        v.translatesAutoresizingMaskIntoConstraints =  false
//        v.distribution = .fill
//        return v
//    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.addSubview(nameLabel)
        self.addSubview(imageView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":nameLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":imageView]))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0][v1(20)]-|", options: [], metrics: nil, views: ["v0":imageView, "v1":nameLabel]))
        
        self.addSubview(selectedImageView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(30)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(30)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        
        selectedImageView.isHidden = true
//        setupGesture()
    }
    
//    func setupGesture() {
//        let tap2Gesture = UITapGestureRecognizer()
//        let
//        self.addGestureRecognizer()
//    }
}


class DesktopViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    //parent controller
    var boardViewController: BoardViewController?
    var cdDesktopList:[CDDesktop]?
    
    let cellId:String = "CellID"
    
    var selectedIndexPath: IndexPath?
    var isInLongTap: Bool = false
    
//    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    lazy var tapGesture:UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        g.delegate = self
        return g
    }()
    
    lazy var tap2Gesture:UITapGestureRecognizer =  {
        let g = UITapGestureRecognizer(target: self, action: #selector(tap2GestureHandler))
        g.numberOfTapsRequired = 2
        g.delegate = self
        return g
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Util.saveAccessLog("Desktop",memo:"Access Desktop")
        
        setupViews()
        freshData()
        setupNavButtomItems()
        setupGesture()
    }
    
    func setupGesture(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.view.addGestureRecognizer(tapGesture)
        
//        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(tap2GestureHandler))
//        tap2Gesture.numberOfTapsRequired = 2
        
        self.view.addGestureRecognizer(tap2Gesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapGestureHandler))
        self.view.addGestureRecognizer(longTapGesture)
    }
    
    
    
    func freshData() {
        self.cdDesktopList = DesktopService().queryUndeletedDesktop()
        self.collectionView?.reloadData()
    }
    
    func setupViews() {
        self.view.backgroundColor = .white
//        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(DesktopCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupNavButtomItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDesktop) )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeViewController) )
    }
    
    
    @objc func addDesktop() {
        
        if DefaultService.isvip() {
            
            let alert = UIAlertController(title: Appi18n.i18n_inputTitle, message: nil, preferredStyle: .alert)
            alert.addTextField { (tf) in tf.placeholder = Appi18n.i18n_placeHolderDesktopName }
            
            let actionOK = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
                guard let name = alert.textFields?.first?.text, name.count <= 20
                    else {
                        let msg = Appi18n.i18n_desktopNameTooLong //NSLocalizedString("Name is too long", comment: "Name is too long")
                        UIUtil.displayToastMessage(msg, completeHandler: nil)
                        return
                        
                }
                self.createDesktop(name)
                self.freshData()
                if let cdDesktopList = self.cdDesktopList {
                    let lastIndexPath = IndexPath(item: cdDesktopList.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: lastIndexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
                }
            }
            let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
                // no actions
            }
            alert.addAction(actionOK)
            alert.addAction(actionCancel)
            present(alert, animated: true, completion: nil)
        } else {
            UIUtil.goPurchaseVIP(self)
        }
    }
    
    func createDesktop(_ name:String) {
        DesktopService().createDesktop(name: name, backImageContent: getRandomDesktopBackgroundImage())
    }
    
    func deleteDesktop(cdDesktop:CDDesktop) {
        // can not delete systemDefault desktop, id = 1
        // if deleted is default, or opening desktop, set opening or default to systemdefault desktop
        if cdDesktop.id == self.boardViewController?.currentDesktop?.id {
            self.boardViewController?.currentDesktop = DefaultService.getSystemDefaultDesktop()
            self.boardViewController?.freshMemoView()
        }
        if cdDesktop.id == DefaultService.getDefault()?.desktop?.id {
            DefaultService.getDefault()?.desktop = DefaultService.getSystemDefaultDesktop()
        }
        if let count = cdDesktop.memos?.count, count == 0 {
            DesktopService().finalDeleteDesktop(cdDesktop: cdDesktop)
            Util.printLog("final delete desktop")
        }else{
            DesktopService().fadeDeleteDesktop(cdDesktop: cdDesktop)
        }
        
    }
    
    // get randomDesktopbackgroundImage
    func getRandomDesktopBackgroundImage() -> Data? {
        
        let randomNum = Int(arc4random_uniform(UInt32(5)))
        let name = "desktop_background\(randomNum)"
        if let uiimage = UIImage(named: name) {
            return uiimage.jpegData(compressionQuality: 1)
        }else {
            
            if let img = UIImage(named:AppDefault.defaultDesktopBackgroundImageName) {
                let imgData = img.jpegData(compressionQuality: 1)
                return imgData
            }
        }
        return nil
    }
    
    @objc func closeViewController() {
        buttonSoundSoso.play()
        dismiss(animated: true, completion:nil)
    }
    
    
    //not worked for partialCurl, remove it
//    private func removePartialCurlTap() {
//        if let gestures = self.view.gestureRecognizers {
//            for gesture in gestures {
//                self.view.removeGestureRecognizer(gesture)
//            }
//        }
//        if let gestures = self.collectionView?.gestureRecognizers {
//            for gesture in gestures {
//                self.view.removeGestureRecognizer(gesture)
//            }
//        }
//
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        removePartialCurlTap()
//    }
    
}
