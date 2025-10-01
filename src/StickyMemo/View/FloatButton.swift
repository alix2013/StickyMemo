//
//  FloatButton.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import Foundation

enum FloatButtonLocation {
    case leftBottom
    case rightBottom
    case leftTop
    case rightTop
    case bottomCenter
    case topCenter
}
enum FloatButtonPopStyle {
    case fan
    case line
}

enum FloatButtonLinePopDirection {
    case left
    case right
    case top
    case bottom
}

protocol FloatButtonDelegate {
    func floatButtonClicked(_ button:FloatButton, index: Int)
}


class FloatButton {
    
    var identifier: String = "" //for multiple instance
    var isChildUnpopAfterClick = true
    var delegate:FloatButtonDelegate?
    var buttonCount: Int
    var buttonWidthHeight:CGFloat = 50
    lazy var popRadius:CGFloat = buttonWidthHeight * 2.5
//    var buttonMargin:CGFloat = 30
    var leftMargin: CGFloat = 30
    var rightMargin: CGFloat = 30
    var topMargin: CGFloat = 30
    var bottomMargin: CGFloat = 30
    
    var childButonScaleSize:CGFloat = 0.75
    var style: FloatButtonPopStyle = .line
    var lineSylePopDirection: FloatButtonLinePopDirection = .right
    
    //startOffsetDegree, startDegree default is 0, for bottomCenter and topCenter 30 is better
    var startOffsetDegree:Double = 0  // every degree == (90 - 2*startOffsetDegree)/(buttonCount - 1) or (180 - 2*startOffsetDegree)/(buttonCount - 1)
    
    var isShowBorder:Bool = true
    var borderColor:UIColor = .white
    
    var childButtonBackgroundColor: UIColor
    var mainButtonBackgroundColor:UIColor

    var mainButtonImage:UIImage?
    var mainButtonSelectedImage:UIImage?
    
    var childButtonImageList:[UIImage]?
    var childButtonSelectedImageList:[UIImage]?
    
    var mainButtonTitle:String? = nil
    var childButtonTitleList:[String]? = nil
    
    var buttonLocation: FloatButtonLocation = .topCenter
    
    private var isButtonPoped: Bool = false
    
    
    
    private lazy var mainButton : UIButton = {
        // let btn = UIButton.createButton("tabbar_compose_icon_add", bgImageName: "tabbar_compose_button")
        let btn = UIButton()
        //btn.setTitle("💀", for: .normal)
        
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
        
        if self.isShowBorder {
            btn.layer.borderColor = self.borderColor.cgColor //UIColor.white.cgColor
            btn.layer.borderWidth = 2
        }
        
        btn.isHidden = true
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
                btn.setTitle(title, for: .normal)
            }
            
            btn.backgroundColor = self.childButtonBackgroundColor
            btn.sizeToFit()
            btn.layer.cornerRadius = buttonWidthHeight / 2
            btn.clipsToBounds = true
            
            if self.isShowBorder {
                btn.layer.borderColor = self.borderColor.cgColor //UIColor.white.cgColor
                btn.layer.borderWidth = 2
            }
            
