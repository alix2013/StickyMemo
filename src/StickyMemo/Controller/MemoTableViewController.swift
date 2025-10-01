//
//  MemoTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/1.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class MemoTableViewController:  MemoBaseTVContoller {//BaseTableViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }

    override func freshTableData() {
        Util.printLog("freshTableData called")
        guard let currentDesk = self.boardViewController?.currentDesktop else {
            Util.printLog("========NO current Desktop set")
            return
        }
        let memoList =  MemoService().queryCurrentDesktopUndeletedMemos(currentDesk)
        self.memoTableList = self.convertMemoList(memoList)
        self.tableView.reloadData()
    }

}
