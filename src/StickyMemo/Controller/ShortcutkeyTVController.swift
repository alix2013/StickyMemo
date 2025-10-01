//
//  ShortcutkeyTVController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/21.
//  Copyright © 2018年 alix. All rights reserved.
//


import UIKit

class Shortcutkey{
    var order: Int
    var key: String
    var cdShortcutkey: CDShortcutkey?
    
    init(order:Int,key:String ) {
        self.order = order
        self.key = key
    }
    func reOrder(orderId:Int){
        self.order = orderId
    }
    
    init(_ cdKey: CDShortcutkey){
        self.order = Int(cdKey.order)
        self.key = cdKey.key ?? ""
        self.cdShortcutkey = cdKey
    }
}

class ShortcutkeyTVController:UITableViewController,AddShortcutKeyDelegate {
    func onShortcutKeySelected(_ selectedKey: String) {
        addNewKey(selectedKey)
    }
    
    
//    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
//    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    var deletedKeysData:[Shortcutkey] = []
//    var keysData:[Shortcutkey] = [
//        Shortcutkey(orderId:1, key: "A"),
//        Shortcutkey(orderId:2, key: "B"),
//        Shortcutkey(orderId:3, key: "C"),
//        Shortcutkey(orderId:4, key: "D")
//    ]
    var keysData:[Shortcutkey] = []
    
    let cellId:String = "CellID"
    
    lazy var saveButton: UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_save, style: .plain, target: self, action: #selector(saveButtonTap))
        v.isEnabled = false
        return v
    }()
    
    lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTap))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [editButtonItem,addButton,saveButton]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView(frame:.zero)
        refreshTableData()
        
    }
    
    func refreshTableData() {
        let cdKeys = ShortcutkeyService.currentCDShortcutKeys
        let sorted = cdKeys.sorted { $0.order < $1.order
        }
        self.keysData = sorted.map{ Shortcutkey($0) }
    }
    
    
    func saveData() {
        
        // for delete
        deletedKeysData.forEach({ (key) in
            if let cdKey = key.cdShortcutkey {
                ShortcutkeyService.deleteShortcutkey(cdKey)
            }
        })
        
        self.keysData.forEach { (key) in
            // for update
            if let cdKey = key.cdShortcutkey {
                cdKey.order = Int32(key.order)
                cdKey.key = key.key
                ShortcutkeyService.updateShortcutkey(cdKey)
                
            }else{ // for insert
                let _ = ShortcutkeyService.insertShortcutkey(key.order, key: key.key)
            }
            
        }
        
        ShortcutkeyService.initOrFreshShortcutkeyCache()
    }
    @objc func saveButtonTap() {
        //        let orderedData = data.map { $0.reOrder(orderId: <#T##Int#>)}
        self.tableView.setEditing(false, animated: false)
        
        for (index,key) in keysData.enumerated(){
            key.reOrder(orderId: index)
        }
        
        keysData.forEach({ (key) in
            if let _ = key.cdShortcutkey {
                Util.printLog("for update: \(key.order)-->\(key.key)")
            }else{
                Util.printLog("Insert:\(key.order)-->\(key.key)")
            }
            
        })
        Util.printLog("deleted:")
        deletedKeysData.forEach({ (key) in
            Util.printLog("\(key.order)-->\(key.key)")
        })
        
        self.saveData()
        
        self.saveButton.isEnabled = false
    }
    
    @objc func addButtonTap() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let addKeyVC = AddShortcutViewController(collectionViewLayout: layout)
        addKeyVC.delegate = self
        let navVC = UINavigationController(rootViewController: addKeyVC)
        
        ButtonSoundSerive.playDing()
        self.present(navVC, animated: true, completion: nil)
    }
    
    func addNewKey(_ newKey:String) {
        
        //get max order for new key
//        let orders = self.keysData.flatMap{$0.order}
        let orders = self.keysData.compactMap{$0.order}
        var max = 0
        orders.forEach({ (order) in
            if order > max {
                max = order
            }
        })
        
        let key:Shortcutkey = Shortcutkey(order: max + 1, key:newKey)
        
        self.keysData.append(key)
        self.tableView.reloadData()
        
        self.saveButton.isEnabled = true
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keysData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = keysData[indexPath.row].key
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let srcdata = keysData[sourceIndexPath.row]
        keysData.remove(at: sourceIndexPath.row)
        keysData.insert(srcdata, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deletedKeysData.append(keysData[indexPath.row])
            keysData.remove(at: indexPath.row)
            //            tableView.reloadRows(at: [indexPath], with: .right)
            
            self.saveButton.isEnabled = true
            tableView.reloadData()
        }
    }
    
    //    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
}

