//
//  MemoView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import Foundation

enum PinchDirection {
    case horizon
    case vertical
    case both
}

protocol MemoViewDelegate {
    func positionChangedMemoViewDelegate(_ memoView:MemoView, x: CGFloat?, y:CGFloat?, width: CGFloat?,height:CGFloat?,rotate: CGFloat?)
    func doubleTapActionMemoViewDelegate(_ memoView: MemoView)
    func longTapActionMemoViewDelegate(_ memoView: MemoView)
    func deleteActionMemoViewDelegate(_ memoView:MemoView)
    func closeAndSaveMemoViewDelegate(_ memoView:MemoView)
    func closeWithoutSaveMemoViewDelegate(_ memoView:MemoView)
}

class MemoView:UIView {
    
//    let i18n_setDefaultStyle:String = NSLocalizedString("Set the current appearance to the default of the next new memo?", comment: "Set the current appearance to the default of the next new memo?")
//    let i18n_ok:String = NSLocalizedString("OK", comment: "OK")
//    let i18n_cancel:String = NSLocalizedString("Cancel", comment: "Cancel")
    
    //for IAP show contoller
    var boardViewController:BoardViewController?
    
    var delegate:MemoViewDelegate?
    
    var identifier: String = ""
    var lastRotation:CGFloat = 0
    
    // for layoutconstaint
    var textMarginSpace: CGFloat = 20 // 15
    
    // for scale out/in
    let minWidthInNoneEditing : CGFloat =  120
    let minHeightInNoneEditing: CGFloat =  120
    
    //for tool buttons can show normally
    let minWidthInEditing : CGFloat =  240
    let minHeightInEditing: CGFloat =  260
    
    lazy var panGesture:UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        return g
    }()
    
    // did set content
    var memo: Memo    {
        didSet {
            self.body = memo.body
            self.subject = memo.subject
        }
    }
    
    var body: String? {
        set{
            self.textView.text  = newValue
        }
        get{
            return self.textView.text
        }
    }
    
    var subject: String? {
        get{
            return self.textFieldView.text
        }
        set{
            self.textFieldView.text = newValue
        }
    }
    
    var leftToolsButtonLeftConstraint:NSLayoutConstraint?
    var rightToolsButtonRightConstraint:NSLayoutConstraint?
    var topButtonBottomConstraint:NSLayoutConstraint?
    
    var descriptionLabelTopConstraint:NSLayoutConstraint?
    
    var isEditable : Bool = false {
        didSet {
            self.textView.isEditable = isEditable
            self.textView.isSelectable = isEditable
            self.textFieldView.isEnabled = isEditable
            self.lineView.isHidden = !isEditable

            self.favImageView.isHidden = isEditable
            self.leftToolsButtonStackView.isHidden = !isEditable
            self.rightToolsButtonStackView.isHidden = !isEditable
            self.topButtonStackView.isHidden = !isEditable
            
            if isEditable {
                self.hideDescription()
                UIView.animate(withDuration: 0.5, animations: {
                    self.leftToolsButtonLeftConstraint?.constant = -35
                    self.rightToolsButtonRightConstraint?.constant = 35
                    self.topButtonBottomConstraint?.constant = 0
                    self.superview?.layoutIfNeeded()
    
                })
            }else{
                self.showDescription()
                
                self.leftToolsButtonLeftConstraint?.constant = 0
                self.rightToolsButtonRightConstraint?.constant = 0
                self.topButtonBottomConstraint?.constant = 30
            }
            
        }
    }
    
    var isSelected:Bool = false
    {
        didSet{
            if isSelected{
                if !isEditable {
//                    self.layer.borderColor = UIColor.red.cgColor
//                    self.layer.borderWidth = 3
                    self.showDescription()
                }else{
//                    self.layer.borderColor = UIColor.clear.cgColor
//                    self.layer.borderWidth = 0
                    self.hideDescription()
                }
            }else{
//                self.layer.borderColor =  UIColor.clear.cgColor
//                self.layer.borderWidth = 0
                self.hideDescription()
            }
        }
    }
    var isFavorited:Bool{
        didSet{
            favImageView.tintColor = isFavorited ? UIColor.red : UIColor.clear
            buttonFavorited.tintColor = isFavorited ? UIColor.red : UIColor.lightGray
            self.memo.isFavorited = isFavorited
        }
    }
    
    var font: UIFont?  {
        set {
            guard  let _ = newValue else {
                return
            }
            self.textView.font = newValue
            self.textFieldView.font = newValue
            if let name =  newValue?.fontName {
                self.memo.displayStyle.fontName = name
                if let size = font?.pointSize {
                    self.memo.displayStyle.fontSize = size
                }
            }
        }
        get {
            return self.textView.font
        }
    }
    
    var textColor: UIColor?  {
        set {
            guard  let _ = newValue else {
                return
            }
            self.textView.textColor = newValue
            self.textFieldView.textColor = newValue
            self.lineView.backgroundColor = newValue
            self.memo.displayStyle.textColor = newValue
            if let cHex = (newValue?.toHex) {
                self.memo.displayStyle.textColorHex = cHex
            }
            
        }
        get {
            return self.textView.textColor
        }
    }
    
    //not use now
    var textAlignment: NSTextAlignment?{
        set {
            if let align = newValue {
                self.textView.textAlignment = align
                if let align = newValue?.rawValue {
                    self.memo.displayStyle.alignment = align
                }
            }
        }
        get {
            return self.textView.textAlignment
        }
    }
    
    //save orignal backgoundImage
