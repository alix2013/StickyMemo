//
//  StyleView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//
import UIKit

enum StyeViewStyle {
    case fontSize
//    case alignment
    case fontName
    case fontColor
    case backgroundImage
}

class StyleView:NSObject, MemoBackgroundImageCatalogTableViewDelegate,MemoBackgroundImageTableViewDelegate {
    
    // just for present IAP alert VC
    var boardViewController: BoardViewController?
    
    //for selected image template delegate
    func onCompletedSelectImage(_ tableView: MemoBackgroundImageTableView, selectedImageTemplate: BKImageTemplate) {
        guard let memoView = self.memoView else { return }
        
        if selectedImageTemplate.isLocked, let vc = self.boardViewController {
            self.dismiss()
            UIUtil.goStickerShop(vc)
        } else {
            memoView.backgroundImageTemplate = selectedImageTemplate
        }
    }
    
//    func onCompletedSelect(_ tableView: MemoBackgroundImageCatalogTableView, selectedBackground: BackgroundImageTemplate) {
    func onCompletedSelect(_ tableView: MemoBackgroundImageCatalogTableView, selectedBackground: BKImageCatalog) {


//        if let imgList = BackgroundImageGallery.getBackgroundImageTemplatesByCatalog(selectedBackground) {
//            self.backgroundImageTableView.imageList = imgList
////            print("selected count:\(imgList.count)")
//        }
//        if selectedBackground.isLocked, let vc = self.boardViewController {
//            self.dismiss()
//            UIUtil.goStickerShop(vc)
//        } else {
        
        self.backgroundImageTableView.imageList = selectedBackground.imageTemplate
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //            self.backView.alpha = 0
//            self.memoBackImageCatalogTableView.frame.origin.x += 100
//            self.backgroundImageTableView.frame.origin.x -= 100
            self.backImageLeftConstraint?.constant -= 130
            self.backImageCatalogLeftConstraint?.constant = 10
            
            self.backgroundImageTableView.superview?.layoutIfNeeded()
            
        },completion: { b in

        })
