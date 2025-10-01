//
//  SlideMenuTable.swift
//  StickyMemo
//
//  Created by alex on 2017/12/18.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

// usage
/*
 let slideMenuTable = SlideMenuTable(.red, alpha: 0.5, rowHeight: 44, backgroundColor: .gray)
 
 slideMenuTable.menuItemList = [MenuTableItem(name: "Settings", imageName: nil), MenuTableItem(name: "Terms & privacy policy", imageName: "privacy"), MenuTableItem(name: "Send Feedback", imageName: "feedback"), MenuTableItem(name: "Help", imageName: "help"), MenuTableItem(name: "Switch Account", imageName: "switch_account"), MenuTableItem(name: "Cancel", imageName: "cancel")]
 //        slideMenuTable.menuItemTintColor = .blue
 slideMenuTable.delegate = self
 
 //when needed 
 slideMenuTable.show()
 
 */

protocol SlideMenuTableDelegate {
    func onSelect(_ selectedIndex: Int, slideMenuTable: SlideMenuTable )
}

class MenuTableItem: NSObject {
    let name: String
    let imageName: String?
    
    init(name: String, imageName: String?) {
        self.name = name
        self.imageName = imageName
    }
}


class SlideMenuTableCell: UITableViewCell {
    //    override var isSelected: Bool {
    //        didSet {
    //            print("isSelected set")
    //            backgroundColor = isSelected ? UIColor.darkGray : UIColor.white
    //            self.textLabel?.textColor = isSelected ? UIColor.white : UIColor.black
    //            self.imageView?.tintColor = isSelected ? UIColor.white : UIColor.darkGray
    //        }
    //    }
    
    var menuItemTintColor: UIColor = UIColor.darkGray
    
    var menuItem: MenuTableItem? {
        didSet {
            textLabel?.text = menuItem?.name
            textLabel?.textColor = menuItemTintColor
            if let imageName = menuItem?.imageName {
                //print("=====imagename:\(imageName)")
                imageView?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                imageView?.tintColor = menuItemTintColor
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SlideMenuTable:NSObject,UITableViewDelegate,UITableViewDataSource {
    
    var delegate:SlideMenuTableDelegate?
    
    var identifier = ""
    var menuItemList:[MenuTableItem] = []
    let cellId = "Cell"
    
    var alpha: CGFloat = 0.5
    var rowHeight:CGFloat = 44
    
    var menuItemTintColor: UIColor = .darkGray
    
    var backgroundColor: UIColor = .white
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.backgroundColor = self.backgroundColor
        v.autoresizingMask = [.flexibleWidth,.flexibleTopMargin]
        
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    lazy var backView:UIView = {
        let v = UIView()
        v.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        v.backgroundColor = UIColor(white: 0, alpha: alpha)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        v.addGestureRecognizer(tapGesture)
        return v
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemList.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selectedIndexPath:\(indexPath)")
        //tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        if let delegate = delegate {
            delegate.onSelect(indexPath.item, slideMenuTable: self)
            self.dismissMenu()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SlideMenuTableCell
        cell.menuItemTintColor = menuItemTintColor
        cell.backgroundColor = backgroundColor
        
        cell.menuItem = self.menuItemList[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    @objc func dismissMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.backView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.tableView.frame = CGRect(x:0, y:window.frame.height, width:self.tableView.frame.width,height: self.tableView.frame.height)
            }
            
        },completion: { b in
            self.tableView.removeFromSuperview()
            self.backView.removeFromSuperview()
        })
        
    }
    
    func show() {
        if let window = UIApplication.shared.keyWindow {
            backView.alpha = 0
            window.addSubview(backView)
            backView.frame = window.frame
            
            //add collectionView
            window.addSubview(tableView)
            var height =  self.rowHeight * CGFloat(self.menuItemList.count )
            
            if height >= window.frame.height / 2 {
                height = window.frame.height / 2
            }
            let y = window.frame.height - height
            
            tableView.frame = CGRect(x:0, y:window.frame.height, width: window.frame.width, height:height)
            tableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.tableView.frame = CGRect(x:0,y: y, width:self.tableView.frame.width, height:self.tableView.frame.height)
                self.backView.alpha = 1
                self.tableView.alpha = 1
            }, completion: nil)
            
        }
    }
    
    override init() {
        super.init()
        tableView.register(SlideMenuTableCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        
    }
    
    init(_ menuItemTintColor: UIColor = .darkGray,alpha:CGFloat = 0.5,rowHeight:CGFloat = 50, backgroundColor:UIColor = .white ) {
        super.init()
        tableView.register(SlideMenuTableCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        
        self.alpha = alpha
        self.menuItemTintColor = menuItemTintColor
        self.backgroundColor = backgroundColor
        self.rowHeight = rowHeight
    }
    
}




