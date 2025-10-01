//
//  MemoViewExtension.swift
//  StickyMemo
//
//  Created by alex on 2017/12/16.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

extension MemoView {
    
    
    //for button move outside of view
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //        let uiview = super.hitTest(point, with: event)
        //        print("hittest",uiview)
        return overlapHitTest(point: point, withEvent: event)
    }
    
    
    func setupGesture(){
        //drap and drop
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        //zoom out/in
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
        
        //        v.addGestureRecognizer(pinchGesture)
        //long tap
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler(_:)))
        //        v.addGestureRecognizer(longPressGestureHandler)
        
        let tap1Gesture = UITapGestureRecognizer(target: self, action: #selector(tap1GestureHandler(_:)))
        tap1Gesture.numberOfTapsRequired = 1
        
        //double tap
        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(tap2GestureHandler(_:)))
        //        tap2Gesture.delegate = self
        tap2Gesture.numberOfTapsRequired = 2
        //        view.addGestureRecognizer(tapGR)
        
        // for rotate
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateGestureHandler(_:)))
        //        v.addGestureRecognizer(longPressGestureHandler)
        
//        //for swip gesture
//        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeHandler(_:)))
//        leftSwipeGesture.direction = .left
////        v.addGestureRecognizer(leftSwipeGesture)
//        
//        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeHandler(_:)))
//        rightSwipeGesture.direction = .right
////        v.addGestureRecognizer(rightSwipeGesture)
        
        self.gestureRecognizers = [panGesture,pinchGesture,longPressGesture,tap1Gesture,tap2Gesture,rotateGesture]
        
    }
    
    
    @objc func rotateGestureHandler(_ sender : UIRotationGestureRecognizer){
        //        self.superview?.bringSubview(toFront: self)
        ////        sender.view?.transform = (sender.view?.transform.rotated(by: sender.rotation))!
        //        var originalRotation = CGFloat()
        //        if sender.state == .began {
        //            sender.rotation = lastRotation
        //            originalRotation = sender.rotation
        //        } else if sender.state == .ended {
        //            // Save the last rotation
        //            lastRotation = sender.rotation
        //            if let delegate = delegate {
        //                delegate.locationChanged(x: self.frame.minX, y: self.frame.minY, width: nil, height: nil, rotate: lastRotation)
        //            }
        //        }
        //        else if sender.state == .changed {
        //            let newRotation = sender.rotation + originalRotation
        //            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        //
        //        }
        //        //print("last rotation:\(lastRotation)")
    }
    
    
    @objc func tap1GestureHandler(_ sender:UITapGestureRecognizer) {
        //        print("tap1GestureHandler called")
        
        self.superview?.bringSubviewToFront(self)
        //        if let v = sender.view,(v.frame.width < minWidth || v.frame.height < minHeight) {
        //            v.transform = v.transform.scaledBy(x: 1.5, y: 1.5)
        //            if let delegate = delegate {
        //                delegate.locationChanged(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.frame.height, rotate: nil)
        //            }
        //        }
        
    }
    
    @objc func tap2GestureHandler(_ sender:UITapGestureRecognizer) {
        self.superview?.bringSubviewToFront(self)
        //        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: 1.5, y: 1.5)
        if let delegate = delegate {
            delegate.doubleTapActionMemoViewDelegate(self)
        }
        
    }
    
    @objc func longPressGestureHandler(_ sender:UILongPressGestureRecognizer){
        self.superview?.bringSubviewToFront(self)
        if let delegate = delegate {
            if !self.isEditable {
                delegate.longTapActionMemoViewDelegate(self)
            }
        }
    }
    
    
    
    @objc func pinchGestureHandler(_ sender:UIPinchGestureRecognizer){
        //        print("pinch gesture:\(sender.scale)")
//        self.superview?.bringSubview(toFront: self)
        //如果用下面方法  先缩放再拖拽回再次变大，模拟器没有问题，实体机器有问题
        //        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
        //        sender.scale = 1.0
        
        switch sender.state {
        case .began:
            originalFrameCenter = self.center
            self.superview?.bringSubviewToFront(self)
        case .changed:
            if  let direction = getPinchDirection(sender) {
                var x:CGFloat = 1.0
                var y:CGFloat = 1.0
                switch direction {
                case .horizon:
                    x = sender.scale
                case .vertical :
                    y = sender.scale
                case .both:
                    x = sender.scale
                    y = sender.scale
                }
                
                var minWidth = self.minWidthInNoneEditing
                var minHeight = self.minHeightInNoneEditing
                if self.isEditable {
                    minWidth = self.minWidthInEditing
                    minHeight = self.minHeightInEditing
                }
            
                let width  = self.frame.width * x < minWidth ? minWidth : self.frame.width * x
                let height = self.frame.height * y < minHeight ? minHeight : self.frame.height * y
                self.frame = CGRect(x: 0, y: 0, width:width, height: height)
                self.center = originalFrameCenter
                sender.scale = 1.0
                
                
            }
            
            //            self.frame = CGRect(x: 0, y: 0, width: self.frame.width * sender.scale, height: self.frame.height * sender.scale)
            //            self.center = originalFrame
        //            sender.scale = 1.0
        case .ended:
            if let delegate = delegate {
                //                delegate.positionChanged(self,x: self.frame.minX, y: self.frame.minY, width: positionChanged, height: nil, rotate: nil)
                delegate.positionChangedMemoViewDelegate(self,x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.frame.height, rotate: nil)
            }
        default:
            break
        }
        
        //        if sender.state == .began {
        //           originalFrame = self.center
        //            return
        //        }
        //
        //        self.frame = CGRect(x: 0, y: 0, width: self.frame.width * sender.scale, height: self.frame.height * sender.scale)
        //        self.center = originalFrame
        //        sender.scale = 1.0
        //        if  let direction = getPinDirection(sender) {
        //            var x:CGFloat = 1.0
        //            var y:CGFloat = 1.0
        //
        //            switch direction {
        //            case .horizon :
        //                x = sender.scale
        //            case .vertical :
        //                y = sender.scale
        //            case .both :
        //                x = sender.scale
        //                y = sender.scale
        //
        //            }
        //            sender.view?.transform = (sender.view?.transform)!.scaledBy(x: x, y: y)
        //            sender.scale = 1.0
        
        //            self.layoutIfNeeded()
        
        //}
        //      print("pinchGestureHandler numberoftouch:\(sender.numberOfTouches)")
        
    }
    
