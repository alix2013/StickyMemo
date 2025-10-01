//
//  BaseTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2017/12/1.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class BaseTableViewController:UITableViewController,UISearchResultsUpdating {
    
    var isSearchBarEnabled : Bool = true
    
    var searchController:UISearchController!
    
    var progressIndicator:ProgessIndicator = ProgessIndicator(style: .large, indicatorColor: .white, backgroundColor: AppDefault.themeColor)
    
    func beforeViewDidLoad() {
        //dummy for before load
    }
    
    func afterViewDidLoad() {
         //dummy for after load
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.progressIndicator.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beforeViewDidLoad()
        
        if isSearchBarEnabled {
            //for searchBar
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.backgroundColor = AppDefault.themeColor
            searchController.searchBar.tintColor =  .white
            searchController.searchBar.barTintColor = AppDefault.themeColor
            searchController.searchBar.sizeToFit()
            //        self.tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.isHidden = true
            //        definesPresentationContext = true
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            
            //for search
            //        definesPresentationContext = true
            self.searchController.hidesNavigationBarDuringPresentation = false;
            self.definesPresentationContext = false;
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            
            
            //add search barbutton item
            let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchHandler))
            // if exist other barbutton items
            if let items = navigationItem.rightBarButtonItems, items.count > 0 {
                var currentItems = items
                currentItems.append(searchBarButtonItem)
                navigationItem.rightBarButtonItems = currentItems
            } else {
                navigationItem.rightBarButtonItems = [searchBarButtonItem]
            }
            
        }
        
        afterViewDidLoad()
        
        freshTableData()
        
        self.tableView.tableFooterView = UIView(frame:.zero)
    }
    
    func freshTableData() {
        //dummy for child override
        
    }
    @objc func searchHandler() {
        if searchController.searchBar.isHidden {
            searchController.searchBar.isHidden = false
//            self.tableView.tableHeaderView = searchController.searchBar
            if let parent = self.parent {
                parent.navigationItem.titleView = searchController.searchBar
            } else {
                self.navigationItem.titleView = searchController.searchBar
            }
            
        }else {
            searchController.searchBar.isHidden = true
//            self.tableView.tableHeaderView = UIView(frame:CGRect.zero)
            if let parent = self.parent {
                parent.navigationItem.titleView = nil
            } else {
                self.navigationItem.titleView = nil
            }
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText!)
        self.tableView.reloadData()
        
    }
    
    /// for search Bar
    func filterContentForSearchText(_ searchText: String) {
//        self.searchResults = self.memoList.filter(
//            { ( memo : Memo) -> Bool in
//                //let nameMatch = server.name.rangeOfString(searchText, options:NSStringCompareOptions.CaseInsensitiveSearch)
//                //return nameMatch != nil
//                if let _ = memo.body.range(of: searchText, options:NSString.CompareOptions.caseInsensitive) {
//                    return true
//                }
//
//                return false })
//
        
         
    }
    
    
    func getParentCell(_ sender: UIView ) -> UITableViewCell? {
        var parentView = sender.superview
        while !( parentView is UITableViewCell ) {
            // first parent is UITableViewCellContentView
            parentView = parentView?.superview
        }
        return parentView as? UITableViewCell
    }
    
    func getParentCellIndexPath(_ sender:UIView) -> IndexPath? {
        if let cell = self.getParentCell(sender) {
            return self.tableView.indexPath(for: cell)
        }
        return nil
    }
    
    
    func startProgressIndicator() {
        DispatchQueue.main.async {
            if self.progressIndicator.isRunning {
                return
            }else {
                self.progressIndicator.start()
            }
        }
    }
    
    func stopProgressIndicator() {
        DispatchQueue.main.async {
            self.progressIndicator.stop()
        }
    }
}
