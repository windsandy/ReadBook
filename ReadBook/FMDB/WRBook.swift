//
//  WRBook.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/19.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation

class WRBook:WRBaseClass{
	 var id:NSNumber?
	 var author: String?
	 var cat: String?
	 var chaptersCount: NSNumber?
	 var cover: String?
	 var coverData: NSData?
	 var insertTime: NSDate?
	 var isSerial: NSNumber?
	 var lastChapter: String?
	 var longIntro: String?
	 var majorCate: String?
	 var minorCate: String?
	 var tags: String?
	 var title: String!
	 var updateTime: NSDate?
	 var wordCount: NSNumber?
	 var pk: String!
	 var gid: String!
	 var nid: String!
	 var status: String?
	 init(pk:String,title:String,gid:String,nid:String) {
		self.pk = pk
		self.title = title
		self.gid = gid
		self.nid = nid
	}
}