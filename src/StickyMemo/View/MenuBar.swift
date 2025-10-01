//
//  MenuBar.swift
//  StickyMemo
//
//  Created by alex on 2017/11/30.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class BaseCollectionViewCell:UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        beforeSetupViews()
        setupView()
        afterSetupViews()
    }
    
    func beforeSetupViews(){
        
    }
    func afterSetupViews(){
    }
    
    func setupView(){
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BaseMenuCell:BaseCollectionViewCell  {
    //    var isShowLineIndicator: Bool =  true
    var selectedTintColor: UIColor = .white
    var itemTintColor: UIColor = .black
    //    var lineIndicatorHeight: CGFloat = 4
    
    //    let horizonIndicatorLineView: UIView = {
    //        let v = UIView()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    
    override func setupView() {
        super.setupView()
        
    }
    func setStyle(_ itemTintColor: UIColor,selectedTintColor:UIColor) {
        
        
        self.itemTintColor = itemTintColor
        self.selectedTintColor = selectedTintColor
        
        
    }
    
}

class ImageMenuCell: BaseMenuCell {
    
    let imageView : UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    //    override var isHighlighted: Bool {
    //        didSet {
    //            if let mb = self.superview?.superview as? MenuBar {
    //                imageView.tintColor = isSelected ? mb.selectedItemTintColor : mb.menuItemTintColor//UIColor.rgb(red:91, green: 14, blue: 13)
    //            }else{
    //                //                imageView.tintColor = isSelected ? .white : .black
    //            }
    //        }
    //    }
    var isAnimateSelected:Bool = true
    
    override var isSelected: Bool {
        didSet {
            imageView.tintColor = isSelected ? selectedTintColor : itemTintColor
            if isSelected && isAnimateSelected {
                self.animateButton(imageView)
            }
        }
    }
    
    func animateButton(_ sender:UIView) {
        sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform.identity
        }, completion: { b in
            if b {
            }
        })
    }
    override func setupView() {
        super.setupView()
        // get init values from MenuBar
        addSubview(imageView)
        
        //        NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(28)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : imageView])
        //
        //        NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(28)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : imageView])
        //
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
    }
    
    
}

class TextMenuCell: BaseMenuCell {
    
    
    let labelText : UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    //    override var isHighlighted: Bool {
    //        didSet {
    //            if let mb = self.superview?.superview as? MenuBar {
    //                imageView.tintColor = isSelected ? mb.selectedItemTintColor : mb.menuItemTintColor//UIColor.rgb(red:91, green: 14, blue: 13)
    //            }else{
    //                //                imageView.tintColor = isSelected ? .white : .black
    //            }
    //        }
    //    }
    override var isSelected: Bool {
        didSet {
            labelText.textColor = isSelected  ? selectedTintColor : itemTintColor
        }
    }
    
    override func setupView() {
        super.setupView()
        addSubview(labelText)
        
        addConstraint(NSLayoutConstraint(item: labelText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: labelText, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
    }
    
}


enum MenuBarStyle {
    case imageList
    case textList
}

protocol MenuBarDelegate {
    func onSelected(_ selectedIndex: Int,sender: UIView)
}



class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate : MenuBarDelegate?
    var imageList:[UIImage] = []
    var textList: [String] = []
    var style: MenuBarStyle = .imageList
    
    let cellID = "Cell"
    
    var menuItemTintColor : UIColor = .red
    var selectedItemTintColor : UIColor = .white
    
    var isShowLineIndicator:Bool = true
    var lineIndicatorHeight:CGFloat = 4
    var lineIndicatorLeft:NSLayoutConstraint?
    
    lazy var horizonIndicatorLineView: UIView = {
        let v = UIView()
        v.backgroundColor = self.selectedItemTintColor
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var selectedIndex: Int = 0 {
        didSet {
            let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
            collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
            
            collectionView.scrollToItem(at: selectedIndexPath, at:.centeredHorizontally, animated: true)
            //collectionView.scrollToItem(at: selectedIndexPath, at:[], animated: true)
            
            showLineIndicator(selectedIndexPath)
            
            if let delegate = delegate {
                delegate.onSelected(selectedIndex, sender: self)
            }
        }
    }
    
    lazy var cellHeight:CGFloat = {
        return CGFloat(self.frame.height)
    }()
    
    lazy var cellWidth: CGFloat  = 50
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout )
        
        cv.dataSource =  self
        cv.delegate =  self
        
        //(cv.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
        
    }()
    
