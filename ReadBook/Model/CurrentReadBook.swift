//
//  CurrentReadBook.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/27.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import UIKit
class CurrentReadBook {
	//正在阅览的书籍对象
	var book:WRBook?
	//当前章节
	var chapterNumber:Int = 1
	//当前页号
	var currentPage:Int = 0{
		didSet {
			saveHistory()
		}
	}
	//每章正文分页数组
	var contentAttribted = [NSMutableAttributedString]()
	//当正文没有下载完，显示的空白页面
	let blankPage = NSMutableAttributedString(string: "")
	//正文字号
	var contentFontSize:CGFloat = 14{
		didSet {
			saveHistory()
		}
	}
	//字体颜色
	var contentColor:UIColor = FORE_LIGHT_COLOR{
		didSet {
			saveHistory()
		}
	}
	//背景色
	var contentBackColor:UIColor = BACK_LIGHT_COLOR{
		didSet {
			saveHistory()
		}
	}
	//行间距
	var lineSize:CGFloat = 5{
		didSet {
			saveHistory()
		}
	}
	//显示模式
	var contentShowMode:ContentShowMode = ContentShowMode.LightMode{
		didSet {
			saveHistory()
		}
	}
	//翻页模式
	var transitionStyle:UIPageViewControllerTransitionStyle = .PageCurl{
		didSet {
			saveHistory()
		}
	}
	//正文
	var content = ""
	var title = ""
	var history:WRHistory?
	
