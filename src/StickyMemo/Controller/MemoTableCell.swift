//
//  MemoTableCell.swift
//  StickyMemo
//
//  Created by alex on 2017/12/10.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class MemoTableSectionHeaderCell:UITableViewCell {
    
    
    var labelDesktopName: UILabel = {
       let v = UILabel()
//        v.text = "long long longlong long long  longlong long long  longlong long long"
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.boldSystemFont(ofSize: 18)
        return v
    }()
    var buttonDesktop:UIButton = {
       let v = UIButton()
        v.setImage(UIImage(named:"button_main"), for: .normal)
//        v.backgroundColor = .blue
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
//    var buttonOpenClose:UIButton = {
//       let v = UIButton()
//        v.setTitle("open", for: .normal)
////        v.backgroundColor = .red
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//    lazy var contentStackView:UIStackView = {
//       let v = UIStackView(arrangedSubviews: [labelDesktopName,buttonDesktop])
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.axis = .horizontal
//        v.distribution = .fill
//        return v
//    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
//        self.backgroundColor = .red
//        self.addSubview(self.contentStackView)
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":contentStackView]))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: nil, views: ["v0":contentStackView]))

        self.addSubview(self.labelDesktopName)
        self.addSubview(self.buttonDesktop)
//        self.addSubview(self.buttonOpenClose)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-|", options: [], metrics: nil, views: ["v0":labelDesktopName]))
        
//         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]-|", options: [], metrics: nil, views: ["v0":buttonOpenClose]))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]-|", options: [], metrics: nil, views: ["v0":buttonDesktop]))
        
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0][v1(30)]-[v2(60)]-|", options: [], metrics: nil, views: ["v0":labelDesktopName, "v1":buttonDesktop,"v2":buttonOpenClose]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0][v1(30)]-|", options: [], metrics: nil, views: ["v0":labelDesktopName, "v1":buttonDesktop]))
        
//        self.backgroundColor = .gray
    }
    
    
    
}

class MemoTableCell:UITableViewCell {
    
//    lazy var photoCollectionView: PhotoCollectionView = {
//        let height = floor(self.contentView.frame.width / 2)
//        let width = height //* 9 / 6
//        let v = PhotoCollectionView(frame: .zero, cellWidth: width, cellHeight: height )
////        v.backgroundColor = .red
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
//    lazy var photoImageView: UIImageView = {
//        let v = UIImageView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
    
    lazy var labelDate: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        //        v.backgroundColor = .red
        v.numberOfLines = 0
        return v
    }()
    
    lazy var labelContentText: UILabel = {
       let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
//        v.backgroundColor = .red
        return v
    }()
    
    lazy var buttonFavorited: UIButton = {
        let v = UIButton() //frame:CGRect(x: 0, y: 0, width: 20, height: 20))
//        v.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named:"button_favorited_small")?.withRenderingMode(.alwaysTemplate)
        v.setImage(image, for: .normal)
//        v.addTarget(self, action: #selector(buttonFavoritedTap), for: .touchUpInside)
        return v
    }()
    
//    lazy var favoritedImageView: UIImageView = {
//        let v = UIImageView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
//        //        v.translatesAutoresizingMaskIntoConstraints = false
//        v.image = UIImage(named:"button_favorited")?.withRenderingMode(.alwaysTemplate)
//
//        return v
//    }()
    
    
    lazy var buttonPhoto:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_photo_small"), for: .normal)
        v.setTitleColor(.black, for: .normal)
//        v.setTitle("99", for: .normal)
//        v.contentHorizontalAlignment = .right
//        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(buttonPhotoTap(_ :)), for: .touchUpInside)
        return v
    }()
    
    lazy var buttonEdit:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_edit_small"), for: .normal)
        v.setTitleColor(.black, for: .normal)
        //        v.setTitle("99", for: .normal)
        //        v.contentHorizontalAlignment = .right
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.addTarget(self, action: #selector(buttonPhotoTap(sender:)), for: .touchUpInside)
        return v
    }()
    
    lazy var buttonDelete:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_trash_small"), for: .normal)
//        v.setTitleColor(.black, for: .normal)
        //        v.setTitle("99", for: .normal)
