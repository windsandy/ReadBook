//
//  CenterViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

//MARK:CenterViewController Delegate
protocol CenterViewControllerDelegate:class{
	func toggleLeftPanel()
	func toggleRightPanel()
	func collapseSidePanels()
	func centerSidePanels()
}
//MARK:CenterViewController
class CenterViewController: UIViewController {
	//给表格加载的数据数组
	var wrBooks = [WRBook]()
	//刷新用的菊花圈
	var refreshControl = UIRefreshControl()
	//表格控件，当初始化时绑定代理
	@IBOutlet weak var tableView: UITableView!{
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
			let nib = UINib(nibName: BOOK_LIST_CELL_NIB_NAME, bundle: nil)
			self.tableView.registerNib(nib, forCellReuseIdentifier: BOOK_LIST_CELL_IDENTIFIER)
		}
	}
	//代理
	weak var delegate:CenterViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
		initRefreshControl()
		navigationItem.title = APP_NAME
		//!!!打印数据库路径，调试用
		//print(Common.getApplicationDocumentsDirectory().stringByAppendingPathComponent(DBBASE_NAME))
    }
	//当视图显示的时候刷新数据,并且使根视图的点击手势可用
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		UIStoryboard.rootViewController()?.havHandlePanGesture = true
		//取消隐藏导航栏
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		loadBooksData()
	}
	//当视图背遮挡的时候使根视图的点击手势不可用，防止影响其它视图的手势
	override func viewDidDisappear(animated: Bool) {
		super.viewDidAppear(animated)
		UIStoryboard.rootViewController()?.havHandlePanGesture = false
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	//删除书籍按钮事件
	@IBAction func btnDeleteBookOnClick(sender: UIBarButtonItem) {
		if tableView.editing{
			tableView.setEditing(false, animated: true)
		}else{
			tableView.setEditing(true, animated: true)
		}
	}
	//添加书籍按钮事件
	@IBAction func btnAddBookOnClick(sender: UIBarButtonItem) {
		delegate?.toggleRightPanel()
	}
	//导航到章节页，传递参数
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == CENTER_TO_READ_SEGUE_IDENTIFIER{
			if let indexPath = self.tableView.indexPathForSelectedRow{
				let book = wrBooks[indexPath.row]
				let vc = segue.destinationViewController as! ReadBookViewController
				let currentRB = CurrentReadBook(currentbook: book)
				vc.currentReadBook = currentRB
			}
		}
	}
	//初始化菊花圈控件
	func initRefreshControl(){
		refreshControl.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
		refreshControl.attributedTitle = NSAttributedString(string: "刷新")
		tableView.addSubview(refreshControl)
	}

}
//MARK:数据处理
extension CenterViewController{
	//加载书籍
	func loadBooksData(){
		wrBooks = BookEasouReload.getBookList()
		tableView.reloadData()
	}
	//删除数据
	func deleteBooksData(book:WRBook){
		BookEasouReload.deleteBook(book) { (isSuccess) -> Void in
			if isSuccess {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.loadBooksData()
				})
			}
		}
	}
	func refreshData(){
		print("刷新数据")
		BookEasouReload.uninRefreshBook()
		self.refreshControl.endRefreshing()
	}
}
//MARK:表格代理
extension CenterViewController:UITableViewDelegate{
	//行选择事件
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.performSegueWithIdentifier(CENTER_TO_READ_SEGUE_IDENTIFIER, sender: self)
	}
	//行高
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return BOOK_LIST_CELL_HEIGHT
	}
}
//MARK:表格数据源
extension CenterViewController:UITableViewDataSource{
	//表格段数量
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	//表格行数量
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return wrBooks.count
	}
	//设置可以删除
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	//加载行数据
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(BOOK_LIST_CELL_IDENTIFIER, forIndexPath: indexPath) as! BookListTableViewCell
		configureCell(cell, indexPath: indexPath)
		return cell
	}
	func configureCell(cell:BookListTableViewCell,indexPath:NSIndexPath){
		let book = wrBooks[indexPath.row]
		cell.bookName = book.title
		cell.bookLastChapter = book.lastChapter
		cell.updateTime = book.updateTime == nil ? "" : Common.getStringFromData(book.updateTime!)
		if book.coverData == nil {
			cell.bookCoverImage = UIImage(named: "default_book_cover")
		}else{
			cell.bookCoverImage = UIImage(data:book.coverData!)
		}
	}
	//编辑事件
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete{
			let book = wrBooks[indexPath.row]
			if let _ = book.id?.integerValue{
				deleteBooksData(book)
			}
		}
	}
}
//MARK:实现右菜单代理
extension CenterViewController:RightPanelViewControllerDelegate{
	func actionRightSelected(action: ActionOption) {
		delegate?.centerSidePanels()
		UIStoryboard.rootViewController()?.havHandlePanGesture = false
		self.performSegueWithIdentifier(CENTER_TO_SEARCH_SEGUE_IDENTIFIER, sender: self)
	}
}
//MARK:实现左菜单代理
extension CenterViewController:LeftPanelViewControllerDelegate{
	func actionLeftSelected(action: ActionOption) {
		
	}
}