//
//  WRFMDBManagerHelper.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation

enum DataType{
	case NSNumber
	case String
	case NSData
	case NSDate
}
enum OperationType{
	case Insert
	case Update
	case Delete
	case Select
}

enum WRSort:String{
	case Asc = "asc"
	case Desc = "desc"
}
struct WRPredicate {
	let key:String!
	let value:AnyObject?
	let dataType:DataType!
	init(key:String,value:AnyObject?,dataType:DataType){
		self.key = key
		self.value = value
		self.dataType = dataType
	}
}
struct WRSortDescriptor{
	let key:String!
	let sort:WRSort!
	init(key:String,sort:WRSort){
		self.key = key
		self.sort = sort
	}
}