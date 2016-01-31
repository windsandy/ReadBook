//
//  WRFMDBManager.swift
//  FMDBManager
//
//  Created by 张旭 on 16/1/22.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
class WRFMDBManager:NSObject{
	
	let dbBase:FMDatabase
	let queue:FMDatabaseQueue
	//MARK:单例化
	class func shareInstance() -> WRFMDBManager{
		struct wmSingle{
			static var onceToken:dispatch_once_t = 0
			static var instance:WRFMDBManager? = nil
		}
		dispatch_once(&wmSingle.onceToken) { () -> Void in
			wmSingle.instance = WRFMDBManager()
		}
		return wmSingle.instance!
	}
	override init() {
		let path = Common.getApplicationDocumentsDirectory().stringByAppendingPathComponent(DBBASE_NAME)
		//创建数据库
		dbBase =  FMDatabase(path: path)
		queue = FMDatabaseQueue(path: path)
	}
	//插入
	func insertDB(sqls:[String])->Bool{
		var isSuccess = true
		dbBase.open()
		dbBase.beginTransaction()
		for sql in sqls{
			if !dbBase.executeUpdate(sql, withArgumentsInArray: nil){
				dbBase.rollback()
				isSuccess = false
				break
			}
		}
		if isSuccess{
			dbBase.commit()
		}
		dbBase.close()
		return isSuccess
	}
	/**
	线程安全的插入(异步)
	
	- parameter wrBaseClasss:      对象数组
	- parameter completionHandler: 回调
	*/
	func insertDB_Queue(wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var successNumber:Int = 0
			var failureNumber:Int = 0
			var isFinish = false
			self.queue.inDatabase({ (db:FMDatabase!) -> Void in
				self.insertDB(db, wrBaseClasss: wrBaseClasss, completionHandler: { (sn,fn,s) -> Void in
					successNumber = sn
					failureNumber = fn
					isFinish = s
				})
			})
			completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
		}
	}
	/**
	线程安全的插入(事务)(异步)
	
	- parameter wrBaseClasss:      对象数组
	- parameter completionHandler: 回调
	*/
	func insertDB_QueueTransaction(wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var successNumber:Int = 0
			var failureNumber:Int = 0
			var isFinish = false
			self.queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
				self.insertDB(db, wrBaseClasss: wrBaseClasss, completionHandler: { (sn,fn,s) -> Void in
					successNumber = sn
					failureNumber = fn
					isFinish = s
				})
			}
			completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
		}
	}
	private func insertDB(db:FMDatabase!, wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		var successNumber:Int = 0
		var failureNumber:Int = 0
		var isFinish:Bool = false
		wrBaseClasss.forEach({ (wrBaseClass) -> () in
			if let sqlAndArr = self.getInsertSqlWithArgumentsInArray(DBBASE_PK_FIELD_NAME, willSaveClass: wrBaseClass){
				if db.executeUpdate(sqlAndArr.0, withArgumentsInArray: sqlAndArr.1){
					successNumber++
				}else{
					failureNumber++
				}
			}
		})
		isFinish = true
		completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
	}
	/**
	线程安全的更新(异步)
	
	- parameter wrBaseClasss:      对象数组
	- parameter completionHandler: 回调
	*/
	func updateDB_Queue(wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var successNumber:Int = 0
			var failureNumber:Int = 0
			var isFinish = false
			self.queue.inDatabase({ (db:FMDatabase!) -> Void in
				self.updateDB(db, wrBaseClasss: wrBaseClasss, completionHandler: { (sn , fn, s) -> Void in
					successNumber = sn
					failureNumber = fn
					isFinish = s
				})
			})
			completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
		}
	}
	/**
	线程安全的更新(事务)(异步)
	
	- parameter wrBaseClasss:      对象数组
	- parameter completionHandler: 回调
	*/
	func updateDB_QueueTransaction(wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var successNumber:Int = 0
			var failureNumber:Int = 0
			var isFinish = false

			self.queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
				self.updateDB(db, wrBaseClasss: wrBaseClasss, completionHandler: { (sn , fn, s) -> Void in
					successNumber = sn
					failureNumber = fn
					isFinish = s
				})
			}
			completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
		}
	}
	private func updateDB(db:FMDatabase!, wrBaseClasss:[WRBaseClass],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		var successNumber:Int = 0
		var failureNumber:Int = 0
		var isFinish:Bool = false
		wrBaseClasss.forEach({ (wrBaseClass) -> () in
			if let sqlAndArr = self.getUpdateSqlWithArgumentsInArrayOnlyPrimaryKey(DBBASE_PK_FIELD_NAME, willSaveClass: wrBaseClass){
				if db.executeUpdate(sqlAndArr.0, withArgumentsInArray: sqlAndArr.1){
					successNumber++
					//print("updateDB.successNumber=\(successNumber)")
				}else{
					failureNumber++
					//print("updateDB.failureNumber=\(failureNumber)")
				}
			}
		})
		isFinish = true
		completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
	}
	/**
	线程安全的删除(事务)(异步)
	
	- parameter sqls:              语句数组
	- parameter completionHandler: 回调
	*/
	func deleteDB_QueueTransactionMulti(sqls:[String],completionHandler:(successNumber:Int,failureNumber:Int,isFinish:Bool)->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var successNumber:Int = 0
			var failureNumber:Int = 0
			var isFinish:Bool = false
			self.queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
				sqls.forEach({ (sql) -> () in
					if db.executeUpdate(sql, withArgumentsInArray: nil){
						successNumber++
					}else{
						failureNumber++
					}
				})
				isFinish = true
			}
			completionHandler(successNumber: successNumber,failureNumber: failureNumber,isFinish: isFinish)
		}
	}	
	/**
	线程安全的查询
	
	- parameter sql: 语句
	
	- returns: 字典数组
	*/
	func selectDB_Queue(sql:String)->[[String:AnyObject]]{
		var results = [[String:AnyObject]]()
		queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
			if let rs = db.executeQuery(sql, withArgumentsInArray: nil){
				while rs.next(){
					let result = rs.resultDictionary() as! [String:AnyObject]
					results.append(result)
				}
			}
		}
		return results
	}
	/**
	线程安全的查询(事务)(异步)
	
	- parameter sql:               语句
	- parameter completionHandler: 回调
	*/
	func selectDB_QueueTransaction(sql:String,completionHandler:(results:[[String:AnyObject]])->Void){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			var results = [[String:AnyObject]]()
			self.queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
				if let rs = db.executeQuery(sql, withArgumentsInArray: nil){
					while rs.next(){
						let result = rs.resultDictionary() as! [String:AnyObject]
						results.append(result)
					}
				}
			}
			completionHandler(results: results)
		}
	}
	/**
	返回第一行第一个字段的内容
	
	- parameter sql: 语句
	
	- returns: 返回AnyObject
	*/
	func selectDB_Object(sql:String)->AnyObject?{
		var  obj:AnyObject?
		dbBase.open()
		if let rs = dbBase.executeQuery(sql, withArgumentsInArray: nil){
			while rs.next(){
				obj = rs.objectForColumnIndex(0)
				break
			}
		}
		dbBase.close()
		return obj
	}
	/**
	返回第一行第一个字段的内容(事务)
	
	- parameter sql: sql: 语句
	
	- returns: 返回AnyObject
	*/
	func selectDB_ObjectQueue(sql:String)->AnyObject?{
		var  obj:AnyObject?
		self.queue.inTransaction { (db:FMDatabase!, save:UnsafeMutablePointer<ObjCBool>) -> Void in
			if let rs = db.executeQuery(sql, withArgumentsInArray: nil){
				while rs.next(){
					obj = rs.objectForColumnIndex(0)
					break
				}
			}
		}
		return obj
	}
}
//MARK:语句拼接
extension WRFMDBManager{
	//根据类获取创建表的sql
	func getCreateSqlWithClass(willSaveClass:WRBaseClass,primaryKeyName:String)->String{
		let result = getAnyObjectClassConvertTuplesAndClassName_Map(willSaveClass)
		let className = result.1
		var values = ""
		let predicates = result.0 as [WRPredicate]
		predicates.forEach { (predicate) -> () in
			if predicate.key == primaryKeyName{
				let keyValue = "\(predicate.key) INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT"
				values += values.isEmpty ? "\(keyValue)" : ",\(keyValue)"
			}else{
				let sqlType = getValueWithSqlliteType(predicate.dataType)
				values += values.isEmpty ? "\(predicate.key)  \(sqlType)" : ",\(predicate.key)  \(sqlType)"
			}
		}
		if !values.isEmpty{
			let sql = "CREATE TABLE IF NOT EXISTS \(className) (\(values));"
			return sql
		}
		return ""
	}
	//获取查询语句
	func getSelectSql(tableName:String,predicates:[WRPredicate]? = nil,sortDescriptors:[WRSortDescriptor]? = nil,fields:[String]? = nil)->String{
		//获取显示字段
		var fieldList = ""
		if fields != nil{
			for field in fields!{
				fieldList += fieldList.isEmpty ? field : "," + field
			}
		}
		//如果没有字段那么，全部显示
		if fieldList.isEmpty{
			fieldList = "*"
		}
		//获取查询条件
		var conditions = ""
		if predicates != nil{
			for predicate in predicates!{
				if let value = predicate.value{
					if let valueString = getValueWithType(value, dataType: predicate.dataType){
						conditions += conditions.isEmpty ? " where \(predicate.key) = \(valueString)" : " and \(predicate.key) = \(valueString)"
					}
				}
			}
		}
		//获取排序
		var sorts = ""
		if sortDescriptors != nil{
			for sortDescriptor in sortDescriptors!{
				sorts += sorts.isEmpty ? " order by \(sortDescriptor.key) \(sortDescriptor.sort.rawValue)" : ", \(sortDescriptor.key) \(sortDescriptor.sort.rawValue)"
			}
		}
		let sql = "select \(fieldList) from  \(tableName) \(conditions) \(sorts)"
		return sql
	}
	//获取删除语句,如果没有条件那么会删除所有纪录
	func getDeleteSql(tableName:String,predicates:[WRPredicate]? = nil)->String{
		//获取查询条件
		var conditions = ""
		if predicates != nil{
			for predicate in predicates!{
				if let value = predicate.value{
					if let valueString = getValueWithType(value, dataType: predicate.dataType){
						conditions += conditions.isEmpty ? " where \(predicate.key) = \(valueString)" : " and \(predicate.key) = \(valueString)"
					}
				}
			}
		}
		let sql = "delete from \(tableName) \(conditions)"
		return sql
	}
	//获取插入语句(传入要保存的类)
	func getInsertSql(primaryKeyName:String,willSaveClass:WRBaseClass)->String{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		return getInsertSql(results.1, primaryKeyName: primaryKeyName, willInsertFields: results.0)
	}
	//获取插入语句
	func getInsertSql(tableName:String,primaryKeyName:String,willInsertFields:[WRPredicate])->String{
		var keys = ""
		var values = ""
		for willInsertField in willInsertFields{
			if willInsertField.key == primaryKeyName {continue}
			if let value = willInsertField.value{
				if let valueString = getValueWithType(value, dataType: willInsertField.dataType){
					keys += keys.isEmpty ? "\(willInsertField.key)" : ",\(willInsertField.key)"
					values += values.isEmpty ? "\(valueString)" : ",\(valueString)"
				}
			}
		}
		if !keys.isEmpty && !values.isEmpty{
			let sql = "insert into \(tableName) (\(keys)) values (\(values))"
			return sql
		}
		return ""
	}
	//获取插入语句(传入要保存的类)
	func getInsertSqlWithArgumentsInArray(primaryKeyName:String,willSaveClass:WRBaseClass)->(String,[AnyObject])?{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		return getInsertSqlWithArgumentsInArray(results.1, primaryKeyName: primaryKeyName, willInsertFields: results.0)
	}
	//获取插入语句
	func getInsertSqlWithArgumentsInArray(tableName:String,primaryKeyName:String,willInsertFields:[WRPredicate])->(String,[AnyObject])?{
		var keys = ""
		var values = ""
		var arr = [AnyObject]()
		for willInsertField in willInsertFields{
			if let value = willInsertField.value{
				if willInsertField.key == primaryKeyName {continue}
				keys += keys.isEmpty ? "\(willInsertField.key)" : ",\(willInsertField.key)"
				values += values.isEmpty ? "?" : ",?"
				arr.append(value)
			}
		}
		if !keys.isEmpty && !values.isEmpty{
			let sql = "insert into \(tableName) (\(keys)) values (\(values))"
			return (sql,arr)
		}
		return nil
	}
	//获取更新语句(用主键作为条件更新)(传入要保存的类)
	func getUpdateSqlOnlyPrimaryKey(primaryKeyName:String,willSaveClass:WRBaseClass)->String{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		if let  pk = getValueTuplesWithKey(primaryKeyName, predicates: results.0){
			if pk.value != nil {
				return getUpdateSql(results.1, willUpdateFields: results.0, primaryKeyName: primaryKeyName, predicates: [pk])
			}
		}
		return ""
	}
	//获取更新语句(用主键作为条件更新)
	func getUpdateSqlOnlyPrimaryKey(tableName:String,willUpdateFields:[WRPredicate],primaryKeyName:String)->String{
		if let  pk = getValueTuplesWithKey(primaryKeyName, predicates: willUpdateFields){
			if pk.value != nil {
				return getUpdateSql(tableName, willUpdateFields: willUpdateFields, primaryKeyName: primaryKeyName, predicates: [pk])
			}
		}
		return ""
	}
	//获取更新语句(传入要保存的类)
	func getUpdateSql(primaryKeyName:String,willSaveClass:WRBaseClass,predicates:[WRPredicate]? = nil)->String{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		return getUpdateSql(results.1, willUpdateFields: results.0, primaryKeyName: primaryKeyName, predicates: predicates)
	}
	//获取更新语句(更新条件可为空,但会更新表中所有纪录)
	func getUpdateSql(tableName:String,willUpdateFields:[WRPredicate],primaryKeyName:String,predicates:[WRPredicate]? = nil)->String{
		//获取查询条件
		var conditions = ""
		if predicates != nil{
			for predicate in predicates!{
				if let value = predicate.value{
					if let valueString = getValueWithType(value, dataType: predicate.dataType){
						conditions += conditions.isEmpty ? " where \(predicate.key) = \(valueString)" : " and \(predicate.key) = \(valueString)"
					}
				}
			}
		}
		//获取更新字段
		var values = ""
		for willUpdateField in willUpdateFields{
			if willUpdateField.key == primaryKeyName{continue}
			if let value = willUpdateField.value{
				if let valueString = getValueWithType(value, dataType: willUpdateField.dataType){
					values += values.isEmpty ? "\(willUpdateField.key) = \(valueString)" : ",\(willUpdateField.key) = \(valueString)"
				}
			}
		}
		if !values.isEmpty{
			let sql = "update \(tableName) set \(values)  \(conditions)"
			return sql
		}
		return ""
	}
	//获取更新语句返回元组或者nil(用主键作为条件更新)(传入要保存的类)
	func getUpdateSqlWithArgumentsInArrayOnlyPrimaryKey(primaryKeyName:String,willSaveClass:WRBaseClass,predicates:[WRPredicate]? = nil)->(String,[AnyObject])?{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		if let  pk = getValueTuplesWithKey(primaryKeyName, predicates: results.0){
			if pk.value != nil {
				return getUpdateSqlWithArgumentsInArray(results.1, willUpdateFields: results.0, primaryKeyName: primaryKeyName, predicates: [pk])
			}
		}
		return nil
		
	}
	//获取更新语句返回元组或者nil(用主键作为条件更新)
	func getUpdateSqlWithArgumentsInArrayOnlyPrimaryKey(tableName:String,willUpdateFields:[WRPredicate],primaryKeyName:String)->(String,[AnyObject])?{
		if let  pk = getValueTuplesWithKey(primaryKeyName, predicates: willUpdateFields){
			if pk.value != nil {
				return getUpdateSqlWithArgumentsInArray(tableName, willUpdateFields: willUpdateFields, primaryKeyName: primaryKeyName, predicates: [pk])
			}
		}
		return nil
	}
	//获取更新语句返回元组或者nil(传入要保存的类)
	func getUpdateSqlWithArgumentsInArray(primaryKeyName:String,willSaveClass:WRBaseClass,predicates:[WRPredicate]? = nil)->(String,[AnyObject])?{
		let results = self.getAnyObjectClassConvertTuplesAndClassName_flatMap(willSaveClass)
		return getUpdateSqlWithArgumentsInArray(results.1, willUpdateFields: results.0, primaryKeyName: primaryKeyName, predicates: predicates)
	}
	//获取更新语句返回元组或者nil(更新条件可为空,但会更新表中所有纪录)
	func getUpdateSqlWithArgumentsInArray(tableName:String,willUpdateFields:[WRPredicate],primaryKeyName:String,predicates:[WRPredicate]? = nil)->(String,[AnyObject])?{
		//获取查询条件
		var conditions = ""
		if predicates != nil{
			for predicate in predicates!{
				if let value = predicate.value{
					if let valueString = getValueWithType(value, dataType: predicate.dataType){
						conditions += conditions.isEmpty ? " where \(predicate.key) = \(valueString)" : " and \(predicate.key) = \(valueString)"
					}
				}
			}
		}
		//获取更新字段
		var values = ""
		var arr = [AnyObject]()
		for willUpdateField in willUpdateFields{
			if willUpdateField.key == primaryKeyName{continue}
			if let value = willUpdateField.value{
				values += values.isEmpty ? "\(willUpdateField.key) = ?" : ",\(willUpdateField.key) = ?"
				arr.append(value)
			}
		}
		if !values.isEmpty{
			let sql = "update \(tableName) set \(values) \(conditions)"
			return (sql,arr)
		}
		return nil
	}
}
//MARK:辅助方法
extension WRFMDBManager{
	//根据值类型返回拼写SQL语句中的值
	func getValueWithType(anyObject:AnyObject,dataType:DataType)->String?{
		switch dataType{
		case .NSNumber:
			let value = "\(anyObject)"
			return "\(value)"
		case .NSDate:
			return "'\(Common.getStringFromData(anyObject as! NSDate))'"
		case .String:
			let value = "\(anyObject)"
			return "'\(value)'"
		default:
			return nil
		}
	}
	//根据值类型返回拼写SQL语句中的值
	func getValueWithSqlliteType(dataType:DataType)->String{
		switch dataType{
		case .NSNumber:
			return "INTEGER"
		case .NSDate:
			return "TIMESTAMP"
		case .String:
			return "VARCHAR"
		case .NSData:
			return "BLOB"
		}
	}
	//查找key值，返回第一个
	func getValueTuplesWithKey(key:String,predicates:[WRPredicate])->WRPredicate?{
		let value =  predicates.filter { (predicate) -> Bool in
			if predicate.key == key{
				return true
			}
			return false
		}
		return value.first
	}
}
//MARK:反射方法
extension WRFMDBManager{
	//根据类反射获取属性名、值、类型 的元组(不包括值为nil)
	func getAnyObjectClassConvertTuples_flatMap(any:AnyObject)->[WRPredicate]{
		let m = Mirror(reflecting: any)
		let p = m.children.flatMap({ (label: String?, value: Any) -> WRPredicate? in
			if let l = label {
				let type: Mirror = Mirror(reflecting:value)
				if let v = unWrap(value) as? AnyObject{
					let t = getDataTypeWithString("\(type.subjectType)".trimOptional())
					return WRPredicate(key: l, value: v, dataType: t)
				}
			}
			return nil
		})
		return p
	}
	//根据类反射获取属性名、值、类型 的元组以及类的名称(不包括值为nil)
	func getAnyObjectClassConvertTuplesAndClassName_flatMap(any:AnyObject)->([WRPredicate],String){
		let m = Mirror(reflecting: any)
		let p = getAnyObjectClassConvertTuples_flatMap(any)
		return (p,"\(m.subjectType)".trimOptional())
	}
	//根据类反射获取属性名、值、类型 的元组(包括值为nil)
	func getAnyObjectClassConvertTuples_Map(any:AnyObject)->[WRPredicate]{
		let m = Mirror(reflecting: any)
		let p = m.children.flatMap({ (label: String?, value: Any) -> WRPredicate? in
			if let l = label {
				let type: Mirror = Mirror(reflecting:value)
				let v = unWrap(value) as? AnyObject
				let t = getDataTypeWithString("\(type.subjectType)".trimOptional())
				return WRPredicate(key: l, value: v, dataType: t)
			}
			return nil
		})
		return p
	}
	//根据类反射获取属性名、值、类型 的元组以及类的名称(包括值为nil)
	func getAnyObjectClassConvertTuplesAndClassName_Map(any:AnyObject)->([WRPredicate],String){
		let m = Mirror(reflecting: any)
		let p = getAnyObjectClassConvertTuples_Map(any)
		return (p,"\(m.subjectType)".trimOptional())
	}
	//将可选类型（Optional）拆包
	func unWrap(any:Any) -> Any {
		let mi = Mirror(reflecting: any)
		if mi.displayStyle != .Optional {
			return any
		}
		if mi.children.count == 0 { return any }
		let (_, some) = mi.children.first!
		return some
	}
	//根据字符串的数据类型返回枚举的数据类型
	func getDataTypeWithString(dataType:String)->DataType{
		switch dataType{
		case "NSNumber":
			return .NSNumber
		case "NSDate":
			return .NSDate
		case "String":
			return .String
		case "NSData":
			return .NSData
		default:
			return .String
		}
	}
	
}
extension String{
	//替换字符串中有Optional()的
	func trimOptional() -> String {
		guard self.rangeOfString("Optional(")?.count == nil else {
			return self.stringByReplacingOccurrencesOfString("Optional(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
		}
		guard self.rangeOfString("Optional<")?.count == nil else {
			return self.stringByReplacingOccurrencesOfString("Optional<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")
		}
		return self
	}
}