//    var backgroundImage:BackgroundImage?
    
//
//    var backgroundImageTemplate: BackgroundImageTemplate? {
//        didSet {
//            guard let backgroundImg = backgroundImageTemplate else {
//                return
//            }
//            let bkimg = BackgroundImage(name: backgroundImg.name, tintColorHex: backgroundImg.tintColorHex, edgeTop: backgroundImg.edgeTop, edgeLeft: backgroundImg.edgeLeft, edgeBottom: backgroundImg.edgeBottom, edgeRight: backgroundImg.edgeRight)
//
////            let bkimg = BackgroundImageGallery.getBackgroundImage(backgroundImg)
//            self.backgroundImageView.image = self.getUIImage(bkimg)
//
//            self.memo.backgroundImage.name = backgroundImg.name
//            self.memo.backgroundImage.edgeTop = backgroundImg.edgeTop
//            self.memo.backgroundImage.edgeRight = backgroundImg.edgeRight
//            self.memo.backgroundImage.edgeBottom = backgroundImg.edgeBottom
//            self.memo.backgroundImage.edgeLeft = backgroundImg.edgeLeft
//            //            self.memo.backgroundImage.tintColor = backgroundImg.tintColor
//            self.memo.backgroundImage.tintColorHex = backgroundImg.tintColorHex
//        }
//    }
//
    var backgroundImageTemplate: BKImageTemplate? {
        didSet {
            guard let backgroundImg = backgroundImageTemplate else {
                return
            }
            
            let bkimg = BackgroundImage(name: backgroundImg.name, tintColorHex: backgroundImg.tintColorHex, edgeTop: backgroundImg.edgeTop, edgeLeft: backgroundImg.edgeLeft, edgeBottom: backgroundImg.edgeBottom, edgeRight: backgroundImg.edgeRight, imageData:backgroundImg.imageData )
            
            //            let bkimg = BackgroundImageGallery.getBackgroundImage(backgroundImg)
//            self.backgroundImageView.image = backgroundImg.uiImage //self.getUIImage(bkimg)
            
            self.backgroundImageView.image = bkimg.uiImage //self.getUIImage(bkimg)
            
            self.memo.backgroundImage.name = backgroundImg.name
            self.memo.backgroundImage.edgeTop = backgroundImg.edgeTop
            self.memo.backgroundImage.edgeRight = backgroundImg.edgeRight
            self.memo.backgroundImage.edgeBottom = backgroundImg.edgeBottom
            self.memo.backgroundImage.edgeLeft = backgroundImg.edgeLeft
            //            self.memo.backgroundImage.tintColor = backgroundImg.tintColor
            self.memo.backgroundImage.tintColorHex = backgroundImg.tintColorHex
            self.memo.backgroundImage.imageData = backgroundImg.imageData
            
        }
    }
    
    
    lazy var textFieldView: UITextField = {
        let v = UITextField()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        //add gesture to avoid textField isEnable = false, it will not pass tap action to parent
        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(tap2GestureHandler(_ :)))
        tap2Gesture.numberOfTapsRequired = 2
        v.addGestureRecognizer(tap2Gesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler(_:)))
        v.addGestureRecognizer(longPressGesture)
        return v
    }()
    
    lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .gray
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var textView: UITextView = {
        let v = UITextView()
        v.backgroundColor = .clear
        //for swip gesture
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeHandler(_:)))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.delegate = self
        v.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeHandler(_:)))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.delegate = self
        v.addGestureRecognizer(rightSwipeGesture)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
