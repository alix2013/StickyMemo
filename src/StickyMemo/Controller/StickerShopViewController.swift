//
//  StickerShopViewController.swift
//  StickyMemo
//
//  Created by alex on 2018/1/13.
//  Copyright © 2018年 alix. All rights reserved.
//

import UIKit
import StoreKit

class StickerProduct {
    var skProduct: SKProduct
    var uiImage: UIImage?
    
    init(skProduct: SKProduct, uiImage:UIImage?) {
        self.skProduct = skProduct
        self.uiImage = uiImage
    }
}

class StickerShopCell: UICollectionViewCell {
    
    var stickerProduct: StickerProduct? {
        didSet {
            guard let stickerProduct = stickerProduct else {
                return
            }
            titleLabel.text = "\(stickerProduct.skProduct.getLocalizedPrice()) \(stickerProduct.skProduct.localizedTitle)"
            
//            let width = self.frame.width / 2  - 2
//            let height = width  //* 1.2
//            let size =  CGSize(width: width, height: height)
            
            imageView.image = stickerProduct.uiImage //?.scaled(to: size, scalingMode: .aspectFill)
//            resizedImageWithinRect(rectSize: size )
        }
    }
    
    
    var titleLabel:UILabel = {
        let v = UILabel()
        //        v.backgroundColor = .blue
        v.textAlignment = .center
        v.numberOfLines = 0
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
    
    var imageView:UIImageView = {
        let v = UIImageView()
        //        v.image = UIImage(named:"desktop_default_background")
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
//        v.contentMode = .center
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
        
        self.addSubview(titleLabel)
        self.addSubview(imageView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":titleLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0":imageView]))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0][v1(80)]-|", options: [], metrics: nil, views: ["v0":imageView, "v1":titleLabel]))
        
        self.addSubview(selectedImageView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0(30)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(30)]", options: [], metrics: nil, views: ["v0":selectedImageView]))
        
        selectedImageView.isHidden = true
        //        setupGesture()
    }
    
}


class StickerShopViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout,SKProductsRequestDelegate {
    
    //parent controller
//    var boardViewController: BoardViewController?
    
    var selectedIndexPath: IndexPath?
//    var isInLongTap: Bool = false
    
    let buttonSoundDing:ButtonSound = ButtonSound(type: .ding)
//    let buttonSoundSoso:ButtonSound = ButtonSound(type: .soso)
    
//    let vipProductID:String = "0000vip"
    let cellId = "Cell"
    let defaultProdIDs = Set(["bg_bubble_left","bg_bubble_right,bg_gap,bg_hole_left,bg_hole_top,bg_sport"])
    

//    var productsArray = Array<SKProduct>()
    var productsArray = Array<StickerProduct>()
    var imageCatalogs:[BKImageCatalog] = []
    var imageCatalogsMap:Dictionary<String,UIImage?> = [:]
    
