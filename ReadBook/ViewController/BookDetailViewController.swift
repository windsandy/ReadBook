//
//  BookDetailViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {

	//简介
	@IBOutlet weak var aboutLabel: UILabel!
	//菊花圈
	@IBOutlet weak var waitingGrayActivity: UIActivityIndicatorView!
	//收藏按钮
	@IBOutlet weak var collectButton: UIButton!
	//其它信息
	@IBOutlet weak var otherLabel: UILabel!
	//作者
	@IBOutlet weak var authorLabel: UILabel!
	//书名
	@IBOutlet weak var bookNameLabel: UILabel!
	//封面图片
	@IBOutlet weak var coverImageView: UIImageView!
	//是否获取完封面
	var isHaveBookCover:Bool = false

	var book:WRBook?
    override func viewDidLoad() {
        super.viewDidLoad()
		//显示导航栏
		self.navigationController?.setNavigationBarHidden(false , animated: true)
		self.navigationItem.title = book?.title
		//设置信息
		setShowMessage()
		//开启菊花圈
		waitingGrayActivity.startAnimating()
		//如果有封面图片链接那么获取封面
		if let coverUrl = book?.cover{
			updateImage(coverUrl)
		}
    }

	@IBAction func btnCollectOnClick(sender: UIButton) {
		guard book != nil else {return}
		book!.pk = Guid.getGuid()
		WRFMDBManager.shareInstance().insertDB_QueueTransaction([book!]) { (successNumber, failureNumber, isFinish) -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.navigationController?.popViewControllerAnimated(true)
			})
		}
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
	//界面填充信息
	func setShowMessage(){
		guard book != nil else {return}
		bookNameLabel.text = book?.title
		aboutLabel.text = book?.longIntro
		authorLabel.text = book?.author
		var  showText = book?.cat  == nil ? "" : book!.cat! + "\n"
		showText += book?.lastChapter == nil ? "" : book!.lastChapter! + "\n"
		showText += book?.updateTime == nil ? "" : Common.getStringFromData(book!.updateTime!)
		otherLabel.text = showText
	}
}
//MARK:获取网络信息
extension BookDetailViewController{
	//获取封面图片
	func updateImage(imageUrl:String?){
		guard imageUrl != nil && !imageUrl!.isEmpty else {
			self.isHaveBookCover = true
			self.setState()
			return
		}
		BookEasouAPI.getBookCoverImage(imageUrl!) { (data) -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				if data != nil {
					self.book?.coverData = data
					self.coverImageView.image = UIImage(data: data!)
				}
				self.isHaveBookCover = true
				self.setState()
			})

		}
		
	}
	func setState(){
		if isHaveBookCover{
			collectButton.enabled = true
			waitingGrayActivity.stopAnimating()
		}
	}
}