//                imageView.image = UIImage(named: "bg_bubble_left")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        
//        if let image = self.getBackgroundImage(memo) {
////        if let backgroundImage = self.originalBackgroundImage, let image = self.getUIImage(backgroundImage) {
//            imageView.image = image
//        }else{
//            //set default image
//            imageView.backgroundColor = memo.backgroundImage.tintColor
//        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    
//    lazy var styleView = StyleView()
    lazy var styleView :StyleView = {
        let v = StyleView()
        v.boardViewController = self.boardViewController
        return v
    }()
    
    let trashImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
        //        imageView.image = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        
        imageView.image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
        
        imageView.tintColor = .red //UIColor(white: 0.90, alpha: 1)
        //        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
//    var buttonFavImage: UIButton = {
//        let v = UIButton()
//
//        let image = UIImage(named:"button_favorited")?.withRenderingMode(.alwaysTemplate)
//        v.setImage(image, for: .normal)
//        v.setImage(image, for: .disabled)
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.addTarget(self, action: #selector(buttonFavTap), for: .touchUpInside)
//        //        v.setContentHuggingPriority( UILayoutPriority(rawValue: 350), for: .horizontal)
//        return v
//    }()
    
    var favImageView: UIImageView = {
        let v = UIImageView()
        
        let image = UIImage(named:"button_favorited")?.withRenderingMode(.alwaysTemplate)
        v.image = image
        v.translatesAutoresizingMaskIntoConstraints = false
        //        v.setContentHuggingPriority( UILayoutPriority(rawValue: 350), for: .horizontal)
        return v
    }()
    
    var buttonFavorited: UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let image = UIImage(named:"button_favorited")?.withRenderingMode(.alwaysTemplate)
        v.setImage(image, for: .normal)
        v.setImage(image, for: .disabled)
//        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonFavTap), for: .touchUpInside)
        //        v.setContentHuggingPriority( UILayoutPriority(rawValue: 350), for: .horizontal)
        return v
    }()