	//保存历史纪录
	func saveHistory(){
		history?.currentPage = currentPage
		history?.lastChapterSort = chapterNumber
		history?.dateTime = NSDate()
		history?.dayOrNight =  contentShowMode == ContentShowMode.DarkMode ? 1 : 0
		history?.fontSize = contentFontSize
		history?.lineSize = lineSize
		guard history != nil else {return}
		WRFMDBManager.shareInstance().updateDB_Queue([history!]) { (successNumber, failureNumber, isFinish) -> Void in
		}
	}
	init(currentbook:WRBook){
		book = currentbook
		if book != nil && book!.id != nil{
			history = BookEasouReload.getBookHistory(book!.id!)
			if let cpNumber = history?.lastChapterSort?.integerValue{
				chapterNumber = cpNumber
			}
			if let cuPage = history?.currentPage?.integerValue{
				currentPage = cuPage
			}
			if let  cfs = history?.fontSize?.integerValue{
				contentFontSize = CGFloat(cfs)
			}
			if let ls = history?.lineSize?.integerValue{
				lineSize = CGFloat(ls)
			}
			if let contentSM = history?.dayOrNight{
				if contentSM == 0{
					contentShowMode = ContentShowMode.LightMode
				}else{
					contentShowMode = ContentShowMode.DarkMode
				}
			}
		}
	}
}
extension CurrentReadBook{
	//根据页号返回显示视图
	 func viewControllerAtIndex(index:Int)->ContentViewController?{
		if contentAttribted.count == 0 || index >= contentAttribted.count{
			return nil
		}
		currentPage = index
		return getContentViewController(contentAttribted[currentPage])
	}
	//根据内容获取页号
	func indexOfViewController(viewController:ContentViewController)->Int{
		if let index = viewController.contentIndex{
			return index
		}else{
			return NSNotFound
		}
	}
	//获取一个显示正文视图
	func getContentViewController(dataAttributedString:NSMutableAttributedString)->ContentViewController?{
		let contentViewController = UIStoryboard.contentViewController()
		contentViewController?.dataAttributedString = dataAttributedString
		contentViewController?.contentIndex = currentPage
		contentViewController?.contentShowMode = contentShowMode
		contentViewController?.contentCountPage = contentAttribted.count
		contentViewController?.titleOfChapter = title
		return contentViewController
	}
	//根据正文设置分页数组
	func createContentPages(content:String)->[NSMutableAttributedString]{
		let font = ReadContent.getContentFont(contentFontSize)
		return ReadContent.getPagesOfString(content,font: font,lineSize: lineSize,foreColor:contentColor,sizeOfContainer: ReadContent.getContentCGRect().size)
	}
	//返回空白页
	func getBlankViewController()->ContentViewController?{
		return getContentViewController(blankPage)
	}
}
//MARK:页面显示文字获取
extension CurrentReadBook{
	//设置
	func setChapterContent(_conentAttributed:[NSMutableAttributedString],_currentPage: Int,currentChapterNumber:Int)->ContentViewController?{
		contentAttribted = _conentAttributed
		//print("contentAttribted=\(contentAttribted)")
		//print("currentPage=\(currentPage)")
		//print("_conentAttributed.count=\(_conentAttributed.count)")
		if currentPage >= _conentAttributed.count{
			currentPage = _conentAttributed.count - 1
		}else if currentPage < 0{
			currentPage = 0
		}
			else {
			currentPage = _currentPage
		}
		print("currentPage=\(currentPage)")
		if let contentViewController = viewControllerAtIndex(currentPage){
			chapterNumber = currentChapterNumber
			self.saveHistory()
			return contentViewController
		}
		return nil
	}
	//根据书id和章节号获取当前章节正文
	func getChapterContent(book:WRBook?,currentChapterNumber:Int,completionHandler:([NSMutableAttributedString],Int)->Void){
		if let chaptersCount = book?.chaptersCount?.integerValue{
			guard currentChapterNumber > 0 &&   currentChapterNumber <=  chaptersCount else {return}
			if book != nil && book?.id != nil{
				BookEasouReload.getBookChapterContent(book!.id!, sort: currentChapterNumber) { (content,title) -> Void in
					self.title = title
					let currentContentAttribted = self.createContentPages(content)
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completionHandler(currentContentAttribted,currentChapterNumber)
					})
				}
			}
		}
	}
	//前一章节
	func getPreChapterContent(completionHandler:(currentContentViewController:ContentViewController?)->Void){
		if chapterNumber > 1{
			getChapterContent(book, currentChapterNumber: chapterNumber - 1) { (contentAttribted,currentChapterNumber) -> Void in
				completionHandler(currentContentViewController: self.setChapterContent(contentAttribted,_currentPage: contentAttribted.count - 1,currentChapterNumber:currentChapterNumber))
			}
		}
	}
	//后一章节
	func getNextChapterContent(completionHandler:(currentContentViewController:ContentViewController?)->Void){
		if chapterNumber < book!.chaptersCount!.integerValue{
			getChapterContent(book, currentChapterNumber: chapterNumber + 1) { (contentAttribted,currentChapterNumber) -> Void in
				completionHandler(currentContentViewController:self.setChapterContent(contentAttribted,_currentPage: 0,currentChapterNumber:currentChapterNumber))
			}
		}
	}
	//当前章节
	func getAgainChapterContent(completionHandler:(currentContentViewController:ContentViewController?)->Void){
		getChapterContent(book, currentChapterNumber: chapterNumber) { (contentAttribted,currentChapterNumber) -> Void in
			completionHandler(currentContentViewController:self.setChapterContent(contentAttribted,_currentPage: self.currentPage,currentChapterNumber:currentChapterNumber))
		}
	}
	//重新获取章节列表
//	mutating func checkChapter(book:WRBook?,completionHandler:(currentContentViewController:ContentViewController?)->Void){
//		if let id = book?.id,gid = book?.gid,nid = book?.nid{
//			let predicate = WRPredicate(key: "bookID", value: id, dataType: DataType.NSNumber)
//			let sort = WRSortDescriptor(key: "sort", sort: WRSort.Asc)
//			BookEasouReload.getBookChapter(id, predicates: [predicate], sorts: [sort], completionHandler: { (wrChapters) -> Void in
//				if wrChapters.count <= 0{
//					BookEasouReload.refreshChapter(id, gid: gid, nid: nid, completionHandler: { (number) -> Void in
//						self.getAgainChapterContent({ (currentContentViewController) -> Void in
//							completionHandler(currentContentViewController: currentContentViewController)
//						})
//					})
//				}
//			})
//		}
//	}
}