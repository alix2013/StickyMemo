//
//  AppDelegate.swift
//  StickyMemo
//
//  Created by alex on 2017/11/24.
//  Copyright © 2017年 alix. All rights reserved.
//

import UIKit
import StoreKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isFistTimeStartForPassword:Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //for theme color
        UINavigationBar.appearance().barTintColor = AppDefault.themeColor //UIColor(red: 188/255.0, green: 58/255.0, blue:18/255.0, alpha: 0.3)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UITabBar.appearance().tintColor = AppDefault.themeColor  //UIColor(red: 188/255.0, green: 58/255.0, blue: 18/255.0, alpha: 1.0)
        
        UITabBar.appearance().barTintColor = UIColor.black

        // get rid of black bar underneath navbar
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        //for notification
        NotificationHelper.requestNotificationAuthz()
        UNUserNotificationCenter.current().delegate = self
        
        //query or init default values
        let defaults = DefaultService.getDefault()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let vc = BoardViewController()
        if defaults?.desktop == nil {
            defaults?.desktop =  DefaultService.getSystemDefaultDesktop()
        }
        vc.currentDesktop = defaults?.desktop
        window?.rootViewController = vc
        
        //init shortcut keys
        ShortcutkeyService.initOrFreshShortcutkeyCache()
        // for IAP observer
        let _ = IAPService.shared
        
        BKImageTemplateService().initBKImageData()
        
//        PasswordAuthService.showPassword()
        
//        let js = JSONMemoService().getAllJSONMemosString()
//        let js = JSONMemoService().getAllDesktopJSON()
//        Util.printLog("*****ALLJSON")
//        Util.printLog(js)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        DBManager.saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        PasswordAuthService.showPassword()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(IAPService.shared)
        DBManager.saveContext()
    }


}

