//
//  ContentViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
	//显示标题
	var titleLabel:UILabel!
	//信息显示
	var messageLabel:UILabel!
	//文本载体
	var contentLabel: UILabel!
	//当前页号
	var contentIndex:Int?
	//本章总页数
	var contentCountPage:Int?
	var titleOfChapter:String?
	//显示的文本
	var dataAttributedString: NSMutableAttributedString?{
		didSet {
			guard contentLabel != nil else {return}
			contentLabel.attributedText = dataAttributedString
		}
	}
	//显示模式
	var contentShowMode:ContentShowMode = ContentShowMode.LightMode{
		didSet{
			guard contentLabel != nil else {return}
			setShowMode(self.contentShowMode)
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		contentLabel = UILabel(frame: ReadContent.getContentCGRect())
		contentLabel.numberOfLines = 0
		contentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
		self.view.addSubview(contentLabel)
		
		messageLabel = UILabel(frame: ReadContent.getMessageCGRect())
		messageLabel.numberOfLines = 1
		messageLabel.font = ReadContent.getContentFont(10)
		messageLabel.textAlignment = NSTextAlignment.Right
		self.view.addSubview(messageLabel)
		
		titleLabel = UILabel(frame: ReadContent.getShowChapterTitle())
		titleLabel.numberOfLines = 1
		titleLabel.font = ReadContent.getContentFont(10)
		titleLabel.textAlignment = NSTextAlignment.Left
		titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
		self.view.addSubview(titleLabel)
		
		contentLabel.attributedText = dataAttributedString
		if let index = contentIndex,countPage = contentCountPage{
			messageLabel.text = "第\(index + 1)页/共\(countPage)页 时间:" + Common.getStringFromData(format: DateToStringFormat.HourAndMinuteAndSecond)
		}
		if let title = titleOfChapter {
			titleLabel.text = title
		}
		setShowMode(contentShowMode)
		//contentLabel.textColor = contentColor
		//self.view.backgroundColor = contentBackColor
		contentLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
//MARK:设置前背景色
extension ContentViewController{
	//根据模式设置前背景色
	func setShowMode(contentShowMode:ContentShowMode){
		switch contentShowMode{
		case .LightMode:
			contentLabel.textColor = FORE_LIGHT_COLOR
			messageLabel.textColor = FORE_LIGHT_COLOR
			titleLabel.textColor = FORE_LIGHT_COLOR
			self.view.backgroundColor = BACK_LIGHT_COLOR
		case .DarkMode:
			contentLabel.textColor = FORE_DARK_COLOR
			messageLabel.textColor = FORE_DARK_COLOR
			titleLabel.textColor = FORE_DARK_COLOR
			self.view.backgroundColor = BACK_DARK_COLOR
		}
	}
}