    override var backgroundColor : UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    override init(frame: CGRect) {
    //        super.init(frame: frame)
    //        setupView()
    //    }
    
    init(frame: CGRect, style:MenuBarStyle,cellWidth:CGFloat,imageList: [UIImage] = [],selectedIndex: Int = 0,selectedMenuItemColor:UIColor = .white , textList: [String] = []) {
        super.init(frame: frame)
        self.style = style
        self.cellWidth = cellWidth
        self.imageList = imageList
        self.textList = textList
        self.selectedItemTintColor = selectedMenuItemColor
        self.selectedIndex = selectedIndex
        
        setupViewCollectionView()
        
        setupLineViewIndicator()
        
        let items = collectionView.numberOfItems(inSection: 0)
        if ( items >= self.selectedIndex ) {
            let selectedIndexPath = IndexPath(row: self.selectedIndex, section: 0)
            collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
        }
        
    }
    
    
    
    private func setupViewCollectionView( ) {
        
        if self.style == .imageList {
            collectionView.register(ImageMenuCell.self, forCellWithReuseIdentifier: cellID)
            
        } else {
            collectionView.register(TextMenuCell.self, forCellWithReuseIdentifier: cellID)
        }
        
        addSubview(collectionView);
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    private func setupLineViewIndicator() {
        
        if self.isShowLineIndicator {
            addSubview(horizonIndicatorLineView)
            
            horizonIndicatorLineView.widthAnchor.constraint(equalToConstant: self.cellWidth).isActive = true
            
            horizonIndicatorLineView.heightAnchor.constraint(equalToConstant: self.lineIndicatorHeight).isActive = true
            horizonIndicatorLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            lineIndicatorLeft = horizonIndicatorLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            lineIndicatorLeft?.isActive = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.style {
        case .imageList :
            return self.imageList.count
        case .textList :
            return self.textList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        switch self.style {
        case .imageList :
            let cell = cell as! ImageMenuCell
            cell.setStyle(self.menuItemTintColor, selectedTintColor: self.selectedItemTintColor)
            cell.imageView.image = imageList[indexPath.row].withRenderingMode(.alwaysTemplate)
            
            if let indexes = collectionView.indexPathsForSelectedItems, indexes.contains(indexPath){
                cell.imageView.tintColor = selectedItemTintColor
                if isShowLineIndicator {
                    showLineIndicator(cell,animate: false)
                }
            }else{
                cell.imageView.tintColor = menuItemTintColor
            }
            
        case .textList :
            let cell = cell as! TextMenuCell
            cell.setStyle(self.menuItemTintColor, selectedTintColor: self.selectedItemTintColor)
            
            cell.labelText.text = textList[indexPath.row]
            if let indexes = collectionView.indexPathsForSelectedItems, indexes.contains(indexPath){
                cell.labelText.textColor = selectedItemTintColor
                if isShowLineIndicator {
                    showLineIndicator(cell,animate: false)
                }
            }else{
                cell.labelText.textColor = menuItemTintColor
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.item
        //        let attr = collectionView.layoutAttributesForItem(at: indexPath)
        //        let cellRect = attr?.frame
        //        let r = collectionView.convert(cellRect!, to: collectionView.superview)
        //        print("------>\(r.origin.x)")
        
        
    }
    
    private func showLineIndicator(_ indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            showLineIndicator(cell)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isShowLineIndicator {
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            showLineIndicator(indexPath)
        }
    }
    
    //    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //        self.horizonIndicatorLineView.isHidden = true
    //    }
    private func  showLineIndicator(_ cell: UICollectionViewCell, animate: Bool = true) {
        let frame = cell.frame
        let rect = collectionView.convert(frame, to: collectionView.superview)
        //        print("------>\(rect.origin.x)")
        //        let from = self.convert(cell.frame, from: cell.superview)
        //        print("===>\(from.origin.x)")
        
        lineIndicatorLeft?.constant = rect.origin.x
        if animate {
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }else{
            self.layoutIfNeeded()
        }
        
        
    }
    
}






