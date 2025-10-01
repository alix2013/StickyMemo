//
//  BoardViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

//just for override bringsubView to do selected memoview boardercolor
class BoardView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bringSubviewToFront(_ view: UIView) {
        super.bringSubviewToFront(view)
//        print("####current subview count:\(self.subviews.count)")
        if let memoView = view as? MemoView {
            for v in self.subviews{
                if let mv = v as? MemoView {
                    mv.isSelected = false
                }
            }
            memoView.isSelected = true
        }
    }
}

class BoardViewController:UIViewController {
    
    var currentDesktop:CDDesktop? {
        didSet{
            guard let selectedDesktop = currentDesktop else {return}
            //save defaultDesktop to last opened
            DefaultService.saveDefaultDesktop(selectedDesktop)
        }
    }
    
//    var memoList:[Memo] = []
    var memoViewList:[MemoView] = []
    
//    var isInEditing:Bool = false {
//
//        didSet{
//            if isInEditing {
//                mainFloatButton.hide()
//            }else{
//                mainFloatButton.show()
//            }
//        }
//    }
    
    var isInEditing:Bool  {
        get{
            return self.isEditMemoViewExisting() //self.editMemoView != nil
        }
//        set{
//            if newValue {
//                mainFloatButton.hide()
//            }else{
//               mainFloatButton.show()
//            }
//        }
    }
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    lazy var  mainFloatButton: FloatButton = {
//       let b = FloatButton(4)
//        let b = FloatButton(4, mainButtonTitle: "A", childButtonTitleList: ["1","2","3","4"])
        let images:[UIImage?] = [UIImage(named:"button_create"), UIImage(named:"button_desktop"),UIImage(named:"button_list"),UIImage(named:"button_more")]
        let mainImage = UIImage(named:"button_main")
        let b = FloatButton(4, buttonLocation:.rightBottom, mainButtonTitle: "", childButtonTitleList: ["","","",""], mainButtonImage: mainImage, childButtonImageList: images as? [UIImage], mainButtonBackgroundColor:.clear)
        b.delegate = self
//        b.startOffsetDegree = 10
//        b.popRadius = 100
        b.identifier = "main"
        return b
    }()
    
    lazy var backgroundImageView:UIImageView = {
       let v = UIImageView(frame: self.view.frame)
        v.contentMode = .scaleAspectFill
        v.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return v
    }()
    
    var editMemoView = EditMemoView(frame: .zero)
    var lastDoubleTapTime: Date = Date()
    
//    var isFistTimeStartForPassword:Bool = true
    