            btn.isHidden = true
            btn.translatesAutoresizingMaskIntoConstraints =  false
            btn.tag = i
            btn.addTarget(self, action: #selector(childButtonClick), for: .touchUpInside)
            btns.append(btn)
        }
        return btns
    }()
    
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
     /*
    init(_ buttonCount: Int,style:FloatButtonPopStyle = .fan, buttonWidthHeight:CGFloat = 50, leftMargin:CGFloat = 30,rightMargin:CGFloat = 30,topMargin:CGFloat = 30,bottomMargin:CGFloat = 30,buttonLocation:FloatButtonLocation = .leftBottom,isChildUnpopAfterClick: Bool = true, startOffsetDegree:Double = 0) {
        
        self.buttonCount = buttonCount
        self.style = style
        self.buttonWidthHeight = buttonWidthHeight
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        self.buttonLocation = buttonLocation
        self.isChildUnpopAfterClick = isChildUnpopAfterClick
        self.startOffsetDegree = startOffsetDegree
        
        if let window = UIApplication.shared.keyWindow {
            setupMainButton(window)
        }
    }
   
    init(_ buttonCount: Int, mainButtonTitle:String? = nil, childButtonTitleList:[String]? = nil) {
        self.mainButtonTitle = mainButtonTitle
        self.childButtonTitleList = childButtonTitleList

        self.buttonCount = buttonCount
        if let window = UIApplication.shared.keyWindow {
            self.setupMainButton(window)
        }
    }
    
    init(_ buttonCount: Int, mainButtonImage:UIImage? = nil, childButtonSelectedImageList:[UIImage]? = nil) {
        self.mainButtonImage = mainButtonImage
        self.childButtonSelectedImageList = childButtonSelectedImageList
        
        self.buttonCount = buttonCount
        if let window = UIApplication.shared.keyWindow {
            self.setupMainButton(window)
        }
    }
    */
    init(_ buttonCount: Int,style:FloatButtonPopStyle = .fan,
         buttonWidthHeight:CGFloat = 50,leftMargin:CGFloat = 30,rightMargin:CGFloat = 30,topMargin:CGFloat = 30,bottomMargin:CGFloat = 30,buttonLocation:FloatButtonLocation = .leftBottom,isChildUnpopAfterClick: Bool = true,startOffsetDegree:Double = 0, mainButtonTitle:String? = nil, childButtonTitleList:[String]? , mainButtonImage:UIImage? = nil, childButtonImageList:[UIImage]? = nil, childButtonSelectedImageList:[UIImage]? = nil,mainButtonBackgroundColor:UIColor = .red,childButtonBackgroundColor:UIColor = .clear ) {
        
//        self.style = style
//        self.buttonWidthHeight = buttonWidthHeight
//
//        self.leftMargin = leftMargin
//        self.rightMargin = rightMargin
//        self.topMargin = topMargin
//        self.bottomMargin = bottomMargin
        
        self.buttonCount = buttonCount
        self.style = style
        self.buttonWidthHeight = buttonWidthHeight
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        self.buttonLocation = buttonLocation
        self.isChildUnpopAfterClick = isChildUnpopAfterClick
        self.startOffsetDegree = startOffsetDegree
        
        self.mainButtonTitle = mainButtonTitle
        self.childButtonTitleList = childButtonTitleList
        self.mainButtonImage = mainButtonImage
        self.childButtonImageList = childButtonImageList
        self.childButtonSelectedImageList = childButtonSelectedImageList
        
        self.mainButtonBackgroundColor = mainButtonBackgroundColor
        self.childButtonBackgroundColor =  childButtonBackgroundColor
        if let window = UIApplication.shared.keyWindow {
            self.setupMainButton(window)
        }
    }
    
    
    func show(){
        mainButton.isHidden = false
        for btn in self.buttonList {
            btn.isHidden = false
        }
    }
    
    func hide(){
//        if self.isButtonPoped {
//            unPopButtons()
//        }
        mainButton.isHidden = true
        for btn in self.buttonList {
            btn.isHidden = true
        }
    }
    
    
    func setupMainButtonConstraint(_ window:UIWindow) {
        let height = buttonWidthHeight
        let width = height
        
        mainButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        mainButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        switch self.buttonLocation {
        case .rightBottom:
            mainButton.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -rightMargin).isActive = true
            mainButton.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -bottomMargin).isActive = true
            
        case .leftBottom :
            mainButton.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: leftMargin).isActive = true
            mainButton.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -bottomMargin).isActive = true
            
        case .rightTop :
            mainButton.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -rightMargin).isActive = true
            mainButton.topAnchor.constraint(equalTo: window.topAnchor, constant: topMargin).isActive = true
        
        case .leftTop :
            mainButton.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: leftMargin).isActive = true
            mainButton.topAnchor.constraint(equalTo: window.topAnchor, constant: topMargin).isActive = true
            
        case .bottomCenter:
            mainButton.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -bottomMargin).isActive = true
            mainButton.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        case .topCenter:
            mainButton.topAnchor.constraint(equalTo: window.topAnchor, constant: topMargin).isActive = true
            mainButton.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        }
        
    }
    
    func setupMainButton(_ window:UIWindow) {
        
        window.addSubview(mainButton)
        
        /*
        window.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(width)]-rigthMargin-|", options: [], metrics: ["width":width,"rigthMargin":buttonMargin], views: ["v0":mainButton]))
        
        window.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(height)]-rigthMargin-|", options: [], metrics: ["height":height,"rigthMargin":buttonMargin], views: ["v0":mainButton]))
         */
        setupMainButtonConstraint(window)
        
        
        //for child buttons
        for btn in self.buttonList {
            window.addSubview(btn)
//            btn.frame = mainButton.frame
            window.addConstraint(NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: mainButton, attribute: .centerX, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: mainButton, attribute: .centerY, multiplier: 1, constant: 0))
            
            window.addConstraint(NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: mainButton, attribute: .width, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: mainButton, attribute: .height, multiplier: 1, constant: 0))
            
        }
        
        window.bringSubviewToFront(mainButton)
        mainButton.isHidden = true
        
    }
    
    
    
    @objc func mainButtonClick() {
        self.buttonSoundSoso.play()
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

        if !self.isButtonPoped {
            popButtons()
        }else{
            unPopButtons()
        }
        
    }
    
    @objc func childButtonClick(sender: UIButton) {
//        print("button click:\(sender.tag)")
        let selectedIndex = sender.tag
        if isChildUnpopAfterClick {
            unPopButtons()
        }
        if let delegate = delegate {
            delegate.floatButtonClicked(self, index: selectedIndex)
        }
    }
    
    func popButtons() {
        
        if self.isButtonPoped {
            return
        }
        // set size to 0 before animate
        let scaleTransformZero =  CGAffineTransform(scaleX: 0, y: 0)
        for btn in self.buttonList {
            btn.transform = scaleTransformZero
        }
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            
            self.isButtonPoped = true
            for (index,button) in self.buttonList.enumerated() {
                button.isHidden = false
                button.alpha = 1
                if self.style == .fan {
                    button.transform  = self.getFanPopTransform(buttonIndex: index)
                } else {
                    button.transform = self.getLinePopTransform(buttonIndex: index)
                }
            }
            
        }, completion: { b in
            if b {
                //                self.isButtonPoped = true
            }
        })
    }
    
    private func getLinePopTransform(buttonIndex:Int ) -> CGAffineTransform {
        
//        let scalePercent:CGFloat = 0.75
        var x: CGFloat = 0
        var y: CGFloat = 0
        var adjustX:CGFloat = 1
        var adjustY:CGFloat = 1
        switch lineSylePopDirection {
        case .left:
            adjustX = -1
            adjustY = 0
        case .right:
            adjustX = 1
            adjustY = 0
        case .top:
            adjustX = 0
            adjustY = -1
        case .bottom:
            adjustX = 0
            adjustY = 1
        }
        
        x = (popRadius *  CGFloat( buttonIndex + 1)) * adjustX
        y = (popRadius *  CGFloat( buttonIndex + 1)) * adjustY
        
        let moveDirectionTransform = CGAffineTransform(translationX: x, y: y )
        
        let targetScaleTransform = CGAffineTransform(scaleX: childButonScaleSize, y: childButonScaleSize)
        
        let transform = moveDirectionTransform.concatenating(targetScaleTransform)
        return transform
        
    }
    private func getFanPopTransform(buttonIndex: Int) -> CGAffineTransform {
        
        //compute transform x and y values:
        //y = sin(degree * Double.pi / 180 ) * r
        //x = cos(degree * Double.pi / 180 ) * r
        var adjustX:CGFloat = 1
        var adjustY:CGFloat = 1
        
        var minDegree:Double = Double( (90 - startOffsetDegree * 2) / Double((self.buttonCount - 1)) ) //Double(90 / (self.buttonCount - 1))
        
        
        switch self.buttonLocation {
        case .rightBottom :
            adjustX = -1
            adjustY = -1
        case .leftBottom:
            adjustX = 1
            adjustY = -1
        case .rightTop:
            adjustX = -1
            adjustY = 1
            
        case .leftTop:
            adjustX = 1
            adjustY = 1
            
        case .bottomCenter:
//            startOffsetDegree = 30
            minDegree =  Double( (180 - startOffsetDegree * 2) / Double((self.buttonCount - 1)) )
            adjustX = 1
            adjustY = -1
        case .topCenter:
            //            startOffsetDegree = 30
            minDegree =  Double( (180 - startOffsetDegree * 2) / Double((self.buttonCount - 1)) )
            adjustX = 1
            adjustY = 1
        }
        
//        let scalePercent:CGFloat = 0.75
        //transform = move + scale(75%)
        //for scale
        let targetScaleTransform = CGAffineTransform(scaleX: childButonScaleSize, y: childButonScaleSize)

        
//        let currentDegree = minDegree * Double(buttonIndex)
        let currentDegree = minDegree * Double(buttonIndex) + startOffsetDegree
        
        let x = CGFloat( cos(currentDegree * Double.pi / 180) ) * popRadius * adjustX //-1
        let y = CGFloat( sin(currentDegree * Double.pi / 180) ) * popRadius * adjustY //-1
      
        //let moveLeftTopTransform = CGAffineTransform(translationX: -distance, y: (-distance) / 2 )
        let moveLeftTopTransform = CGAffineTransform(translationX: x, y: y )
                
        let transform = moveLeftTopTransform.concatenating(targetScaleTransform)
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
                self.isButtonPoped = false
                for button in self.buttonList {
                    button.isHidden = true
                }
            }
        })
        
    }
    
}
