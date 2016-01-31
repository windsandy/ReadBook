//
//  Constant.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/9.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import UIKit
/// 默认表主键名称
let DBBASE_PK_FIELD_NAME = "id"
/// 数据库名称
let DBBASE_NAME = "Cache.sqlite" //"WindReadBook.sqlite"
/// 屏幕宽度
let WIDTH_MAIN = UIScreen.mainScreen().bounds.width
/// 屏幕高度
let HEIGHT_MAIN = UIScreen.mainScreen().bounds.height
/// 左滑菜单最大滑动比例
let CENTER_LEFT_PANEL_EXPANDED_OFFSET:CGFloat = WIDTH_MAIN
/// 右滑菜单最大滑动比例
let CENTER_RIGHT_PANEL_EXPANDED_OFFSET:CGFloat = 60

/// 主页图书列表cell id
let BOOK_LIST_CELL_IDENTIFIER = "bookListCellIdentifier"
/// 主页图书列表cell nib名称
let BOOK_LIST_CELL_NIB_NAME = "BookListTableViewCell"
/// 主页图书列表cell高度
let BOOK_LIST_CELL_HEIGHT:CGFloat = 80

/// 搜索页列表cell id
let BOOK_SEARCH_LIST_CELL_IDENTIFIER = "searchBookCellIdentifier"

/// 章节页列表cell id
let CHAPTER_LIST_CELL_IDENTIFIER = "chapterListCellIdentifier"
/// 章节页列表cell nib名称
let CHAPTER_LIST_CELL_NIB_NAME = "ChapterListTableViewCell"

/// 主页到搜索页导航id
let CENTER_TO_SEARCH_SEGUE_IDENTIFIER = "centerToSearchSegueIdentifier"
/// 主页到章节页导航id
let CENTER_TO_READ_SEGUE_IDENTIFIER = "centerToReadSegueIdentifier"
/// 搜索页到详情页导航id
let SEARCH_TO_DETAIL_SEGUE_IDENTIFIER = "searchToDetailSegueIdentifier"
/// 阅读页到章节列表页导航id
let READ_TO_CHAPTER_SEGUE_IDENTIFIER = "readToChapterSegueIdentifier"
/// 应用名称
let APP_NAME = "风中书屋"

/// 中央主页面
let CENTER_VIEW_CONTROLLER_STORYBOARD_ID = "CenterStoryboardID"
/// 左侧滑动页
let LEFT_VIEW_CONTROLLER_STORYBOARD_ID = "LeftViewStoryboardID"
/// 右侧滑动页
let RIGHT_VIEW_CONTROLLER_STORYBOARD_ID = "RightStoryboardID"
/// 搜索页
let SEARCH_VIEW_CONTROLLER_STORYBOARD_ID = "SearchBookStoryboardID"
/// 详情页
let DETAIL_VIEW_CONTROLLER_STORYBOARD_ID = "BookDetailStoryboardID"
/// 阅读页
let READ_VIEW_CONTROLLER_STORYBOARD_ID = "ReadBookStoryboardID"
/// 显示正文页
let CONTENT_VIEW_CONTROLLER_STORYBOARD_ID = "ContentStoryboardID"
/// 章节列表页
let CHAPTER_VIEW_CONTROLLER_STORYBOARD_ID = "ChapterListStoryboardID"
/// 设置页
let SETTING_VIEW_CONTROLLER_STORYBOARD_ID = "SettingStoryboardID"
/// 导航页
let NAVIGATION_VIEW_CONTROLLER_STORYBOARD_ID = "CenterNavigationStoryboardID"

let MAX_HEIGHT:CGFloat = 100000
/// 表名与类名对应
/// 图书表名
let BOOK_ENTITY_NAME = "WRBook"
/// 章节表名
let CHAPTER_ENTITY_NAME = "WRChapter"
/// 服务器表名
let SERVICE_ENTITY_NAME = "WRService"
/// 设置表名
let SETTING_ENTITY_NAME = "WRSetting"
/// 历史表名
let HISTORY_ENTITY_NAME = "WRHistory"
/// 默认字体大小
let CONTENT_FONT_SIZE_DEFAULT:CGFloat = 14
/// 默认行间距
let CONTENT_LINE_SIZE_DEFAULT:CGFloat = 5
/// 默认字体
let FONT_NAME_DEFAULT:String = "Helvetica-Light"
/// 默认白天模式前景色
let FORE_LIGHT_COLOR = UIColor.blackColor()
/// 默认黑夜模式前景色
let FORE_DARK_COLOR = UIColor.grayColor()
/// 默认白天模式背景色
let BACK_LIGHT_COLOR = UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
/// 默认黑夜模式背景色
let BACK_DARK_COLOR = UIColor(red: 21/255.0, green: 22/255.0, blue: 45/255.0, alpha: 1)
//书籍网站API
struct BookServiceEasouAPI{
	/// 搜索页url
	static let searchUrl = "http://api.easou.com/api/bookapp/search.m"
	/**
	搜索页参数表
	
	- parameter word: 搜索关键词
	
	- returns: 参数表
	*/
	static func getSearchParameters(word:String)->[String:String]{
		var searchParameters = [String:String]()
		searchParameters["type"] = "0"
		searchParameters["sort_type"] = "100"
		searchParameters["cid"] = "eef_"
		searchParameters["word"] = word
		searchParameters["version"] = "002"
		searchParameters["os"] = "ios"
		searchParameters["appverion"] = "1021"
		return searchParameters
	}
	/// 详情页url
	static let detailUrl = "http://api.easou.com/api/bookapp/cover.m"
	/**
	详情页参数表
	
	- parameter gid: gid
	
	- returns: 参数表
	*/
	static func getDetailParameters(gid:String)->[String:String]{
	  var detailParameters = [String:String]()
			detailParameters["gid"] = gid
			detailParameters["cid"] = "eef_"
		return detailParameters
	}
	/// 目录页url
	static let directoryUrl = "http://api.easou.com/api/bookapp/chapter_list.m"
	/**
	目录页参数表
	
	- parameter gid: gid
	- parameter nid: nid
	
	- returns: 参数表
	*/
	static func getDirectoryParameters(gid:String,nid:String)->[String:String]{
		var directoryParameters = [String:String]()
			directoryParameters["gid"] = gid
			directoryParameters["nid"] = nid
			directoryParameters["page_id"] = "1"
			directoryParameters["size"] = "9999"
			directoryParameters["cid"] = "eef_"
		return directoryParameters
	}
	/// 文章页url
	static let chapterUrl = "http://api.easou.com/api/bookapp/chapter.m"
	/**
	文章页参数表
	
	- parameter gid:          gid
	- parameter nid:          nid
	- parameter sort:         序号
	- parameter chapter_name: 章节名称
	
	- returns: 参数表
	*/
	static func getChapterParameters(gid:String,nid:String,sort:String,chapter_name:String)->[String:String]{
		var chapterParameters = [String:String]()
			chapterParameters["cid"] = "eef_"
			chapterParameters["gid"] = gid
			chapterParameters["nid"] = nid
			chapterParameters["sort"] = sort
			chapterParameters["chapter_name"] = chapter_name
		return chapterParameters
	}
	/**
	返回easou的http请求头
	
	- returns: header
	*/
	static func getEAsouHeader()->[String:String]{
		var header = [String:String]()
		header["User-Agent"] = "å®æå°è¯´ 2.7.5 rv:2.7.10 (iPhone; iPhone OS 9.2; zh_CN)"
		header["Host"] = "api.easou.com"
		header["Accept-Encoding"] = "gzip"
		return header
	}
}