//    var isCanMove: Bool = true
    //drag and drop
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        //        print("PanGesture: \(String(describing: sender.view?.center))")
        //        print("senter view:-------\(type(of:sender.view))")
//        if self.isEditable {
//            return
//        }
//        self.superview?.bringSubview(toFront: self)
        
        switch sender.state {
        case .began :
            self.superview?.bringSubviewToFront(self)
            //            print("--------Begin")
            break
        case .changed:
            
            let translation = sender.translation(in: self)
            var centerX = (self.center.x) + translation.x
            var centerY = (self.center.y) + translation.y
            
            (centerX,centerY) = getCenterXY(self,centerX: centerX,centerY: centerY)
            
            if  isOutside() {
                showTrash()
                
            }else{
                hideTrash()
            }
            if self.isEditable { // did not allow horizon move to avoid swipe gesture conflict
                centerX = self.center.x
            }
            self.center = CGPoint(x: centerX, y: centerY)
            //            self.center = CGPoint(x: (self.center.x) + translation.x, y: (self.center.y) + translation.y)
            sender.setTranslation(.zero, in: self)
            
        case .ended:
            if let delegate = delegate {
                delegate.positionChangedMemoViewDelegate(self,x: self.frame.minX, y: self.frame.minY, width: nil, height: nil, rotate: nil)
                
                if isOutside() {
                    delegate.deleteActionMemoViewDelegate(self)
                }
            }
        default:
            break
        }
        
    }
    
    private func getCenterXY(_ memoView: MemoView, centerX:CGFloat,centerY:CGFloat) -> ( newCenterX:CGFloat, newCenterY:CGFloat) {
        var x = centerX
        var y = centerY
        
        if x < 10 {
            x = 10
        }
        if y < 10 {
            y = 10
        }
        
        if let w = memoView.superview?.frame.width {
            if x > w - 10 {
                x = w - 10
            }
        }
        
        if let height = memoView.superview?.frame.height {
            if y > height - 10 {
                y = height - 10
            }
        }
        return (x,y)
        
    }
    
    func showTrash() {
        self.trashImageView.isHidden = false
        let rect = getFrameForTrash()
        self.superview?.addSubview(self.trashImageView)
        self.trashImageView.isHidden = false
        
        //        let centerPoint = CGPoint(x: (rect.minX + rect.width / 2), y: (rect.minY + rect.height / 2))
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width / 3
        let height = rect.height / 3
        
        trashImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        trashImageView.center = centerPoint
        
    }
    
    func hideTrash() {
        self.trashImageView.isHidden = true
        self.trashImageView.removeFromSuperview()
    }
    
    fileprivate func isOutside() -> Bool{
        if let bounds = self.superview?.bounds {
            let interRect  = self.frame.intersection(bounds)
            if interRect.width * interRect.height < (self.frame.width * self.frame.height) / 3 * 2 {
//            if interRect.width * interRect.height < (self.frame.width * self.frame.height) / 3 * 1 {
                return true
            }
        }
        return false
    }
    
    fileprivate func getFrameForTrash() -> CGRect {
        if let bounds = self.superview?.bounds {
            let interRect  = self.frame.intersection(bounds)
            //            let interRect  = bounds.intersection(self.frame)
            //            print("=====interRect=\(interRect)")
            return interRect
        }
        return CGRect.zero
    }
    
    
    /*
     fileprivate func moveOutside() {
     
     if let bounds = self.superview?.bounds {
     let interRect  = self.frame.intersection(bounds)
     if interRect.width * interRect.height < (self.frame.width * self.frame.height) / 3 * 2 {
     //                print("=========out=======")
     if let delegate = delegate {
     delegate.moveToOutside(self)
     }
     }
     
     }
     
     }
     */
    /*
     @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
     //        print("PanGesture: \(String(describing: sender.view?.center))")
     //        print("senter view:-------\(type(of:sender.view))")
     self.superview?.bringSubview(toFront: self)
     //        let translation = sender.translation(in: self)
     //        let translation = sender.translation(in: self.superview)
     let translation = sender.translation(in: self)
     
     //        sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
     //        if let v = sender.view {
     //            v.center = CGPoint(x: (v.center.x) + translation.x, y: (v.center.y) + translation.y)
     //        }
     
     self.center = CGPoint(x: (self.center.x) + translation.x, y: (self.center.y) + translation.y)
     sender.setTranslation(.zero, in: self)
     
     if sender.state == .ended {
     // Save the last rotation
     
     if let delegate = delegate {
     delegate.locationChanged(x: self.frame.minX, y: self.frame.minY, width: nil, height: nil, rotate: nil)
     }
     }
     }
     
     */
    
    
    /*
     func getPinDirectionFromPoints(_ p1: CGPoint, _ p2: CGPoint) -> PinDirection {
     let absolutePoint = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
     
     let radians = atan2(Double(absolutePoint.x), Double(absolutePoint.y))
     
     let absRad = fabs(radians)
     
     if absRad > .pi / 4 && absRad < 3 * .pi / 4 {
     return .X
     } else {
     return .Y
     }
     }*/
    
    
    func getPinchDirection(_ sender: UIPinchGestureRecognizer) -> PinchDirection? {
        
        if sender.numberOfTouches != 2 {
            return nil
        }
        
        let pointA = sender.location(ofTouch: 0, in: nil)
        let pointB = sender.location(ofTouch: 1, in: nil)
        
        let xD = abs( pointA.x - pointB.x )
        let yD = abs( pointA.y - pointB.y )
        if (xD == 0) { return .vertical }
        if (yD == 0) { return .horizon }
        let ratio = xD / yD
        // print(ratio)
        if (ratio > 2) { return .horizon  }
        if (ratio < 0.5) { return .vertical }
        return .both
        
    }
    
    func save() {
        if let s = self.textFieldView.text {
            self.memo.subject = s
        }
        self.memo.body = self.textView.text
        
        self.memo.save()
    }
    
    func savePosition() {
        self.memo.savePosition()
    }
    

    
}
