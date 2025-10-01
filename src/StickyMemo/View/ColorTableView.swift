//
//  ColorTableView.swift
//  StickyMemo
//
//  Created by alex on 2017/11/28.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class MemoColor {
    var image: UIImage
    var color:UIColor
    init(image: UIImage, color:UIColor) {
        self.image = image
        self.color = color
    }
    
}
class ColorTableView:UITableView,UITableViewDelegate,UITableViewDataSource {
    
    let memoColorList:[MemoColor] = [
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.red),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.orange),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor(red: 186/255, green: 132/255, blue: 72/255, alpha: 1)   ),//UIColor.yellow),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor(red: 0/255, green: 88/255, blue: 49/255, alpha: 1)), //UIColor.green),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.blue),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.black),
        MemoColor(image: UIImage(named:"color")!.withRenderingMode(.alwaysTemplate), color: UIColor.white),
        ]
    
    
    var memoView: MemoView?
    
    var colorList:[MemoColor] = []
    
    let cellID:String = "CellID"
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        colorList = self.memoColorList //BackgroundImageGallery.getMemoColors()
        
        self.delegate = self
        self.dataSource = self
        self.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) //as! BackgroundImageCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let memoColor = colorList[indexPath.row]

        cell.imageView?.image = memoColor.image
        cell.imageView?.tintColor = memoColor.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoColor = colorList[indexPath.row]
        if let memoView = self.memoView {
            memoView.textColor = memoColor.color
            //solve textFieldview do not change color immediately
            let text = memoView.textFieldView.text
            memoView.textFieldView.text = text

        }
    }
}


