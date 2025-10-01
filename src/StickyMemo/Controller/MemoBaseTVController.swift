//
//  MemoBaseTVController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/10.
//  Copyright © 2017年 alix. All rights reserved.
//
import UIKit

class SectionMemoTable {
    var sectionName:String
    var cdDesktop: CDDesktop
    var isExtended:Bool
    var memoList:[Memo]
    
    init(sectionName:String,cdDesktop:CDDesktop,memoList:[Memo],isExtended:Bool = true) {
        self.sectionName = sectionName
        self.isExtended = isExtended
        self.cdDesktop = cdDesktop
        self.memoList = memoList
    }
}

class MemoBaseTVContoller: BaseTableViewController,UIGestureRecognizerDelegate {
    
    var boardViewController: BoardViewController?
    let cellID:String = "CellID"
    let headerCellID:String = "headerCellID"
    
//    var memoList:[Memo]?
    var memoTableList:[SectionMemoTable] = []
    var searchResults:[SectionMemoTable] = []
    
    //for fresh if isFavorited taped
    var isFavoritedTableView:Bool = false
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
    var fullScreenTextViewStartFrame:CGRect = .zero
    
    lazy var fullScreenTextView: UITextView = {
        let v = UITextView()
        v.isEditable = false
//        v.translatesAutoresizingMaskIntoConstraints = false
        v.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        v.showsHorizontalScrollIndicator = false
        
//        v.bounces = false
//        v.alwaysBounceHorizontal = false
//        v.contentInset =  UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTap2Guesture))
        tapGesture.numberOfTapsRequired = 2
//        for g in v.gestureRecognizers! {
//            print("-----")
//            print( type(of: g))
////            if g.isKindOfClass(UITapGestureRecognizer.self){
//////            isKindOf UITextTapRecognizer {
////                g.isEnabled = false
////            }
//            if g is UITapGestureRecognizer {
////                g.isEnabled = false
////            if let tap = g as? UITapGestureRecognizer {
////                print("disable double tap")
////                tap.numberOfTapsRequired = 1
////                g.isEnabled = false
////            }
//            }
//        }
        tapGesture.delegate = self
        v.addGestureRecognizer(tapGesture)
//        v.gestureRecognizers = [tapGesture]
        return v
    }()
    
    var isFullScreenTextViewShowing:Bool = false
    //for UITextView may response customized gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupTableView()
        setupGesture()
//        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap2gesture(_ :)))
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
        
