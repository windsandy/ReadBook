//
//  Response.swift
//  FMDBManager
//
//  Created by 张旭 on 16/1/23.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import Alamofire

struct Response{
	/**
	获取网络html数据(回调方式)
	GET方式
	- parameter url:               网络链接
	- parameter parameters:        参数
	- parameter headers:           http头
	- parameter completionHandler: 回调函数
	*/
	static func getHtml(url:String,parameters:[String: AnyObject]? = nil,headers: [String: String]? = nil,completionHandler:(NSString?)->Void){
		getJson(url, parameters: parameters, headers: headers) { (data, error) -> Void in
			if let htmlData = data{
				let string = NSString(data: htmlData, encoding: NSUTF8StringEncoding)
				completionHandler(string)
			}else{
				completionHandler("")
			}
		}
	}
	/**
	获取网络json数据(回调方式)
	GET方式
	- parameter url:               网络链接
	- parameter parameters:        参数
	- parameter headers:           http头
	- parameter completionHandler: 回调函数
	*/
	static func getJson(url:String,parameters:[String: AnyObject]? = nil,headers: [String: String]? = nil,completionHandler:(NSData?,NSError?)->Void){
		getJson(Alamofire.Method.GET, url: url, parameters: parameters, headers: headers) { (data, error) -> Void in
			completionHandler(data, error)
		}
	}
	/**
	获取网络json数据
	GET方式
	- parameter url:               网络链接
	- parameter parameters:        参数
	- parameter headers:           http头
	- returns: 返回Request
	*/
	static func getJson(url:String,parameters:[String: AnyObject]? = nil,headers: [String: String]? = nil)->Request?{
		return getJson(.GET, url: url, parameters: parameters, headers: headers)
	}
	private static func getJson(method: Alamofire.Method,url:String,parameters:[String: AnyObject]? = nil,encoding:ParameterEncoding = .URL,headers: [String: String]? = nil)->Request?{
		return Alamofire.request(method, url, parameters: parameters, encoding: encoding, headers: headers)
			.validate(statusCode: 200..<300)
			.responseJSON { response in}
	}
	private static func getJson(method: Alamofire.Method,url:String,parameters:[String: AnyObject]? = nil,encoding:ParameterEncoding = .URL,headers: [String: String]? = nil,completionHandler:(NSData?,NSError?)->Void){
		Alamofire.request(method, url, parameters: parameters, encoding: encoding, headers: headers)
			.validate(statusCode: 200..<300)
			.responseJSON { response in
				completionHandler(response.data,response.result.error)}
	}
}
//MARK:获取url中的参数
extension Response{
	/**
	获取url中的参数
	- parameter url: 连接
	- returns: 返回字典
	*/
	static func getUrlParameter(url:String?)-> [String:String]?{
		guard url != nil else {return nil}
		var parameterDic = [String:String]()
		let urls = url!.characters.split("?")
		guard urls.count > 1 else {return nil}
		let parameters = urls[1].split("&")
		for parameter in parameters{
			guard parameter.first != "=" else {continue}
			let par = parameter.split("=")
			let name = par[0].map {switchChar($0)}.joinWithSeparator("")
			let value  = (par.count > 1) ? par[1].map {switchChar($0)}.joinWithSeparator("") : ""
			guard !name.isEmpty else {continue}
			parameterDic[name] = value
		}
		return parameterDic
	}
	private static func switchChar(char:Character)-> String{
		var str = ""
		str.append(char)
		return str
	}
}