//    var buttonFontSize: UIButton = {
//        let v = UIButton()
//        let image = UIImage(named:"button_fontsize") //?.withRenderingMode(.alwaysTemplate)
//        v.setImage(image, for: .normal)
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.addTarget(self, action: #selector(toolButtonTap), for: .touchUpInside)
//        v.backgroundColor = .red
//        v.layer.cornerRadius = 10
//        v.clipsToBounds = true
////        v.layer.borderColor = UIColor.red.cgColor
////        v.layer.borderWidth = 2
//        v.contentHorizontalAlignment = .left
//        return v
//    }()

//    var buttonPhoto: UIButton = {
//        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 30))
//        let image = UIImage(named:"button_photo") //?.withRenderingMode(.alwaysTemplate)
//        v.setImage(image, for: .normal)
//
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.addTarget(self, action: #selector(toolButtonTap), for: .touchUpInside)
//        v.backgroundColor = .red
//        v.layer.cornerRadius = 5
//        v.clipsToBounds = true
//        //        v.layer.borderColor = UIColor.red.cgColor
//        //        v.layer.borderWidth = 2
//        v.contentHorizontalAlignment = .left
//        return v
//    }()
//
    lazy var leftToolButtonList:[UIButton] = {
        var btns:[UIButton] = []
        for (i,style) in [
            (name : "button_fontsize",color: UIColor.red),
            (name:"button_font",color: UIColor.blue),
            (name:"button_textcolor",color:UIColor.yellow),
            (name:"button_background",color:UIColor.orange)
//            (name:"button_setting",color:UIColor.brown),
//            (name:"button_photo",color:UIColor.purple)
            ].enumerated() {
            
            let v = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 35))
            let image = UIImage(named:style.name)
            v.setImage(image, for: .normal)
        
//            v.titleEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 5)
//            v.setTitleColor(.white, for: .normal)
//            v.setTitle("A", for: .normal)
//            v.translatesAutoresizingMaskIntoConstraints = false
            v.addTarget(self, action: #selector(leftToolButtonTap), for: .touchUpInside)
            v.backgroundColor = style.color
            
            v.layer.cornerRadius = 5
            v.clipsToBounds = true
//            v.layer.borderColor = UIColor.red.cgColor
//            v.layer.borderWidth = 2
            v.contentHorizontalAlignment = .left
            v.tag = i
            btns.append(v)
        }
//        btns.append(self.buttonPhoto)
        return btns
    }()
    
    
    lazy var rightToolButtonList:[UIButton] = {
        var btns:[UIButton] = []
        
        
        for (i,style) in [
//            (name : "button_favorited",color: UIColor.clear),
//            (name:"button_photo",color:UIColor.purple)
            (name:"button_setting",color:UIColor.brown),
            (name:"button_alarm",color:UIColor.cyan),
            (name:"button_photo",color:UIColor.purple),
            (name:"button_audio",color:UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1))
            ].enumerated() {
                
                let v = UIButton(frame:CGRect(x: 0, y: 0, width: 70, height: 35))
                let image = UIImage(named:style.name)
                v.setImage(image, for: .normal)
                v.setImage(image,for:.disabled)
//                v.titleEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 25)
                
                if i == 0 || i == 1 {
                    v.imageEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 5)
                }
                
                //            v.setTitleColor(.white, for: .normal)
                //            v.setTitle("A", for: .normal)
                //            v.translatesAutoresizingMaskIntoConstraints = false
                v.addTarget(self, action: #selector(rightToolButtonTap), for: .touchUpInside)
                v.backgroundColor = style.color
                
                v.layer.cornerRadius = 5
                v.clipsToBounds = true
                //            v.layer.borderColor = UIColor.red.cgColor
                //            v.layer.borderWidth = 2
                v.contentHorizontalAlignment = .right
                
                v.tag = i
                btns.append(v)
        }
        //        btns.append(self.buttonPhoto)
        return btns
    }()
    
    
    
    lazy var leftToolsButtonStackView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [self.buttonFontSize,self.buttonFontName,self.buttonTextColor,self.buttonBackground,self.buttonPin])
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.spacing = 15
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var rightToolsButtonStackView:UIStackView = {
        //        let v = UIStackView(arrangedSubviews: [self.buttonFontSize,self.buttonFontName,self.buttonTextColor,self.buttonBackground,self.buttonPin])
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.spacing = 15
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var buttonOK: UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        let image = UIImage(named:"button_ok")
        v.setImage(image, for: .normal)
//        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(okButtonTap), for: .touchUpInside)
        v.backgroundColor = .green
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()
    
    lazy var buttonClose: UIButton = {
        let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        let image = UIImage(named:"button_close")
        v.setImage(image, for: .normal)
        //        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        v.backgroundColor = .red
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()
    
//    lazy var topButtonList:[UIButton] = {
//        var btns:[UIButton] = []
//        for (i,style) in [
//            (name : "button_ok",color: UIColor.green),
////            (name : "button_favorited",color: UIColor.clear),
//            (name:"button_close",color:UIColor.red)].enumerated() {
//
//                let v = UIButton(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
//                let image = UIImage(named:style.name)
//                v.setImage(image, for: .normal)
//                v.translatesAutoresizingMaskIntoConstraints = false
//                v.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
//                v.backgroundColor = style.color
//                v.layer.cornerRadius = 15
//                v.clipsToBounds = true
////                v.layer.borderColor = UIColor.red.cgColor
////                v.layer.borderWidth = 2
////                v.contentHorizontalAlignment = .left
//                v.tag = i
//                btns.append(v)
//        }
////        btns.append(buttonFavImage)
//        return btns
//    }()
    
    lazy var topButtonStackView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [self.buttonOK,self.buttonClose])
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.spacing = 30
        //        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var labelDescription:UILabel = {
       let v = UILabel()
        v.numberOfLines = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppDefault.popDescriptionBackgroundColor
//        v.text = "OK.........ok"
        return v
    }()
    // for pinch
    var originalFrameCenter:CGPoint = CGPoint.zero

    
    let buttonSoundSoso: ButtonSound = ButtonSound(type:.soso)
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    
    
    init(memo:Memo) {
        self.memo = memo
        let frame = CGRect(x: memo.position.x, y: memo.position.y, width: memo.position.width, height: memo.position.height)
        
        self.isFavorited = memo.isFavorited
        
        super.init(frame: frame)
        
        setupViews()
        setupGesture()
        
        self.textView.text = memo.body
        self.textFieldView.text = memo.subject
        
        //for displayStyle
        self.textView.textAlignment = memo.displayStyle.textAlignment
        self.textView.textColor = memo.displayStyle.textColor
        self.textColor = memo.displayStyle.textColor
        
        let fontName = memo.displayStyle.fontName
        let fontSize = memo.displayStyle.fontSize
        self.textView.font = UIFont(name: fontName, size: CGFloat(fontSize))
        self.font = UIFont(name: fontName, size: CGFloat(fontSize))
        
        self.textFieldView.textAlignment = .center
        self.textFieldView.textColor = memo.displayStyle.textColor
        self.textFieldView.font = UIFont(name: fontName, size: CGFloat(fontSize + 2))
        
        self.lineView.backgroundColor = memo.displayStyle.textColor
        
        self.favImageView.tintColor = self.isFavorited ? UIColor.red : UIColor.clear
        self.buttonFavorited.tintColor = self.isFavorited ? UIColor.red : UIColor.lightGray
        
        self.setPhotoCount()
        self.setAudioCount()
        self.setReminderButtonImage()
        
        //save orignal backgoundImage
//        self.backgroundImage = memo.backgroundImage
        
//        Util.printLog("current memoview backgoudImage:\(self.backgroundImage?.name)")
        
        if let image = self.memo.backgroundImage.uiImage {
            self.backgroundImageView.image = image
        }else{
            self.backgroundImageView.backgroundColor = memo.backgroundImage.tintColor
        }

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setReminderButtonImage() {
        
        self.rightToolButtonList[1].setImage(UIImage(named:"button_noalarm"), for: .normal)
        
        if let isReminderEnabled = self.memo.cdMemo?.isReminderEnabled {
            if isReminderEnabled {
                self.rightToolButtonList[1].setImage(UIImage(named:"button_alarm"), for: .normal)
            }
        }
    }
    
    func setPhotoCount(){
        if let count = self.memo.cdMemo?.images?.count {
//            print("photoCount:\(count)")
//            self.toolButtonList[5].setTitle("\(count)", for: .normal)
//            self.toolButtonList[5].setTitleColor(.white, for: .normal)
            self.rightToolButtonList[2].setTitle("\(count)", for: .normal)
            self.rightToolButtonList[2].setTitleColor(.white, for: .normal)
        }
    }
    
    func setAudioCount(){
        if let count = self.memo.cdMemo?.audios?.count {
            //            print("photoCount:\(count)")
            //            self.toolButtonList[5].setTitle("\(count)", for: .normal)
            //            self.toolButtonList[5].setTitleColor(.white, for: .normal)
            self.rightToolButtonList[3].setTitle("\(count)", for: .normal)
            self.rightToolButtonList[3].setTitleColor(.white, for: .normal)
        }
    }
    
    @objc func buttonFavTap() {
        self.buttonSoundDing.play()
        self.isFavorited = !self.isFavorited
    }
    
    func setupViews() {
        
        setupLeftToolButtons()
        setupRightToolButtons()
        setupTopButtons()
        
        self.addSubview(backgroundImageView)
        self.addSubview(favImageView)
        self.addSubview(textFieldView)
        self.addSubview(lineView)
        self.addSubview(textView)
        
        self.bringSubviewToFront(textView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":backgroundImageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":backgroundImageView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[v0(20)][v1]-margin-|", options: [], metrics: ["margin":textMarginSpace], views: ["v0":favImageView,"v1":textFieldView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[v0]-margin-|", options: [], metrics: ["margin":textMarginSpace], views: ["v0":lineView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[v0]-margin-|", options: [], metrics: ["margin":textMarginSpace], views: ["v0":textView]))
        
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[v0]-[v1(1)]-[v2]-margin-|", options: [], metrics: ["margin":textMarginSpace], views: ["v0":textFieldView,"v1":lineView,"v2":textView]))
        
        
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[v0(20)]-[v1(1)]-[v2]-margin-|", options: [], metrics: ["margin":textMarginSpace], views: ["v0":buttonFavImage,"v1":lineView,"v2":textView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[v0(20)]", options: [], metrics: ["margin":textMarginSpace], views: ["v0":favImageView]))
        
//        self.buttonFavImage.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
//        self.buttonFavImage.heightAnchor.constraint(equalToConstant: 20)
        hideTrash()
        
        setupDescriptionLabel()
    }
    
    func showDescription(){
        let desc = self.memo.descriptionAttributedText
//        let height = desc.height(withConstrainedWidth: self.frame.width - 20)
        self.labelDescription.attributedText = desc
        self.labelDescription.isHidden = false
    
//        let estimateSize = self.labelDescription.sizeThatFits(CGSize(width: , height: ))
        
//        self.descriptionLabelTopConstraint?.constant = 0 //-(height + 30 ) //-50 //self.labelDescription.intrinsicContentSize.height * -1
//        self.layoutIfNeeded()
    }
    
    func hideDescription(){
//        self.descriptionLabelTopConstraint?.constant = -200
//        self.layoutIfNeeded()
        self.labelDescription.isHidden = true
    }
    
    func setupDescriptionLabel(){
        //todo at next version
//        self.addSubview(self.labelDescription)
//        self.sendSubview(toBack: labelDescription)
//        [
//            labelDescription.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
//            labelDescription.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
//            ].forEach{ $0.isActive = true }
//
//        self.descriptionLabelTopConstraint = labelDescription.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
//        self.descriptionLabelTopConstraint?.isActive = true
        
        self.labelDescription.isHidden = true
    }
    
    func setupLeftToolButtons() {
        for button in self.leftToolButtonList {
            //add a container view for button to avoid change size
            let containerView = UIView(frame:CGRect(x: 0, y: 0, width: 70, height: 35))
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: 70).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            containerView.backgroundColor = button.backgroundColor
            containerView.layer.cornerRadius = 5
            containerView.clipsToBounds = true
    
            containerView.addSubview(button)
            self.leftToolsButtonStackView.addArrangedSubview(containerView)
        }
        self.addSubview(self.leftToolsButtonStackView)
        
       leftToolsButtonLeftConstraint = leftToolsButtonStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0)
        leftToolsButtonLeftConstraint?.isActive = true
        
