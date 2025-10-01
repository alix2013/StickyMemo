//
//  AddShortcutViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/21.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit



class ShortcutkeyCell: UICollectionViewCell {

    var keyChar:String? {
        didSet{
            guard let keyChar = keyChar else { return }
            
            let attributeString = NSAttributedString(string: keyChar, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 80)])
            keyLabel.attributedText = attributeString
            
        }
    }
    var keyLabel:UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
        
    }()
    
    var selectedImageView:UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named:"button_selected")
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.addSubview(keyLabel)
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":keyLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: nil, views: ["v0":keyLabel]))
        
        self.addSubview(selectedImageView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(20)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(20)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        
        selectedImageView.isHidden = true
        
    }
}

protocol AddShortcutKeyDelegate {
    func onShortcutKeySelected(_ selectedKey:String)
}

class AddShortcutViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout  {
    
    var delegate:AddShortcutKeyDelegate?
    let shortcutKeyList:[String] = [ "☒","☑︎","✗","✓","☞","☛","➢","➤","☆","★","◻︎","◼︎",
                                     "○","●","◎","◉","◇","◆","▷","►","△",
                                     "✧","✦","❀","✿","➳","➸"]
    let cellId = "cellId"
    
    var selectedIndexPath:IndexPath?
    
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupNavButtomItems()
        setupCollectionView()
        
    }
    
    func setupNavButtomItems() {
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDesktop) )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeViewController) )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionHandler) )
        
    }
    
    
    func setupCollectionView(){
        self.collectionView?.register(ShortcutkeyCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.backgroundColor = .white
    }
    
   
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shortcutKeyList.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShortcutkeyCell
    
        cell.keyChar =  self.shortcutKeyList[indexPath.item]
        if let selectedIndexPath = self.selectedIndexPath {
            if selectedIndexPath == indexPath {
                cell.selectedImageView.isHidden = false
            }else{
                cell.selectedImageView.isHidden = true
            }
        }
        return cell
    }
    
    @objc func doneActionHandler(){
        if let delegate = delegate {
            if let selectedIndex = self.selectedIndexPath {
                delegate.onShortcutKeySelected(self.shortcutKeyList[selectedIndex.item])
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: 100, height: 100)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        collectionView.reloadData()
    }
    
    @objc func closeViewController(){
        buttonSoundSoso.play()
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


