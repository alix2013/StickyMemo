//
//  AllMemoTVController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/10.
//  Copyright © 2017年 alix. All rights reserved.
//

//
//  MemoTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/1.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit


class FavoritedMemoTVContoller: MemoBaseTVContoller {
    override func afterViewDidLoad() {
        self.isFavoritedTableView = true
        setupGesture()
    }
    
    
    override func freshTableData() {
        let memoList = MemoService().queryFavoritedUndeletedMemos()
        self.memoTableList = convertMemoList(memoList)
        self.tableView.reloadData()
    }
    
}



class AllMemoTVContoller: MemoBaseTVContoller {
    override func freshTableData() {
        // convert memoList to SectonmemoTable
        let memoList = MemoService().queryAllUndeletedMemos()
        self.memoTableList = convertMemoList(memoList)
        self.tableView.reloadData()
    }

}

class ReminderMemoTVContoller: MemoBaseTVContoller {
    override func freshTableData() {
        // convert memoList to SectonmemoTable
        let memoList = ReminderService().queryReminderMemos()
        self.memoTableList = convertMemoList(memoList)
        self.tableView.reloadData()
    }
    
}