//        v.contentHorizontalAlignment = .right
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.addTarget(self, action: #selector(buttonPhotoTap(sender:)), for: .touchUpInside)
        return v
    }()
    
    lazy var buttonRestore:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_restore_small"), for: .normal)
        v.isHidden = true
        return v
    }()
    
    lazy var buttonMail:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_mail_small"), for: .normal)
        return v
    }()
    
    lazy var buttonShare:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_share_small"), for: .normal)
        return v
    }()
    
    lazy var buttonMove:UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named:"button_move_small"), for: .normal)
        return v
    }()
    
    lazy var topButtonBackgroundView:UIView = {
        let v = UIView()
//        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var topStackView:UIStackView = {
       let v = UIStackView(arrangedSubviews: [self.buttonEdit, self.buttonMail,self.buttonShare,self.buttonMove,self.buttonFavorited,self.buttonRestore,self.buttonPhoto,self.buttonDelete])
//        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.distribution = .equalCentering
        return v
    }()

//    lazy var bottomStackView:UIStackView = {
//        let v = UIStackView(arrangedSubviews: [ self.buttonDelete,self.buttonEdit,self.buttonPhoto])
//        //        let v = UIStackView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.axis = .horizontal
//        v.distribution = .fillEqually
//        return v
//
//    }()
    
//    lazy var memoTextView: UITextView = {
//       let v = UITextView()
//        v.translatesAutoresizingMaskIntoConstraints = false
////        v.attributedText = ""
////        v.text = "AAAAAAA"
//        v.isEditable = false
////        v.isScrollEnabled = true
////        v.layer.cornerRadius = 5
////        v.clipsToBounds = true
//
//        let tap1Gesture  = UITapGestureRecognizer(target: self, action: #selector(tap1Handler))
//        tap1Gesture.numberOfTapsRequired = 1
////
////        let tap2Gesture  = UITapGestureRecognizer(target: self, action: #selector(tap2Handler))
////        tap2Gesture.numberOfTapsRequired = 2
////
////        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureHandler(_:)))
////
////        v.gestureRecognizers = [tap1Gesture,tap2Gesture,longPressGesture]
//        v.gestureRecognizers = [tap1Gesture]
//        return v
//    }()
    
//    var imageDataList:[Data]?
    var photoUIImageList:[UIImage]?
    var memo:Memo? {
        didSet {
            guard let memo = memo else {
                return
            }
            labelDate.attributedText = memo.updateDateAttributedText
            labelDate.backgroundColor = memo.backgroundImage.tintColor
            
            if memo.isFavorited {
                buttonFavorited.tintColor = .red
//                favoritedImageView.isHidden = false
            }else {
//                favoritedImageView.tintColor = memo.backgroundImage.tintColor
//                favoritedImageView.isHidden = true
                buttonFavorited.tintColor = UIColor.lightGray
            }
//            favoritedImageView.backgroundColor = memo.backgroundImage.tintColor
            
            labelContentText.attributedText = memo.contentAttributedText
            labelContentText.backgroundColor = memo.backgroundImage.tintColor
       
//            if let images = self.getImageList(memo.cdMemo){
//            if let images = self.getImageList(memo.cdMemo), images.count > 0 {
            if let images = memo.getPhotoUIImageList(), images.count > 0 {
//                self.photoCollectionView.imageDataList = images
//                let height = self.contentView.frame.width / 2
////                Util.printLog("photo height:\(height)")
//                self.photoCollectionView.isHidden = false
//                self.photoViewHeightConstraint?.constant = height
                
                
                self.buttonPhoto.setTitle("\(images.count)", for: .normal)
                self.buttonPhoto.isHidden = false
    
//                self.imageDataList = images
                self.photoUIImageList = images
                //
                //        let imageList = imageDataList.flatMap{ return UIImage(data: $0)}
                //
                
            } else {
                self.buttonPhoto.isHidden = true
//                self.photoCollectionView.isHidden = true
                self.photoViewHeightConstraint?.constant = 0
            }
            //set background color
            self.buttonPhoto.backgroundColor = memo.backgroundImage.tintColor
//            self.photoCollectionView.backgroundColor = memo.backgroundImage.tintColor
            self.topButtonBackgroundView.backgroundColor = memo.backgroundImage.tintColor
//            self.contentView.layoutIfNeeded()
        }
    }
    
    var photoFullScreenView: PhotoFullScreenView?
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    
    @objc func buttonPhotoTap(_ sender:UIButton) {
        self.buttonSoundDing.play()
        guard let imageList = self.photoUIImageList else { return }
//        guard let imageDataList = self.imageDataList else { return }
//        let imageList = imageDataList.flatMap{ return UIImage(data: $0)}

        if let keyWindow = UIApplication.shared.keyWindow {
            var keyframe = keyWindow.convert((sender.frame), from: sender.superview)
            //            print(keyframe)
            
            keyframe = CGRect(origin: CGPoint(x: keyframe.origin.x + 8, y: keyframe.origin.y + 12)  , size: CGSize(width: 5, height: 5)  )
//            keyframe = CGRect(x: keyframe.minX + 5, y: keyframe.minY + 5, width: 5, height: 5)
            photoFullScreenView = PhotoFullScreenView(imageList, currentIndex: 0, startFrame: keyframe)
            photoFullScreenView?.show()
        
        }
    }
