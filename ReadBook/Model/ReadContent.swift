//
//  ReadContent.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/16.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation
import UIKit

struct ReadContent{
	/**
	字符串分页
	- parameter content:         要分页的字符串
	- parameter font:            字体
	- parameter lineSize:        行间距
	- parameter foreColor:       字颜色
	- parameter sizeOfContainer: 容器size
	- returns: 分页的AttributedString数组
	*/
	static func getPagesOfString(content:String,font:UIFont,lineSize:CGFloat,foreColor:UIColor,sizeOfContainer:CGSize)->[NSMutableAttributedString]{
		//获取单个字符的大小
		let (_,sampleSize) = getSizeFromString("旭", font: font, lineSize: lineSize, foreColor: foreColor, widthOfContainer: sizeOfContainer.width)
		//把文字按照回行符分割
		let paragraphs = content.componentsSeparatedByString("\n")
		//段落序号
		var p = 0
		//计算每页的高度
		var totalHeight:CGFloat = 0
		//每行所能容纳的字符个数
		let maxCharOfOneLine = Int(floor(sizeOfContainer.width / sampleSize.width))
		//段落的剩余字符
		var remainParaString = ""
		//返回的数组声明
		var pageStringArray = [NSMutableAttributedString]()
		//每页的字符
		var attributedString = NSMutableAttributedString()
		//按照段落循环
		while p < paragraphs.count{
			//如果有段落的剩余字符,那么使用,如果没有用新的段落
			let paragraph = remainParaString.isEmpty ? paragraphs[p] : remainParaString
			//段落的剩余字符使用后清空
			remainParaString = ""
			//获取字符的占位高度
			let (paragraphAttributed,paragraphSize) = getSizeFromString(paragraph, font: font, lineSize: lineSize, foreColor: foreColor, widthOfContainer: sizeOfContainer.width)
			//如果总的高度小于页面高度
			if totalHeight + paragraphSize.height < sizeOfContainer.height{
				//总高度累加
				totalHeight += paragraphSize.height
				//把字符加入每页的字符变量
				attributedString.appendAttributedString(paragraphAttributed)
				//补偿一个因为分割字符串损失的回行符
				attributedString.appendAttributedString(NSAttributedString(string: "\n"))
				//总高度需要加一个行间距
				totalHeight += lineSize
				//段落＋1
				p++
			}else{
				//如果总高度大于页面高度,说明这个页面放不下最后的这个段落
				//获取页面剩余的高度
				let remainHeight = sizeOfContainer.height - totalHeight
				//计算剩余的高度能容纳的行
				let remainLine = Int(floor(remainHeight / sampleSize.height))
				//剩余的空间能容纳的字符个数
				let remainCharNumber = remainLine * maxCharOfOneLine
				//在段落中获取能容纳的字符
				let remainString = (paragraph as NSString).substringToIndex(remainCharNumber)
				//获取AttributedString
				let (remainAttributed,remainSize) = getSizeFromString(remainString, font: font, lineSize: lineSize, foreColor: foreColor, widthOfContainer: sizeOfContainer.width)
				//把字符加入每页的字符变量
				attributedString.appendAttributedString(remainAttributed)
				//总高度累加
				totalHeight += remainSize.height
				//获取段落剩余字符
				remainParaString = (paragraph as NSString).substringFromIndex(remainCharNumber)
				//print("remainParaString=\(remainParaString)")
				//如果剩余字符为空,那说明段落用完,那么＋1
				if remainParaString.isEmpty{
					p++
				}
			}
			//如果剩余高度无法再容纳一行,或者没有新段落,那么完成一页
			if totalHeight + sampleSize.height >= sizeOfContainer.height || p >= paragraphs.count{
				pageStringArray.append(attributedString)
				attributedString = NSMutableAttributedString()
				totalHeight = 0
			}
		}
		//print("pageStringArray=\(pageStringArray.count)")
		return pageStringArray
		
	}
	/**
	获取字符串的AttributedString以及size
	- parameter content:   字符串
	- parameter font:      字体
	- parameter lineSize:  行间距
	- parameter foreColor: 字颜色
	- parameter width:     容器宽度
	- returns: 返回AttributedString以及size
	*/
	static func getSizeFromString(content:String,font:UIFont,lineSize:CGFloat,foreColor:UIColor,widthOfContainer:CGFloat)->(NSMutableAttributedString,CGSize){
		let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: content)
		let range = NSMakeRange(0, attributedString.length)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = lineSize
		attributedString.addAttributes([NSFontAttributeName:font], range: range)
		attributedString.addAttributes([NSParagraphStyleAttributeName:paragraphStyle], range: range)
		attributedString.addAttributes([NSForegroundColorAttributeName:foreColor], range: range)
		let rect = attributedString.boundingRectWithSize(CGSizeMake(widthOfContainer, MAX_HEIGHT), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
		let size = CGSize(width: rect.width, height: rect.height)
		return (attributedString,size)
	}
	static func getPagesOfString(cache:String,font:UIFont,r:CGRect) ->NSArray{
		//返回一个数组，包含每一页的字符串开始点喝长度(NSRange)
		let ranges = NSMutableArray()
		//显示字体的行高
		let tmp:NSString = "Sample样本"
		
		let fontCGSize = tmp.sizeWithAttributes([NSFontAttributeName:font])
		let maxLine = Int(floor(r.size.height/fontCGSize.height))
		var totalLines = 0
		var lastParaLeft = ""
		var range = NSMakeRange(0, 0)
		//按段落将字符串分开
		let paragraphs = cache.componentsSeparatedByString("\n")
		var p = 0
		while (p < paragraphs.count){
			var para:NSString = ""
			if !lastParaLeft.isEmpty{
				para = lastParaLeft
				lastParaLeft = ""
			}else{
				para = paragraphs[p]
				if p < paragraphs.count{
					para = para.stringByAppendingString("\n")
				}
				p++
			}
			let paraSize = getSize(font,size: r.size,para: para)
			let paraLines = Int(floor(paraSize.height/fontCGSize.height))
			if totalLines + paraLines < maxLine{
				totalLines += paraLines
				range.length += para.length
				if p == paragraphs.count {
					//到文章结尾
					ranges.addObject(NSValue(range: range))
				}else {
					if totalLines + paraLines == maxLine{
						//刚好一段结束，本页也结束
						ranges.addObject(NSValue(range: range))
						range.location += range.length
						range.length = 0
						totalLines = 0
					}
				}
			}else{
				//页结束本段文字还有剩余
				let lineLeft = maxLine - totalLines
				var tmpSize:CGSize
				var i:Int
				for i = 1 ; i < para.length ; ++i{
					//逐字判断是否达到了本页最大容量
					let tmp = para.substringToIndex(i)
					tmpSize = getSize(font, size: r.size, para: tmp)
					let nowLine = Int(floor(tmpSize.height/fontCGSize.height))
					if lineLeft < nowLine{
						//超出容量，跳出，字符要回退一个，因为当前字符已经超出范围
						lastParaLeft = para.substringFromIndex(i-1)
						break
					}
				}
				range.length += i-1
				ranges.addObject(NSValue(range: range))
				range.location += range.length
				range.length = 0
				totalLines = 0
			}
		}
		return NSArray(array: ranges)
		
	}
	static func getSize(font:UIFont,size:CGSize,para:NSString)->CGSize{
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .ByCharWrapping
		let att = [NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle]
		let paraSize = para.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: att, context: nil).size
		return paraSize
	}
	static func getContentCGRect()->CGRect{
		return getContentCGRect(10,top: 20,right: 10,bottom: 10)
	}
	static func getMessageCGRect()->CGRect{
		return getContentCGRect(WIDTH_MAIN - 140,top:2,right: 10,bottom: HEIGHT_MAIN - 10)
	}
	static func getShowChapterTitle()->CGRect{
		return getContentCGRect(10 ,top:2,right: 140,bottom: HEIGHT_MAIN - 10)
	}
	static func getContentCGRect(left:CGFloat,top:CGFloat,right:CGFloat,bottom:CGFloat)->CGRect{
		return CGRect(x: left, y: top, width: WIDTH_MAIN - left - right, height: HEIGHT_MAIN - top - bottom)
	}
	static func getContentFont()->UIFont{
		return UIFont.systemFontOfSize(CONTENT_FONT_SIZE_DEFAULT)
	}
	static func getContentFont(contentFontSize:CGFloat)->UIFont{
		return UIFont.systemFontOfSize(contentFontSize)
	}
}