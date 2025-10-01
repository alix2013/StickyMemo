//
//  CustomUITableViewCell.swift
//  StickyMemo
//
//  Created by alex on 2017/12/31.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

// parrent class for customized UITableViewCell
class CustomUITableViewCell : UITableViewCell {
    // for getValues and getValue returned map key
    var cellName = ""
    
    //cellHeight for  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    var cellHeight: CGFloat = CGFloat(44)
    
    // for child view left and right margin
    //var leftRightMargin: CGFloat = CGFloat(10)
    var leadingMargin: CGFloat = CGFloat(10)
    var trailingMargin: CGFloat = CGFloat(10)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style,reuseIdentifier: reuseIdentifier )
        beforeSetupViews()
        setupViews()
        afterSetupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beforeSetupViews() {
        //dummy method for child class set var margin etc
    }
    
    func afterSetupViews() {
        //set cell other properties
        self.selectionStyle =  .none
    }
    
    func setupViews() {
        //dummy method for child override
        
    }
    
    // name for getValues dictionary key
    func getName() -> String {
        return cellName
    }
    func setName(name: String){
        self.cellName = name
    }
    
    func getValue() -> Any?{
        return nil
    }
    
    //    func configCell( callback: ( (CustomUITableViewCell) -> CustomUITableViewCell ) ) -> CustomUITableViewCell {
    //        return callback(self)
    //    }
    
}

/*
// customized UITableViewCell, locate a label in left of cell , default label width is half or screen
class LeftLabelTableViewCell : CustomUITableViewCell {
    //    var nameLabelWidth:CGFloat = {
    //        return  UIScreen.main.bounds.width / 2
    //    }()
    
    var nameLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = .red
        return v
    }()
    
    override func setupViews() {
        super.setupViews()
        self.contentView.addSubview(nameLabel)
        /*
         nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor,constant: leadingMargin).isActive = true
         nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
         */
        nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: leadingMargin).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        //nameLabel.widthAnchor.constraint(equalToConstant: nameLabelWidth).isActive = true
        
    }
    
    func getTitle() -> String? {
        return nameLabel.text
    }
    func setTitle(text: String) {
        nameLabel.text = text
    }
    
    //    func configCell( callback: ( (LeftLabelTableViewCell) -> LeftLabelTableViewCell ) ) -> LeftLabelTableViewCell {
    //        return callback(self)
    //    }
}


//customized UITableViewCell, a label in left of cell, a UISwitch in right of cell
class SwitchTableViewCell : LeftLabelTableViewCell {
    var valueSwitch : UISwitch = {
        let v = UISwitch()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func setupViews() {
        super.setupViews()
        
        self.contentView.addSubview(valueSwitch)
        valueSwitch.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -trailingMargin).isActive = true
        valueSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    override func getValue() -> Any?{
        return valueSwitch.isOn ? "1" : "0"
    }
    func setValue( on: Bool ) {
        valueSwitch.isOn = on
    }
    
    func configCell( callback: ( (SwitchTableViewCell) -> SwitchTableViewCell ) ) -> SwitchTableViewCell {
        return callback(self)
    }
}

*/

class SwitchTableCell : CustomUITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.numberOfLines =  0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var valueSwitch : UISwitch = {
        let v = UISwitch()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func setupViews() {
        super.setupViews()
        self.contentView.addSubview(valueSwitch)
        valueSwitch.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -trailingMargin).isActive = true
        valueSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    override func getValue() -> Any?{
        return valueSwitch.isOn ? "1" : "0"
    }
    func setValue( on: Bool ) {
        valueSwitch.isOn = on
    }
    
}