//        }
        
    }
    
    
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
//    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)

    var memoView: MemoView?
    
    var style: StyeViewStyle = .fontSize
    var alpha: CGFloat = 0.1
    
    lazy var backView:UIView = {
        let v = UIView()
//        v.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0, alpha: alpha)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        v.addGestureRecognizer(tapGesture)
        return v
    }()
    
    lazy var fontSizeSlider : UISlider = {
        let v = UISlider()
        v.maximumValue = 100
        v.minimumValue = 5
        v.addTarget(self, action: #selector(fontSizeChanged(_: )), for: .valueChanged)
        return v
    }()
    
//    lazy var alignmentSegment: UISegmentedControl =  {
//        let v = UISegmentedControl()
//        v.insertSegment(withTitle: "left", at: 0, animated: false)
//        v.insertSegment(withTitle: "center", at: 1, animated: false)
//        v.insertSegment(withTitle: "right", at: 2, animated: false)
//        v.addTarget(self, action: #selector(alignmentSegmentChanged(_ :)), for: .valueChanged)
//        return v
//    }()
    
//    lazy var buttonClose: UIButton  = {
//        let v = UIButton()
//        v.setImage(UIImage(named:"button_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        v.tintColor = .white
//        v.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
//        //        v.layer.borderColor = .white
//        return v
//    }()
//    
//    lazy var stackViewFontSize:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [buttonClose,fontSizeSlider])
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.axis = .vertical
//        v.distribution = .fill
//        v.spacing = 20
//        return v
//    }()
    
    
    lazy var fontTableView: FontTableView = {
        let v = FontTableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
//        v.backgroundColor = UIColor.lightGray
        v.memoView = self.memoView
        return v
    }()
    
    lazy var memoBackImageCatalogTableView: MemoBackgroundImageCatalogTableView = {
        let v = MemoBackgroundImageCatalogTableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.catalogDelegate = self
        v.rowHeight =  122
        //        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    lazy var backgroundImageTableView: MemoBackgroundImageTableView = {
        let v = MemoBackgroundImageTableView(frame:.zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.imageTemplateDelegate = self
        v.backgroundColor = .clear
        //        v.backgroundColor = UIColor.lightGray
        //        v.memoView = self.memoView
        v.rowHeight = 100
        return v
    }()
    
    
    lazy var colorTableView: ColorTableView = {
        let v = ColorTableView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        //        v.backgroundColor = UIColor.lightGray
        //        v.memoView = self.memoView
        v.rowHeight = 60
        return v
    }()
    
    
    var fontColorLeftConstraint:NSLayoutConstraint?
    var backImageCatalogLeftConstraint:NSLayoutConstraint?
    var backImageLeftConstraint:NSLayoutConstraint?
    var fontTableViewLeftContraint:NSLayoutConstraint?
    
//    lazy var styleContainerView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [fontSizeSlider,alignmentSegment,fontTableView])
//        //        v.translatesAutoresizingMaskIntoConstraints = false
//        v.axis = .vertical
//        v.distribution = .fill
//        v.spacing = 10
//        return v
//    }()
//
    override init() {
        super.init()
        
//        if let window = UIApplication.shared.keyWindow {
//            window.addSubview(backView)
////            window.addConstraint(NSLayoutConstraint()
////            self.translatesAutoresizingMaskIntoConstraints = false
//            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics:nil, views: ["v0":backView]))
//            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics:nil, views: ["v0":backView]))
//
//
//        }
        
    }
    
    func getBackgroundImage(_ background: BackgroundImage ) -> UIImage? {
        let imgName = background.name
        var ret: UIImage?
        
        //        resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        if let image = UIImage(named: imgName) {
            ret = image.resizableImage(withCapInsets: UIEdgeInsets(top: background.edgeTop, left: background.edgeLeft, bottom: background.edgeBottom, right: background.edgeRight))
        }else{
            return nil
        }
        return ret
    }
    //    var styleViewBottomLayout : NSLayoutConstraint?
    
    @objc func fontSizeChanged(_ sender: UISlider) {
        //        print(sender.value)
//        let f = self.memoView?.font
//        self.memoView?.font = UIFont(name: (f?.fontName)!, size: CGFloat(Int(sender.value)))
        
        if let f = self.memoView?.font {
            let fontName = f.fontName
            self.memoView?.font = UIFont(name: fontName, size: CGFloat(Int(sender.value)))
        }
        
    }

    /*
    @objc func alignmentSegmentChanged(_ sender: UISegmentedControl) {
        //        print(sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case 0:
            self.memoView?.textAlignment = .left
        case 1:
            self.memoView?.textAlignment = .center
        case 2:
            self.memoView?.textAlignment = .right
        default:
            break
        }
    }
    */
    
    
    @objc func dismiss() {
        //        print("dismiss called")
        self.buttonSoundDing.play()
        self.backView.removeFromSuperview()
        switch self.style {
        case .fontSize:
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //            self.backView.alpha = 0
                self.fontSizeSlider.frame.origin.x += 55
            },completion: { b in
                self.fontSizeSlider.removeFromSuperview()
                
            })
        case .fontName :
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //            self.backView.alpha = 0
                self.fontTableViewLeftContraint?.constant = 0
                self.fontTableView.superview?.layoutIfNeeded()
                
            },completion: { b in
                self.fontTableView.removeFromSuperview()
//                self.backView.removeFromSuperview()
//                self.stackViewFontTable.removeFromSuperview()
            })
            
       
        case .backgroundImage :
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //            self.backView.alpha = 0
//                self.fontTableView.frame.origin.x += 101
//                self.memoBackImageCatalogTableView.frame.origin.x += 100
//                self.backgroundImageTableView.frame.origin.x += 100
                self.backImageCatalogLeftConstraint?.constant = 10
                self.backImageLeftConstraint?.constant = 10
                self.backgroundImageTableView.superview?.layoutIfNeeded()
            },completion: { b in
                self.memoBackImageCatalogTableView.removeFromSuperview()
//                self.backView.removeFromSuperview()
                self.backgroundImageTableView.removeFromSuperview()
            })
            
        case .fontColor :
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //            self.backView.alpha = 0
//                self.colorTableView.frame.origin.x += 80
                self.fontColorLeftConstraint?.constant = 0
                self.colorTableView.superview?.layoutIfNeeded()
                
            },completion: { b in
                self.colorTableView.removeFromSuperview()
//                self.backView.removeFromSuperview()
            })
            
        }

        self.memoView?.restoreButtonLocation()
    }
    
    func setCurrentValues() {
        switch self.style {
        case .fontSize :
            if let font = self.memoView?.font{
                let size = font.pointSize
                self.fontSizeSlider.value = Float(size)
            }

        case .fontName:
            if let font = self.memoView?.font{
//                let size = font.pointSize
//                print("current font=====\(font)")
//                self.fontSizeSlider.value = Float(size)
//                Util.printLog("======font======")
//                Util.printLog(font.fontName)
                fontTableView.currentFontName = font.fontName

            }
        default:
            break
        }
        
        
        /*
        
        if let align = self.memoView?.textAlignment {
            switch align {
            case .left :
                self.alignmentSegment.selectedSegmentIndex = 0
            case .center :
                self.alignmentSegment.selectedSegmentIndex = 1
            case .right :
                self.alignmentSegment.selectedSegmentIndex = 2
            default:
                //                self.alignmentSegment.selectedSegmentIndex = 0
                break
            }
        }
 */
    }
    
    func show(_ style: StyeViewStyle) {
        self.style = style
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(backView)
//            backView.frame = window.frame
//            backView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics:nil, views: ["v0":backView]))
            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics:nil, views: ["v0":backView]))
            
            
            switch style {
            case .fontSize :
                showFontSizeSlider(window)
            case .fontName:
                showFontNameTable(window)
            case .backgroundImage:
                showMemoBackImageTable(window)
           
            case .fontColor:
                showMemoFontColorTable(window)
                
            }
            setCurrentValues()
            
        }
    }
    
