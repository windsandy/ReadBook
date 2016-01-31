//
//  ReadBookViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class ReadBookViewController: UIViewController {
	//当前章节设置
	var currentReadBook:CurrentReadBook!
	//设置对象
	var setting:WRSetting?
	//历史纪录对象
	var history:WRHistory?
	//翻页控件
	var pageController:UIPageViewController!
	//显示或隐藏导航栏和工具栏
	var isHidden = true{
		didSet {
			navigationController?.setNavigationBarHidden(isHidden, animated: true)
			//navigationController?.setToolbarHidden(isHidden, animated: true)
			UIStoryboard.rootViewController()?.setThisStatusBarHidden(isHidden)
		}
	}
	//点击手势承载视图，用于显示隐藏导航栏和工具栏
	var gestureView:UIView!
	//是否正在翻页
	var isPageUp:Bool = false
	//翻页方向
	var isPrePageUp = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		isHidden = true
		//翻页控件初始化
		initPageController(currentReadBook.transitionStyle,currentPage: currentReadBook.currentPage)
		//工具栏初始化
		//configureToolbar(currentReadBook.contentShowMode)
		//点击手势依附视图初始化
		let gestureViewCGRect = CGRect(x: UIScreen.mainScreen().bounds.width/3, y: UIScreen.mainScreen().bounds.height/3, width: UIScreen.mainScreen().bounds.width/3, height: UIScreen.mainScreen().bounds.height/3)
		gestureView = UIView(frame: gestureViewCGRect)
		self.view.addSubview(gestureView)
		initGesture()
		setPageControllerCurrentPage()
		
    }
	
	func setPageControllerCurrentPage(){
		//加载当前章节
		currentReadBook.getAgainChapterContent { (currentContentViewController) -> Void in
			self.pageControllerSetViewControllers(currentContentViewController)
		}
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		isHidden = true
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//MARK:页面控制
extension ReadBookViewController{
	//翻页控件初始化
	func initPageController(transitionStyle:UIPageViewControllerTransitionStyle,currentPage:Int){
		pageController = UIPageViewController(transitionStyle: transitionStyle, navigationOrientation: .Horizontal, options:[UIPageViewControllerOptionSpineLocationKey:NSNumber(float: 12)])
		pageController.automaticallyAdjustsScrollViewInsets = true
		pageController.delegate = self
		pageController.dataSource = self
		pageController.view.frame = self.view.frame
		self.addChildViewController(pageController)
		self.view.addSubview(pageController.view)
		pageController.didMoveToParentViewController(self)
	}
}
//MARK:翻页控制器数据源
extension ReadBookViewController:UIPageViewControllerDataSource{
	//向前翻页
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		//如果导航控制器没有隐藏,不能翻页
		guard isHidden else {return nil}
		//向前翻页
		isPrePageUp = true
		isPageUp = false
		let index = currentReadBook.indexOfViewController(viewController as! ContentViewController)
		if index == NSNotFound{
			return nil
		}
		//当当前页号为0,那么再往前翻就是换到前一章节
		if index == 0{
			//只有当前章节>1才能往前翻页
			if currentReadBook.chapterNumber > 1{
				currentReadBook.content = ""
				currentReadBook.currentPage = 1
				isPageUp = true
				return currentReadBook.getBlankViewController()
			}else {
				return nil
			}
		}
		return currentReadBook.viewControllerAtIndex(index - 1)
	}
	//向后翻页
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		guard isHidden else {return nil}
		isPrePageUp = false
		isPageUp = false
		let index = currentReadBook.indexOfViewController(viewController as! ContentViewController)
		if index == NSNotFound{
			return nil
		}
		//当当前页是这个章节的最后一页,那么再往后翻页就是换到下一章节
		if index + 1 == currentReadBook.contentAttribted.count{
			//判断当前章节是否是最后一个章节,如果不是才能翻页
			if let chaptersCount =  currentReadBook.book?.chaptersCount?.integerValue{
				if currentReadBook.chapterNumber < chaptersCount{
					currentReadBook.content = ""
					currentReadBook.currentPage = 1
					isPageUp = true
					return currentReadBook.getBlankViewController()
				}else {
					return nil
				}
			}else{
				return nil
			}
		}
		return currentReadBook.viewControllerAtIndex(index + 1)
	}
}
//MARK:翻页控制器代理
extension ReadBookViewController:UIPageViewControllerDelegate{
	//将要翻页
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
		//设置在翻页的时候用户无法交互，防止混乱
		pageViewController.view.userInteractionEnabled = false
	}
	//翻页完成
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if finished{
			pageViewController.view.userInteractionEnabled = true
		}
		if completed{
			currentReadBook.saveHistory()
		}
		if completed && isPageUp{
			if isPrePageUp{
				currentReadBook.getPreChapterContent({ (currentContentViewController) -> Void in
					self.pageControllerSetViewControllers(currentContentViewController)
				})
			}else {
				currentReadBook.getNextChapterContent({ (currentContentViewController) -> Void in
					self.pageControllerSetViewControllers(currentContentViewController)
				})
			}
			
		}
	}
	func pageControllerSetViewControllers(currentContentViewController:ContentViewController?){
		if let currentCV = currentContentViewController{
			self.pageController.setViewControllers([currentCV], direction: .Forward, animated: false, completion: { (b:Bool) -> Void in })
		}
	}

}
//MARK: 手势
extension ReadBookViewController{
	func initGesture(){
		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
		tapGesture.numberOfTapsRequired = 1
		self.gestureView.addGestureRecognizer(tapGesture)
	}
	func handleTapGesture(sender:UITapGestureRecognizer){
		let point = sender.locationOfTouch(0, inView: self.view)
		let width = UIScreen.mainScreen().bounds.width
		let height = UIScreen.mainScreen().bounds.height
		if point.x > width/3 &&  point.x < width/3*2 {
			if point.y > height/3 &&  point.y < height/3*2 {
				//isHidden = !isHidden
				Setting()
			}
		}
	}
}
//MARK:工具栏
//extension ReadBookViewController{
//	func configureToolbar(contentShowMode:ContentShowMode){
//		navigationController?.toolbarItems = nil
//		var items = [UIBarButtonItem]()
//		let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
//		items.append(barButtonItemWithImageNamed("directory", title: "", action: "showChapterList:"))
//		items.append(flexibleSpace)
//		switch contentShowMode{
//		case .LightMode:
//			items.append(barButtonItemWithImageNamed("day_mode", title: "", action: "lookMode:"))
//		case .DarkMode:
//			items.append(barButtonItemWithImageNamed("night_mode", title: "", action: "lookMode:"))
//		}
//		items.append(flexibleSpace)
//		items.append(barButtonItemWithImageNamed("preview_btn", title: "", action: "download:"))
//		items.append(flexibleSpace)
//		items.append(barButtonItemWithImageNamed("reading_more_setting", title: "", action: "Setting:"))
//		items.append(flexibleSpace)
//		items.append(barButtonItemWithImageNamed("font_increase_unable", title: "", action: "fontBig:"))
//		items.append(flexibleSpace)
//		items.append(barButtonItemWithImageNamed("font_decrease_unable", title: "", action: "fontSmall:"))
//		self.setToolbarItems(items, animated: true)
//		navigationController?.setToolbarHidden(false, animated: true)
//	}
//	func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
//		let button = UIButton(type: .Custom)
//		
//		if let imageName = imageName {
//			button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
//		}
//		if let title = title {
//			button.setTitle(title, forState: .Normal)
//			button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
//			
//			let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
//			button.titleLabel?.font = font
//		}
//		
//		let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
//		button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
//		
//		if let action = action {
//			button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
//		}
//		
//		let barButton = UIBarButtonItem(customView: button)
//		
//		return barButton
//	}
//	//目录
//	func showChapterList(barButtonItem:UIBarButtonItem ){
//		let chapterVC = UIStoryboard.chapterListViewController()
//		guard chapterVC != nil else {return}
//		chapterVC!.book = currentReadBook.book
//		chapterVC!.chapterNumber = currentReadBook.chapterNumber
//		chapterVC!.choiceChapter = { (newChapterNumber:Int) -> Void in
//			//print("newChapterNumber=\(newChapterNumber)")
//			self.currentReadBook.chapterNumber = newChapterNumber
//			self.setPageControllerCurrentPage()
//		}
//		self.navigationController?.pushViewController(chapterVC!, animated: true)
//	}
//	//观看模式
//	func lookMode(barButtonItem:UIBarButtonItem ){
//		let contentViewController = pageController.viewControllers?[0] as? ContentViewController
//		if let x = contentViewController{
//			let mode = x.contentShowMode
//			switch mode {
//			case .DarkMode:
//				currentReadBook.contentShowMode = .LightMode
//			case .LightMode:
//				currentReadBook.contentShowMode = .DarkMode
//			}
//			x.contentShowMode = currentReadBook.contentShowMode
//			configureToolbar(currentReadBook.contentShowMode)
//		}
//	}
//	//放大字体
//	func fontBig(barButtonItem:UIBarButtonItem ){
//		currentReadBook.contentFontSize++
//		setPageControllerCurrentPage()
//	}
//	//缩小字体
//	func fontSmall(barButtonItem:UIBarButtonItem ){
//		currentReadBook.contentFontSize--
//		setPageControllerCurrentPage()
//	}
//	//下载
//	func download(barButtonItem:UIBarButtonItem ){
//		if let id = currentReadBook.book?.id{
//			BookEasouReload.getBookChapterContent(id, completionHandler: { (content) -> Void in})
//		}
//	}
//	//设置
//	func Setting(barButtonItem:UIBarButtonItem){
//		isHidden = true
//		navigationController?.setNavigationBarHidden(isHidden, animated: true)
//		navigationController?.setToolbarHidden(isHidden, animated: true)
//		let settingVC = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(SETTING_VIEW_CONTROLLER_STORYBOARD_ID) as! SettingViewController
//		settingVC.delegate = self
//		self.definesPresentationContext = true
//		settingVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
//		settingVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//		presentViewController(settingVC, animated: false) { () -> Void in
//		}
//	}
//
//}
extension ReadBookViewController:SettingViewControllerDelegate{
	func closeReadBook(){
		isHidden = false
		self.navigationController?.popViewControllerAnimated(true)
	}
	func fontBig(){
		currentReadBook.contentFontSize++
		setPageControllerCurrentPage()
	}
	func fontSmall(){
		currentReadBook.contentFontSize--
		setPageControllerCurrentPage()
	}
	func download(){
		if let id = currentReadBook.book?.id{
			BookEasouReload.getBookChapterContent(id, completionHandler: { (content) -> Void in})
		}
	}
	func lookMode(){
		let contentViewController = pageController.viewControllers?[0] as? ContentViewController
		if let x = contentViewController{
			let mode = x.contentShowMode
			switch mode {
			case .DarkMode:
				currentReadBook.contentShowMode = .LightMode
			case .LightMode:
				currentReadBook.contentShowMode = .DarkMode
			}
			x.contentShowMode = currentReadBook.contentShowMode
			//configureToolbar(currentReadBook.contentShowMode)
		}

	}
	func showChapterList(){
		let chapterVC = UIStoryboard.chapterListViewController()
		guard chapterVC != nil else {return}
		chapterVC!.book = currentReadBook.book
		chapterVC!.chapterNumber = currentReadBook.chapterNumber
		chapterVC!.choiceChapter = { (newChapterNumber:Int) -> Void in
			//print("newChapterNumber=\(newChapterNumber)")
			self.currentReadBook.chapterNumber = newChapterNumber
			self.setPageControllerCurrentPage()
		}
		self.navigationController?.pushViewController(chapterVC!, animated: true)
	}
	//设置
	func Setting(){
		let settingVC = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(SETTING_VIEW_CONTROLLER_STORYBOARD_ID) as! SettingViewController
		settingVC.delegate = self
		self.definesPresentationContext = true
		settingVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
		settingVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
		presentViewController(settingVC, animated: false) { () -> Void in
		}
	}
}
