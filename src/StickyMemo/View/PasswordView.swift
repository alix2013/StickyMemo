//
//  PasswordView.swift
//  StickyMemo
//
//  Created by alex on 2018/1/31.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol PasswordViewDelegate {
    func authPassword(_ password:String) -> Bool
    func setPassword(_ password:String)
    
}

protocol PasswordViewAuthCompleteDelegate{
    func onAuthComplete()
}


enum PasswordViewStyle{
    case setPassword
    case authPassword
}

class PasswordView {
    
    let i18n_authPasswordTitle:String = Appi18n.i18n_authPasswordTitle //"Input password"
    let i18n_setPasswordTitle:String = Appi18n.i18n_setPasswordTitle //"Input new password"
    let i18n_wrongPassword:String = Appi18n.i18n_wrongPassword // "Password is invalid"
    let i18n_inputAgain:String = Appi18n.i18n_inputPasswordAgain //"Input again"
    let i18n_inputDifference:String = Appi18n.i18n_inputPasswordDifference //"2 passwords are different,re-input"
    let i18n_setpasswordSuccess = Appi18n.i18n_setpasswordSuccess //"password set success!"
    
    var openDoorSpecialPassword:[String] = []
    var specialPassword:String{
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let dateInFormat = dateFormatter.string(from: Date())
            return dateInFormat
        }
    }
    
    var style:PasswordViewStyle
    var delegate:PasswordViewDelegate?
    var authCompleteDelegate:PasswordViewAuthCompleteDelegate?
    
    var firstPasswordString: String = ""
    var passwordText:[String] = [] {
        didSet{
            Util.printLog("Set passwordText:\(passwordText)")
            let count = passwordText.count
            Util.printLog("fillpassword count :\(count)")
            
            //clear all first
            for v in  self.passwordCircleViewList {
                v.backgroundColor = .clear
            }
            
            //fill 0-count
            var i: Int = 0
            while i <= count - 1 {
                self.passwordCircleViewList[i].backgroundColor =  AppDefault.themeColor //.yellow
                i = i + 1
            }
            
            //authentication
            if count >= 4 {
                let finalPassword = self.passwordText.reduce("", {$0+$1})
                
                switch self.style {
                case .authPassword:
                    
                    if self.authPassword(finalPassword) {
                        //                        self.passwordText.removeAll()
                        self.dismiss()
                    }else{
                        animateWrongPassword()
                        //                        self.passwordText.removeAll()
                    }
                case .setPassword:
                    
                    if self.firstPasswordString == "" {
                        self.firstPasswordString = finalPassword
                        //input again
                        self.clearAllPassword()
                        self.messageLabel.text = i18n_inputAgain
                        
                    }else{
                        if self.firstPasswordString == finalPassword {
                            
                            self.messageLabel.text = i18n_setpasswordSuccess
                            self.setPassword(finalPassword)
                            self.dismiss()
                        }else{
                            self.messageLabel.text = i18n_inputDifference
                            self.firstPasswordString = ""
                            //                            self.passwordText.removeAll()
                            //                            self.clearAllPassword()
                            animateWrongPassword()
                        }
                    }
                }
            }
        }
    }
    
    //for fingerprint
    var isFingerprintEnabled:Bool
