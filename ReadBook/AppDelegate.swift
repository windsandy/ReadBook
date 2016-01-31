//
//  AppDelegate.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		window = UIWindow(frame:UIScreen.mainScreen().bounds)
		let containerViewController = ContainerViewController()
		window!.rootViewController = containerViewController
		window!.makeKeyAndVisible()
		//初始化数据库
		initDBBase()
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	/**
	初始化数据库
	
	- returns: 是否成功
	*/
	func initDBBase()->Bool{
		let book = WRBook(pk: "", title: "", gid: "", nid: "")
		let sqlBook = WRFMDBManager.shareInstance().getCreateSqlWithClass(book, primaryKeyName: DBBASE_PK_FIELD_NAME)
		let chapter = WRChapter(pk: "", bookID: 1, gid: "", nid: "")
		let sqlChapter = WRFMDBManager.shareInstance().getCreateSqlWithClass(chapter, primaryKeyName: DBBASE_PK_FIELD_NAME)
		let history = WRHistory(bookID: 1, lastChapterSort: 1, dateTime: NSDate())
		let sqlHistory = WRFMDBManager.shareInstance().getCreateSqlWithClass(history, primaryKeyName: DBBASE_PK_FIELD_NAME)
		let setting = WRSetting()
		let sqlSetting = WRFMDBManager.shareInstance().getCreateSqlWithClass(setting, primaryKeyName: DBBASE_PK_FIELD_NAME)
		if WRFMDBManager.shareInstance().insertDB([sqlBook,sqlChapter,sqlHistory,sqlSetting]){
			print("创建表成功")
		}else {
			print("创建表失败,\(sqlBook)")
			return false
		}
		
		return true
	}


}