//        toolStackView.topAnchor.constraint(equalTo: self.textView.topAnchor, constant: 0).isActive = true
        leftToolsButtonStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
//        toolStackView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
//        toolStackView.heightAnchor.constraint(equalToConstant: 120)
        leftToolsButtonStackView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
    }
    
    
    func setupRightToolButtons() {
        for button in self.rightToolButtonList {
            //add a container view for button to avoid change size
            let containerView = UIView(frame:CGRect(x: 0, y: 0, width: 70, height: 35))
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: 70).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            containerView.backgroundColor = button.backgroundColor
            containerView.layer.cornerRadius = 5
            containerView.clipsToBounds = true
            
            containerView.addSubview(button)
            self.rightToolsButtonStackView.addArrangedSubview(containerView)
        }
        self.addSubview(self.rightToolsButtonStackView)
        
        rightToolsButtonRightConstraint = rightToolsButtonStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        rightToolsButtonRightConstraint?.isActive = true
        
        //        toolStackView.topAnchor.constraint(equalTo: self.textView.topAnchor, constant: 0).isActive = true
        rightToolsButtonStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        //        toolStackView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        //        toolStackView.heightAnchor.constraint(equalToConstant: 120)
        rightToolsButtonStackView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
    }
    
    func setupTopButtons() {
        let topButtonList:[UIButton] = [buttonOK,buttonFavorited, buttonClose]
//        let topButtonList:[UIButton] = [buttonOK, buttonClose]
        for button in topButtonList {
            let containerView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            containerView.addSubview(button)
            self.topButtonStackView.addArrangedSubview(button)
        }
        
        self.addSubview(self.topButtonStackView)
        topButtonBottomConstraint = topButtonStackView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -30 )
        topButtonBottomConstraint?.isActive = true
        
        topButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        
