//
//  Common.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/9.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import UIKit

/**
显示模式

- LightMode: 白天模式
- DarkMode:  黑夜模式
*/
enum ContentShowMode{
	case LightMode
	case DarkMode
}
/**
滑动模式

- BothCollapsed:      中间
- LeftPanelExpanded:  左滑
- RightPanelExpanded: 右滑
*/
enum SlideOutState{
	case BothCollapsed
	case LeftPanelExpanded
	case RightPanelExpanded
}
enum DateToStringFormat:String{
	case YearAndMonthAndDayAndHourAndMinuteAndSecond = "yyyy-MM-dd HH:mm:ss"
	case HourAndMinuteAndSecond = "HH:mm:ss"
}
/**
动作模式

- Search:  搜索
- Setting: 设置
*/
enum ActionOption{
	case Search
	case Setting
}
struct Common{
	/**
	获取所有字体
	*/
	static func getFontName(){
		for familyName in UIFont.familyNames(){
			print("\nFont FamilyName = \(familyName)")
			for fontName in UIFont.fontNamesForFamilyName(familyName){
				print("\(fontName)")
			}
		}
	}
	/**
	日期时间转字符串
	yyyy-MM-dd HH:mm:ss
	- parameter date: 要转换的日期
	
	- returns: 转换后的字符串
	*/
	static func getStringFromData(date:NSDate)->String{
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter.stringFromDate(date)
	}
	static func getStringFromData(date:NSDate = NSDate(),format:DateToStringFormat)->String{
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateFormat = format.rawValue
		return dateFormatter.stringFromDate(date)
	}
	/**
	字符串转日期
	
	- parameter dateString: 要转换的字符串
	- parameter dateFormat: 格式默认(yyyy-MM-dd HH:mm:ss)
	
	- returns: 转换后的日期
	*/
	static func getDataFromString(dateString:String,dateFormat:String = "yyyy-MM-dd HH:mm:ss")->NSDate?{
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateFormat = dateFormat
		return dateFormatter.dateFromString(dateString)
	}
	/**
	获取用户文档目录
	
	- returns: 文档目录
	*/
	static func getApplicationDocumentsDirectory()->NSString{
		let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
		return documentsFolder as NSString
	}
}
extension UIStoryboard{
	/**
	获取主Storyboard
	
	- returns:Storyboard
	*/
	class func mainStoryboard()->UIStoryboard{
		return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
	}
	/**
	获取左滑视图
	
	- returns: 左滑视图
	*/
	class func leftViewController()->LeftViewController?{
		return mainStoryboard().instantiateViewControllerWithIdentifier(LEFT_VIEW_CONTROLLER_STORYBOARD_ID) as? LeftViewController
	}
	/**
	获取右滑视图
	
	- returns: 右滑视图
	*/
	class func rightViewController()->RightViewController?{
		return mainStoryboard().instantiateViewControllerWithIdentifier(RIGHT_VIEW_CONTROLLER_STORYBOARD_ID) as? RightViewController
	}
	/**
	获取中间视图
	
	- returns: 中间视图
	*/
	class func centerViewController()->CenterViewController?{
		return mainStoryboard().instantiateViewControllerWithIdentifier(CENTER_VIEW_CONTROLLER_STORYBOARD_ID) as? CenterViewController
	}
	/**
	获取主NavigationController
	
	- returns: 主NavigationController
	*/
	class func centerNavigationController()->UINavigationController?{
		return mainStoryboard().instantiateViewControllerWithIdentifier(NAVIGATION_VIEW_CONTROLLER_STORYBOARD_ID) as? UINavigationController
		
	}
	/**
	获取文本浏览视图
	
	- returns: 文本浏览视图
	*/
	class func contentViewController()->ContentViewController? {
		return mainStoryboard().instantiateViewControllerWithIdentifier(CONTENT_VIEW_CONTROLLER_STORYBOARD_ID) as? ContentViewController
	}
	/**
	获取根视图
	
	- returns: 根视图
	*/
	class func rootViewController()->ContainerViewController?{
		return UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
	}
	/**
	获取章节列表页
	
	- returns: 章节列表页
	*/
	class func chapterListViewController()->ChapterListTableViewController?{
		return mainStoryboard().instantiateViewControllerWithIdentifier(CHAPTER_VIEW_CONTROLLER_STORYBOARD_ID) as? ChapterListTableViewController
	}
}