    lazy var passwordView:PasswordView = {
        var passwordView = PasswordView(.authPassword,isFingerprintEnabled:DefaultService.isTouchIDEnabled())
        passwordView.delegate = self
        passwordView.authCompleteDelegate = self
        return passwordView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //todo at next version
//        let boardView = BoardView(frame:UIScreen.main.bounds)
//        boardView.frame = self.view.frame
//        self.view = boardView
        
        self.view.backgroundColor = .white
        
        //for notification handler
        NotificationCenter.default.addObserver(self, selector: #selector(myNotificationHandler), name: NSNotification.Name(rawValue: "myNotificationViewMemo"), object: nil)

        
        self.view.addSubview(self.backgroundImageView)
        self.setupGesture()
        self.freshMemoView()
        
        //to save cloud
        
        if let currentDesktop = self.currentDesktop, let name=currentDesktop.name, let count = currentDesktop.memos?.count {
            Util.saveAccessLog("Board",memo:"Access Board,Name:\(name),MemoCount=\(count)")
        }else{
            Util.saveAccessLog("Board",memo:"Access Board")
        }
        
//        setupBackgroundImage()
    }
    
    @objc func myNotificationHandler(notification:Notification ){
        Util.printLog("--------myNotificationHandler called---------")
        guard let userInfo = notification.userInfo,
            let cdMemo  = userInfo["CDMemo"] as? CDMemo, let cdDesktop = cdMemo.desktop else {
                Util.printLog("--------No userInfo found in notification")
                return
        }
        self.currentDesktop = cdDesktop
        self.freshMemoView()
        let locateMemoView = self.memoViewList.filter { (memoView) -> Bool in
            if memoView.memo.cdMemo?.id == cdMemo.id {
                
                return true
            }else{
                Util.printLog("======need attention, not found memoview at myNotificationHandler")
                Util.saveAccessLog("myNotificationHandler*error",memo:"Error: not found memoview at myNotificationHandler \(#function)-\(#line)")
                return false
            }
        }
        if let mv = locateMemoView.first {
            mv.center = self.view.center
            self.view.bringSubviewToFront(mv)
        }
        
    }
//    func saveAccessLog() {
//        AccessLogCloudService().save("Board", memo:"Access Board") { result in
//            if result.isSuccess {
//                Util.printLog("Success to save log")
//            }else{
//                Util.printLog("failed to save log:\(String(describing: result.error))")
//            }
//        }
//    }
    func setupGesture() {
        let tap2Gesture = UITapGestureRecognizer()
        tap2Gesture.numberOfTapsRequired = 2
        tap2Gesture.addTarget(self, action: #selector(tap2GestureHandle))
        self.view.addGestureRecognizer(tap2Gesture)
    }
    
    @objc func tap2GestureHandle(_ sender: UITapGestureRecognizer) {
//        self.buttonSoundSoso.play()
        //avoid too many taps
        if ( Date().timeIntervalSince(self.lastDoubleTapTime)) < 2 {
            Util.printLog("tap2GestureHandle less time!")
            return
        }
        self.lastDoubleTapTime =  Date()
        if !self.isInEditing {
            self.createMemo()
        }else{
            self.editMemoView.memoView?.endEditing(true)
            self.editMemoView.memoView?.saveAndClose()
        }
    }

    func isEditMemoViewExisting() -> Bool {
        for view in self.view.subviews {
            if view is EditMemoView  {
                return true
            }
        }
        return false
    }
    
    func freshMemoView() {
        setupBackgroundImage()
        deleteMemoViews()
        
//        self.memoList = fetchMemo()
        let memoList = fetchMemo()
        showMemo(memoList)
    }
    
    func deleteMemoViews() {
//        for subview in  self.view.subviews {
//            if let v = subview as? MemoView {
//                v.removeFromSuperview()
//            }
//        }
        for mview in self.memoViewList {
            mview.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //for switch back the VC from other presented(Desktop,MemoTableVC), show/hide mainFloatButton
        super.viewDidAppear(animated)

        if DefaultService.isFirstStart() {
            UIUtil.gotoQuickStartPage(self)
        }

        Util.printLog("=========Board viewDidAppear called=======")
        if !self.isInEditing {
            mainFloatButton.show()
        }else{
            mainFloatButton.hide()
        }
        
        //use local delegate for mainbutton hiden after dismiss password view
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if DefaultService.isPasswordEnabled() && appDelegate.isFistTimeStartForPassword{
                appDelegate.isFistTimeStartForPassword = false
                self.showPasswordView()
            }
        }
//        if DefaultService.isPasswordEnabled() && isFistTimeStartForPassword {
//
//            self.isFistTimeStartForPassword = false
//            //            PasswordAuthService.showPassword()
//            self.showPasswordView()
//        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//    }
    //for open other vc hiden mainFloatButton, i.e, desktop and MemoTableVC
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainFloatButton.hide()
    }

    func setupBackgroundImage() {
//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        if let desktop = self.currentDesktop,let imgData = desktop.backImageContent  {
            backgroundImageView.image = UIImage(data: imgData)
        } else {
            //for default backgroundImage
        //        backgroundImage.image = UIImage(named: "desktop_background1")
        }
//        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func fetchMemo() -> [Memo] {
        guard let currentDesk = self.currentDesktop else {
            Util.printLog("========NO current Desktop set")
            return []
        }
        return MemoService().queryCurrentDesktopUndeletedMemos(currentDesk)
        
    }
    
    func showMemo(_ memoList:[Memo]) {
        self.memoViewList = []
        for memo in memoList {
            let view = showMemo(memo)
            self.memoViewList.append(view)
        }
    }
    
    func showMemo(_ memo: Memo) -> MemoView {
        let v = MemoView( memo: memo )
        v.boardViewController = self
//        v.textAlignment = .left
//        v.font = UIFont(name: "Helvetica", size: 30)
        reArrangeIfOutSide(v)
        v.delegate = self
        v.isEditable = false
        v.isSelected = false
        v.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin]
        animateShowMemo(v)
        
        return v
    }
    
    //re-arrange memoView to self.view.center + random x y[10-30]
    //portal <-> landscape cause location outside of board view
    func reArrangeIfOutSide(_ memoView: MemoView) {
        let frame = memoView.frame
        if !frame.intersects(self.view.bounds) {
            let randomNum = Int(arc4random_uniform(UInt32(20)))
            let x = CGFloat(randomNum + 10)
            let y = x
            let center = CGPoint(x: self.view.center.x + x, y: self.view.center.y + y)
            Util.printLog("Re-arrange center:\(center)")
            memoView.center = center
        }
    }
    
