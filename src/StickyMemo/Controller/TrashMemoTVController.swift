//
//  TrashMemoTVController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/31.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
class TrashMemoTVContoller: MemoBaseTVContoller {
    
    override func freshTableData() {
        let memoList = MemoService().queryTrashMemos()
        self.memoTableList = convertMemoList(memoList)
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MemoTableCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        let memo = self.searchController.isActive ? self.searchResults[section].memoList[row] :  self.memoTableList[section].memoList[row]
        cell.memo = memo
        
        //        cell.separatorInset = .zero
        //        cell.preservesSuperviewLayoutMargins = false
        //        cell.layoutMargins = .zero
        
        cell.buttonEdit.isHidden = true
        cell.buttonFavorited.isHidden = true
        //        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTap(_:)), for: .touchUpInside)
        cell.buttonMail.isHidden = true
        cell.buttonShare.isHidden = true
        cell.buttonMove.isHidden = true
        cell.buttonRestore.isHidden = false
        cell.buttonDelete.isHidden = false
        
        cell.buttonDelete.addTarget(self, action: #selector(buttonConfirmDeleteTap(_:)), for: .touchUpInside)
        cell.buttonRestore.addTarget(self, action: #selector(buttonRestoreTap(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func freshCurrentBoard(_ memo: Memo) {
        guard let desktop =  memo.cdMemo?.desktop else { return }
        if let boardVC = self.boardViewController {
            if boardVC.currentDesktop == desktop {
                boardVC.freshMemoView()
            }
        }
    }
    
    @objc func buttonConfirmDeleteTap(_ sender:UIButton) {
        self.buttonSoundDing.play()
        
        UIUtil.animateButton(sender)
        
        let alert = UIAlertController(title: "\(Appi18n.i18n_finalDeleteMemo)", message: nil, preferredStyle: .alert)
        
        let deleteOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            // confirm delete
            self.animateFinalDelete(sender)
            
        }
        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            
        }
        
        alert.addAction(deleteOK)
        alert.addAction(deleteCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func animateFinalDelete(_ sender:UIButton) {
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        
        if let cell = self.getParentCell(sender) {
            self.buttonSoundSoso.play()
            UIView.animate(withDuration: 0.5, animations: {
                //                    cell.transform = CGAffineTransform(translationX: self.view.frame.width + 10, y: 0)
                cell.frame.origin.x += UIScreen.main.bounds.width//cell.frame.width + 10
            }, completion: { b in
                //fresh current board
                //                    self.freshCurrentBoard(memo)
                memo.finalDelete()
                self.freshTableData()
            })
        }
    }
    @objc func buttonRestoreTap(_ sender:UIButton) {
        self.buttonSoundDing.play()
        UIUtil.animateButton(sender)
        
        let alert = UIAlertController(title: "\(Appi18n.i18n_deleteRestoreMemo)", message: nil, preferredStyle: .alert)
        
        let restoreOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            self.animateRestore(sender)
        }
        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            
        }
        
        alert.addAction(restoreOK)
        alert.addAction(deleteCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func animateRestore(_ sender: UIButton) {
        guard let memo = self.getButtonTapedMemo(sender) else { return }
        
        if let cell = self.getParentCell(sender) {
            self.buttonSoundSoso.play()
            UIView.animate(withDuration: 0.5, animations: {
                cell.frame.origin.x -= UIScreen.main.bounds.width  //cell.frame.width - 10
            }, completion: { b in
                // restore
                memo.restoreDeleted()
                self.freshCurrentBoard(memo)
                self.freshTableData()
            })
        }
    }
    
    //    override func beforeViewDidLoad() {
    //        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchHandler))
    //        let buttonItem = UIBarButtonItem(image: UIImage(named:"button_trash"), style: .plain, target: self, action: #selector(emptyTrashTap))
    //        self.navigationItem.rightBarButtonItems = [buttonItem,searchBarButtonItem]
    //    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let emptyTrashButton = UIButton(type: .system)
        emptyTrashButton.setImage(UIImage(named:"navbutton_empty_trash"), for: .normal)
        emptyTrashButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        emptyTrashButton.addTarget(self, action: #selector(emptyTrashTap), for: .touchUpInside)
        //        let buttonTrashItem = UIBarButtonItem(image: UIImage(named:"navbutton_empty_trash"), style: .plain, target: self, action: #selector(emptyTrashTap))
        
        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchHandler))
        //save orignal buttom items
        
        if let parent =  self.parent {
            //            parent.navigationItem.rightBarButtonItems = [searchBarButtonItem, buttonTrashItem]
            
            parent.navigationItem.rightBarButtonItems = [searchBarButtonItem, UIBarButtonItem(customView: emptyTrashButton) ]
            
            //            parent.navigationItem.rightBarButtonItems = [buttonItem]
            
            //            if let orignialItems = parent.navigationItem.rightBarButtonItem {
            //                parent.navigationItem.rightBarButtonItems = [buttonItem,orignialItems]
            //            }else{
            //                parent.navigationItem.rightBarButtonItems = [buttonItem]
            //            }
        }
    }
    
    //switch to another VC, reset navigate bar button, it will show child vc search button
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        Util.printLog("viewWillDisappear called")
        if let parent =  self.parent {
            parent.navigationItem.rightBarButtonItems = []
        }
    }
    
    
    func animateButton(_ sender:UIView) {
        let rotate = CGAffineTransform(rotationAngle: CGFloat(80 * Double.pi / 180 ))
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        sender.transform = rotate.concatenating(scale)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform.identity
            
        }, completion: { b in
            if b {
            }
        })
    }
    
    @objc func emptyTrashTap(sender:  UIButton ) { //UIBarButtonItem) {
        //    @objc func emptyTrashTap(sender:  UIBarButtonItem) {
        self.buttonSoundDing.play()
        self.animateButton(sender)
        let alert = UIAlertController(title: "\(Appi18n.i18n_emptyTrashcan)", message: nil, preferredStyle: .alert)
        
        let deleteOK = UIAlertAction(title: Appi18n.i18n_ok, style: .destructive) { (_) in
            // confirm delete
            //            memo.deleteRestore()
            //            self.freshTableData()
            for sectionData in self.memoTableList {
                for memo in sectionData.memoList {
                    memo.finalDelete()
                    self.freshTableData()
                }
            }
        }
        let deleteCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
            
        }
        
        alert.addAction(deleteOK)
        alert.addAction(deleteCancel)
        
        present(alert, animated: true, completion: nil)
        
    }
}