        //longtap call tap2gesture
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(tap2gesture(_ :)))
        self.view.addGestureRecognizer(longTapGesture)
    }
    
    @objc func tap2gesture(_ sender:UITapGestureRecognizer) {
        Util.printLog("tap2gesture called")
        if self.isFullScreenTextViewShowing {
            Util.printLog("FullscreenView showing")
            return
        }
        self.isFullScreenTextViewShowing = true
        let loc = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: loc) else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        let memo = self.memoTableList[indexPath.section].memoList[indexPath.row]
        animateCellAtDoubleTap(memo,cell:cell)
    }
    
    func animateCellAtDoubleTap(_ memo: Memo, cell:UITableViewCell) {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(fullScreenTextView)
            //            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":fullScreenTextView]))
            //            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":fullScreenTextView]))
            
            fullScreenTextView.attributedText = memo.contentAttributedText
            fullScreenTextView.backgroundColor = memo.backgroundImage.tintColor
            
            let fontSize = max( memo.displayStyle.fontSize, 40)
            let fontName = memo.displayStyle.fontName
            
            fullScreenTextView.font = UIFont(name: fontName, size: fontSize)

            fullScreenTextView.isSelectable = true
            
            //to avoid horizon scroll
            fullScreenTextView.contentSize = fullScreenTextView.bounds.size
            
//            fullScreenTextView.contentInset =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            self.fullScreenTextView.frame = keyWindow.frame
            let startFrame = keyWindow.convert(cell.frame, from: cell.superview)
            fullScreenTextView.frame = startFrame
            self.fullScreenTextViewStartFrame = startFrame
            UIView.animate(withDuration: 0.75, animations: {
                self.fullScreenTextView.frame = keyWindow.frame
                //for vertical center textview
                self.fullScreenTextView.alignTextVerticallyInContainer()
            })
        }
    }
    
    //dismiss fullscreenTextView
    @objc func textViewTap2Guesture(_ sender:UITapGestureRecognizer) {
        print("textViewTap2Guesture called")
        //to dismiss black selected popup memu
        fullScreenTextView.isSelectable = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenTextView.frame = self.fullScreenTextViewStartFrame
        }, completion: { b in
            if b {
                self.fullScreenTextView.removeFromSuperview()
                self.isFullScreenTextViewShowing = false
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.freshTableData()
    }
    
    //switch viewController from one to another, hiden searchController
    override func viewWillDisappear(_ animated: Bool) {
        Util.printLog("MemoBaseTVC viewWillDisappear called")
        super.viewWillDisappear(animated)
        if self.searchController.isActive {
            self.searchController.isActive = false
        }
        self.parent?.navigationItem.titleView = nil
    }
    
    func setupTableView() {
        self.tableView.register(MemoTableCell.self, forCellReuseIdentifier: cellID)
        self.tableView.register(MemoTableSectionHeaderCell.self, forCellReuseIdentifier: headerCellID)
        
        // for auto cell height by constraints
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //to avoid tableView cell edge is too large in iPad
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        //to avoid bottom content not show
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return self.searchResults.count
        } else {
            return self.memoTableList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return self.searchResults[section].memoList.count
        } else {
            if self.memoTableList[section].isExtended {
                return self.memoTableList[section].memoList.count
            }else{
                return 0
            }
            
        }
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
        
        cell.buttonEdit.addTarget(self, action: #selector(buttonEditMemoTap), for: .touchUpInside)
        cell.buttonFavorited.addTarget(self, action: #selector(buttonFavoriedTap), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTap(_:)), for: .touchUpInside)
        cell.buttonMail.addTarget(self, action: #selector(buttonMailTap), for: .touchUpInside)
        cell.buttonShare.addTarget(self, action: #selector(buttonShareTap), for: .touchUpInside)
        cell.buttonMove.addTarget(self, action: #selector(buttonMoveTap), for: .touchUpInside)
        return cell
    }
    


//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.memoTableList[section].sectionName
//    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    
////        let memo = self.memoTableList[indexPath.section].memoList[indexPath.row]
////        let textHeight =  memo.attributedText.height(withConstrainedWidth: self.view.frame.width - 40)
////        let newTextHeight = min(textHeight, 200)
////
////        let photoHeight = getPhotoViewHeight(memo) //tableView.frame.width / 4 //getPhotoViewHeight(memo)//
////        let height = newTextHeight + photoHeight + 20
////        return height
//        return UITableViewAutomaticDimension
//    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: headerCellID) as! MemoTableSectionHeaderCell
        
//        let cell = MemoTableSectionHeaderCell()
//        cell.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        
        // set name
        let desktopName = self.memoTableList[section].sectionName
        let count = self.memoTableList[section].memoList.count
        cell.labelDesktopName.text = "\(desktopName)[\(count)]"
        
        //set section background image
        let desktop = self.memoTableList[section].cdDesktop
        if let imgData = desktop.backImageContent {
            let imageView = UIImageView(image: UIImage(data:imgData))
            imageView.contentMode = .scaleAspectFill
                //        imageView.clipsToBounds = true
            cell.insertSubview(imageView, at: 0)
            cell.clipsToBounds = true
        }
        
//        cell.buttonOpenClose.tag = section
        cell.buttonDesktop.tag = section
//        cell.buttonOpenClose.addTarget(self, action: #selector(buttonOpenClosTap(_ :)), for: .touchUpInside)
        cell.buttonDesktop.addTarget(self, action: #selector(buttonOpenDesktap(_ :)), for: .touchUpInside)
        return cell

    }
    

    
//    func getPhotoViewHeight(_ memo: Memo) -> CGFloat {
//        if let count = memo.cdMemo?.images?.count, count > 0 {
//            return tableView.frame.width / 4
//        } else {
//            return 0
//        }
//    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    

    override func filterContentForSearchText(_ searchText: String) {
        
        self.searchResults = []
        
        for memoTable in self.memoTableList {
            let list = memoTable.memoList.filter({ (memo) -> Bool in
                if let _ = memo.body.range(of: searchText, options:NSString.CompareOptions.caseInsensitive) {
                    return true
                }
                if let _ = memo.subject.range(of: searchText, options:NSString.CompareOptions.caseInsensitive) {
                    return true
                }
                return false
            })
            if list.count > 0 {
                self.searchResults.append(SectionMemoTable(sectionName: memoTable.sectionName, cdDesktop: memoTable.cdDesktop, memoList: list,isExtended: memoTable.isExtended))
            }
        }

    }
    
    
    func convertMemoList(_ memoList:[Memo]) -> [SectionMemoTable] {
        var sections:[SectionMemoTable] = []
        var map:Dictionary<String,[Memo]> = Dictionary<String,[Memo]>()
        
        for memo in memoList {
//            Util.printLog("memo.subject:\(memo.subject)")
            if map[memo.desktopName] != nil {
//                Util.printLog("DesktopName:\(memo.desktopName)")
                //map key have been there
                map[memo.desktopName]?.append(memo)
            }else{
                map[memo.desktopName] = [memo]
            }
        }
        for (k,v) in map {
            if v.count > 0, let cdDesktop = v[0].cdMemo?.desktop {
                let sectionMemo = SectionMemoTable(sectionName: k, cdDesktop: cdDesktop, memoList: v.sorted(by: {
                    if let aUpdateAt = $0.updateAt, let bUpdateAt = $1.updateAt {
                        return aUpdateAt.compare(bUpdateAt) == .orderedDescending
                    }else {
                        return false
                    }
                    
                }))
                sections.append(sectionMemo)
            }
            
        }
        return sections
    }
    
    
}


