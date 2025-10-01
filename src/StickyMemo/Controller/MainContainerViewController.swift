//
//  MainContainerViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class MainContainerViewController:UIViewController {
    
//    var memoList:[Memo]!
//    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    var boardViewController: BoardViewController?
    
    lazy var viewControllerList : [UIViewController] = {
        var vcs : [UIViewController] = []
//        let vcarray:[(color:UIColor, title:String)] = [  (UIColor.green,"Green")]
        
        let vc1 = MemoTableViewController()
        vc1.boardViewController = self.boardViewController
//        vc1.title = "Current Desktop"
//        vc1.memoList = self.memoList
        vcs.append(vc1)

        let vc2 = FavoritedMemoTVContoller()
        vc2.boardViewController = self.boardViewController
//        vc2.title = "Favorited"
//        vc2.containerVC = self
        vcs.append(vc2)
        
        let reminderVC = ReminderMemoTVContoller()
//        reminderVC.boardViewController = self.boardViewController
        //        vc2.title = "Favorited"
        //        vc2.containerVC = self
        vcs.append(reminderVC)
        
        
        
        let vc3 = TrashMemoTVContoller()
        vc3.boardViewController = self.boardViewController
//        vc3.title = "Trash"
        //        vc2.containerVC = self
        vcs.append(vc3)
        
        let vc4 = AllMemoTVContoller()
        vc4.boardViewController = self.boardViewController
//        vc4.title = "All"
        //        vc2.containerVC = self
        vcs.append(vc4)
        
//        for v in vcarray {
//            var vc = UIViewController()
//            vc.view.backgroundColor = v.color
//            //vc.navigationItem.title = v.title
//            vc.title = v.title
//            vcs.append(vc)
//        }
//
        return vcs
    }()
    
    var selectedIndex: Int? {
        didSet{
            self.navigationItem.rightBarButtonItem = self.viewControllerList[selectedIndex!].navigationItem.rightBarButtonItem
            //            self.navigationItem.titleView = self.viewControllerList[selectedIndex!].navigationItem.titleView
        }
    }
    
//    var localCloudSegment:UISegmentedControl = {
//       let v = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 200, height: 28  ))
////        v.insertSegment(withTitle: "Local", at: 0, animated: false)
////        v.insertSegment(withTitle: "Cloud", at: 1, animated: false)
//        v.insertSegment(with: UIImage(named:"button_mobile"), at: 0, animated: false)
//        v.insertSegment(with: UIImage(named:"button_cloud"), at: 1, animated: false)
//        v.selectedSegmentIndex = 0
//        return v
//    }()
    
    var menuImageList:[UIImage] = {
        
        var images: [UIImage]  = [UIImage]()
        let  imageNames = ["navbutton_list", "navbutton_favorited","navbutton_alarm", "navbutton_trash", "navbutton_list_all"]
        for img in imageNames {
            //images.append(UIImage(named: img))
            if let image = UIImage(named: img) {
                images.append(image)
            }
            
        }
        return images
    }()
    
    lazy var menuBar:MenuBar = {
        //let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let mb = MenuBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50 )  , style: .imageList, cellWidth:self.view.frame.width / 5, imageList: self.menuImageList,selectedIndex: 0,selectedMenuItemColor: .red)
    
        mb.backgroundColor = AppDefault.themeColor
        mb.menuItemTintColor = .white
        mb.cellHeight = 50
        //        switch self.imageList.count {
        //        case 1...5:
        //            mb.cellWidth = self.view.frame.width / CGFloat(self.imageList.count)
        //        case 5...1000 :
        //            mb.cellWidth = self.view.frame.width / 4
        //        default:
        //            mb.cellWidth = mb.cellHeight
        //        }
        
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.delegate = self
        return mb
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewController()
        
        configLeftRightGesture()
        configBarItems()
        
        setupMenuBar()
        
//        setupNavigationSegement()
        
        gotoFirstViewController()
        
        //drop black line bellow navigation bar
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
    }
    
    func gotoFirstViewController() {
        self.menuBar.selectedIndex = 0
    }
    
    func configBarItems() {
        let closeWindowItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeWindow))
        self.navigationItem.leftBarButtonItem = closeWindowItem
        
    }
    func customizeViewController() {
        self.view.backgroundColor = .white
        
        navigationController?.navigationBar.isTranslucent = false
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
    }
    func configLeftRightGesture() {
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        leftGesture.direction = [.left]
        self.view.addGestureRecognizer(leftGesture)
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        rightGesture.direction = [.right]
        self.view.addGestureRecognizer(rightGesture)
    }
    @objc func closeWindow() {
        self.buttonSoundSoso.play()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func swipeHandler(_ gesture: UISwipeGestureRecognizer) {
        //print(gesture.direction)
        
        switch gesture.direction {
        case .left:
            navigateToNextViewController()
        case .right:
            navigateToPreViewController()
        default:
            break
        }
//
    }
    
    
    func setupMenuBar(){
    
        self.view.addSubview(menuBar)
//        menuBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        menuBar.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0).isActive = true
//        menuBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        menuBar.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        let menuBarHeight:CGFloat = 50
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(menuBarHeight)]", options: [], metrics: ["menuBarHeight":menuBarHeight], views: ["v0":menuBar]))
            
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":menuBar]))
    }
    
//    func setupNavigationSegement() {
//        self.navigationItem.titleView = self.localCloudSegment
//    }
    
}
