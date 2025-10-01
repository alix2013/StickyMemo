//
//  KeyboardButtonView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//
import UIKit

protocol KeyboardButtonViewDelegate{
    func onKeyboardButtonSelected(_ keyboardButtonView: KeyboardButtonView, sender: UIButton, selectedIndex: Int)
}

//enum KeyboardButtonLocation{
//    case bottomOfWindow
//    case outsideOfWindow
//}

class KeyboardButtonView: UIView {
    var delegate:KeyboardButtonViewDelegate?
    var identifier:String = ""
    var buttonTitleList:[String]?
    var buttonImageList:[UIImage]?
    var buttonBackgroundColor: UIColor? = .gray
    var buttonTitleColor:UIColor?
    var buttonSpace:CGFloat
    var height: CGFloat = 48
    
    var isShowSeperator:Bool
    var seperatorHeight:CGFloat
    var seperatorColor:UIColor
    
    //    var location: KeyboardButtonLocation
    // bottomOffsetWhenKeyboardShow when keyboard show, buttons offset, -value locate above of keyboard
    //+value = bottom of keyboard
    var bottomOffsetWhenKeyboardShow:CGFloat
    var bottomOffsetWhenKeyboardHide:CGFloat
    var keyboardButtonBottomConstraint:NSLayoutConstraint?
    
    var topMargin:CGFloat
    var bottomMargin:CGFloat
    
    lazy var containerStackView:UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.spacing = self.buttonSpace
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    init(frame: CGRect,height:CGFloat = 48,bottomOffsetWhenKeyboardShow:CGFloat = 0, bottomOffsetWhenKeyboardHide:CGFloat = 0,buttonTitleList:[String]? = nil,buttonImageList:[UIImage]? = nil,buttonTitleColor:UIColor = .black,buttonBackgroundColor:UIColor = .lightGray,buttonSpace:CGFloat = 6, topMargin:CGFloat = 6, bottomMargin:CGFloat = 6, isShowSeperator:Bool = true,seperatorHeight:CGFloat = 0.5, seperatorColor:UIColor =  UIColor(white: 0.5, alpha: 0.5)) {
        self.bottomOffsetWhenKeyboardShow = bottomOffsetWhenKeyboardShow
        self.bottomOffsetWhenKeyboardHide = bottomOffsetWhenKeyboardHide
        self.height = height
        self.buttonTitleList = buttonTitleList
        self.buttonImageList = buttonImageList
        self.buttonTitleColor = buttonTitleColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonSpace = buttonSpace
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        
        self.isShowSeperator = isShowSeperator
        self.seperatorHeight = seperatorHeight
        self.seperatorColor = seperatorColor
        
        super.init(frame: frame)
        setupViews()
        
        setupNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector:  #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            //            print(keyboardFrame)
            let isKeyboradShowing  = notification.name == UIResponder.keyboardWillShowNotification
            
            var offset:CGFloat  = 0
            if isKeyboradShowing {
                offset = self.bottomOffsetWhenKeyboardShow - keyboardFrame.height
            }else {
                offset = self.bottomOffsetWhenKeyboardHide
            }
            keyboardButtonBottomConstraint?.constant = offset
            
            //            if self.location == .outsideOfWindow {
            //                offset = height
            //            }
            //            keyboardButtonBottomConstraint?.constant = isKeyboradShowing ? -keyboardFrame.height : offset
            
            //                textFieldContainerView.layoutIfNeeded()
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.superview?.layoutIfNeeded()
            }, completion: { (completed) in
            })
        }
    }
    
    func setupViews(){
        // for containerStackView
        self.addSubview(containerStackView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":containerStackView]))
        //                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(48)]|", options: [], metrics: nil, views: ["v0":containerStackView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[v0]-bottomMargin-|", options: [], metrics: ["topMargin":topMargin,"bottomMargin":bottomMargin], views: ["v0":containerStackView]))
        
        if isShowSeperator {
            //for top line
            let topBorderView = UIView()
            topBorderView.backgroundColor = self.seperatorColor//UIColor(white: 0.5, alpha: 0.5)
            topBorderView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(topBorderView)
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(seperatorHeight)]", options: [], metrics: ["seperatorHeight":seperatorHeight], views: ["v0":topBorderView]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":topBorderView]))
        }
        //        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(0.5)]-[v1]", options: [], metrics: nil, views: ["v0":topBorderView,"v1":containerStackView]))
        
        
        
        
        
        setupButtons()
        
    }
    
    func setupButtons() {
        
        if let buttonTitleList = self.buttonTitleList {
            for (index,title) in buttonTitleList.enumerated() {
                let v = UIButton()
                
                v.backgroundColor = buttonBackgroundColor
                v.setTitle(title, for: .normal)
                v.setTitleColor(buttonTitleColor, for: .normal)
                
                if let buttonImageList = self.buttonImageList, index < buttonImageList.count {
                    v.setImage(buttonImageList[index], for: .normal)
                }
                v.tag = index
                v.addTarget(self, action: #selector(buttonTap(_ :)), for: .touchUpInside)
                self.addSubview(v)
                containerStackView.addArrangedSubview(v)
            }
        }
        
    }
    
    @objc func buttonTap(_ sender:UIButton) {
        if let delegate = self.delegate {
            delegate.onKeyboardButtonSelected(self, sender: sender, selectedIndex: sender.tag)
        }
    }
    
    
    
    
    func show() {
        if let view = UIApplication.shared.keyWindow {
            self.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":self]))
            
            //            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(48)]", options: [], metrics: nil, views: ["v0":self]))
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(height)]", options: [], metrics: ["height":height], views: ["v0":self]))
            
            let offset:CGFloat = self.bottomOffsetWhenKeyboardHide
            //            if location == .outsideOfWindow {
            //                offset = height
            //            }
            keyboardButtonBottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1, constant: offset)
            view.addConstraint(keyboardButtonBottomConstraint!)
        }
    }
    
    
    func dismiss() {
        self.removeFromSuperview()
    }
}