//    private func showMemoFontColorTable(_ window:UIWindow) {
//        window.addSubview(self.colorTableView)
//        self.colorTableView.memoView = self.memoView
//
//        colorTableView.frame = CGRect(x: (window.frame.width), y: 20, width: window.frame.width , height: window.frame.height - 20)
//        colorTableView.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.colorTableView.frame.origin.x -= 80
//
//        }, completion: nil)
//    }
    
    
    
    private func showMemoFontColorTable(_ window:UIWindow) {
//        self.colorTableView.translatesAutoresizingMaskIntoConstraints = false
        self.colorTableView.memoView = self.memoView
        window.addSubview(self.colorTableView)
        
//        colorTableView.widthAnchor.constraint(equalToConstant: window.frame.width ).isActive = true
        colorTableView.widthAnchor.constraint(equalToConstant: 200 ).isActive = true
        colorTableView.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
        colorTableView.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        
        fontColorLeftConstraint = colorTableView.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
        
        fontColorLeftConstraint?.isActive = true
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.fontColorLeftConstraint?.constant -= 100
            window.layoutIfNeeded()
        }, completion: nil)
    }
    
//    private func showMemoBackImageTable(_ window:UIWindow) {
//
//        window.addSubview(self.memoBackImageCatalogTableView)
//        memoBackImageCatalogTableView.frame = CGRect(x: (window.frame.width), y: 20, width: window.frame.width , height: window.frame.height - 20)
//        memoBackImageCatalogTableView.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.memoBackImageCatalogTableView.frame.origin.x -= 100
//
//        }, completion: nil)
//
//        // add detailed backimagetableview
//        backgroundImageTableView.memoView = self.memoView
//        window.addSubview(self.backgroundImageTableView)
//
//        backgroundImageTableView.frame = CGRect(x: (window.frame.width), y: 20, width: window.frame.width, height: window.frame.height - 20)
//        backgroundImageTableView.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
//
//    }
    
    
    
    private func showMemoBackImageTable(_ window:UIWindow) {
        // query at show  every time for see unlocked catalog
        self.memoBackImageCatalogTableView.catalogImageList = BKImageTemplateService().getAllBKImageCatalogs()
//        self.memoBackImageCatalogTableView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self.memoBackImageCatalogTableView)
        
        memoBackImageCatalogTableView.widthAnchor.constraint(equalToConstant: 200 ).isActive = true
        memoBackImageCatalogTableView.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
        memoBackImageCatalogTableView.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        
        backImageCatalogLeftConstraint = memoBackImageCatalogTableView.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
        backImageCatalogLeftConstraint?.isActive = true
        window.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.memoBackImageCatalogTableView.frame.origin.x -= 100
            self.backImageCatalogLeftConstraint?.constant -= 130
            window.layoutIfNeeded()
        }, completion: nil)
        
        
        // add detailed backimagetableview
        backgroundImageTableView.memoView = self.memoView
        window.addSubview(self.backgroundImageTableView)
        
//        backgroundImageTableView.frame = CGRect(x: (window.frame.width), y: 20, width: window.frame.width, height: window.frame.height - 20)
//        backgroundImageTableView.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
        backgroundImageTableView.widthAnchor.constraint(equalToConstant: 200 ).isActive = true
        backgroundImageTableView.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
        backgroundImageTableView.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        
        backImageLeftConstraint = backgroundImageTableView.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
        backImageLeftConstraint?.isActive = true
        window.layoutIfNeeded()
        
    }
    
