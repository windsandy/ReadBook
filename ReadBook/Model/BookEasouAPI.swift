//
//  BookEasouAPI.swift
//  FMDBManager
//
//  Created by 张旭 on 16/1/23.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import SwiftyJSON
//MARK: 根据链接获取内容
struct BookEasouAPI{
	/**
	查询接口
	
	- parameter key:               查询关键词
	- parameter completionHandler: 回调函数
	*/
	static func searchBook(key:String,completionHandler:(bookDics:[[String:AnyObject]])->Void){
		var books = [[String:AnyObject]]()
		guard !key.isEmpty else {return}
		Response.getJson(BookServiceEasouAPI.searchUrl, parameters: BookServiceEasouAPI.getSearchParameters(key)) { (data, error) -> Void in
			guard data != nil else {return}
			let json = JSON(data:data!)
			let array = json["all_book_items"]
			array.array?.forEach({ (book) -> () in
				if let book = book.dictionaryObject{
					books.append(book)
				}
			})
			completionHandler(bookDics: books)
		}
	}
	
	/**
	根据double值返回日期对象
	
	- parameter timeInterval: timeInterval
	
	- returns: 返回日期对象
	*/
	private static func getBookDateTime(timeInterval:Double?)->NSDate{
		guard timeInterval != nil else {return NSDate()}
		let date = NSDate(timeIntervalSince1970: timeInterval! / 1000)
		return date
	}
	/**
	根据链接返回章节详细信息(回调方式)
	
	- parameter gid:               gid
	- parameter completionHandler: 回调
	*/
	static func getBookDetail(gid:String,completionHandler:(bookDic:[String:AnyObject])->Void){
		guard !gid.isEmpty else {return}
		Response.getJson(BookServiceEasouAPI.detailUrl, parameters: BookServiceEasouAPI.getDetailParameters(gid)) { (data, error) -> Void in
			guard data != nil else {return}
			let json = JSON(data: data!)
			if let bookDetail = json.dictionaryObject{
				completionHandler(bookDic: bookDetail)
			}
		}
	}
	
	/**
	根据链接获取封面图片
	
	- parameter imageCoverUrl:     图片链接地址
	- parameter completionHandler: 回调
	*/
	static func getBookCoverImage(imageCoverUrl:String,completionHandler:(imageData:NSData?)->Void){
		Response.getJson(imageCoverUrl) { (data, error) -> Void in
//			if error == nil {
//				completionHandler(imageData: data)
//			}else{
//				completionHandler(imageData: nil)
//			}
			completionHandler(imageData: data)
		}
	}
	/**
	根据链接获取章节列表页面返回字典数组(回调方式)
	
	- parameter nid:               nid
	- parameter gid:               gid
	- parameter currentMaxSort:    现有最大章节序号
	- parameter completionHandler: 回调
	*/
	static func getBookChapter(nid:String,gid:String,currentMaxSort:Int = 0,completionHandler:(chaptersDic:[[String:AnyObject]])->Void){
		Response.getJson(BookServiceEasouAPI.directoryUrl, parameters: BookServiceEasouAPI.getDirectoryParameters(gid, nid: nid)) { (data, error) -> Void in
			guard data != nil else {return}
			let json = JSON(data:data!)			
			guard json != nil else {return}
			let success = json["success"].bool
			guard  success != nil && success! else {return}
			let serviceMaxSort = json["totalCount"].intValue
			if serviceMaxSort > currentMaxSort{
				let newChapters = json["items"].array
				if let addChapter = newChapters?.filter({ (chapter) -> Bool in
					let c = chapter["sort"].intValue
					if c > currentMaxSort{
						return true
					}else {
						return false
					}
				}){
					let chapters = addChapter.flatMap({ (JSON) -> [String:AnyObject]? in
						return JSON.dictionaryObject
					})
					completionHandler(chaptersDic: chapters)
				}
			}
		}
		
	}
	
