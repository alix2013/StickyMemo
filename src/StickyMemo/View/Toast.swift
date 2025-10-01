//
//  Toast.swift
//  StickyMemo
//
//  Created by alex on 2018/1/4.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

enum  ToastLocation {
    case auto
    case bottom
    case center
    case top
    
}

class Toast{
    
    var toastLabel : UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.backgroundColor = UIColor(red: 74/256, green: 144/256, blue: 226/256, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textColor = UIColor.white
        v.textAlignment = NSTextAlignment.center;
        v.lineBreakMode = .byWordWrapping
        v.alpha = 1.0
        //toastLabel.layer.cornerRadius = 10;
        v.layer.cornerRadius = 10
        v.clipsToBounds  =  true
        return v;
    }()
    
    func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    func displayMessageAtCenter(_ message: String, duration: Double=4, backgroudColor:UIColor = UIColor(red: 74/256, green: 144/256, blue: 226/256, alpha: 1), textColor: UIColor = UIColor.white,completeHandler:(() -> Void)?) {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            let realDuration = duration
            toastLabel.text = message
            toastLabel.backgroundColor = backgroudColor
            toastLabel.textColor = textColor
            
            let size = toastLabel.intrinsicContentSize
            keyWindow.addSubview(toastLabel)
            
            var height: CGFloat
            var width: CGFloat
            
            if size.width > keyWindow.frame.size.width { //if line wrap
                let multiplier = size.width / keyWindow.frame.size.width + 3.0
                height = size.height*multiplier
                width = keyWindow.frame.size.width - 40
            }else{
                width = size.width + 20.0
                height = size.height + 20.0
            }
            
            
            let centerXConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.centerX,
                                                        relatedBy: NSLayoutConstraint.Relation.equal, toItem: keyWindow,
                                                        attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0  )
            