//    private func showFontNameTable(_ window:UIWindow) {
//
//        window.addSubview(self.fontTableView)
//        fontTableView.frame = CGRect(x: (window.frame.width), y: 20, width: window.frame.width / 3, height: window.frame.height - 20)
//        fontTableView.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.fontTableView.frame.origin.x -= window.frame.width / 3
//
//        }, completion: nil)
//
//    }
    
    
    private func showFontNameTable(_ window:UIWindow) {

        window.addSubview(self.fontTableView)

        fontTableView.widthAnchor.constraint(equalToConstant: 300 ).isActive = true
        fontTableView.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
        fontTableView.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true

        fontTableViewLeftContraint = fontTableView.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
        fontTableViewLeftContraint?.isActive = true
        window.layoutIfNeeded()

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //            self.fontTableView.frame.origin.x -= window.frame.width / 3
            self.fontTableViewLeftContraint?.constant -= min(window.frame.width / 2, CGFloat(250))
            window.layoutIfNeeded()
        }, completion: nil)

    }

    
//    private func showFontNameTable(_ window:UIWindow) {
//
//        window.addSubview(self.stackViewFontTable)
//        let width = min(window.frame.width / 2, CGFloat(250))
//        stackViewFontTable.widthAnchor.constraint(equalToConstant: width ).isActive = true
//        stackViewFontTable.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
//        stackViewFontTable.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
//
//        fontTableViewLeftContraint = stackViewFontTable.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
//        fontTableViewLeftContraint?.isActive = true
//        window.layoutIfNeeded()
//
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
////            self.fontTableView.frame.origin.x -= window.frame.width / 3
//            self.fontTableViewLeftContraint?.constant -= min(window.frame.width / 2, CGFloat(250))
//            window.layoutIfNeeded()
//        }, completion: nil)
//
//    }
    
    private func showFontSizeSlider(_ window:UIWindow) {
        // rotate for vertical
        fontSizeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(90 * Double.pi / 180 * -1 ))

        window.addSubview(self.fontSizeSlider)
        //            fontSizeSlider.center = CGPoint(x: window.frame.width/2, y: window.frame.height/2)
        fontSizeSlider.frame = CGRect(x: (window.frame.width), y: 20, width: 50, height: window.frame.height/2)

        fontSizeSlider.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //                self.styleContainerView.frame = CGRect(x:x,y: y, width:self.width, height:height)
            //                self.styleContainerView.frame.origin.y -=  height

            //                                self.backView.alpha = 1
            //                                self.styleContainerView.alpha = 1
            self.fontSizeSlider.frame.origin.x -= 50

        }, completion: nil)

    }
    
    
//    ///for button
//    private func showFontSizeSlider(_ window:UIWindow) {
//        // rotate for vertical
//        fontSizeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(90 * Double.pi / 180 * -1 ))
//
//        window.addSubview(self.fontSizeSlider)
//
//        buttonClose.translatesAutoresizingMaskIntoConstraints = false
//        window.addSubview(self.buttonClose)
//        buttonClose.frame = CGRect(x: (window.frame.width), y: 20, width: 50, height: 50)
//        //            fontSizeSlider.center = CGPoint(x: window.frame.width/2, y: window.frame.height/2)
////        fontSizeSlider.frame = CGRect(x: (window.frame.width), y: 20, width: 50, height: window.frame.height/2)
//
//        fontSizeSlider.frame = CGRect(x: (window.frame.width), y: 50, width: 50, height: window.frame.height/2)
//
//        fontSizeSlider.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.fontSizeSlider.frame.origin.x -= 50
//
//        }, completion: nil)
//
//    }
//
    
    
//    var fontSizeSliderLeftConstraint:NSLayoutConstraint?
//    private func showFontSizeSlider(_ window:UIWindow) {
//        // rotate for vertical
//        fontSizeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(90 * Double.pi / 180 * -1 ))
//
//        window.addSubview(self.fontSizeSlider)
//
//        fontSizeSlider.translatesAutoresizingMaskIntoConstraints = false
//        fontSizeSlider.widthAnchor.constraint(equalToConstant: window.frame.width ).isActive = true
//        fontSizeSlider.heightAnchor.constraint(equalToConstant: window.frame.height - 20 ).isActive = true
//        fontSizeSlider.topAnchor.constraint(equalTo: window.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
//
//        fontSizeSliderLeftConstraint = fontSizeSlider.leadingAnchor.constraint(equalTo: window.layoutMarginsGuide.trailingAnchor, constant: 0)
//        fontSizeSliderLeftConstraint?.isActive = true
//        window.layoutIfNeeded()
//
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
////            self.fontSizeSlider.frame.origin.x -= 50
//            self.fontSizeSliderLeftConstraint?.constant -= 50
//            window.layoutIfNeeded()
//        }, completion: nil)
//
//    }
//
}