	/**
	根据链接获取章节正文(回调方式)
	
	- parameter url:               章节正文链接
	- parameter parameters:        参数列表
	- parameter completionHandler: 回调
	*/
	static func getBookChapterContent(url:String?,parameters:[String:String],completionHandler:(bookContentDic:[String:AnyObject])->Void){
		guard url != nil else {return}
		Response.getJson(url!, parameters: parameters) { (data, error) -> Void in
			guard data != nil else {return}
			let json = JSON(data: data!)
			guard json != nil else {return}
			let success = json["success"].bool
			guard success != nil  else {return}
			guard success!   else {return}
			completionHandler(bookContentDic: json.dictionaryObject!)
		}
	}
	
}
// MARK: - 字典填充对象
extension BookEasouAPI{
	/**
	根据字典返回WRBook对象
	
	- parameter bookDic: book字典
	
	- returns: 返回WRBook对象
	*/
	static func getBookWithDic(bookDic:[String:AnyObject])->WRBook{
		let book = WRBook(pk: "", title: "", gid: "", nid: "")
		if let id = bookDic["id"]?.intValue{
			book.id = NSNumber(int: id)
		}
		if let nid = bookDic["nid"]?.intValue{
			book.nid = "\(nid)"
			
		}else {
			book.nid = "0"
		}
		if let gid  = bookDic["gid"]?.intValue{
			book.gid = "\(gid)"
		}else {
			book.gid = "0"
		}
		book.title = bookDic["name"] as? String
		book.author = bookDic["author"] as? String
		book.longIntro = bookDic["desc"] as? String
		book.cat = bookDic["category"] as? String
		book.cover = bookDic["imgUrl"] as? String
		book.chaptersCount = bookDic["chapterCount"] as? Int
		book.wordCount = 0
		book.lastChapter = bookDic["lastChapterName"] as? String
		book.status = bookDic["status"] as? String
		book.updateTime = getBookDateTime(bookDic["lastTime"] as? Double)
		return book
	}
	/**
	根据字典填充书籍对象
	
	- parameter bookDic: 书籍字典
	- parameter book:    书籍对象
	
	- returns: 返回的书籍对象
	*/
	static func getBookDetail(bookDic:[String:AnyObject],book:WRBook)->WRBook{
		book.author = bookDic["author"] as? String
		book.cat = bookDic["category"] as? String
		book.chaptersCount = bookDic["last_sort"] as? Int
		book.cover = bookDic["img_url"] as? String
		book.lastChapter = bookDic["last_chapter_name"] as? String
		book.longIntro = bookDic["desc"] as? String
		book.title = bookDic["name"] as? String
		book.wordCount = bookDic["wordCount"] as? Int
		book.insertTime = NSDate()
		book.updateTime = getBookDateTime(bookDic["last_time"] as? Double)
		return book
	}
	/**
	根据字典更新章节对象内容
	
	- parameter chapterDic: 章节字典
	- parameter gid:        gid
	- parameter chapter:    章节对象
	
	- returns: 返回章节对象
	*/
	static func getBookChapter(chapterDic:[String:AnyObject],gid:String,chapter:WRChapter)->WRChapter{
		if let sort = chapterDic["sort"] as? String{
			chapter.pk = gid.stringByAppendingString(sort)
		}else{
			chapter.pk = gid
		}
		if let nid = chapterDic["nid"]?.intValue{
			chapter.nid = "\(nid)"
		}
		chapter.gid = gid
		chapter.service = "easou"
		chapter.chapter_name = chapterDic["chapter_name"] as? String
		chapter.ctype = chapterDic["ctype"] as? String
		chapter.curl = chapterDic["curl"] as? String
		chapter.sort = chapterDic["sort"] as? NSNumber
		chapter.url = BookServiceEasouAPI.chapterUrl
		chapter.content = ""
		chapter.success = 0
		chapter.updateTime = getBookDateTime(chapterDic["time"] as? Double)
		return chapter
	}
	/**
	根据字典更新章节正文
	
	- parameter chapterContentDic: 章节正文字典
	- parameter chapter:           章节对象
	
	- returns: 返回章节对象
	*/
	static func getBookChapterContent(chapterContentDic:[String:AnyObject],chapter:WRChapter)->WRChapter{
		if let content = chapterContentDic["content"] as? String{
			if !content.isEmpty{
				chapter.content = content
				chapter.success = 1
			}
		}
		return chapter
	}
}
