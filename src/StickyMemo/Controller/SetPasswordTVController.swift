//
//  SetPasswordTVController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/31.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit

class SetPasswordTVController:UITableViewController {
    
    var setpasswordCell:UITableViewCell = {
       let v = UITableViewCell(style: .default, reuseIdentifier: "setpasswordCell")
        v.textLabel?.text = Appi18n.i18n_setPasswordForSettings
        v.accessoryType = .disclosureIndicator
        return v
        
    }()
    
    lazy var enablePasswordCell:SwitchTableCell = {
        let cell = SwitchTableCell()
        cell.textLabel?.text = Appi18n.i18n_enablePassword
        cell.detailTextLabel?.text = Appi18n.i18n_enablePasswordSubtitle
        
        cell.valueSwitch.isOn = DefaultService.isPasswordEnabled()
        cell.valueSwitch.addTarget(self, action: #selector(switchPasswordChanged), for: .valueChanged )

        return cell
    }()
    
    var enableTouchIDCell:SwitchTableCell = {
        
        let cell = SwitchTableCell()
        cell.textLabel?.text = Appi18n.i18n_enableTouchID
        cell.detailTextLabel?.text = Appi18n.i18n_enableTouchIDSubtitle
        
        cell.valueSwitch.isOn = DefaultService.isTouchIDEnabled()
        cell.valueSwitch.addTarget(self, action: #selector(switchTouchIDChanged), for: .valueChanged )
        return cell
    }()

    
    @objc func switchPasswordChanged(_ sender:UISwitch) {
        Util.printLog("switchPasswordChanged:\(sender.isOn)")
        
        if sender.isOn {
            if !DefaultService.isvip() {
                sender.isOn = false
                UIUtil.goPurchaseVIP(self)
                return
            }
        }
        
        self.enablePassword(sender.isOn)
        
    }
    
    func enablePassword(_ enabled:Bool) {
        
        
        
        if !enabled { //off password, then off touchID
            self.enableTouchIDCell.valueSwitch.isOn = false
            DefaultService.saveTouchIDEnable(false)
        }else{
            let password = DefaultService.getAccessPassword()
            if password == "" {
                PasswordAuthService.showSetPassword()
            }
        }
        DefaultService.savePasswordEnable(enabled)
    }
    
    @objc func switchTouchIDChanged(_ sender:UISwitch) {
        Util.printLog("switchTouchIDChanged:\(sender.isOn)")
        
        if sender.isOn {
            if !DefaultService.isvip() {
                sender.isOn = false
                UIUtil.goPurchaseVIP(self)
                return
            }
        }
        
        if sender.isOn {
            if !self.enablePasswordCell.valueSwitch.isOn {
                self.enablePasswordCell.valueSwitch.isOn = true
                self.enablePassword(true)
            }
        }
        
        DefaultService.saveTouchIDEnable(sender.isOn)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if DefaultService.isPasswordEnabled() {
            PasswordAuthService.showPassword()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
        self.tableView.tableFooterView = UIView(frame:.zero)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return self.setpasswordCell
            }else{
                return self.enablePasswordCell
            }
        
        case 1:
            return self.enableTouchIDCell
        default:
            break
            
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return CGFloat(50)
            }else{
                return CGFloat(80)
            }
            
        case 1:
            return CGFloat(80)
        default:
            return 44
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            PasswordAuthService.showSetPassword()
        }
    }
}


