//
//  AppDelegate.swift
//  target_project
//
//  Created by 黄彦棋 on 2019/4/18.
//  Copyright © 2019 seer. All rights reserved.
//

import UIKit
import AMapFoundationKit
import MAMapKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,BMKLocationAuthDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AMapServices.shared()?.enableHTTPS = true
        AMapServices.shared()?.apiKey = "304dc392dd803df97037ca5373b508fa"
        
        let bmk = BMKMapManager.init()
        let ret = bmk.start("abf7arxd4qQm3SrAnyoyE48P3AqECtBg", generalDelegate: nil)
        if !ret {
            print("百度地图初始化错误")
        }
        
        BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORD_TYPE.COORDTYPE_COMMON)
        
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: "abf7arxd4qQm3SrAnyoyE48P3AqECtBg", authDelegate: self)
        return true
    }

    func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        if iError.rawValue == 0 {
            print("百度地图定位鉴权成功.  --- 百度SDK api架构真的很烂啊，有没有？")
        }else{
            print("百度地图定位鉴权失败.  --- 百度SDK api架构真的很烂啊，有没有？")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