            let centerYConstraint  = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutConstraint.Attribute.centerY,
                                                        relatedBy: NSLayoutConstraint.Relation.equal, toItem: keyWindow,
                                                        attribute: NSLayoutConstraint.Attribute.centerY,multiplier: 1.0, constant: 0 )
            
            let widthContraint = NSLayoutConstraint(item: toastLabel, attribute: .width, relatedBy: .equal, toItem:nil,
                                                    attribute: .notAnAttribute, multiplier: 1.0, constant: width )
            let heightContraint = NSLayoutConstraint(item: toastLabel, attribute: .height, relatedBy: .equal, toItem: nil,
                                                     attribute: .notAnAttribute, multiplier: 1.0, constant: height )
            
            keyWindow.addConstraints( [centerXConstraint, centerYConstraint,widthContraint,heightContraint] )
            
            UIView.animate(withDuration: realDuration, delay: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
                self.toastLabel.alpha = 0.0
            }, completion: { b in
                self.toastLabel.removeFromSuperview()
                completeHandler?()
                
            } )
            
        }
        
    }
    
    func displayMessageAtBottom(_ message: String, duration: Double=4, backgroudColor:UIColor = UIColor(red: 74/256, green: 144/256, blue: 226/256, alpha: 1), textColor: UIColor = UIColor.white,completeHandler:(() -> Void)?) {
        
        if let keyWindow = UIApplication.shared.keyWindow, let viewController = getTopViewController() {
            var isTabbarHidden = false
            let realDuration = duration
            toastLabel.text = message
            toastLabel.backgroundColor = backgroudColor
            toastLabel.textColor = textColor
            toastLabel.layer.cornerRadius = 5
            
            let size = toastLabel.intrinsicContentSize
            keyWindow.addSubview(toastLabel)
            
            var height: CGFloat
            
            if let tabBarController = viewController.tabBarController  { //if tabBar exist,hiden
                //                tabBarController.tabBar.isHidden = true
                //                isTabbarHidden =  true
                // if current viewController show tabBar, hiden it first, show it after toast msg show
                if !tabBarController.tabBar.isHidden {
                    tabBarController.tabBar.isHidden = true
                    isTabbarHidden =  true
                }
            }
            
            if size.width > keyWindow.frame.size.width  {
                let multiplier = size.width / viewController.view.frame.size.width + 1.0
                height = size.height*multiplier
                
            }else {
                height = size.height * 1.5
            }
            
            let topConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.top,
                                                    relatedBy: NSLayoutConstraint.Relation.equal, toItem: keyWindow,
                                                    attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0 - height )
            
            let bottomConstraint  = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutConstraint.Attribute.bottom,
                                                       relatedBy: NSLayoutConstraint.Relation.equal, toItem: keyWindow,
                                                       attribute: NSLayoutConstraint.Attribute.bottom,multiplier: 1.0, constant: 0 )
            
            let leftConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.left,
                                                     relatedBy: NSLayoutConstraint.Relation.equal,toItem: keyWindow,
                                                     attribute: NSLayoutConstraint.Attribute.left,multiplier: 1.0,constant: 0 )
            
            let rightConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.right,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,toItem: keyWindow,
                                                      attribute: NSLayoutConstraint.Attribute.right,multiplier: 1.0,constant: 0 )
            keyWindow.addConstraints([ topConstraint,bottomConstraint,leftConstraint,rightConstraint  ] )
            
            UIView.animate(withDuration: realDuration, delay: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
                self.toastLabel.alpha = 0.0
            }, completion: { b in
                self.toastLabel.removeFromSuperview()
                if isTabbarHidden, let tabBarController = viewController.tabBarController  {
                    tabBarController.tabBar.isHidden = false
                }
                completeHandler?()
                
            } )
            
        }
        
    }
    
    
    func displayMessageAtTop(_ message: String, duration: Double=4, backgroudColor:UIColor = UIColor(red: 74/256, green: 144/256, blue: 226/256, alpha: 1), textColor: UIColor = UIColor.white,completeHandler:(() -> Void)?) {
        
        if let keyWindow = UIApplication.shared.keyWindow, let viewController = getTopViewController() {
            
            let realDuration = duration
            toastLabel.text = message
            toastLabel.backgroundColor = backgroudColor
            toastLabel.textColor = textColor
            toastLabel.layer.cornerRadius = 5
            
            let size = toastLabel.intrinsicContentSize
            keyWindow.addSubview(toastLabel)
            
            var height: CGFloat
            
            var adjustPos = CGFloat(0)
            
            if let nav = viewController.navigationController {
                adjustPos = adjustPos + nav.navigationBar.frame.height
                
            }
            
            if size.width > keyWindow.frame.size.width  {
                let multiplier = size.width / keyWindow.frame.size.width + 1.0
                height = size.height*multiplier
            }else {
                height = size.height * 1.5
            }
            
            //status bar
            let topPos = adjustPos + UIApplication.shared.statusBarFrame.size.height
            
            let topConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.top,
                                                    relatedBy: NSLayoutConstraint.Relation.equal, toItem: keyWindow,
                                                    attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant:  topPos )
            
            let leftConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.left,
                                                     relatedBy: NSLayoutConstraint.Relation.equal,toItem: keyWindow,
                                                     attribute: NSLayoutConstraint.Attribute.left,multiplier: 1.0,constant: 0 )
            
            let rightConstraint  = NSLayoutConstraint(item: toastLabel,attribute: NSLayoutConstraint.Attribute.right,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,toItem: keyWindow,
                                                      attribute: NSLayoutConstraint.Attribute.right,multiplier: 1.0,constant: 0 )
            
            let heightContraint = NSLayoutConstraint(item: toastLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height )
            
            keyWindow.addConstraints([ topConstraint,leftConstraint,rightConstraint ,heightContraint ] )
            
            
            UIView.animate(withDuration: realDuration, delay: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
                self.toastLabel.alpha = 0.0
            }, completion: { b in
                self.toastLabel.removeFromSuperview()
                completeHandler?()
                
            } )
            
        }
    }
    
    func displayMessage(_ message: String, duration: Double=4, location: ToastLocation = .auto, backgroudColor:UIColor = UIColor(red: 74/256, green: 144/256, blue: 226/256, alpha: 1), textColor: UIColor = UIColor.white,completeHandler:(() -> Void)?) {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            toastLabel.text = message
            let size = toastLabel.intrinsicContentSize
            // if label content length > view width show at bottom, else show at view center
            //let realDuration = 8.0
            if size.width > keyWindow.frame.size.width  { //calc height a
                //displayMessageAtBottom(message, duration:realDuration , completeHandler: completeHandler)
                displayMessageAtBottom(message, duration: duration, backgroudColor: backgroudColor, textColor: textColor, completeHandler: completeHandler)
                
            }else {
                displayMessageAtCenter(message, duration: duration, backgroudColor: backgroudColor, textColor: textColor, completeHandler: completeHandler)
            }
        }
    }
    
}