//        closeButtonStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    @objc func leftToolButtonTap(sender:UIButton) {
        self.endEditing(true)
        
        Util.printLog("tool button frame:\(sender.frame)")
        for b in self.leftToolButtonList {
            if b == sender {
                b.superview?.transform = CGAffineTransform(translationX: -8, y: 0)
                
            }else{
                b.superview?.transform = CGAffineTransform.identity
            }
        }
        
        styleView.memoView = self
        switch sender.tag {
        case 0:
            self.buttonSoundDing.play()
            styleView.show(.fontSize)
        case 1:
            self.buttonSoundDing.play()
            styleView.show(.fontName)
        case 2:
            self.buttonSoundDing.play()
            styleView.show(.fontColor)
            
        case 3:
            self.buttonSoundDing.play()
            styleView.show(.backgroundImage)
        
//        case 4:
//            self.buttonSoundDing.play()
//            showDefaultStyleAlert()
//
//        case 5:
//            self.buttonSoundSoso.play()
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .vertical
//            let vc = ImageViewController(collectionViewLayout: layout)
////            vc.editViewFloatButton = self.editViewFloatButton
//            vc.cdMemo = self.memo.cdMemo
//            vc.memoView = self
//            let nav = UINavigationController(rootViewController: vc)
//            self.parentViewController?.present(nav, animated: true, completion: nil)
////            self.editViewFloatButton.hide()
            
        default:
            break
        }
        
    }
    
    
    @objc func rightToolButtonTap(sender:UIButton) {
        self.endEditing(true)
        
        Util.printLog("tool button frame:\(sender.frame)")
        for b in self.rightToolButtonList {
            if b == sender {
                b.superview?.transform = CGAffineTransform(translationX: 8, y: 0)
                
            }else{
                b.superview?.transform = CGAffineTransform.identity
            }
        }
        
        styleView.memoView = self
        switch sender.tag {
            
        case 0:
            self.buttonSoundDing.play()
            showDefaultStyleAlert()
        
        case 1: //for notitication
            
            if !DefaultService.isvip() {
                if let bordViewVC = self.boardViewController {
                    UIUtil.goPurchaseVIP(bordViewVC)
                }

            }else{
                if self.textFieldView.text == "" && self.textView.text == "" {
                    let t = Toast()
                    t.displayMessage(Appi18n.i18n_notifyNoContent, completeHandler: nil)
                    return
                }
                self.buttonSoundSoso.play()
//                self.memo.save()
                self.save()
                let vc = SetNotificationViewController()
                //            vc.editViewFloatButton = self.editViewFloatButton
                vc.cdMemo = self.memo.cdMemo
                vc.memoView = self
                let nav = UINavigationController(rootViewController: vc)
                self.parentViewController?.present(nav, animated: true, completion: nil)
            }
        case 2:
            self.buttonSoundSoso.play()
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let vc = ImageViewController(collectionViewLayout: layout)
            //            vc.editViewFloatButton = self.editViewFloatButton
            vc.cdMemo = self.memo.cdMemo
            vc.memoView = self
            let nav = UINavigationController(rootViewController: vc)
            self.parentViewController?.present(nav, animated: true, completion: nil)
            //            self.editViewFloatButton.hide()
            
        
            break
        case 3:
            self.buttonSoundSoso.play()
            let vc = AudioTVController()
            vc.cdMemo = self.memo.cdMemo
            vc.memoView = self
            let nav = UINavigationController(rootViewController: vc)
            self.parentViewController?.present(nav, animated: true, completion: nil)
        //            self.editViewFloatButton.hide()
        default:
            break
        }
        
    }
    
    func restoreButtonLocation(){
        for b in self.leftToolButtonList {
            b.superview?.transform = CGAffineTransform.identity
        }
        for b in self.rightToolButtonList {
            b.superview?.transform = CGAffineTransform.identity
        }
    }
    
    @objc func okButtonTap(sender:UIButton) {
        saveAndClose()
    }
    
    func saveAndClose() {
        if let delegate = delegate {
            delegate.closeAndSaveMemoViewDelegate(self)
        }
    }
    @objc func closeButtonTap(sender:UIButton) {
//        Util.printLog(sender.frame)
        exitEditing()
    }
    func exitEditing() {
        if let delegate = delegate {
            delegate.closeWithoutSaveMemoViewDelegate(self)
        }
    }
    private func saveStyleAsDefault() {
        DefaultService.saveStyleAsDefault(memo)
    }
    
    func showDefaultStyleAlert() {
        let alert = UIAlertController(title: Appi18n.i18n_setDefaultStyle, message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
            self.restoreButtonLocation()
            self.saveStyleAsDefault()
        }
        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            //
            self.restoreButtonLocation()
        }
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        
        self.parentViewController?.present(alert, animated: true, completion: nil)
        //        self.next
        
    }
    
    