//    func getImageList(_ cdMemo: CDMemo?) -> [Data]? {
//        if let images = cdMemo?.images,let imageArray = Array(images) as? [CDImage] {
//            let sortedImages = imageArray.sorted{
////                return $0.id < $1.id
//                if let createAt1 = $0.createAt, let createAt2 = $1.createAt {
//                    return createAt1 < createAt2
//                }else{
//                    return false
//                }
//            }
//            let imageList = sortedImages.map{
//                return $0.imageContent
//            }
//            if let imageList = imageList as? [Data] {
//                return imageList
//            }
//            
//        }
//        return nil
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    var photoViewHeightConstraint:NSLayoutConstraint?
//    var memoTextViewHeightConstraint:NSLayoutConstraint?
    
    func setupViews() {
        
        self.contentView.addSubview(topButtonBackgroundView)
        topButtonBackgroundView.addSubview(self.topStackView)

        topButtonBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
        topButtonBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
        
                self.contentView.addSubview(self.labelDate)
        self.contentView.addSubview(self.labelContentText)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelDate]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topButtonBackgroundView]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelContentText]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topBackView(30@750)][labelDate(20@700)][labelContentText]|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"topBackView":topButtonBackgroundView,"labelDate":self.labelDate]))
        
//        contentView.addSubview(photoCollectionView)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":photoCollectionView]))
        
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[topBackView(30@750)][labelDate(20@700)][labelContentText][photoCollectionView(0@700)]-|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"topBackView":topButtonBackgroundView,"labelDate":self.labelDate,"photoCollectionView":photoCollectionView]))
//        photoViewHeightConstraint =  photoCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0) //.constraint(equalToConstant: 0)
//        photoViewHeightConstraint?.isActive = true
        
    }
    
    // with photoCollectionView, always layout warining:
//
//    Will attempt to recover by breaking constraint
//    <NSLayoutConstraint:0x6040002880c0 StickyMemo.PhotoCollectionView:0x7faa30449b60.height >= 160   (active)>
//
//    Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
//    The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.
//    2017-12-22 09:23:29.711249+0800 StickyMemo[34442:3522302] The behavior of the UICollectionViewFlowLayout is not defined because:
//    2017-12-22 09:23:29.711390+0800 StickyMemo[34442:3522302] the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values.
//    2017-12-22 09:23:29.711837+0800 StickyMemo[34442:3522302] The relevant UICollectionViewFlowLayout instance is <UICollectionViewFlowLayout: 0x7faa30449d80>, and it is attached to <UICollectionView: 0x7faa3116b200; frame = (0 0; 304 12); clipsToBounds = YES; gestureRecognizers = <NSArray: 0x60400044d7a0>; layer = <CALayer: 0x60400043ff80>; contentOffset: {0, 0}; contentSize: {0, 0}; adjustedContentInset: {0, 0, 0, 0}> collection view layout: <UICollectionViewFlowLayout: 0x7faa30449d80>.
//    2017-12-22 09:23:29.711995+0800 StickyMemo[34442:3522302] Make a symbolic breakpoint at UICollectionViewFlowLayoutBreakForInvalidSizes to catch this in the debugger.
//
//
//    func setupViews() {
//
//        self.contentView.addSubview(topButtonBackgroundView)
//        topButtonBackgroundView.addSubview(self.topStackView)
//
//        topButtonBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
//        topButtonBackgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
//
//        self.contentView.addSubview(self.labelDate)
//        self.contentView.addSubview(self.labelContentText)
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelDate]))
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topButtonBackgroundView]))
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelContentText]))
//
//        contentView.addSubview(photoCollectionView)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":photoCollectionView]))
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[topBackView(30@750)][labelDate(20@700)][labelContentText][photoCollectionView(0@700)]-|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"topBackView":topButtonBackgroundView,"labelDate":self.labelDate,"photoCollectionView":photoCollectionView]))
//        photoViewHeightConstraint =  photoCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0) //.constraint(equalToConstant: 0)
//        photoViewHeightConstraint?.isActive = true
//
//    }
    
    
    
    
    
    
//    func setupViews() {
//
//        self.contentView.addSubview(topStackView)
//
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
//
//
////        self.contentView.addSubview(self.labelDate)
//        self.contentView.addSubview(self.labelContentText)
//
////        let width = self.frame.width / 4
////        let heigh = width
////        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelDate]))
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelContentText]))
//
////        self.contentView.addSubview(bottomStackView)
////        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(150)]-|", options:[], metrics:nil, views: ["v0":bottomStackView]))
////
////        self.labelDate.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
////        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topStackView(30@751)][labelDate(20@750)][labelContentText]|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"topStackView":topStackView,"labelDate":self.labelDate]))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[topStackView][labelContentText]-|", options:[], metrics:nil, views: ["labelContentText":labelContentText,"topStackView":topStackView,"labelDate":self.labelDate]))
//
////        photoViewHeightConstraint =  photoCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0) //.constraint(equalToConstant: 0)
////        photoViewHeightConstraint?.isActive = true
//
//    }

//    func setupViews() {
//
//        self.contentView.addSubview(topStackView)
//
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
//
//
//        self.contentView.addSubview(labelText)
//
//        //        let width = self.frame.width / 4
//        //        let heigh = width
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelText]))
//
//        self.contentView.addSubview(bottomStackView)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(150)]-|", options:[], metrics:nil, views: ["v0":bottomStackView]))
//
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topStackView][v0][bottomStackView]|", options:[], metrics:nil, views: ["v0":labelText,"topStackView":topStackView,"bottomStackView":bottomStackView]))
//
//
//        //        photoViewHeightConstraint =  photoCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0) //.constraint(equalToConstant: 0)
//        //        photoViewHeightConstraint?.isActive = true
//
//    }
//
//    
//    func setupViews() {
//
//        self.contentView.addSubview(topStackView)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":topStackView]))
//
//        self.contentView.addSubview(labelText)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":labelText]))
//
//        self.contentView.addSubview(photoCollectionView)
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options:[], metrics:nil, views: ["v0":photoCollectionView]))
//
//        //        let height = floor(self.contentView.frame.width / 2) + 10
//
//        //        Util.printLog("======\(self.contentView.frame.width)=====\(height)")
//        //        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topStackView][v0][v1]|", options:[], metrics:["height":height], views: ["v0":labelText,"v1":photoCollectionView,"topStackView":topStackView]))
//
//        //        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topStackView][v0][v1]|", options:[], metrics:nil, views: ["v0":labelText,"v1":photoCollectionView,"topStackView":topStackView]))
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topStackView][v0][v1]|", options:[], metrics:nil, views: ["v0":labelText,"v1":photoCollectionView,"topStackView":topStackView]))
//
//        photoViewHeightConstraint =  photoCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0) //.constraint(equalToConstant: 0)
//        photoViewHeightConstraint?.isActive = true
//
//    }
//
//
//    @objc func tap1Handler(_ sender : UIRotationGestureRecognizer) {
//        Util.printLog("Tap1 handler called")
//
//        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.allowUserInteraction,.curveEaseInOut], animations: {
//            self.transform = CGAffineTransform.identity
//        }, completion: { b in
//            if b {
//
//            }
//        })
//
//    }
//
//    @objc func tap2Handler(_ sender : UIRotationGestureRecognizer) {
//        Util.printLog("Tap2 handler called")
//    }
//
//    @objc func longPressGestureHandler(_ sender : UIRotationGestureRecognizer) {
//        Util.printLog("Long Tap handler called")
//    }
}

