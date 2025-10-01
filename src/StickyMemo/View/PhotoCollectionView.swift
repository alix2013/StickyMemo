//
//  PhotoCollectionView.swift
//  StickyMemo
//
//  Created by alex on 2017/12/12.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class PhotoCell:UICollectionViewCell {
    
    var imageData:Data? {
        didSet {
            guard let imageData = imageData else { return  }
            self.imageView.image = UIImage(data: imageData)
        }
        
    }
    var imageView:UIImageView = {
       let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(imageView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":imageView]))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":imageView]))
    }
    
}


class PhotoCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    override var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    var imageDataList:[Data]?
    let cellId:String = "cellID"
    var cellWidth:CGFloat
    var cellHeight:CGFloat
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets.zero;
        layout.footerReferenceSize = .zero;
        layout.headerReferenceSize = .zero;
//        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        layout.scrollDirection = .horizontal
    
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout )
        cv.contentInset = .zero
//        cv.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        cv.dataSource =  self
        cv.delegate =  self
//        cv.backgroundColor = .red
        //(cv.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
        
    }()
    
    var photoQuickView: PhotoFullScreenView?
    
    init(frame: CGRect,cellWidth:CGFloat, cellHeight:CGFloat) {
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        super.init(frame:frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(collectionView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))
        
        self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imageDataList = self.imageDataList {
            return imageDataList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCell
        if let imageDataList = self.imageDataList {
            cell.imageData = imageDataList[indexPath.item]
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth , height: cellHeight )
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        Util.printLog("selected photo index:\(indexPath)")
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
//        print(cell.frame)
//        let cellFrame1 = self.superview?.convert((cell.frame), from: cell.superview)
//        print(cellFrame1)
//        let cellFrame2 = self.superview?.superview?.superview?.convert((cell.frame), from: cell.superview)
//        print(cellFrame2)
        
        guard let imageDataList = self.imageDataList else { return }
        
//        let imageList = imageDataList.flatMap{ return UIImage(data: $0)}
        let imageList = imageDataList.compactMap{ return UIImage(data: $0)}
        
        if let keyWindow = UIApplication.shared.keyWindow {
            let keyframe = keyWindow.convert((cell.frame), from: cell.superview)
            //            print(keyframe)
            
            photoQuickView = PhotoFullScreenView(imageList, currentIndex: indexPath.row, startFrame: keyframe)
            photoQuickView?.show()
        }
    }
}



