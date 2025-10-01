//
//  BackgroundImageTableView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/27.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit


class BKImageCatalogCell:UITableViewCell {
    
    var catalogImage: BKImageCatalog? {
        didSet{
            guard let catImage = catalogImage else { return }
            catalogImageView.image = catImage.uiImage
//            catalogImageView.image = catImage.originalSizeUIImage
//                ?.resizedImageWithinRect(rectSize:CGSize(width: 120, height: 120))
//            catalogImageView.image = catImage.uiImage?.scaled(to: CGSize(width: 200, height: 200), scalingMode: .aspectFill)
            self.lockImageView.isHidden = !catImage.isLocked
        }
    }
    
    var catalogImageView :UIImageView = {
        let v = UIImageView()
//        v.contentMode = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var lockImageView:UIImageView = {
        let v = UIImageView(frame:CGRect(x: 20, y: 10, width: 25, height: 25))
        v.image = UIImage(named:"button_lock")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
//        self.contentView.addSubview(self.lockImageView)
        
        self.contentView.addSubview(catalogImageView)
        self.contentView.addSubview(lockImageView)
        
//        catalogImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
//        catalogImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
//        catalogImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
//        catalogImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
//        catalogImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true

//        self.catalogImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        self.catalogImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        catalogImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(120)]", options: [], metrics: nil, views: ["v0":catalogImageView]) )
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(120)]", options: [], metrics: nil, views: ["v0":catalogImageView]) )
        
        self.lockImageView.centerXAnchor.constraint(equalTo: catalogImageView.centerXAnchor).isActive = true
        self.lockImageView.centerYAnchor.constraint(equalTo: catalogImageView.centerYAnchor).isActive = true
    }
}



class BKImageTemplateCell:UITableViewCell {

    var templateImage: BKImageTemplate? {
        didSet{
            guard let templateImage = templateImage else { return }
            catalogImageView.image = templateImage.uiImage
            self.lockImageView.isHidden = !templateImage.isLocked
        }
    }

    var catalogImageView :UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    var lockImageView:UIImageView = {
        let v = UIImageView(frame:CGRect(x: 20, y: 10, width: 25, height: 25))
        v.image = UIImage(named:"button_lock")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {

        //        self.contentView.addSubview(self.lockImageView)

        self.contentView.addSubview(catalogImageView)
        self.contentView.addSubview(lockImageView)


        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(100)]", options: [], metrics: nil, views: ["v0":catalogImageView]) )
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(100)]", options: [], metrics: nil, views: ["v0":catalogImageView]) )

        self.lockImageView.centerXAnchor.constraint(equalTo: catalogImageView.centerXAnchor).isActive = true
        self.lockImageView.centerYAnchor.constraint(equalTo: catalogImageView.centerYAnchor).isActive = true
    }
}


protocol MemoBackgroundImageTableViewDelegate {
    func onCompletedSelectImage(_ tableView: MemoBackgroundImageTableView, selectedImageTemplate:BKImageTemplate)
}

class MemoBackgroundImageTableView:UITableView,UITableViewDelegate,UITableViewDataSource {
    var memoView: MemoView?
    var imageTemplateDelegate: MemoBackgroundImageTableViewDelegate?
    
    var imageList:[BKImageTemplate]? {
        didSet {
            self.reloadData()
        }
    }
    
    let cellID:String = "CellID"
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.delegate = self
        self.dataSource = self
//        self.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.register(BKImageTemplateCell.self, forCellReuseIdentifier: cellID)
        self.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let imageList = imageList {
            return imageList.count
        } else {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BKImageTemplateCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if let backImg = self.imageList?[indexPath.row] {
            cell.templateImage = backImg
//            cell.imageView?.image = backImg.uiImage
//            cell.imageView?.image = backImg.originalSizeUIImage
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let memoView = self.memoView, let imageList = self.imageList {
        if let imageList = self.imageList {
            let backImg = imageList[indexPath.row]
//            memoView.backgroundImageTemplate = backImg
            if let imageTemplateDelegate = self.imageTemplateDelegate {
                imageTemplateDelegate.onCompletedSelectImage(self, selectedImageTemplate: backImg)
            }
        }
    }
}



protocol MemoBackgroundImageCatalogTableViewDelegate {
//    func onCompletedSelect(_ tableView: MemoBackgroundImageCatalogTableView, selectedBackground:BackgroundImageTemplate)
    func onCompletedSelect(_ tableView: MemoBackgroundImageCatalogTableView, selectedBackground:BKImageCatalog)
}

class MemoBackgroundImageCatalogTableView:UITableView,UITableViewDelegate,UITableViewDataSource
{
    
    var catalogDelegate:MemoBackgroundImageCatalogTableViewDelegate?
//    var catalogImageList:[BackgroundImageTemplate] = []
    var catalogImageList:[BKImageCatalog] = [] {
        didSet{
            self.reloadData()
        }
    }
    
    let cellID:String = "CellID"
    
    var selectedIndex: IndexPath?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.delegate = self
        self.dataSource = self
//        self.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.register(BKImageCatalogCell.self, forCellReuseIdentifier: cellID)
        self.separatorStyle = .none
//        self.rowHeight = 60
//        self.catalogImageList = BackgroundImageGallery.getBackgroundImageTemplateCatalogs()
//        self.catalogImageList = BKImageTemplateService().getAllBKImageCatalogs()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogImageList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BKImageCatalogCell
//        cell.imageView?.image = UIImage(named:catalogImageList[indexPath.row].name)
        let cataImage = catalogImageList[indexPath.row]
        cell.backgroundColor = tableView.backgroundColor
        cell.selectionStyle = .none
        cell.catalogImage = cataImage
        
//        if let imageView = cell.imageView {
//            imageView.image = cataImage.uiImage
//            if cataImage.isLocked {
//                let lockImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 25, height: 25))
//                cell.contentView.addSubview(lockImageView)
//                lockImageView.center = imageView.center
//            }
//        }
        
        
//        cell.catalogImage = catalogImageList[indexPath.row]
        
//        if indexPath ==  self.selectedIndex {
//            cell.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
////            cell.transform = CGAffineTransform(rotationAngle:CGFloat( 30 * Double.pi / 180))
//        }else{
////            cell.transform = CGAffineTransform.identity
//            cell.transform = CGAffineTransform.identity
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        if let window = UIApplication.shared.keyWindow {
//            cell?.frame.origin.x -= 50
//        }
        
        self.selectedIndex = indexPath
        self.reloadData()
        //todo unlock IAP
        if let catalogDelegate =  self.catalogDelegate {
            catalogDelegate.onCompletedSelect(self, selectedBackground: self.catalogImageList[indexPath.row])
        }
    }
    
   
    
}