    //animate show memoView from 4 direction
    func animateShowMemo(_ memoView: MemoView) {
        let randomNum = Int(arc4random_uniform(UInt32(3)))
        //animate show
        switch randomNum {
        case 0,1:
            let beforeY = randomNum == 0 ? self.view.frame.height : memoView.frame.height * -1
            
            //save original location, restore after animate
            let originalY = memoView.frame.origin.y
            memoView.frame.origin.y += beforeY
            self.view.addSubview(memoView)
            UIView.animate(withDuration: 0.75, delay: 0.1, options: .curveEaseInOut, animations: {
                memoView.frame.origin.y = originalY
            }, completion:{ b in  })
        case 2,3:
            let beforeX = randomNum == 2 ? self.view.frame.width : memoView.frame.width * -1
            let originalX = memoView.frame.origin.x
            memoView.frame.origin.x += beforeX
            self.view.addSubview(memoView)
            UIView.animate(withDuration: 0.75, delay: 0.1, options: .curveEaseInOut, animations: {
                memoView.frame.origin.x = originalX
            }, completion:{ b in  })
            
//            let originalY = memoView.frame.origin.y
//            memoView.frame.origin.y -=  memoView.frame.height
//            self.view.addSubview(memoView)
//            UIView.animate(withDuration: 0.75, delay: 0.1, options: .curveEaseInOut, animations: {
//                memoView.frame.origin.y = originalY
//            }, completion:{ b in  })
        
        default:
            self.view.addSubview(memoView)
        }
    }
    
    func createMemo() {
        self.buttonSoundDing.play()
        
        if let currentDesktop = self.currentDesktop {
            let memo = MemoService().createMemo(currentDesktop)
            memo.position = getDefaultLocation()
            memo.displayStyle = getDefualtDisplayStyle()
            memo.backgroundImage = getDefaultBackgroundImage()
//            memo.cdMemo?.desktop = currentDesktop
            let view = showMemo(memo)
            self.memoViewList.append(view)
            memo.save()
        }
    }
    
    func getDefaultLocation() -> Position {
        //default width = view.frame.width * 0.6 or 400
        let width:CGFloat =  min(400, self.view.frame.width * 0.6 )
        let height:CGFloat = width//min(400,self.view.frame.height * 0.7 )
        let x = self.view.frame.width / 2 - width / 2
        let y = self.view.frame.height / 2 - height / 2
        return  Position(x: x, y: y, width: width, height: height, rotate: 0)
    }
    
    func getDefaultBackgroundImage() -> BackgroundImage {
        
        //let backgroundImage = BackgroundImage(name: "bg_roundrect_star", tintColor: .blue, edgeTop: 20, edgeLeft: 10, edgeBottom: 10, edgeRight: 20)
        if let defaultValues = DefaultService.getDefault(), let imgName = defaultValues.bkImageName, let color = defaultValues.bkImageColorHex, let imgData = defaultValues.bkImageData, let img = UIImage(data: imgData)  {
            let backgroundImage = BackgroundImage(name: imgName, tintColorHex: color, edgeTop: CGFloat(defaultValues.bkImageTop), edgeLeft: CGFloat(defaultValues.bkImageLeft), edgeBottom: CGFloat(defaultValues.bkImageBottom), edgeRight: CGFloat(defaultValues.bkImageRight), imageData: img.pngData())
            return backgroundImage
        } else {

            let imgName = AppDefault.defaultBackgoundImageName
            let colorHex = AppDefault.defaultBackgoundImageColorHex
            
            let imgdata = UIImage(named:imgName) 
            return BackgroundImage(name: imgName, tintColorHex: colorHex, edgeTop: 10, edgeLeft: 10, edgeBottom: 10, edgeRight: 10,imageData:imgdata!.pngData() )
        }
    }
    
    func getDefualtDisplayStyle() -> DisplayStyle {
        if let defaultValues = DefaultService.getDefault(), let font = defaultValues.textFontName, let colorHex = defaultValues.textColorHex {
            let savedStyle = DisplayStyle(fontName: font, fontSize: CGFloat(defaultValues.textFontSize), textColorHex: colorHex)
            return savedStyle
        } else {
            return  DisplayStyle(fontName: DefaultService.defaultFontName, fontSize: DefaultService.defaultFontSize, textColorHex: DefaultService.defaultTextColorHex)
        }
        
    }
}

