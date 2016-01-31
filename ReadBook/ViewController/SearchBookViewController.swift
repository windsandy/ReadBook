//
//  SearchBookViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class SearchBookViewController: UIViewController {
	
	//表格加载数据数组
	var books = [[String:AnyObject]]()
	@IBOutlet weak var tableView: UITableView!{
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
		}
	}
	@IBOutlet weak var searchBar: UISearchBar!{
		didSet {
			searchBar.delegate = self
		}
	}
	//搜索关键词,当改变时进行搜索
	var searchKey:String?{
		didSet {
			searchBar.text = searchKey
			books.removeAll()
			guard searchKey != nil else {return }
			search(searchKey!)
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		//隐藏导航栏
		self.navigationController?.setNavigationBarHidden(true , animated: true)
		//定义滑动手势,用于右滑返回主界面
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
		self.view.addGestureRecognizer(panGestureRecognizer)
		//!!!初始化一个关键词,用于测试
		//searchKey = "" //完美世界
    }
	//返回
	func goBack(){
		self.navigationController?.popViewControllerAnimated(true)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	//导航到详情页时传递参数
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == SEARCH_TO_DETAIL_SEGUE_IDENTIFIER {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let book = books[indexPath.row]
				let vc = segue.destinationViewController as! BookDetailViewController
				vc.book = BookEasouAPI.getBookWithDic(book)
			}
		}
	}

}
//MARK:搜索
extension SearchBookViewController{
	func search(key:String){
		BookEasouAPI.searchBook(key) { (bookDics) -> Void in
			self.books = bookDics
			self.tableView.reloadData()
		}
	}
}
//MARK:搜索栏代理
extension SearchBookViewController:UISearchBarDelegate{
	//当点击搜索按钮时，进行搜索
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchKey = searchBar.text
		searchBar.resignFirstResponder()
	}
	//当将要对搜索关键词进行编辑的时候隐藏导航栏
	func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		return true
	}
	//当取消搜索的时候收起键盘并且显示导航栏
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
}
//MARK:滑动手势
extension SearchBookViewController:UIGestureRecognizerDelegate{
	//当右滑的时候返回主页面
	func handlePanGesture(recognizer:UIPanGestureRecognizer){
		let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
		switch recognizer.state{
		case .Began:
			if gestureIsDraggingFromLeftToRight{
				goBack()
			}
		case .Changed:
			break
		case .Ended:
			break
		default:
			break
		}
		if gestureIsDraggingFromLeftToRight{
			goBack()
		}
	}
}
//MARK:表格代理
extension SearchBookViewController:UITableViewDelegate{
	//表格行点击,进入详情页面
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.performSegueWithIdentifier(SEARCH_TO_DETAIL_SEGUE_IDENTIFIER, sender: self)
	}
}
//MARK:表格数据源
extension SearchBookViewController:UITableViewDataSource{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return books.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let book = books[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(BOOK_SEARCH_LIST_CELL_IDENTIFIER)
		cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BOOK_SEARCH_LIST_CELL_IDENTIFIER)
		cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		cell!.textLabel?.text = book["name"] as? String
		if let author = book["author"] as? String{
			cell!.detailTextLabel?.text = "作者:\(author)"
		}else{
			cell!.detailTextLabel?.text = "作者:"
		}
		return cell!
	}
}