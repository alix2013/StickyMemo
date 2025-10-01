//
//  SettingTVController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/31.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import MessageUI

class SettingTVController:UITableViewController {
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    
//    lazy var soundSwitchCell: SwitchTableViewCell = {
//        let cell = SwitchTableViewCell()
//        cell.setName(name: "EnableSound")
//        cell.setTitle(text: Appi18n.i18n_soundSwitch)
//        cell.valueSwitch.isOn = DefaultService.isSoundEnabled()
//        cell.valueSwitch.addTarget(self, action: #selector(switchSoundChanged), for: .valueChanged )
//        return cell
//    }()
    
    lazy var quickstartCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "quickstartCell")
        
        cell.textLabel?.text = Appi18n.i18n_quickstart //"Help"
//        cell.detailTextLabel?.text = Appi18n.i18n_goVIPsubtitle
//        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_quickstart")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var contactDeveloperCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "contactDeveloperCell")
        
        cell.textLabel?.text = Appi18n.i18n_contactDeveloper //"Help"
        //        cell.detailTextLabel?.text = Appi18n.i18n_goVIPsubtitle
        //        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_mail")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var ratingmeCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ratingmeCell")
        
        cell.textLabel?.text = Appi18n.i18n_ratingme
        cell.imageView?.image = UIImage(named:"setting_rateme")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var soundSwitchCell: SwitchTableCell = {
        let cell = SwitchTableCell()
//        cell.setName(name: "EnableSound")
//        cell.setTitle(text: Appi18n.i18n_soundSwitch)
        cell.textLabel?.text = Appi18n.i18n_soundSwitch
        cell.valueSwitch.isOn = DefaultService.isSoundEnabled()
        cell.valueSwitch.addTarget(self, action: #selector(switchSoundChanged), for: .valueChanged )
        if cell.valueSwitch.isOn {
            cell.imageView?.image = UIImage(named:"setting_sound")
        }else{
            cell.imageView?.image = UIImage(named:"setting_nosound")
        }
        
        return cell
    }()
    
    lazy var goPremiumCell: UITableViewCell = {
       let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellidforpricecell")
        
        cell.textLabel?.text = Appi18n.i18n_goVIPtitle
        cell.detailTextLabel?.text = Appi18n.i18n_goVIPsubtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_govip")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    
    lazy var tickerShopCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "tickerShopCell")
        
        cell.textLabel?.text = Appi18n.i18n_stickerShop
        cell.detailTextLabel?.text = Appi18n.i18n_goStickerShopSubtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_sale")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    lazy var pasteSwitchCell: SwitchTableCell = {
        let cell = SwitchTableCell()
        //        cell.setName(name: "EnableSound")
        //        cell.setTitle(text: Appi18n.i18n_soundSwitch)
        cell.textLabel?.text = Appi18n.i18n_autoPasteTitle
        cell.detailTextLabel?.text = Appi18n.i18n_autoPasteSubtitle
        
        
        cell.valueSwitch.isOn = DefaultService.isAutoPasteEnabled()
        cell.valueSwitch.addTarget(self, action: #selector(switchPasteChanged), for: .valueChanged )
        cell.imageView?.image = UIImage(named:"setting_paste")
        
        
        return cell
    }()
    
    lazy var shortcutkeyCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "shortcutkeyCell")
        
        cell.textLabel?.text = Appi18n.i18n_shortcut
        cell.detailTextLabel?.text = Appi18n.i18n_shortcutSubtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_shortcutkey") //?.withRenderingMode(.alwaysTemplate)
//        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
//    var nameTextField: TextFieldTableViewCell = TextFieldTableViewCell().configCell(){
//        $0.setName(name: "nameTextField")
//        $0.setTitle(text: "name")
//        $0.valueTextField.placeholder =  " Your name"
//        return $0
//    }
    
    
    lazy var passwordCell: UITableViewCell = {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "passwordCell")
        cell.textLabel?.text = Appi18n.i18n_password
        cell.detailTextLabel?.text = Appi18n.i18n_passwordSubtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named:"setting_touchid")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = AppDefault.themeColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }()
    
    let versionBuild:String = {
        if let version  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            var versionBuild = "V\(version)"
            if let build  = Bundle.main.infoDictionary?["CFBundleVersion"] {
                versionBuild = "\(versionBuild)(B\(build))"
                return versionBuild
            }
        }
        return ""
    }()
    
    lazy var versionLabel:UILabel = {
        let v = UILabel(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        v.backgroundColor = .white
        
        let nsStr = NSAttributedString(string: "\(self.versionBuild)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray])
        v.attributedText = nsStr
        
//        if let version  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
//            var versionBuild = "V\(version)"
//            if let build  = Bundle.main.infoDictionary?["CFBundleVersion"] {
//                versionBuild = "\(versionBuild)(B\(build))"
//
////                v.text = versionBuild
//            }
//        }
        
        v.textAlignment = .center
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Util.saveAccessLog("Setting",memo:"Access Setting")
        
        configBarItems()
        setupTableView()
    }
    
    func configBarItems() {
        let closeWindowItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeWindow))
        self.navigationItem.leftBarButtonItem = closeWindowItem

        //for change child vc <back to <
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain,
                                                                target: nil, action: nil)
        
