//
//  MainContainerExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit


extension MainContainerViewController:MenuBarDelegate {
    
    func onSelected(_ selectedIndex: Int, sender: UIView) {
        Util.printLog("onSelected called:\(selectedIndex)")
        //        updateViews(selectedIndex:selectedIndex)
        self.gotoViewController(selectedIndex)
    }
    
    func navigateToNextViewController() {
        if let selectedIndex = selectedIndex {
            let nextIndex  = selectedIndex + 1
            if nextIndex < self.viewControllerList.count {
                //                gotoViewController(nextIndex)
                self.buttonSoundSoso.play()
                self.menuBar.selectedIndex = nextIndex
                self.selectedIndex = nextIndex
                
            }
        }
    }
    
    func navigateToPreViewController() {
        if let selectedIndex = selectedIndex {
            let nextIndex  = selectedIndex - 1
            if nextIndex >= 0 {
                //gotoViewController(nextIndex)
                self.buttonSoundSoso.play()
                self.menuBar.selectedIndex = nextIndex
                self.selectedIndex = nextIndex
            }
        }
    }
    
    
    func gotoViewController(_ index: Int) {
        if let selectedIndex = selectedIndex, index != selectedIndex {
            self.remove( self.viewControllerList[selectedIndex])
        }
        
        if index < self.viewControllerList.count {
            self.add(self.viewControllerList[index])
            self.title = self.viewControllerList[index].title
            self.selectedIndex = index
            //            self.menuBar.selectedIndex = index
        }
    }
    
    
    private func add(_ viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        // Add Child View as Subview
        view.addSubview(viewController.view)
        // Configure Child View
        //let frame = CGRect(x: 0, y: view.frame.minY + 50, width: view.frame.width, height: view.frame.height)
        
        let frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height )
        
        //viewController.view.frame = view.bounds
        viewController.view.frame =  frame
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(_ viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
}
