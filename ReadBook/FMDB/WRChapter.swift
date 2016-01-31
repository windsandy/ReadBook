//
//  WRChapter.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/19.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation

class WRChapter:WRBaseClass{
	
	 var id:NSNumber?
	 var chapter_name: String?
	 var content: String?
	 var ctype: String?
	 var curl: String?
	 var gid: String?
	 var nid: String?
	 var service: String?
	 var sort: NSNumber?
	 var success: NSNumber?
	 var url: String?
	 var pk: String?
	 var bookID: NSNumber?
	 var updateTime: NSDate?
	 init(pk:String,bookID:NSNumber,gid:String,nid:String){
		self.pk = pk
		self.bookID = bookID
		self.gid = gid
		self.nid = nid
	}
}