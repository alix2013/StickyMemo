//
//  FontTableView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//


import UIKit
class FontTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    var cellId: String = "CellID"
    
//    var fontNames:[String]  =  UIFont.familyNames.sorted(){return $0 < $1}
    var fontNames:[String]  =  {
        let family = UIFont.familyNames.sorted(){return $0 < $1}
        var fontList:[String] = []
        for fname in family {

            let fList = UIFont.fontNames(forFamilyName: fname)
            for f in fList {
                fontList.append(f)
            }
            
        }
        return fontList
    }()
    //    var fontNames:[String] = UIFont.fontNamesForFamilyName( //sorted() {return $0 < $1}
    var memoView: MemoView?
    var selectedIndex: IndexPath?
    
    var currentFontName:String? {
        didSet {
            
            for (i,f) in fontNames.enumerated() {
                if currentFontName == f {
                    let index = IndexPath(row: i, section: 0)
                    self.selectedIndex = index
                    self.scrollToRow(at: index, at: .top, animated: true)
                }
            }
        }
    }
    
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
        self.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = fontNames[indexPath.item]
        cell.textLabel?.font = UIFont(name: fontNames[indexPath.item], size: 16)
        cell.backgroundColor = tableView.backgroundColor
        cell.selectionStyle = .none
        
        if selectedIndex == indexPath {
            cell.textLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .blue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("current font:\(String(describing: self.memoView?.textView.font))")
//        print("selected font:\(fontNames[indexPath.item])")
//        
        self.selectedIndex = indexPath

        if let size = self.memoView?.font?.pointSize {
            self.memoView?.font = UIFont(name: fontNames[indexPath.item], size: size)
        }
        tableView.reloadData()
    }
}


