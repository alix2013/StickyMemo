//
//  IAPService.swift
//  StickyMemo
//
//  Created by alex on 2018/1/8.
//  Copyright © 2018年 alix. All rights reserved.
//

import StoreKit

class IAPService:NSObject,SKPaymentTransactionObserver {
    static let shared = IAPService()
    
    var transationInProgress:Bool = false {
        didSet{
            if transationInProgress {
                self.startProgressIndicator()
            }else{
                self.stopProgressIndicator()
            }
        }
    }
    
    var progressIndicator:ProgessIndicator = ProgessIndicator(style: .large, indicatorColor: .white, backgroundColor: AppDefault.themeColor)
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
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
    
    func isTransInProgress() -> Bool {
        return transationInProgress
    }
    
    func setTransInProgress(_ inProgress: Bool)  {
        self.transationInProgress = inProgress
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
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
                
                
            case SKPaymentTransactionState.failed:
                Util.printLog("Transaction Failed")
                Util.printLog("falied transaction Identifier: \(String(describing: transaction.transactionIdentifier ))")
                
                SKPaymentQueue.default().finishTransaction(transaction)
                Util.saveTransLog(transaction.payment.productIdentifier, transId: transId , memo: "FailedAtApple")
                UIUtil.displayToastMessage(Appi18n.i18n_transFailed, completeHandler: nil)
                
                self.transationInProgress = false
            case .purchasing :
                Util.printLog("TransactionState: purchasing")
                break
            //                self.startProgressIndicator()
            case .restored :
                Util.printLog("TransactionState: restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transationInProgress = false
                
            case .deferred :
                Util.printLog("TransactionState: deferred")
                //            default:
                //                SKPaymentQueue.default().finishTransaction(transaction)
            @unknown default:
//                <#fatalError()#>
                Util.printLog("Unkown transaction.transactionState")
            }
            Util.printLog("TransactionState:\(transaction.transactionState.rawValue)")
            
//            self.stopProgressIndicator()
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
    }

    func buyProductFromServer(_ productId:String, transId:String) {
//        switch productId {
        
//        case "0000vip":
//            DefaultService.purchaseVIP()
//        case "":
//            break
//        default:
//            break
//
//        }
        if productId == "0000vip" {
            DefaultService.purchaseVIP()
        }else{
            BKImageTemplateService().unlockImageCatalog(productId)
        }
        UIUtil.displayToastMessage(Appi18n.i18n_transSuccess, completeHandler: nil)
        Util.saveTransLog(productId, transId: transId , memo: "success")
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
            
            buyProductFromServer(prodID, transId:transID)
            UIUtil.displayToastMessage(Appi18n.i18n_restoreSuccessMessage, completeHandler: nil)
            self.transationInProgress = false
            Util.printLog("trans restored productID:\(prodID) transaction Identifier:\(transID)")
            Util.saveTransLog(prodID, transId: transID, memo: "restore")
            
        }
        
//        self.stopProgressIndicator()
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Util.printLog("====transaction restored failed======= ")
        Util.printLog(error.localizedDescription)
        UIUtil.displayToastMessage(error.localizedDescription, completeHandler: nil)
        self.transationInProgress = false
    }
    
}
