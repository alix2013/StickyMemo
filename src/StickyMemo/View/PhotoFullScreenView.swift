//
//  PhotoFullScreenView.swift
//  StickyMemo
//
//  Created by alex on 2017/12/17.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

/*
 
 guard let imageDataList = self.imageDataList else { return }
 
 let imageList = imageDataList.flatMap{ return UIImage(data: $0)}
 
 if let keyWindow = UIApplication.shared.keyWindow {
 let keyframe = keyWindow.convert((cell.frame), from: cell.superview)
 //            print(keyframe)
 
 photoQuickView = PhotoFullScreenView(imageList, currentIndex: indexPath.row, startFrame: keyframe)
 photoQuickView?.show()
 }
 */
class PhotoFullScreenView {
    var imageList:[UIImage]
    var currentIndex:Int
    var startFrame:CGRect
    init(_ imageList:[UIImage], currentIndex:Int, startFrame:CGRect) {
        self.imageList = imageList
        self.currentIndex = currentIndex
        self.startFrame = startFrame
    }
    
    lazy var pageLabel:UILabel = {
        let v = UILabel()
        v.textColor = .white
        return v
    }()
    
    lazy var backView:UIView = {
        let v = UIView()
        v.backgroundColor = .black
        //        v.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler))
        swipeLeftGesture.direction = .left
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGesture.direction = .right
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
        
        let tapImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageViewHandler))
        //        tapImageViewGesture.numberOfTapsRequired = 2
        
        v.gestureRecognizers = [tapGesture,swipeLeftGesture,swipeRightGesture]
        return v
    }()
    
    lazy var imageView: UIImageView  = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler))
        swipeLeftGesture.direction = .left
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGesture.direction = .right
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
        
        let tapImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageViewHandler))
        //        tapImageViewGesture.numberOfTapsRequired = 2
        v.gestureRecognizers = [swipeLeftGesture,swipeRightGesture,pinchGesture,tapImageViewGesture]
        v.isUserInteractionEnabled = true
        return v
    }()
    
    // scale
    @objc func pinchGestureHandler(_ sender:UIPinchGestureRecognizer){
        //        Util.printLog("pinch gesture:\(sender.scale)")
        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
    }
    
    @objc func tapImageViewHandler(sender: UIGestureRecognizer) {
        if self.imageView.transform == CGAffineTransform.identity {
            dismiss()
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform.identity
            })
        }
    }
    
    @objc func swipeLeftHandler(sender: UIGestureRecognizer) {
        if currentIndex < self.imageList.count - 1 {
            currentIndex = currentIndex + 1
            self.imageView.alpha = 0
            self.imageView.image = self.imageList[self.currentIndex]
            //            Util.printLog("left currentIndex:\(currentIndex)")
            UIView.animate(withDuration: 0.65, animations: {
                self.imageView.alpha = 1
                self.pageLabel.text = "\(self.currentIndex + 1)/\(self.imageList.count)"
            }, completion:{ b in
                self.pageLabel.superview?.bringSubviewToFront(self.pageLabel)
            })
        }
    }
    
    
    @objc func swipeRightHandler(sender: UIGestureRecognizer) {
        if currentIndex > 0 {
            currentIndex = currentIndex - 1
            self.imageView.image = self.imageList[currentIndex]
            self.imageView.alpha = 0
            UIView.animate(withDuration: 0.65, animations: {
                self.imageView.alpha = 1
                self.pageLabel.text = "\(self.currentIndex + 1)/\(self.imageList.count)"
            }, completion:{ b in
                self.pageLabel.superview?.bringSubviewToFront(self.pageLabel)
            })
            
        }
    }
    
    @objc func tapHandler() {
        //        Util.printLog("tap handler called")
        dismiss()
    }
    func show() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(backView)
            backView.frame = keyWindow.frame
            backView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            
            keyWindow.addSubview(pageLabel)
            pageLabel.frame = CGRect(x: 20, y: keyWindow.frame.height - 40, width: 100, height: 20)
            pageLabel.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin]
            
            keyWindow.addSubview(imageView)
            imageView.image = self.imageList[currentIndex]
            imageView.frame = startFrame
            UIView.animate(withDuration: 0.75, animations: {
                self.backView.alpha = 1
                self.imageView.frame =  self.getPhotoFrame(keyWindow)
                self.imageView.center = keyWindow.center
                self.imageView.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
                
            }, completion: { b in
                self.pageLabel.text = "\(self.currentIndex + 1)/\(self.imageList.count)"
                self.pageLabel.superview?.bringSubviewToFront(self.pageLabel)
            })
        }
    }
    
    func getPhotoFrame(_ keyWindow: UIWindow) -> CGRect {
        if keyWindow.frame.width < keyWindow.frame.height {
            let width = keyWindow.frame.width //- 4
            let height = width * 6 / 9
            return CGRect(x: width / 2, y: height / 2, width: width, height: height)
        }else{
            let height = keyWindow.frame.height
            let width = height * 9 / 6
            return CGRect(x: width / 2, y: height / 2, width: width, height: height)
        }
    }
    
    func dismiss() {
        self.pageLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.75, animations: {
            self.backView.alpha = 0
            self.imageView.frame = self.startFrame
        }, completion: {b in
            self.backView.removeFromSuperview()
            self.imageView.removeFromSuperview()
            
        })
        
    }
}

