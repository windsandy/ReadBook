//
//  ChapterListTableViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/27.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

typealias choiceChapterBlock = (Int)->Void
class ChapterListTableViewController: UITableViewController {

	var choiceChapter:choiceChapterBlock?
	var book:WRBook?
	var chapterNumber:NSNumber?
	var selectLine:NSIndexPath?
	var chapter = [WRChapter]()
    override func viewDidLoad() {
        super.viewDidLoad()
		let nib = UINib(nibName: CHAPTER_LIST_CELL_NIB_NAME, bundle: nil)
		self.tableView.registerNib(nib, forCellReuseIdentifier: CHAPTER_LIST_CELL_IDENTIFIER)
		navigationController?.setNavigationBarHidden(false , animated: true)
		navigationController?.setToolbarHidden(true, animated: true)
		initTableData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
//MARK:表格数据源
extension ChapterListTableViewController{
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chapter.count
	}
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let chapterCurrent = chapter[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(CHAPTER_LIST_CELL_IDENTIFIER, forIndexPath: indexPath) as! ChapterListTableViewCell
		if let success = chapterCurrent.success{
			
			let image = success.integerValue == 1 ? UIImage(named: "directory_previewed") : UIImage(named: "directory_not_previewed")
			cell.statShowImage = image
		}
		cell.chapterName = chapterCurrent.chapter_name
		if chapterCurrent.sort == chapterNumber{
			selectLine = indexPath
			tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
			tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
		}
		return cell
	}
}
//MARK:表格代理
extension ChapterListTableViewController{
	//点击事件
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let chapterCurrent = chapter[indexPath.row]
		if let sort = chapterCurrent.sort?.integerValue{
			if self.choiceChapter != nil{
				self.choiceChapter!(sort)
			}
		}
		self.navigationController?.popViewControllerAnimated(true)
	}
}
//MAEK:加载数据
extension ChapterListTableViewController{
	func initTableData(){
		guard book != nil else {return}
		if let bookID = book?.id{
			let predicate = WRPredicate(key: "bookID", value: bookID, dataType: DataType.NSNumber)
			let sort = WRSortDescriptor(key: "sort", sort: WRSort.Asc)
			BookEasouReload.getBookChapter(bookID, predicates: [predicate], sorts: [sort], completionHandler: { (wrChapters) -> Void in
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.chapter = wrChapters
					self.tableView.reloadData()
				})
			})
		}
	}
}