//    func getUIImage(_ background: BackgroundImage ) -> UIImage? {
//        let imgName = background.name
//        var ret: UIImage?
//
//        //        resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
//        if let data = background.imageData, let img = UIImage(data: data) {
//            Util.printLog("=======get image from data=======left:\(background.edgeLeft), right:\(background.edgeRight), top:\(background.edgeTop), bottom:\(background.edgeBottom)")
//            ret = img.resizableImage(withCapInsets: UIEdgeInsets(top: background.edgeTop  , left: background.edgeLeft  , bottom: background.edgeBottom  , right: background.edgeRight  ))
//
//        }
////        if let image = UIImage(named: imgName) {
////            ret = image.resizableImage(withCapInsets: UIEdgeInsets(top: background.edgeTop, left: background.edgeLeft, bottom: background.edgeBottom, right: background.edgeRight))
////        }else{
////            return nil
////        }
//        return ret
//    }
    
//    func getBackgroundImage(_ memo: Memo ) -> UIImage? {
//        let imgName = memo.backgroundImage.name
//        var ret: UIImage?
//        //        resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
//        if let image = UIImage(named: imgName) {
//            ret = image.resizableImage(withCapInsets: UIEdgeInsets(top: memo.backgroundImage.edgeTop, left: memo.backgroundImage.edgeLeft, bottom: memo.backgroundImage.edgeBottom, right: memo.backgroundImage.edgeRight))
//        }else{
//            return nil
//        }
//        return ret
//    }
    
    
}


