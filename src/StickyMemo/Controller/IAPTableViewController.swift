//
//  IAPTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/8.
//  Copyright © 2018年 alix. All rights reserved.
//

//
//  PriceTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/5.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import StoreKit



class IAPCell:UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:UITableViewCell.CellStyle.subtitle,reuseIdentifier:reuseIdentifier )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class IAPTableViewController: BaseTableViewController, SKProductsRequestDelegate {

//    let vipProductID:String = "0000vip"
    let cellId = "Cell"
//    let defaultProdIDs = Set(["0000vip","bg_bubble_left","bg_bubble_right,bg_gap,bg_hole_left,bg_hole_top"])
    let defaultProdIDs = Set(["0000vip"])
    
    //let productIdentifiers = Set(["51vpn.buyvolumeprice1","51vpn.buyvolumeprice2"])
    //var product: SKProduct?
    var productsArray = Array<SKProduct>()
//    var imageCatalogs:[BKImageCatalog] = []
    
    lazy var restoreBarItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_restorePurchase, style: .plain, target: self, action: #selector(restorePurchase(_ :)))
        return v
    }()
    
    lazy var closeBarItem: UIBarButtonItem = {
        let v = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTap))
        return v
    }()
    
    var request:SKProductsRequest?
    
    deinit {
        // cancel request to avoid crash at quick in/out viewcontroller
        if let request = request {
            Util.printLog("======IAPTableView Deinit cancel request ===================")
            request.cancel()
        }
    }
    
    override func beforeViewDidLoad() {
        super.beforeViewDidLoad()
        self.isSearchBarEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Appi18n.i18n_purchase //NSLocalizedString("Purchase", comment: "Purchase")
        setupNavigationButton()
        setupTableView()
        setupSKPayment()
        //        self.hidesBottomBarWhenPushed = true

    }
    
    func setupNavigationButton() {
        self.navigationItem.leftBarButtonItem =  closeBarItem
    }

    func setupSKPayment(){
        var prodIDSet = Set<String>()
        prodIDSet = self.defaultProdIDs
        //        if self.loginUser.productIdList.count == 0 {
        //            prodIDSet = self.defaultProdIDs
        //
        //            //Util.getProductList(self.loginUser)
        //        } else {
        //            prodIDSet = Set( self.loginUser.productIdList.sorted() )
        //        }
        requestProductData( productIdentifiers: prodIDSet )
        
    }
    
    func setupTableView(){
        self.tableView.register(IAPCell.self, forCellReuseIdentifier: cellId)
        self.tableView.rowHeight = 100
    }
    
    func showRestoreButton() {
        self.navigationItem.rightBarButtonItem = restoreBarItem
    }
    
//    func hideRestoreButton() {
//        self.navigationItem.rightBarButtonItem = nil
//    }
    
    @objc func closeButtonTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func restorePurchase(_ sender: UIBarButtonItem) {
        if DefaultService.isvip() {
            UIUtil.displayToastMessage(Appi18n.i18n_noNeedRestore, completeHandler: {})
            return
        }
        if IAPService.shared.isTransInProgress()  {
            UIUtil.displayToastMessage(Appi18n.i18n_transInProgress, completeHandler: {})
            return
        }else{
            IAPService.shared.setTransInProgress(true)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    
    func requestProductData(productIdentifiers: Set<String>)
    {
        if SKPaymentQueue.canMakePayments() {
            request = SKProductsRequest(productIdentifiers:
                productIdentifiers as Set<String>)
            request?.delegate = self
            self.startProgressIndicator()
            request?.start()

        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplication.openSettingsURLString)
                if url != nil
                {
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url! as URL,options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url! as URL)
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products : [SKProduct] = response.products
        
        if (products.count != 0) {
            for product in products {
//                if product.productIdentifier == self.vipProductID {
//                    self.productsArray.append(product)
//                } else {
//                    let found = self.imageCatalogs.filter({ (catalog) -> Bool in
//                        return catalog.name == product.productIdentifier
//                    })
//                    if found.count == 1 {
//                        self.productsArray.append(product)
//                    }
//                }

                self.productsArray.append(product)
                Util.printLog("===productIdentifier:\(product.productIdentifier)")
                Util.printLog("===productlocalizedTitle:\(product.localizedTitle)")
                Util.printLog("===product.localizedDescription:\(product.localizedDescription)")
                Util.printLog("===price:\(product.price)")
                Util.printLog("===currencySymbol:\(String(describing: product.priceLocale.currencySymbol))")
            }
            
//            self.productsArray.sort{
//                Double(truncating: $0.price) < Double(truncating:$1.price)
//            }
            self.productsArray.sort{
                $0.productIdentifier < $1.productIdentifier
            }
            self.tableView.reloadData()
            self.showRestoreButton()
            
        } else {
            Util.printLog("No products found")
        }
        
        //products = response.invalidProductIdentifiers as! [SKProduct]
        let productStrList = response.invalidProductIdentifiers //as! [SKProduct]
        for productStr in productStrList{
            Util.printLog("invalidProductIdentifiers:: \(productStr)")
        }
        /*
         if response.invalidProductIdentifiers.count != 0 {
         Util.printLog("invalidProductIdentifiers:\(response.invalidProductIdentifiers.description)")
         }*/
        
        self.stopProgressIndicator()
        
    }
    
    
    func buyProduct(_ product: SKProduct) {
        //let payment = SKPayment(product: productsArray[sender.tag])
        Util.printLog("buyProduct called")
        IAPService.shared.setTransInProgress(true)
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  productsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let product = productsArray[indexPath.row]
        cell.textLabel?.text = "\(product.localizedTitle)"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "\(product.getLocalizedPrice()) \(product.localizedDescription)"
        
//        let found = self.imageCatalogs.filter { (catalog) -> Bool in
//            return catalog.name == product.productIdentifier
//        }
//        if found.count >= 0, let image = found.first?.uiImage {
//            cell.imageView?.image = image
//        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if IAPService.shared.isTransInProgress() {
            UIUtil.displayToastMessage(Appi18n.i18n_transInProgress, completeHandler: {})
            return
        }
        let row = indexPath.row
//        self.startProgressIndicator()
        buyProduct(self.productsArray[row])
    }
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
