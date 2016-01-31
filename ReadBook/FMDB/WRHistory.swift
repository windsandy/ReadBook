//
//  WRHistory.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/19.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation

class WRHistory:WRBaseClass{
	 var id:NSNumber?
	 var bookID: NSNumber!
	 var lastChapterSort: NSNumber!
	 var dateTime: NSDate!
	 var currentPage: NSNumber?
	 var dayOrNight: NSNumber?
	 var fontSize: NSNumber?
	 var lineSize: NSNumber?
	 init(bookID:NSNumber,lastChapterSort:NSNumber,dateTime:NSDate) {
		self.bookID = bookID
		self.lastChapterSort = lastChapterSort
		self.dateTime = dateTime
	}
}