//    {
//        didSet{
//            self.fingerPrintButton.isHidden = isFingerprintEnabled
//        }
//    }
    
    //    var identifier: String = "" //for multiple instance
    var buttonCount: Int = 10
    var buttonWidthHeight:CGFloat {
        return minScreenWidth > 500 ? 200 : 150
    } //= 150 //65 //50
    //半径
    
    var minScreenWidth:CGFloat{
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    
    var stackViewOffset:CGFloat {
        return popRadius * 0.75
    }
    
    //    lazy var popRadius:CGFloat =  buttonWidthHeight * 1.68 // 2.5
    var popRadius:CGFloat  {
        if minScreenWidth < 350 { //iphone 5/5s
            return 245
        }
        return minScreenWidth < 500 ? 300 : 450
    }
    
    var childButonScaleSize:CGFloat = 0.5 //0.75
    
    //第一个childButton开始的水平夹角
    //startOffsetDegree, startDegree default is 0, for bottomCenter and topCenter 30 is better
    // every degree == (90 - 2*startOffsetDegree)/(buttonCount - 1) or (180 - 2*startOffsetDegree)/(buttonCount - 1)
    // 2 is 开始+结尾的夹角部分
    var startOffsetDegree:Double = 0
    
    var isShowBorder:Bool = true
    var borderColor:UIColor = .white
    
    var childButtonBackgroundColor: UIColor = .clear
    var mainButtonBackgroundColor:UIColor = .clear //.red
    
    var mainButtonImage:UIImage?
    var mainButtonSelectedImage:UIImage?
    
    var childButtonImageList:[UIImage]?
    var childButtonSelectedImageList:[UIImage]?
    
    var mainButtonTitle:String? = nil
    var childButtonTitleList:[String]? = ["0","1","2","3","4","5","6","7","8","9"]
    
    private var isShowing:Bool = false
    
    private lazy var dismissButton:UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        v.setTitle("X", for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonDismissTap), for: .touchUpInside)
        v.setTitleColor(.white, for: .normal)
        return v
    }()
    
    private let messageLabel:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .center
        v.textColor = .white
        return v
    }()
    
    private lazy var mainButton : UIButton = {
        // let btn = UIButton.createButton("tabbar_compose_icon_add", bgImageName: "tabbar_compose_button")
        let btn = UIButton()
        //        btn.setTitle("💀", for: .normal)
        
        if let image = self.mainButtonImage {
            btn.setImage(image, for: .normal)
        }
        if let image = self.mainButtonSelectedImage {
            btn.setImage(image, for: .selected)
        }
        
        //        btn.setTitle("++", for: .normal)
        if let title = self.mainButtonTitle {
            btn.setTitle(title, for: .normal)
        }
        //        btn.setTitle(self.mainButtonTitle, for: .normal)
        
        btn.backgroundColor = self.mainButtonBackgroundColor
        btn.sizeToFit()
        btn.layer.cornerRadius = buttonWidthHeight / 2
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints =  false
        btn.addTarget(self, action: #selector(mainButtonClick), for: .touchUpInside)
        
        //        if self.isShowBorder {
        //            btn.layer.borderColor = self.borderColor.cgColor //UIColor.white.cgColor
        //            btn.layer.borderWidth = 2
        //        }
        
        //        btn.isHidden = true
        return btn
    }()
    
    
    lazy var buttonList: [UIButton] = {
        var btns = [UIButton]()
        for i in 0..<self.buttonCount {
            let btn = UIButton()
            
            //btn.setImage(UIImage(named: "home"), for: .normal)
            if let imageList = self.childButtonImageList,  i < imageList.count   {
                let image = imageList[i]
                btn.setImage(image, for: .normal)
            }
            
            if let imageList = self.childButtonSelectedImageList,  i < imageList.count   {
                let image = imageList[i]
                btn.setImage(image, for: .selected)
            }
            
            if let childButtonList = self.childButtonTitleList,  i < childButtonList.count {
                //                btn.setTitle("+", for: .normal)
                let title = childButtonList[i]
                //                btn.setTitle(title, for: .normal)
                let attributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 80), NSAttributedString.Key.foregroundColor:UIColor.white ])
                btn.setAttributedTitle(attributedString, for: .normal)
            }
            
            btn.backgroundColor = self.childButtonBackgroundColor
            btn.sizeToFit()
            btn.layer.cornerRadius = buttonWidthHeight / 2
            btn.clipsToBounds = true
            
            if self.isShowBorder {
                btn.layer.borderColor = self.borderColor.cgColor //UIColor.white.cgColor
                btn.layer.borderWidth =  4  //2
            }
            
            btn.isHidden = true
            btn.translatesAutoresizingMaskIntoConstraints =  false
            btn.tag = i
            btn.addTarget(self, action: #selector(childButtonClick), for: .touchUpInside)
            btns.append(btn)
        }
        return btns
    }()
    
    
    // all views container View
    let fullscreenView:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()
    
    //for location close door
    let centerVerticalLine:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(1)
        return v
    }()
    
    var passwordCircleViewList:[UIView] = []
    
    //for animate passwordCircle
    var stackViewCenterYConstraint:NSLayoutConstraint?
    
    var passwordStackView:UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.spacing = 30
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    let leftDoorView:UIView = {
        let v = UIView(frame:UIScreen.main.bounds)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 237/255, green: 45/255, blue: 35/255, alpha: 1) //UIColor.black.withAlphaComponent(0.9) // UIColor(white:0, alpha:0.9) //
        return v
    }()
    
    let rightDoorView:UIView = {
        let v = UIView(frame:UIScreen.main.bounds)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 237/255, green: 45/255, blue: 35/255, alpha: 1) // UIColor.red.withAlphaComponent(0.9) //.red //UIColor(white:0, alpha:0.9) //
        return v
    }()
    
    var leftDoorOpenConstraint:NSLayoutConstraint?
    var leftDoorCloseConstraint:NSLayoutConstraint?
    
    var rightDoorOpenConstraint:NSLayoutConstraint?
    var rightDoorCloseConstraint:NSLayoutConstraint?
    
    lazy var fingerPrintButton:UIButton = {
        let b = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        b.setImage(UIImage(named:"button_fingerprint")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.addTarget(self, action: #selector(fingerPrintButtonHandler), for: .touchUpInside)
        b.tintColor = AppDefault.themeColor //UIColor(red: 18/255, green: 157/255, blue: 226/255, alpha: 1)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    init(_ style:PasswordViewStyle = .authPassword,isFingerprintEnabled:Bool = false,
         mainButtonTitle:String? = nil, childButtonTitleList:[String]? = nil , mainButtonImage:UIImage? = nil, childButtonImageList:[UIImage]? = nil, childButtonSelectedImageList:[UIImage]? = nil,mainButtonBackgroundColor:UIColor = .clear,childButtonBackgroundColor:UIColor = .clear ) {
        
        self.style = style
        self.isFingerprintEnabled = isFingerprintEnabled
        if self.style == .setPassword {
            self.isFingerprintEnabled  = false
        }
        if mainButtonImage != nil {
            self.mainButtonImage = mainButtonImage
        }else{
            self.mainButtonImage = UIImage(named:"button_doorlock")
        }
        
        
        self.mainButtonTitle = mainButtonTitle
        //        self.childButtonTitleList = childButtonTitleList
        
        
        self.childButtonImageList = childButtonImageList
        self.childButtonSelectedImageList = childButtonSelectedImageList
        
        self.mainButtonBackgroundColor = mainButtonBackgroundColor
        self.childButtonBackgroundColor =  childButtonBackgroundColor
        //        if let window = UIApplication.shared.keyWindow {
        //            self.setupMainButton(window)
        //        }
    }
    
    
    func clearAllPassword() {
        self.passwordText.removeAll()         //will call passwordText didSet, clean all cicleView
        
        self.openDoorSpecialPassword.removeAll()
    }
    
    @objc func buttonDismissTap(){
        self.dismiss()
    }
    
    @objc func fingerPrintButtonHandler(){
        //        dismiss()
        self.authTouchID()
    }
    
    
    func dismiss(){
        
        //        self.unPopButtons()
        
        //circle button animate move to top of screen, remove digital buttons
        stackViewCenterYConstraint?.isActive = false
        stackViewCenterYConstraint = self.passwordStackView.topAnchor.constraint(equalTo: self.fullscreenView.topAnchor, constant: -100)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            //            self.passwordStackView.frame.origin.y = -100
            self.mainButton.transform = CGAffineTransform(scaleX: 2, y: 2) //zoom mainbutton
            self.stackViewCenterYConstraint?.isActive = true
            self.fullscreenView.layoutIfNeeded()
            self.unPopButtons()
            //            self.hideButtons()
            
        }, completion: { b in
            self.hideButtons()
            for button in self.buttonList {
                button.removeFromSuperview()
            }
            
            self.centerVerticalLine.removeFromSuperview()
            
            for v in self.passwordStackView.arrangedSubviews {
                v.removeFromSuperview()
            }
            self.passwordCircleViewList.removeAll()
            
            self.passwordStackView.removeFromSuperview()
            
        })
        
        
        //open door animate
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
            
            
            
            self.leftDoorCloseConstraint?.isActive = false
            self.leftDoorOpenConstraint?.isActive = true
            
            self.rightDoorCloseConstraint?.isActive = false
            self.rightDoorOpenConstraint?.isActive = true
            
            //            self.leftDoorView.superview?.layoutIfNeeded()
            self.fullscreenView.layoutIfNeeded()
        }, completion: { b in
            
            self.mainButton.removeFromSuperview()
            
            if self.style == .setPassword {
                self.dismissButton.removeFromSuperview()
            }
            
            if self.style == .authPassword && self.isFingerprintEnabled {
                self.fingerPrintButton.removeFromSuperview()
            }
            
            self.leftDoorView.removeFromSuperview()
            self.rightDoorView.removeFromSuperview()
            
            self.messageLabel.removeFromSuperview()
            self.fullscreenView.removeFromSuperview()
            self.isShowing = false
            
            if let dissmisDelegate = self.authCompleteDelegate, self.style == .authPassword  {
                dissmisDelegate.onAuthComplete()
            }
        })
        
        self.passwordText.removeAll()
        
        self.openDoorSpecialPassword.removeAll()
        
        self.firstPasswordString  = ""
    }
    
    
    
    func addCenterVerticalLine(){
        //centerHorizonLine定位用
        fullscreenView.addSubview(centerVerticalLine)
        centerVerticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        centerVerticalLine.heightAnchor.constraint(equalTo: fullscreenView.heightAnchor, multiplier: 1).isActive = true
        centerVerticalLine.centerXAnchor.constraint(equalTo: fullscreenView.centerXAnchor).isActive = true
        centerVerticalLine.centerYAnchor.constraint(equalTo: fullscreenView.centerYAnchor).isActive = true
        
    }
    
    func addFingerprintButton(_ parentView:UIView) {
        parentView.addSubview(self.fingerPrintButton)
        
        fingerPrintButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        fingerPrintButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //        fingerPrintButton.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -30).isActive = true
        fingerPrintButton.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 80).isActive = true
        
        fingerPrintButton.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -30 ).isActive = true
    }
    
    func addLeftDoor(){
        fullscreenView.addSubview(leftDoorView)
        
        leftDoorView.widthAnchor.constraint(equalTo: fullscreenView.widthAnchor, multiplier: 1).isActive = true
        leftDoorView.heightAnchor.constraint(equalTo: fullscreenView.heightAnchor, multiplier: 1).isActive = true
        leftDoorView.topAnchor.constraint(equalTo: fullscreenView.topAnchor, constant: 0).isActive = true
        leftDoorOpenConstraint = leftDoorView.rightAnchor.constraint(equalTo: fullscreenView.leftAnchor, constant: 0)
        leftDoorOpenConstraint?.isActive = true
        
        fullscreenView.layoutIfNeeded()
        //set close door constraint
        leftDoorCloseConstraint = leftDoorView.rightAnchor.constraint(equalTo: centerVerticalLine.leftAnchor, constant: 0)
        
    }
    
    func addRightDoor(){
        
        fullscreenView.addSubview(rightDoorView)
        
        rightDoorView.widthAnchor.constraint(equalTo: fullscreenView.widthAnchor, multiplier: 1).isActive = true
        rightDoorView.heightAnchor.constraint(equalTo: fullscreenView.heightAnchor, multiplier: 1).isActive = true
        rightDoorView.topAnchor.constraint(equalTo: fullscreenView.topAnchor, constant: 0).isActive = true
        
        rightDoorOpenConstraint = rightDoorView.leftAnchor.constraint(equalTo: fullscreenView.rightAnchor, constant: 0)
        rightDoorOpenConstraint?.isActive = true
        fullscreenView.layoutIfNeeded()
        
        //set close door constraint
        rightDoorCloseConstraint = rightDoorView.leftAnchor.constraint(equalTo: centerVerticalLine.rightAnchor, constant: 0)
        
        if self.style == .setPassword {
            addDismissButton(rightDoorView)
        }
    }
    
    func addDismissButton(_ parentView:UIView) {
        parentView.addSubview(self.dismissButton)
        
        dismissButton.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 30).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: parentView.centerXAnchor, constant: -30).isActive = true
        
    }
    
    func animateCloseDoor(){
        self.centerVerticalLine.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.leftDoorOpenConstraint?.isActive = false
            self.leftDoorCloseConstraint?.isActive = true
            
            self.rightDoorOpenConstraint?.isActive = false
            self.rightDoorCloseConstraint?.isActive = true
            
            self.fullscreenView.layoutIfNeeded()
        }, completion: {b in
            
            self.animatePopChildButtons()
            //            self.addPasswordCircleViews()
            self.passwordStackView.isHidden = false
            self.centerVerticalLine.isHidden = false
        })
    }
    
    
    func show(_ isFingerprintEnabled: Bool){
        if self.isShowing {
            return
        }
        if let keyWindow = UIApplication.shared.keyWindow {
            
            
            self.isShowing = true
            self.isFingerprintEnabled = isFingerprintEnabled
            
            self.centerVerticalLine.isHidden = true
            
            self.passwordText = []
            self.firstPasswordString = ""
            if style == .authPassword {
                self.messageLabel.text = i18n_authPasswordTitle
            }else{
                self.messageLabel.text = i18n_setPasswordTitle
            }
            
            
            //add full sceenview
            keyWindow.addSubview(fullscreenView)
            
            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":fullscreenView]))
            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":fullscreenView]))
            
            
            self.addCenterVerticalLine()
            
            self.addLeftDoor()
            
            if self.isFingerprintEnabled {
                self.addFingerprintButton(self.leftDoorView)
            }
            
            self.addRightDoor()
            
            self.setupMainButton(self.fullscreenView)
            
            addPasswordCircleViews()
            animateCloseDoor()
            
            addMessageLabel(self.fullscreenView)
            
            
        }
        
    }
    
    
    func addMessageLabel(_ parentView: UIView){
        
        parentView.addSubview(self.messageLabel)
        messageLabel.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 1).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 0).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: self.passwordStackView.topAnchor, constant: -10).isActive = true
    }
    
    
    func addPasswordCircleViews(){
        for _ in 0...3 {
            let v = UIView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
            v.layer.borderColor = AppDefault.themeColor.cgColor //UIColor.blue.cgColor
            v.layer.borderWidth = 2
            v.clipsToBounds = true
            v.layer.cornerRadius = 7.5
            //            v.backgroundColor = .red
            v.translatesAutoresizingMaskIntoConstraints = false
            v.widthAnchor.constraint(equalToConstant: 15).isActive = true
            v.heightAnchor.constraint(equalToConstant: 15).isActive = true
            self.passwordCircleViewList.append(v)
            
            self.fullscreenView.addSubview(v)
            passwordStackView.addArrangedSubview(v)
        }
        
        self.fullscreenView.addSubview(self.passwordStackView)
        
        passwordStackView.centerXAnchor.constraint(equalTo: self.fullscreenView.centerXAnchor, constant: 0).isActive = true
        
        //        stackViewCenterYConstraint = passwordStackView.centerYAnchor.constraint(equalTo: self.fullscreenView.centerYAnchor, constant: -200)
        //        Util.printLog("stackViewOffset:\(stackViewOffset)")
        stackViewCenterYConstraint = passwordStackView.centerYAnchor.constraint(equalTo: self.fullscreenView.centerYAnchor, constant: -stackViewOffset)
        
        stackViewCenterYConstraint?.isActive = true
        passwordStackView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        passwordStackView.isHidden = true
    }
    
    
    func animateWrongPassword() {
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping:0.1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            //            self.stackViewCenterXConstraint?.constant = 10
            //            self.fullscreenView.layoutIfNeeded()
            self.passwordStackView.frame.origin.x += 10
        })
        
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping:0.1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            //            self.stackViewCenterXConstraint?.constant = -20
            //            self.fullscreenView.layoutIfNeeded()
            self.passwordStackView.frame.origin.x -= 20
        })
        
        
        UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping:0.1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            //            self.stackViewCenterXConstraint?.constant = 10
            //            self.stackViewCenterXConstraint?.isActive = true
            //            self.fullscreenView.layoutIfNeeded()
            self.passwordStackView.frame.origin.x += 10
            
        })
        
        self.passwordText.removeAll()
        
        self.openDoorSpecialPassword.removeAll()
    }
    
    
    ////for MainButton
    func setupMainButton(_ parentView:UIView) {
        
        parentView.addSubview(mainButton)
        setupMainButtonConstraint(parentView)
        
        //for child buttons
        for btn in self.buttonList {
            parentView.addSubview(btn)
            //            btn.frame = mainButton.frame
            parentView.addConstraint(NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: mainButton, attribute: .centerX, multiplier: 1, constant: 0))
            parentView.addConstraint(NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: mainButton, attribute: .centerY, multiplier: 1, constant: 0))
            
            parentView.addConstraint(NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: mainButton, attribute: .width, multiplier: 1, constant: 0))
            parentView.addConstraint(NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: mainButton, attribute: .height, multiplier: 1, constant: 0))
            
        }
        
        parentView.bringSubviewToFront(mainButton)
        //        mainButton.isHidden = true
        
        self.hideButtons()
    }
    
    
    func setupMainButtonConstraint(_ parentView:UIView) {
        let height = buttonWidthHeight
        let width = height
        mainButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        mainButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        mainButton.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        mainButton.centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: 0).isActive = true
    }
    
    
    
    func animatePopChildButtons() {
        self.showButtons()
        
        //dismiss keyboard
        //        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
        }
        self.mainButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            self.mainButton.transform = CGAffineTransform.identity
        }, completion: { b in
            if b {
                //self.composeBtn.transform = CGAffineTransform.identity
            }
        })
        
        popButtons()
        
    }
    
    
    @objc func mainButtonClick() {
        //dismiss keyboard
        //        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
        }
        
        if let last = self.passwordText.last {
            self.openDoorSpecialPassword.append(last)
            
            let pass = self.openDoorSpecialPassword.reduce("", {$0+$1})
            if pass == self.specialPassword {
                self.dismiss()
            }
        }
        
        self.animateButtonTap(mainButton)
        self.clearLastText()
        
    }
    
    func clearLastText(){
        let count = self.passwordText.count
        
        if count <= 4 && count >= 1 {
            self.passwordText.removeLast()
        }
        
    }
    
    func animateButtonTap(_ sender:UIButton){
        //        sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform.identity
        }, completion: { b in
            if b {
                //self.composeBtn.transform = CGAffineTransform.identity
            }
        })
    }
    
    
    func authPassword(_ password:String) -> Bool {
        if let delegate = delegate {
            let success = delegate.authPassword(password)
            if success {
                //                if let statusDelegate = self.authStatusDelegate {
                //                    statusDelegate.onAuthSuccess()
                //                    return true
                //                }
                return true
            }else{
                //                if let statusDelegate = self.authStatusDelegate {
                //                    statusDelegate.onAuthFailure()
                //                    return false
                //                }
                return false
            }
        } else {
            return false
        }
    }
    
    func setPassword(_ password:String)  {
        if let delegate = delegate {
            delegate.setPassword(password)
        }
    }
    
    @objc func childButtonClick(sender: UIButton) {
        Util.printLog("button click:\(sender.tag)")
        let password = String(sender.tag)
        self.passwordText.append(password)
    }
    
    func popButtons() {
        
        //        if self.isButtonPoped {
        //            return
        //        }
        // set size to 0 before animate
        let scaleTransformZero =  CGAffineTransform(scaleX: 0, y: 0)
        for btn in self.buttonList {
            btn.transform = scaleTransformZero
        }
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            
            //            self.isButtonPoped = true
            for (index,button) in self.buttonList.enumerated() {
                button.isHidden = false
                button.alpha = 1
                
                button.transform  = self.getFanPopTransform(buttonIndex: index)
                //                if self.style == .fan {
                //
                //                } else {
                //                    button.transform = self.getLinePopTransform(buttonIndex: index)
                //                }
            }
            
        }, completion: { b in
            if b {
                //                self.isButtonPoped = true
            }
        })
    }
    
    private func getFanPopTransform(buttonIndex: Int) -> CGAffineTransform {
        
        //compute transform x and y values:
        //y = sin(degree * Double.pi / 180 ) * r
        //x = cos(degree * Double.pi / 180 ) * r
        var adjustX:CGFloat = 1
        var adjustY:CGFloat = 1
        
        //        var minDegree:Double = Double( (90 - startOffsetDegree * 2) / Double((self.buttonCount - 1)) ) //Double(90 / (self.buttonCount - 1))
        //        var minDegree:Double = Double( (360 - startOffsetDegree * 2) / Double((self.buttonCount - 1)) ) //Double(180 / (self.buttonCount - 1))
        
        //transform = move + scale(75%)
        //for scale
        
        let minDegree:Double =  Double( (360 - startOffsetDegree * 2) / Double((self.buttonCount)) )
        //        Util.printLog(minDegree)
        // adjustX，-1， 从左边开始第一个button, adjustY = -1, 左上，顺时针
        adjustX = -1
        adjustY = -1
        
        let targetScaleTransform = CGAffineTransform(scaleX: childButonScaleSize, y: childButonScaleSize)
        
        //        let currentDegree = minDegree * Double(buttonIndex)
        let currentDegree = minDegree * Double(buttonIndex) + startOffsetDegree
        
        let x = CGFloat( cos(currentDegree * Double.pi / 180) ) * popRadius * adjustX //-1
        let y = CGFloat( sin(currentDegree * Double.pi / 180) ) * popRadius * adjustY //-1
        
        let moveTransform = CGAffineTransform(translationX: x  , y: y )
        let transform = moveTransform.concatenating(targetScaleTransform) //move + scale
        return transform
    }
    
    func unPopButtons() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            for button in self.buttonList {
                button.alpha = 0
                button.transform = CGAffineTransform.identity
            }
            
        }, completion: { complete in
            if complete {
                //                self.isButtonPoped = false
                for button in self.buttonList {
                    button.isHidden = true
                }
            }
        })
        
    }
    
    
    func showButtons(){
        mainButton.isHidden = false
        for btn in self.buttonList {
            btn.isHidden = false
        }
    }
    
    func hideButtons(){
        //        if self.isButtonPoped {
        //            unPopButtons()
        //        }
        mainButton.isHidden = true
        for btn in self.buttonList {
            btn.isHidden = true
        }
    }
    
    
    
    func authTouchID(){
        //        guard let keyWindow = UIApplication.shared.keyWindow  else { return }
        let context: LAContext! = LAContext()
        
        //        let blurEffect = UIBlurEffect(style:.prominent)
        //        let blurView = UIVisualEffectView()
        //        blurView.effect = blurEffect
        //        blurView.isOpaque = false
        //
        //        blurView.frame = keyWindow.frame
        //        keyWindow.addSubview(blurView)
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "TouchID") { (success, authenticationError) in
                if success{
                    Util.printLog("success yes")
                    DispatchQueue.main.async {
                        
                        //                        self.isLocked = true
                        //                        blurView.removeFromSuperview()
                        self.dismiss()
                    }
                    
                }else{
                    
                    //                    DispatchQueue.main.async {
                    //                        blurView.removeFromSuperview()
                    //                        TouchID.authTouchID()
                    //                    }
                    
                    //                    let theError:LAError = authenticationError as! LAError
                    //                    switch theError{
                    //                    case LAError.authenticationFailed :
                    //                        Util.printLog("Authentication Failed")
                    //                        break
                    //                    case LAError.appCancel :
                    //                        Util.printLog("User Canceled")
                    //                        break
                    //                    case LAError.touchIDNotAvailable :
                    //                        Util.printLog("TouchID not avaliable")
                    //                        break
                    //                    default :
                    //                        Util.printLog("error")
                    //                        break
                    //                    }
                }
            }
        } else {
            Util.printLog("can't use TouchID")
        }
    }
}

