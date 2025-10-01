//
//  TabViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/21.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
class HomeTabViewController:UITabBarController {
    
    var boardViewController: BoardViewController
    
    init(_ boardViewController: BoardViewController) {
        self.boardViewController =  boardViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.saveAccessLog("HomeTab",memo:"Access HomeTab")
        setupViewControllers()
    }
    
    func setupViewControllers() {
        
        let mainVC = MainContainerViewController()
        mainVC.boardViewController = self.boardViewController
        let vc1 = UINavigationController(rootViewController: mainVC)
        //vc1.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        //vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
        vc1.tabBarItem.image = UIImage(named: "tabbutton_list")
        vc1.view.backgroundColor = .white
        
        let airVC = AirTransferVC() // AirTransferViewController() // 
        airVC.boardViewController = self.boardViewController
        let airNavVC = UINavigationController(rootViewController:airVC)
        airNavVC.tabBarItem.image = UIImage(named: "tabbutton_air")
//        airNavVC.view.backgroundColor = .white
        
        let vc2 = UINavigationController(rootViewController:SettingTVController())
        vc2.tabBarItem.image = UIImage(named: "tabbutton_setting")
//        vc2.navigationController?.navigationItem.title = "cloud"
//        vc2.title = "Cloud"
        vc2.view.backgroundColor = .white
        
//        let vc3 = UINavigationController(rootViewController:ViewController())
//        //let vc3 = MenuBarVC()
//        //        vc3.tabBarItem = UITabBarItem(title:"Pop",image: UIImage(named:"user"), tag: 1)
//        vc3.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
//
        self.viewControllers = [ vc1,airNavVC,vc2 ]

    }
}
