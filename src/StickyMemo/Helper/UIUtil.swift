//
//  UIUtil.swift
//  StickyMemo
//
//  Created by alex on 2017/12/23.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit

class UIUtil {
    
    class func animateButton(_ sender:UIView) {
        sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            sender.transform = CGAffineTransform.identity
        }, completion: { b in
            if b {
            }
        })
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.allowUserInteraction,.curveEaseInOut], animations: {
//            sender.transform = CGAffineTransform.identity
//        }, completion: { b in
//            if b {
//            }
//        })
    }

    class func displayToastMessage(_ message: String, duration: Double=AppDefault.toastDuration, location: ToastLocation = .auto, backgroudColor: UIColor=AppDefault.toastBackgroundColor, textColor: UIColor = AppDefault.toastTextColor,completeHandler:(() -> Void)?) {
        
        Toast().displayMessage(message, duration: duration, location: location, backgroudColor: backgroudColor, textColor: textColor, completeHandler: completeHandler)
        
    }
    
    class func displayToastMessageAtTop(_ message: String, duration: Double=AppDefault.toastDuration, backgroudColor: UIColor=AppDefault.toastBackgroundColor, textColor: UIColor = AppDefault.toastTextColor,completeHandler:(() -> Void)?) {
        
        Toast().displayMessageAtTop(message, duration: duration, backgroudColor: backgroudColor, textColor: textColor, completeHandler: completeHandler)
        
    }
    
    class func goPurchaseVIP(_ viewController:UIViewController) {
//        let title = "\(Appi18n.i18n_goVIPtitle),\(Appi18n.i18n_goVIPsubtitle)"
        let alert = UIAlertController(title: Appi18n.i18n_goVIPtitle, message: Appi18n.i18n_goVIPsubtitle, preferredStyle: .alert)
        
        let purchaseAction = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
//            let priceVC = PriceTableViewController()
            let priceVC = IAPTableViewController()
            let navVc = UINavigationController(rootViewController: priceVC)
            viewController.present(navVc, animated: true, completion: nil)
            
//            if let nav = viewController.navigationController {
//                nav.pushViewController(priceVC, animated: true)
//            }else{
//                let vc = UINavigationController(rootViewController: priceVC)
//                viewController.present(vc, animated: true, completion: nil)
//            }
//            viewController.navigationController?.pushViewController(priceVC, animated: true)
//            viewController.present(priceVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
        }
        alert.addAction(purchaseAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    class func goStickerShop(_ viewController:UIViewController) {
        //        let title = "\(Appi18n.i18n_goVIPtitle),\(Appi18n.i18n_goVIPsubtitle)"
        //todo need change titile
        let alert = UIAlertController(title: Appi18n.i18n_goStickerShop, message: Appi18n.i18n_goStickerShopSubtitle, preferredStyle: .alert)
        
        let purchaseAction = UIAlertAction(title: Appi18n.i18n_ok, style: .default) { (_) in
            //            let priceVC = PriceTableViewController()
//            let priceVC = IAPTableViewController()
//            let navVc = UINavigationController(rootViewController: priceVC)
//            viewController.present(navVc, animated: true, completion: nil)
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let shopVC = StickerShopViewController(collectionViewLayout: layout)
            //            deskVC.boardViewController = self
            let nav = UINavigationController(rootViewController: shopVC)
            
            //            nav.modalTransitionStyle = .flipHorizontal
            viewController.present(nav, animated: true, completion: nil)
            
        }
        let cancelAction = UIAlertAction(title: Appi18n.i18n_cancel, style: .cancel) { (_) in
        }
        alert.addAction(purchaseAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    static func getPasteBoardString() -> String? {
        return UIPasteboard.general.string
    }
    
    
    static func gotoQuickStartPage(_ parentController:UIViewController) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let quickstartVC = QuickstartViewController(collectionViewLayout: layout)
        parentController.present(quickstartVC, animated: false, completion: nil)
        
    }
    
}
