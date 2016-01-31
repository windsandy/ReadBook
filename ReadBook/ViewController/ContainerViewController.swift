//
//  ContainerViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
	//是否可以滑动
	let isSlide = false
	
	
	//当前滑动状态
	var currentState:SlideOutState = SlideOutState.BothCollapsed{
		didSet {
			//如果正在滑动，那么设置阴影
			let shouldShowShadow = currentState != .BothCollapsed
			showShadowForCenterViewController(shouldShowShadow)
		}
	}
	//定义导航控制器
	var centerNavigationController:UINavigationController!
	//定义中央主窗体控制器
	var centerViewController:CenterViewController!
	//定义左滑菜单窗体控制器
	var leftViewController:LeftViewController?
	//定义右滑菜单窗体控制器
	var rightViewController:RightViewController?
	//是否启用点击手势
	var havHandlePanGesture:Bool = true
	//定义点击手势,作用是在滑动的情况下可以点击取消滑动
	var tapGesture:UITapGestureRecognizer!
	//顶部状态栏是否隐藏
	var statusBarHidden = false
    override func viewDidLoad() {
        super.viewDidLoad()
		//设置导航控制器
		centerNavigationController = UIStoryboard.centerNavigationController()
		//获取中央主窗体控制器
		centerViewController = centerNavigationController.viewControllers.first as! CenterViewController
		centerViewController.delegate = self
		view.addSubview(centerNavigationController.view)
		addChildViewController(centerNavigationController)
		centerNavigationController.didMoveToParentViewController(self)
		//定义滑动手势
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
		//滑动手势添加到到导航控制器
		centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
		//定义点击手势
		tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
		tapGesture.numberOfTapsRequired = 1

    }
	//顶端状态栏样式
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.Default
	}
	//是否显示顶端状态栏,只能在root视图设置
	override func prefersStatusBarHidden() -> Bool {
		return statusBarHidden
	}
	//设置是否显示顶端状态栏
	func setThisStatusBarHidden(isHidden:Bool){
		statusBarHidden = isHidden
		self.setNeedsStatusBarAppearanceUpdate()
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
//MARK:CenterViewController代理,视图滑动
extension ContainerViewController:CenterViewControllerDelegate{
	//设置滑动阴影
	func showShadowForCenterViewController(shouldShowShadow:Bool){
		if shouldShowShadow{
			centerNavigationController.view.layer.shadowOpacity = 0.8
		}else {
			centerNavigationController.view.layer.shadowOpacity = 0.0
		}
	}
	//设置取消滑动
	func centerSidePanels(){
		if leftViewController != nil{
			animateLeftPanel(shouldExpand: false)
		}else if rightViewController != nil {
			animateRightPanel(shouldExpand: false)
		}
		removeTapGesture()
	}
	//设置左滑
	func toggleLeftPanel() {
		let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
		if notAlreadyExpanded{
			addLeftPanelViewController()
		}
		animateLeftPanel(shouldExpand: notAlreadyExpanded)
	}
	//设置右滑
	func toggleRightPanel() {
		let notAlreadyExpanded = (currentState != .RightPanelExpanded)
		if notAlreadyExpanded{
			addRightPanelViewController()
		}
		animateRightPanel(shouldExpand: notAlreadyExpanded)
	}
	func collapseSidePanels() {
		switch currentState{
		case .LeftPanelExpanded:
			toggleLeftPanel()
		case .RightPanelExpanded:
			toggleRightPanel()
		default:
			break
			
		}
	}
	//左滑时，初始化左滑窗体
	func addLeftPanelViewController(){
		if leftViewController == nil {
			leftViewController = UIStoryboard.leftViewController()
			leftViewController!.delegate = centerViewController
			view.insertSubview(leftViewController!.view, atIndex: 0)
			addChildViewController(leftViewController!)
			leftViewController!.didMoveToParentViewController(self)
		}
	}
	//右滑时,初始化右滑窗体
	func addRightPanelViewController(){
		if rightViewController == nil {
			rightViewController = UIStoryboard.rightViewController()
			rightViewController!.delegate = centerViewController
			view.insertSubview(rightViewController!.view, atIndex: 0)
			addChildViewController(rightViewController!)
			rightViewController!.didMoveToParentViewController(self)
			initGesture();
		}
	}
	//滑动动画
	func animateCenterPanelXPosition(targetPosition targetPostion:CGFloat,completion:((Bool) -> Void)! = nil){
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
			self.centerNavigationController.view.frame.origin.x = targetPostion
			}, completion: completion)
	}
	//左滑动画
	func animateLeftPanel(shouldExpand shouldExpand:Bool){
		if shouldExpand{
			currentState = .LeftPanelExpanded
			animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - CENTER_LEFT_PANEL_EXPANDED_OFFSET)
		}else {
			animateCenterPanelXPosition(targetPosition: 0, completion: { (_) -> Void in
				self.currentState = .BothCollapsed
				self.leftViewController!.view.removeFromSuperview()
				self.leftViewController = nil
			})
		}
	}
	//右滑动画
	func animateRightPanel(shouldExpand shouldExpand:Bool){
		if shouldExpand{
			currentState = .RightPanelExpanded
			animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerNavigationController.view.frame) + CENTER_RIGHT_PANEL_EXPANDED_OFFSET)
		}else{
			animateCenterPanelXPosition(targetPosition: 0, completion: { (_) -> Void in
				self.currentState = .BothCollapsed
				self.rightViewController!.view.removeFromSuperview()
				self.rightViewController = nil
			})
		}
	}
}
//MARK:滑动手势
extension ContainerViewController:UIGestureRecognizerDelegate{
	func handlePanGesture(recognizer:UIPanGestureRecognizer){
		guard isSlide else {return}
		guard havHandlePanGesture else {return}
		let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
		switch recognizer.state{
		case .Began:
			if currentState == .BothCollapsed{
				if gestureIsDraggingFromLeftToRight{
					addLeftPanelViewController()
				}else{
					addRightPanelViewController()
				}
				showShadowForCenterViewController(true)
			}
		case .Changed:
			recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
			recognizer.setTranslation(CGPointZero, inView: view)
		case .Ended:
			if leftViewController != nil{
				let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
				animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
			}else if rightViewController != nil {
				let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
				animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
			}
		default:
			break
		}
	}
}
//MARK:点击手势
//???设置只有在侧滑的时候有效，其它页面移除，否则会与其它手势冲突
extension ContainerViewController{
	//初始化点击手势，防止多次初始化，需要判断是否存在
	func initGesture(){
		let index = getTapGestureIndex()
		if index >= 0 {return}
		centerNavigationController.view.addGestureRecognizer(tapGesture)
	}
	//点击手势的动作
	func handleTapGesture(sender:UITapGestureRecognizer){
		centerSidePanels()
	}
	//移除点击手势
	func removeTapGesture(){
		let index = getTapGestureIndex()
		if index >= 0 {
			centerNavigationController.view.gestureRecognizers!.removeAtIndex(index)
		}
	}
	//查找是否存在点击手势
	func getTapGestureIndex()->Int{
		let index = centerNavigationController.view.gestureRecognizers?.indexOf(tapGesture)
		return  index == nil ? -1 : index!
	}
}
