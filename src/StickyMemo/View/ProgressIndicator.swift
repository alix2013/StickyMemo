//
//  ProgressIndicator.swift
//  StickyMemo
//
//  Created by alex on 2018/1/5.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

enum  ProgressIndicatorStyle {
    case small
    case large
    case withMessage
    case animationImages
}

class ProgessIndicator {
    var style: ProgressIndicatorStyle = .small
    
    var defaultSmallIndictorWidth : CGFloat = CGFloat(30)
    var defaultSmallIndictorHeight : CGFloat = CGFloat(30)
    
    var defaultLargeIndictorWidth : CGFloat = CGFloat(50)
    var defaultLargeIndictorHeight : CGFloat = CGFloat(50)
    
    var isRunning : Bool =  false
    var indicatorView : UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    var parentIndicatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = .lightGray
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()
    
    var indicatorColor: UIColor = .white
    var message: String?
    var messageColor: UIColor = .white
    //if backgroundColor == .clear,  no backgroundColor
    var backgroundColor : UIColor = .gray
    
    var indicatorImageView: UIImageView = UIImageView()
    
    var animationImageWidth: CGFloat = CGFloat(50)
    var animationImageHeight: CGFloat = CGFloat(33)
    
    
    init(style: ProgressIndicatorStyle = .large, indicatorColor: UIColor = .white, backgroundColor: UIColor = .gray ) {
        self.style = style
        //self.message = message
        self.indicatorColor = indicatorColor
        self.backgroundColor = backgroundColor
    }
    
    init(message: String? ,indicatorColor: UIColor = .white, backgroundColor: UIColor = .gray, messageColor: UIColor = .white ) {
        self.style = .withMessage
        self.message = message
        self.messageColor = messageColor
        self.indicatorColor = indicatorColor
        self.backgroundColor = backgroundColor
    }
    
    init(style: ProgressIndicatorStyle, animationImages:[UIImage],  animationImageWidth: CGFloat = 50, animationImageHeight: CGFloat = 33, animationDuration: Double = 2.0 , animationRepeatCount: Int = 100  ) {
        self.style = style
        self.indicatorImageView =  UIImageView(frame: CGRect(x: 0, y: 0 , width: animationImageWidth, height: animationImageHeight))
        self.indicatorImageView.animationImages = animationImages
        self.indicatorImageView.animationDuration = animationDuration
        self.animationImageWidth = animationImageWidth
        self.animationImageHeight = animationImageHeight
    }
    
    
    
    
    
    
    func setAnimationImages(_ images: [UIImage]) {
        self.indicatorImageView.animationImages = images
    }
    
    func setMessage(_ message: String?) {
        self.style = .withMessage
        self.message = message
    }
    
    
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
    
    
    func start() {
        if let keyWindow = UIApplication.shared.keyWindow {
            
            var parentViewWidth = defaultSmallIndictorWidth
            var parentViewHeight = defaultSmallIndictorHeight
            
            switch self.style {
            case .small :
                indicatorView.style = .white
                parentIndicatorView.layer.cornerRadius = 5
                
            case .large :
                //indicatorView  = UIActivityIndicatorView()
                indicatorView.style = .whiteLarge
                parentViewWidth = defaultLargeIndictorWidth
                parentViewHeight = defaultLargeIndictorHeight
                parentIndicatorView.layer.cornerRadius = 10
                
            case .animationImages:
                
                if let images = self.indicatorImageView.animationImages, images.count == 0 {
                    return
                }
                
                //no backuground color for image
                parentIndicatorView.backgroundColor = .clear
                
                parentViewWidth = self.animationImageWidth
                parentViewHeight = self.animationImageHeight
                
                parentIndicatorView.addSubview(indicatorImageView)
                //keyWindow.addSubview(indicatorParentView)
                indicatorImageView.startAnimating()
                
            case .withMessage:
                
                if let msg = self.message {
                    let msgLabel = UILabel()
                    msgLabel.textColor = self.messageColor
                    msgLabel.textAlignment = .center
                    msgLabel.numberOfLines = 0
                    //msgLabel.backgroundColor = .clear
                    msgLabel.text = msg
                    msgLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    let size = msgLabel.intrinsicContentSize
                    
                    var height: CGFloat
                    var width: CGFloat
                    
                    if size.width > keyWindow.frame.size.width { //if line wrap
                        let multiplier = size.width / keyWindow.frame.size.width + 2.0
                        height = size.height*multiplier
                        width = keyWindow.frame.size.width - 40
                    }else{
                        width = size.width + 20.0
                        height = size.height + 20.0
                    }
                    
                    parentIndicatorView.addSubview(msgLabel)
                    //msgLabel.backgroundColor = .yellow
                    
                    msgLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                    msgLabel.heightAnchor.constraint(equalToConstant:height).isActive = true
                    msgLabel.bottomAnchor.constraint(equalTo: parentIndicatorView.bottomAnchor).isActive = true
                    msgLabel.centerXAnchor.constraint(equalTo: parentIndicatorView.centerXAnchor).isActive = true
                    
                    
                    indicatorView.style = .whiteLarge
                    parentIndicatorView.layer.cornerRadius = 10
                    
                    parentViewWidth = width //+ defaultLargeIndictorWidth
                    parentViewHeight = height + defaultLargeIndictorHeight
                    parentIndicatorView.addSubview(indicatorView)
                    indicatorView.bottomAnchor.constraint(equalTo: msgLabel.topAnchor).isActive = true
                    indicatorView.centerXAnchor.constraint(equalTo: parentIndicatorView.centerXAnchor).isActive = true
                    //indicatorView.widthAnchor.constraint(equalToConstant: defaultLargeIndictorWidth)
                    //indicatorView.heightAnchor.constraint(equalToConstant: defaultLargeIndictorHeight)
                    
                    indicatorView.color = self.indicatorColor
                    parentIndicatorView.backgroundColor = self.backgroundColor
                    indicatorView.startAnimating()
                    
                }
                
            }
            
            if self.style == .small || self.style == .large {
                
                indicatorView.color = self.indicatorColor
                parentIndicatorView.backgroundColor = self.backgroundColor
                
                parentIndicatorView.addSubview(indicatorView)
                
                indicatorView.centerXAnchor.constraint(equalTo: parentIndicatorView.centerXAnchor).isActive = true
                indicatorView.centerYAnchor.constraint(equalTo: parentIndicatorView.centerYAnchor).isActive = true
                indicatorView.startAnimating()
            }
            
            
            //add parentView
            keyWindow.addSubview(parentIndicatorView)
            
            parentIndicatorView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true
            parentIndicatorView.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
            parentIndicatorView.widthAnchor.constraint(equalToConstant: parentViewWidth).isActive = true
            parentIndicatorView.heightAnchor.constraint(equalToConstant: parentViewHeight).isActive = true
            
            self.isRunning = true
            
        }
    }
    
    func stop() {
        if isRunning {
            if self.indicatorView.isAnimating {
                self.indicatorView.stopAnimating()
                self.indicatorView.removeFromSuperview()
                
            }else {
                self.indicatorImageView.stopAnimating()
                self.indicatorImageView.removeFromSuperview()
            }
            self.parentIndicatorView.removeFromSuperview()
        }
    }
    
}