//        let mainButton = UIButton(type: .system)
//        mainButton.setImage(UIImage(named:"button_main"), for: .normal)
//        mainButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        mainButton.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainButton)
//        self.navigationController?.navigationBar.tintColor =  nil
    }
    
    func setupTableView() {
        self.tableView.tableFooterView = versionLabel //UIView(frame:.zero)
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    @objc func closeWindow() {
        self.buttonSoundSoso.play()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func switchSoundChanged(_ sender: UISwitch) {
        Util.printLog("switchSoundChanged:\(sender.isOn)")
        
        if sender.isOn {
            soundSwitchCell.imageView?.image = UIImage(named:"setting_sound")
        }else{
            soundSwitchCell.imageView?.image = UIImage(named:"setting_nosound")
        }
        DefaultService.saveSoundEnable(sender.isOn)
    }
    
    @objc func switchPasteChanged(_ sender: UISwitch) {
        Util.printLog("switchPasteChanged:\(sender.isOn)")
        if DefaultService.isvip() {
            DefaultService.saveAutoPasteEnable(sender.isOn)
        }else{
            sender.isOn = false
           UIUtil.goPurchaseVIP(self)
        }
    }
    
    func ratingMe(){
        let urlStr = "https://itunes.apple.com/us/app/stickymemo/id1321800123?mt=8"
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    func sendEmail(){
        
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients(["alix2013@icloud.com"])
            //            composer.setSubject("Best Sticky Memo Shared:\(memo.subject)")
            composer.setSubject("StickyMemo \(self.versionBuild):")
//            composer.setMessageBody(memo.htmlBody, isHTML: true)
           
            present(composer, animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: //quickstart and contact developer
            return 3
        case 1: //for soundswitch
            return 1
        case 2: // for IAP
            return 2
        case 3: // for auto paste
            return 1
        case 4:
            return 1
        case 5:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return CGFloat(44)
//        switch section {
//        case 0:
//            return CGFloat(44)
//        case 1:
//            return CGFloat(55)
//        default:
//            return 44
//        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        
        case 2,3,4,5:
            return CGFloat(80)
//        case 3:
//            return CGFloat(80)
        default:
            return 44
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return "    "
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return self.quickstartCell
            }
            if indexPath.row == 1{
                return self.contactDeveloperCell
            }
            if indexPath.row == 2 {
                return self.ratingmeCell
            }
        case 1:
            if indexPath.row == 0 {
                return self.soundSwitchCell
            }
        case 2:
            if indexPath.row == 0 {
                return self.goPremiumCell
            }
            if indexPath.row == 1 {
                return self.tickerShopCell
            }
            
        case 3:
            if indexPath.row == 0 {
                return self.pasteSwitchCell
            }
            
        case 4:
            if indexPath.row == 0 {
                return self.shortcutkeyCell
            }
        case 5:
            if indexPath.row == 0 {
                return self.passwordCell
            }
            
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0 {
            UIUtil.gotoQuickStartPage(self)
        }
        
        if section == 0 && row == 1{
            self.sendEmail()
        }
        if section == 0 && row == 2 {
            self.ratingMe()
        }
        
        if section == 2 && row == 0 {
//            let vc = IAPTableViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
            buttonSoundDing.play()
            let priceVC = IAPTableViewController()
            let navVc = UINavigationController(rootViewController: priceVC)
            self.present(navVc, animated: true, completion: nil)
            
        }
        if section == 2 && row == 1 {
            buttonSoundDing.play()
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let shopVC = StickerShopViewController(collectionViewLayout: layout)
//            deskVC.boardViewController = self
            let nav = UINavigationController(rootViewController: shopVC)
            
//            nav.modalTransitionStyle = .flipHorizontal
            present(nav, animated: true, completion: nil)
            
        }
        
        if section == 4 && row == 0  { //for shortcut key
            
            if DefaultService.isvip() {
                buttonSoundDing.play()
                
                let shortcutVC = ShortcutkeyTVController()
                if let nav = self.navigationController {
                    nav.pushViewController(shortcutVC, animated: true)
                }
            }else{
                UIUtil.goPurchaseVIP(self)
            }
        }
        
        
        if section == 5 && row == 0  { //for shortcut key
            buttonSoundDing.play()
            
            let passwordVC = SetPasswordTVController()
            if let nav = self.navigationController {
                nav.pushViewController(passwordVC, animated: true)
            }
            
        }
        
    }
}

extension SettingTVController:MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
