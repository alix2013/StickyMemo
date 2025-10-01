//
//  PriceTableViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/5.
//  Copyright © 2018年 alix. All rights reserved.
//

/*
import UIKit
import StoreKit

class PriceCell:UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:UITableViewCellStyle.subtitle,reuseIdentifier:reuseIdentifier )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class PriceTableViewController: BaseTableViewController, SKProductsRequestDelegate,SKPaymentTransactionObserver {
  
    //let productList = ["a","b"]
    let cellId = "Cell"
    let defaultProdIDs = Set(["stickymemo.vip"])


    //let productIdentifiers = Set(["51vpn.buyvolumeprice1","51vpn.buyvolumeprice2"])
    //var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    var transationInProgress:Bool = false
    
    lazy var restoreBarItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_restorePurchase, style: .plain, target: self, action: #selector(restorePurchase(_ :)))
        return v
    }()
    
    override func beforeViewDidLoad() {
        super.beforeViewDidLoad()
        self.isSearchBarEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupNavBarButtonItem()
        
        setupTableView()
        setupSKPayment()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        //self.title = "Sale";
//        self.hidesBottomBarWhenPushed = true
//        self.title = NSLocalizedString("Sale",comment: "sale")

//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    }

    deinit {
        Util.printLog("Deinit called===================")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressIndicator.stop()
        //to avoid crash, exit then re-enter vc
        SKPaymentQueue.default().remove(self)
    }
    
    func setupSKPayment(){
        //add observer
        SKPaymentQueue.default().add(self)
        
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
        
        //        restoreFailedTransaction()
    }
    func setupTableView(){
        self.tableView.register(PriceCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    func showRestoreButton() {
        self.navigationItem.rightBarButtonItem = restoreBarItem
    }
    
    func hideRestoreButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func restorePurchase(_ sender: UIBarButtonItem) {
        if DefaultService.isvip() {
            UIUtil.displayToastMessage(Appi18n.i18n_noNeedRestore, completeHandler: {})
            return
        }
        if self.transationInProgress  {
            UIUtil.displayToastMessage(Appi18n.i18n_transInProgress, completeHandler: {})
            return
        }else{
            self.transationInProgress = true
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Util.printLog("====transaction restored failed======= ")
        Util.printLog(error.localizedDescription)
        
        UIUtil.displayToastMessage(error.localizedDescription, completeHandler: nil)
        self.transationInProgress = false
        
//        for transaction:SKPaymentTransaction in queue.transactions as! [SKPaymentTransaction] {
//            if transaction.payment.productIdentifier == "your id"
//            {
//                print("Consumable Product Purchased")
//                // Unlock Feature
//            }
//        }
    }
    

//    func restoreFailedTransaction() {
//        /*
//         SKPaymentQueue.default().add(self)
//         SKPaymentQueue.default().restoreCompletedTransactions()
//         */
//        let transId = Util.getSavedFailedIAPTransTransId();
//        let productId = Util.getSavedFailedIAPTransProductId()
//        if transId.isEmpty || productId.isEmpty {
//            //self.displayToastMessage("No transaction need restore", completeHandler: {} )
//        } else {
//            self.buyProductFromServer(self.loginUser, productId: productId, transId: transId)
//        }
//
//    }
    func requestProductData(productIdentifiers: Set<String>)
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                productIdentifiers as Set<String>)
            request.delegate = self
            self.startProgressIndicator()
            request.start()

        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)

                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {

                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url! as URL,options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url! as URL)
                    }
                }

            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        let products : [SKProduct] = response.products

        if (products.count != 0) {
            for product in products {
                self.productsArray.append(product)
                Util.printLog("===productIdentifier:\(product.productIdentifier)")
                Util.printLog("===productlocalizedTitle:\(product.localizedTitle)")
                Util.printLog("===product.localizedDescription:\(product.localizedDescription)")
                Util.printLog("===price:\(product.price)")
                Util.printLog("===currencySymbol:\(String(describing: product.priceLocale.currencySymbol))")
            }
            self.productsArray.sort{
                Double(truncating: $0.price) < Double(truncating:$1.price)
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
        cell.textLabel?.text = "\(product.localizedTitle) \(product.getLocalizedPrice())"

        //let priceStr = productsArray[indexPath.row].price
        //let  a = productsArray[indexPath.row].priceLocale.
        //let currency = productsArray[indexPath.row].priceLocale.currencySymbol!
        //cell.detailTextLabel?.text = "\(productsArray[indexPath.row].localizedDescription) \(currency)\(priceStr)"
//        cell.detailTextLabel?.text = "\(product.localizedDescription) \(product.getLocalizedPrice())"
        cell.detailTextLabel?.text = "\(product.localizedDescription)"
        return cell
    }

    func buyProduct(_ product: SKProduct) {
        //let payment = SKPayment(product: productsArray[sender.tag])
        Util.printLog("buyProduct called")
        self.transationInProgress = true
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

//        self.stopProgressIndicator()

        
        for transaction in transactions {
            let transId = transaction.transactionIdentifier ?? "TXID_\(Date().timeIntervalSince1970)"
            
            switch transaction.transactionState {

            case SKPaymentTransactionState.purchased:
                Util.printLog("Transaction purchased")
                Util.printLog("Product Identifier: \(transaction.payment.productIdentifier)")
                Util.printLog("transaction Identifier:\(transId)")
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transationInProgress = false
                self.stopProgressIndicator()
                
            case SKPaymentTransactionState.failed:
                Util.printLog("Transaction Failed")
                Util.printLog("falied transaction Identifier: \(String(describing: transaction.transactionIdentifier ))")
                
                SKPaymentQueue.default().finishTransaction(transaction)
                Util.saveTransLog(transaction.payment.productIdentifier, transId: transId , memo: "FailedAtApple")
                UIUtil.displayToastMessage(Appi18n.i18n_transFailed, completeHandler: nil)
                
                self.transationInProgress = false
                self.stopProgressIndicator()
            case .purchasing :
                
                Util.printLog("TransactionState: purchasing")
                break
//                self.startProgressIndicator()
            case .restored :
                Util.printLog("TransactionState: restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transationInProgress = false
                self.stopProgressIndicator()
                
            case .deferred :
                Util.printLog("TransactionState: deferred")
//            default:
//                SKPaymentQueue.default().finishTransaction(transaction)
            }
            Util.printLog("TransactionState:\(transaction.transactionState.rawValue)")
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Util.printLog("transactions need restored count:\(queue.transactions.count)")

        if queue.transactions.count == 0 {
            UIUtil.displayToastMessage(Appi18n.i18n_notFoundProdNeedRestore, completeHandler: nil)
            self.transationInProgress = false
            return
        }
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction

            let prodID = t.payment.productIdentifier as String
            let transID = transaction.transactionIdentifier ?? "EmptyTransID"
//            if transaction.transactionIdentifier != nil {
//                transID = transaction.transactionIdentifier!
//            }
            
            var foundProduct:Bool = false
            for product in self.productsArray {
                if product.productIdentifier == prodID {
                    foundProduct = true
                    break
                }
            }
            
            if foundProduct {
                buyProductFromServer(prodID, transId:transID)
                UIUtil.displayToastMessage(Appi18n.i18n_restoreSuccessMessage, completeHandler: nil)
                self.transationInProgress = false
                Util.printLog("trans restored productID:\(prodID) transaction Identifier:\(transID)")
                Util.saveTransLog(prodID, transId: transID, memo: "restore")
                
            }else{
                Util.printLog("=====No found Product id:\(prodID)")
            }
            /*
             switch prodID {
             case "51VPN.BuyVolumeTier1":
             Util.printLog("51VPN.BuyVolumeTier1 restored")
             default:
             Util.printLog("IAP not setup")
             }
             */
        }
    }

    func deliverProduct(_ transaction:SKPaymentTransaction) {

        Util.printLog("IAP : productIdentifier:\(transaction.payment.productIdentifier)")
        //if transID is null use default id: TXID_username_datesecondsfrom1970

        let productId = transaction.payment.productIdentifier
        var transId = "TXID_\(Date().timeIntervalSince1970)"
        if let id = transaction.transactionIdentifier {
            transId = id
        }

        buyProductFromServer(productId, transId:transId)
//        buyProductFromServer(self.loginUser, productId: productId, transId: transId)

        /*
         if transaction.payment.productIdentifier == "51VPN.BuyVolumeTier1"
         {
         Util.printLog("Consumable Product Purchased")
         // Unlock Feature
         }
         else if transaction.payment.productIdentifier == "51VPN.BuyVolumeTier2"
         {
         Util.printLog("Non-Consumable Product Purchased")
         // Unlock Feature
         }*/
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.transationInProgress {
            UIUtil.displayToastMessage(Appi18n.i18n_transInProgress, completeHandler: {})
            return
        }
        let row = indexPath.row
        Util.printLog("======row:\(row) selected, start indicator")
        DispatchQueue.main.async{
            self.startProgressIndicator()
        }
        
        buyProduct(self.productsArray[row])
    }


    func buyProductFromServer(_ productId:String, transId:String) {
        
        DefaultService.purchaseVIP()
        UIUtil.displayToastMessage(Appi18n.i18n_transSuccess, completeHandler: nil)
        DispatchQueue.main.async{
            self.stopProgressIndicator()
        }
        
        Util.saveTransLog(productId, transId: transId , memo: "success")
    }

//
//    func buyProductFromServer(_ loginUser: LoginUser,productId:String, transId:String ) {
//        self.startProgressIndicator()
//        UserService().buyProduct(loginUser, productId: productId, transId: transId ) { result in
//            if result.isSuccess {
//
//                self.displayToastMessage(NSLocalizedString("Transaction success", comment: "tx success"), completeHandler: {})
//
//                //clean saved failed trans
//                Util.cleanSavedFailedIAPTrans()
//
//                Util.saveTransLog(loginUser.username, productId: productId, transId: transId, memo: "Transaction Success")
//
//            }else{
//                Util.saveFailedIAPTrans(productId: productId, transId: transId)
//                // for duplicate
//                if result.errorCode == 409 {
//                    self.displayToastMessage(NSLocalizedString("Transaction completed", comment: "tx completed"), completeHandler: {})
//                    Util.cleanSavedFailedIAPTrans()
//                } else {
//                    let i18nMsg = NSLocalizedString("Sorry,Backend server error,app will try again at next time access this page", comment:"failed at backend")
//                    self.displayToastMessage(i18nMsg, completeHandler: {})
//                }
//                Util.printLog( "Failed to buyProduct: \(result.errorMessage))");
//
//                Util.saveTransLog(loginUser.username, productId: productId, transId: transId, memo: "Transaction failed at backend server:\(result.errorMessage) \(result.errorCode)")
//            }
//
//            DispatchQueue.main.async{
//                self.stopProgressIndicator()
//                //self.endRefreshControlDisplay()
//
//            }
//
//        }
//    }
}

*/