    var progressIndicator:ProgessIndicator = ProgessIndicator(style: .large, indicatorColor: .white, backgroundColor: AppDefault.themeColor)
    
    
    lazy var restoreBarItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_restorePurchase, style: .plain, target: self, action: #selector(restorePurchase(_ :)))
        return v
    }()
    
    lazy var buyBarItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: Appi18n.i18n_purchase, style: .plain, target: self, action: #selector(goPurchase(_ :)))
        return v
    }()
    
    lazy var closeBarItem: UIBarButtonItem = {
        
//        let v = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(closeButtonTap))
         let v = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTap) )
        
        return v
    }()
    
    var request:SKProductsRequest?
    
    deinit {
        // cancel request to avoid crash at quick in/out viewcontroller
        Util.printLog("======StickerShopViewController Deinit cancel request ===================")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopProgressIndicator()
        if let request = request {
             Util.printLog("======StickerShopViewController cancel request====")
            request.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = Appi18n.i18n_stickerShop

        queryLockedCatalogs()
        
        setupViews()
        setupNavigationButton()
        
        setupSKPayment()
    
//        setupGesture()
        
    }
    
//    func setupGesture(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))

//        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(tap2GestureHandler))
//        tap2Gesture.numberOfTapsRequired = 2
//        self.view.addGestureRecognizer(tap2Gesture)

//        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapGestureHandler))
//        self.view.addGestureRecognizer(longTapGesture)
//    }
    
    
    func setupViews() {
        self.view.backgroundColor = .white
        //        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(StickerShopCell.self, forCellWithReuseIdentifier: cellId)
    }
    

    func queryLockedCatalogs() {
        self.imageCatalogs = BKImageTemplateService().queryLockedImageCatalogs()
        for catalog in self.imageCatalogs {
            self.imageCatalogsMap["\(catalog.name)"] = catalog.uiImage
        }
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
    
    
    func showRestoreButton() {
        self.navigationItem.rightBarButtonItems = [buyBarItem,restoreBarItem]
    }
    
    @objc func closeButtonTap(_ sender: UIBarButtonItem) {
        buttonSoundDing.play()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goPurchase(_ sender: UIBarButtonItem) {
        if IAPService.shared.isTransInProgress() {
            UIUtil.displayToastMessage(Appi18n.i18n_transInProgress, completeHandler: {})
            return
        }
        
        if let indexPath = self.selectedIndexPath {
            let product = self.productsArray[indexPath.item].skProduct
            self.buyProduct(product)
        }
        
    }
    @objc func restorePurchase(_ sender: UIBarButtonItem) {
        
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
            Util.printLog("======product count:\(products.count)")
            for product in products {
                if let uiImage = self.imageCatalogsMap[product.productIdentifier] {
                    self.productsArray.append(StickerProduct(skProduct:product,uiImage:uiImage))
                }else{
                    Util.printLog("======not found product in catalog:\(product.productIdentifier)")
                }
                Util.printLog("===productIdentifier:\(product.productIdentifier)")
                Util.printLog("===productlocalizedTitle:\(product.localizedTitle)")
                Util.printLog("===product.localizedDescription:\(product.localizedDescription)")
                Util.printLog("===price:\(product.price)")
                Util.printLog("===currencySymbol:\(String(describing: product.priceLocale.currencySymbol))")
                
//                let lockedCatalogs = self.imageCatalogs.filter({ (catalog) -> Bool in
//                    return catalog.name == product.productIdentifier
//                })
//
//                if lockedCatalogs.count == 1, let cataImage = lockedCatalogs.first {
//                    Util.printLog("===add productIdentifier:\(product.productIdentifier)")
//
//                    self.productsArray.append(StickerProduct(skProduct:product,uiImage:cataImage.uiImage))
//                }else{
//                    Util.printLog("======not found product in catalog image:\(product.productIdentifier)")
//                }
//                for catalog in self.imageCatalogs {
//                    print("--------name>:\(catalog.name)")
//                }
                
                
                
//                for catalog in self.imageCatalogs {
//                    if catalog.name == product.productIdentifier {
//                        self.productsArray.append(StickerProduct(skProduct:product,uiImage:catalog.uiImage))
//                        break
//                    }
//                }
                
            }
            
            self.productsArray.sort{
                            Double(truncating: $0.skProduct.price) < Double(truncating:$1.skProduct.price)
                        }
//            self.productsArray.sort{
//                $0.skProduct.productIdentifier < $1.skProductproductIdentifier
//            }

            self.showRestoreButton()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
            
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

}

extension StickerShopViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsArray.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StickerShopCell
        let stickerProduct = productsArray[indexPath.item]
        cell.stickerProduct = stickerProduct
       
        if let selectedIndexPath = self.selectedIndexPath {
            if selectedIndexPath == indexPath {
                cell.selectedImageView.isHidden = false
            }else{
                cell.selectedImageView.isHidden = true
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        collectionView.reloadData()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let width = min(self.view.frame.width / 2, 150)
        let width = self.view.frame.width / 2  - 2
        let height = width  //* 1.2
        return CGSize(width: width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.reloadData()
    }
    
    
    
//    @objc func tapGestureHandler(sender: UITapGestureRecognizer){
//        guard let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) else { return }
//
//        guard let desktopList = self.cdDesktopList,let desktopName = desktopList[indexPath.item].name  else { return }
//        guard let cell = collectionView?.cellForItem(at: indexPath) else { return }
//
//        let tapPoint = sender.location(in: cell)
//        let sourcRect = CGRect(x: tapPoint.x, y: tapPoint.y, width: 1, height: 1)
//        Util.printLog("source rect:\(sourcRect)")
//
//        self.selectedIndexPath = indexPath
//
//        let actionSheet = UIAlertController(title: "\(Appi18n.i18n_choiceActionTitle) \(desktopName) ", message: nil, preferredStyle: .actionSheet)
//
//        let actionOpen = UIAlertAction(title:Appi18n.i18n_open, style: .default) { (_) in
//
//            if let desktopList = self.cdDesktopList {
//                let desktop = desktopList[indexPath.item]
//                self.openDesktop(desktop)
//            }
//
//        }
//        let actionDelete = UIAlertAction(title:Appi18n.i18n_delete, style: .default) { (_) in
//            if let cdDesktopList = self.cdDesktopList{
//                let cdDesktop = cdDesktopList[indexPath.item]
//                self.confirmDelete(cdDesktop)
//            }
//
//        }
//
//        let actionCancel = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
//
//        }
//
//        let actionSetBGImage = UIAlertAction(title: Appi18n.i18n_setDesktopBackground, style: .default) { (_) in
//
//            self.choiceBackgroundImage(sourcRect)
//        }
//
//        actionSheet.addAction(actionOpen)
//
//        // system default desktop id = 1, no delete
//        if desktopList[indexPath.item].id != "1" {
//            actionSheet.addAction(actionDelete)
//        }
//        actionSheet.addAction(actionCancel)
//        actionSheet.addAction(actionSetBGImage)
//
//        // adaptive iPad
//        if let popoverPresentationController = actionSheet.popoverPresentationController {
//            //            if let cell = collectionView?.cellForItem(at: indexPath)  {
//            popoverPresentationController.sourceView = cell
//            let tapPoint = sender.location(in: cell)
//            let sourcRect = CGRect(x: tapPoint.x, y: tapPoint.y, width: 1, height: 1)
//            //                popoverPresentationController.sourceRect = cell.bounds
//            popoverPresentationController.sourceRect = sourcRect
//            // arrow point to cell center
//            //                popoverPresentationController.sourceRect = CGRect(x: (cell.bounds.origin.x + cell.frame.width / 2), y: (cell.bounds.origin.y + cell.frame.height / 2), width: 1, height: 1)
//            popoverPresentationController.permittedArrowDirections = .any
//            //popoverPresentationController.preferredContentSize
//            //popoverPresentationController.popoverLayoutMargins = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
//            //            }
//            //            else {
//            //                popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
//            //            }
//        }
//
//        present(actionSheet, animated: true, completion: nil)
//
//        //            let cell = self.collectionView?.cellForItem(at: indexPath)

//    }

    
   
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
