//
//  BookEasouReload.swift
//  FMDBManager
//
//  Created by 张旭 on 16/1/23.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
struct BookEasouReload{
	/**
	刷新书籍和章节列表
	*/
	static func uninRefreshBook(){
		let books = getBookList()
		books.forEach { (book) -> () in
			refreshBook(book, completionHandler: { (isSuccess) -> Void in
				if isSuccess{
					if let id  = book.id,gid = book.gid,nid = book.nid{
						refreshChapter(id, gid: gid, nid: nid, completionHandler: { (number) -> Void in})
					}
				}
			})
		}
		
	}
	/**
	获取书籍列表(同步方式)
	
	- returns: 书籍对象数组
	*/
	static func getBookList()->[WRBook]{
		let sql = WRFMDBManager.shareInstance().getSelectSql(BOOK_ENTITY_NAME,sortDescriptors:[WRSortDescriptor(key: "insertTime", sort: WRSort.Desc)])
		let bookArray = WRFMDBManager.shareInstance().selectDB_Queue(sql)
		var wrBooks = [WRBook]()
		bookArray.forEach { (rowDic) -> () in
			let wrbook = WRBook(pk: "", title: "", gid: "", nid: "")
			wrbook.setValuesForKeysWithDictionary(rowDic)
			wrBooks.append(wrbook)
		}
		return wrBooks
	}
	/**
	更新书籍(回调方式)
	
	- parameter book:              要更新的书籍对象
	- parameter completionHandler: 回调
	
	- returns: 失败
	*/
	static func refreshBook(book:WRBook,completionHandler:(isSuccess :Bool)->Void)->Bool{
		if let gid = book.gid{
			guard !gid.isEmpty else {return false}
			BookEasouAPI.getBookDetail(gid, completionHandler: { (bookDic) -> Void in
				let bookNew = BookEasouAPI.getBookDetail(bookDic, book: book)
				print("bookNew=\(bookNew.title)")
				WRFMDBManager.shareInstance().updateDB_QueueTransaction([bookNew], completionHandler: { (successNumber, failureNumber, isFinish) -> Void in
					completionHandler(isSuccess: successNumber > 0 ? true : false)
				})
			})
		}
		return true
	}
	/**
	更新封面图片(回调方式)
	
	- parameter book:              book对象
	- parameter isCover:           如果已有是否覆盖
	- parameter completionHandler: 回调
	
	- returns: 失败
	*/
	static func refreshBookCover(book:WRBook,isCover:Bool,completionHandler:(isSuccess :Bool)->Void)->Bool{
		if let coverUrl = book.cover{
			guard !coverUrl.isEmpty else {return false}
			if book.coverData == nil || isCover{
				BookEasouAPI.getBookCoverImage(coverUrl, completionHandler: { (imageData) -> Void in
					book.coverData = imageData
					WRFMDBManager.shareInstance().updateDB_QueueTransaction([book], completionHandler: { (successNumber, failureNumber, isFinish) -> Void in
						completionHandler(isSuccess: successNumber > 0 ? true : false)
					})
				})
			}
		}
		return true
	}
	/**
	更新章节列表(回调方式 返回更新的章节数量)
	
	- parameter bookID:            bookID
	- parameter gid:               gid
	- parameter nid:               nid
	- parameter completionHandler: 回调
	
	- returns: 失败
	*/
	static func refreshChapter(bookID:NSNumber,gid:String,nid:String,completionHandler:(number :NSNumber)->Void)->Bool{
		var currentMaxSort = 0
		let sql = " select max(sort) from WRChapter where bookID=\(bookID)"
		if let maxSort = WRFMDBManager.shareInstance().selectDB_ObjectQueue(sql) as? Int{
			currentMaxSort = maxSort
		}
		BookEasouAPI.getBookChapter(nid, gid: gid, currentMaxSort: currentMaxSort, completionHandler: { (chaptersDic) -> Void in
			var chapters = [WRChapter]()
			chaptersDic.forEach({ (chapterDic) -> () in
				var  chapter = WRChapter(pk: "", bookID: bookID, gid: "", nid: "")
				chapter = BookEasouAPI.getBookChapter(chapterDic, gid: gid, chapter: chapter)
				chapter.bookID = bookID
				chapters.append(chapter)
			})
			WRFMDBManager.shareInstance().insertDB_Queue(chapters, completionHandler: { (successNumber, failureNumber, isFinish) -> Void in
				completionHandler(number: successNumber)
			})
		})
		return true
	}
	/**
	从数据库获取章节(回调方式 返回章节对象数组)
	
	- parameter bookID:            bookID
	- parameter predicates:        条件
	- parameter sorts:             排序
	- parameter completionHandler: 回调
	
	- returns: 失败
	*/
	static func getBookChapter(bookID:NSNumber,predicates:[WRPredicate],sorts:[WRSortDescriptor],completionHandler:(wrChapters :[WRChapter])->Void){
		let sql = WRFMDBManager.shareInstance().getSelectSql(CHAPTER_ENTITY_NAME, predicates: predicates, sortDescriptors: sorts)
		WRFMDBManager.shareInstance().selectDB_QueueTransaction(sql) { (results) -> Void in
			var wrChapters = [WRChapter]()
			results.forEach { (rowDic) -> () in
				let wrChapter = WRChapter(pk: "", bookID: bookID, gid: "", nid: "")
				wrChapter.setValuesForKeysWithDictionary(rowDic)
				wrChapters.append(wrChapter)
			}
			completionHandler(wrChapters: wrChapters)
		}
	}
	/**
	获取章节正文
	如果sort传入的>0那么是获取单章节正文,如果=0那么是获取全部没有正文的章节的正文
	- parameter bookID:            bookID
	- parameter sort:              sort
	- parameter completionHandler: 回调
	
	- returns: 失败
	*/
	static func getBookChapterContent(bookID:NSNumber,sort:Int = 0,completionHandler:(content:String,title:String)->Void)->Bool{
		var  predicates = [WRPredicate]()
		predicates.append(WRPredicate(key: "bookID", value: bookID, dataType: DataType.NSNumber))
		if sort > 0{
			predicates.append(WRPredicate(key: "sort", value: sort, dataType: DataType.NSNumber))
		}else{
			predicates.append(WRPredicate(key: "success", value: 0, dataType: DataType.NSNumber))
		}
		let sortDescriptors = WRSortDescriptor(key: "sort", sort: WRSort.Asc)
		predicates.forEach { (predicate) -> () in
			//print("predicate=\(predicate.key);\(predicate.value)")
		}
		
		getBookChapter(bookID, predicates: predicates, sorts: [sortDescriptors]) { (wrChapters) -> Void in
			if wrChapters.count <= 0{
				completionHandler(content: "没有章节",title:"")
				return
			}
			if sort > 0{
				getBookChapterContent(wrChapters[0], completionHandler: { (content,title) -> Void in
					completionHandler(content: content,title:title)
				})
				return
			}
			wrChapters.forEach({ (wrChapter) -> () in
				getBookChapterContent(wrChapter, completionHandler: { (content,title) -> Void in})
			})
		}
		return true
	}
	/**
	获取章节正文
	
	- parameter chapter:           章节对象
	- parameter completionHandler: 回调
	*/
	static func getBookChapterContent(chapter:WRChapter,completionHandler:(content:String,title:String)->Void){
		if chapter.success == nil || chapter.success!.intValue <= 0{
			if let sort = chapter.sort,gid = chapter.gid,nid = chapter.nid,chapter_name = chapter.chapter_name{
				let parameters = BookServiceEasouAPI.getChapterParameters(gid, nid: nid, sort: sort.description, chapter_name: chapter_name)
				BookEasouAPI.getBookChapterContent(BookServiceEasouAPI.chapterUrl, parameters: parameters, completionHandler: { (bookContentDic) -> Void in
					if let content = bookContentDic["content"] as? String{
						if !content.isEmpty{
							chapter.content = content
							chapter.success = 1
							WRFMDBManager.shareInstance().updateDB_QueueTransaction([chapter], completionHandler: { (successNumber, failureNumber, isFinish) -> Void in})
							let title = chapter.chapter_name == nil ? "" : chapter.chapter_name!
							let content = title + "\n" + chapter.content!
							completionHandler(content: content,title:title)
						}
					}
				})
				
			}
		}else{
			let title = chapter.chapter_name == nil ? "" : chapter.chapter_name!
			let content = title + "\n" + chapter.content!
			completionHandler(content: content,title:title)
		}
	}
	/**
	删除书籍
	
	- parameter book:              book对象
	- parameter completionHandler: 回调
	*/
	static func deleteBook(book:WRBook,completionHandler:(isSuccess:Bool)->Void){
		let sqlBook = WRFMDBManager.shareInstance().getDeleteSql(BOOK_ENTITY_NAME, predicates: [WRPredicate(key: "id", value: book.id, dataType: DataType.NSNumber)])
		let sqlChapter = WRFMDBManager.shareInstance().getDeleteSql(CHAPTER_ENTITY_NAME, predicates:
		[WRPredicate(key: "bookID", value: book.id, dataType: DataType.NSNumber)])
		WRFMDBManager.shareInstance().deleteDB_QueueTransactionMulti([sqlBook,sqlChapter]) { (successNumber, failureNumber, isFinish) -> Void in
			completionHandler(isSuccess: isFinish)
		}
	}
	/**
	删除章节
	
	- parameter bookID:            bookID
	- parameter completionHandler: 回调
	*/
	static func deleteChapter(bookID:NSNumber,completionHandler:(isSuccess:Bool)->Void){
		let sqlChapter = WRFMDBManager.shareInstance().getDeleteSql(CHAPTER_ENTITY_NAME, predicates:
			[WRPredicate(key: "bookID", value: bookID, dataType: DataType.NSNumber)])
		WRFMDBManager.shareInstance().deleteDB_QueueTransactionMulti([sqlChapter]) { (successNumber, failureNumber, isFinish) -> Void in
			completionHandler(isSuccess: isFinish)
		}
	}
	/**
	获取历史纪录,如果不存在创建一个
	
	- parameter bookID: bookID
	
	- returns: 历史记录对象
	*/
	static func getBookHistory(bookID:NSNumber)->WRHistory{
		let predicate = WRPredicate(key: "bookID", value: bookID, dataType: DataType.NSNumber)
		let wrHistory = WRHistory(bookID: bookID, lastChapterSort: 1, dateTime: NSDate())
		let sql = WRFMDBManager.shareInstance().getSelectSql(HISTORY_ENTITY_NAME, predicates: [predicate])
		let historyDic = WRFMDBManager.shareInstance().selectDB_Queue(sql)
		if historyDic.count <= 0{
			wrHistory.currentPage = 0
			wrHistory.dayOrNight = 1
			wrHistory.fontSize =  CONTENT_FONT_SIZE_DEFAULT
			wrHistory.lineSize = CONTENT_LINE_SIZE_DEFAULT
			WRFMDBManager.shareInstance().insertDB_Queue([wrHistory], completionHandler: { (successNumber, failureNumber, isFinish) -> Void in})
		}else{
			wrHistory.setValuesForKeysWithDictionary(historyDic[0])
		}
		return wrHistory
	}
	/**
	获取设置,如果不存在就创建一个
	
	- returns: 设置对象
	*/
	static func getSetting()->WRSetting{
		let sql = WRFMDBManager.shareInstance().getSelectSql(SETTING_ENTITY_NAME)
		let settingDic = WRFMDBManager.shareInstance().selectDB_Queue(sql)
		let wrSetting = WRSetting()
		if settingDic.count <= 0{
			wrSetting.fontSize = CONTENT_FONT_SIZE_DEFAULT
			wrSetting.dayOrNight = 1
			wrSetting.pageMode = "PageCurl"
			wrSetting.theme = "DEFAULT"
			WRFMDBManager.shareInstance().insertDB_Queue([wrSetting], completionHandler: { (successNumber, failureNumber, isFinish) -> Void in})
		}else{
			wrSetting.setValuesForKeysWithDictionary(settingDic[0])
		}
		return wrSetting
	}
}