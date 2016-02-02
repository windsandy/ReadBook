//
//  SettingViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

protocol SettingViewControllerDelegate:class{
	func closeReadBook()
	func fontBig()
	func fontSmall()
	func download()
	func lookMode()
	func showChapterList()
}


class SettingViewController: UIViewController {
	//let originCGRect = CGRect(x: WIDTH_MAIN / 2 - 15, y: HEIGHT_MAIN / 2 - 15 , width: 30, height: 30)
	let originCGRect = CGRect(x: WIDTH_MAIN / 2 - 5, y: HEIGHT_MAIN / 2 - 5 , width: 10, height: 10)
	let  radius:CGFloat = 100.0
	weak var delegate : SettingViewControllerDelegate?
	var button:UIButton!
	var button1:UIButton!
	var button2:UIButton!
	var button3:UIButton!
	var button4:UIButton!
	var button5:UIButton!
	var button6:UIButton!
	var tapGesture:UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
		setButton()
		
    }
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		buttonAnimateOpen()
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	func setButton(){
		
		
		button1 = UIButton(frame: originCGRect)
		button1.setBackgroundImage(UIImage(named: "menu_home"), forState: UIControlState.Normal)
		button1.addTarget(self, action: Selector("button1OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button1.alpha = 0
		self.view.addSubview(button1)
		
		button2 = UIButton(frame: originCGRect)
		button2.setBackgroundImage(UIImage(named: "menu_font_increase"), forState: UIControlState.Normal)
		button2.addTarget(self, action: Selector("button2OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button2.alpha = 0
		self.view.addSubview(button2)
		
		button3 = UIButton(frame: originCGRect)
		button3.setBackgroundImage(UIImage(named: "menu_font_decrease"), forState: UIControlState.Normal)
		button3.addTarget(self, action: Selector("button3OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button3.alpha = 0
		self.view.addSubview(button3)
		
		button4 = UIButton(frame: originCGRect)
		button4.setBackgroundImage(UIImage(named: "menu_sun"), forState: UIControlState.Normal)
		button4.addTarget(self, action: Selector("button4OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button4.alpha = 0
		self.view.addSubview(button4)
		
		button5 = UIButton(frame: originCGRect)
		button5.setBackgroundImage(UIImage(named: "menu_menu"), forState: UIControlState.Normal)
		button5.addTarget(self, action: Selector("button5OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button5.alpha = 0
		self.view.addSubview(button5)
		
		button6 = UIButton(frame: originCGRect)
		button6.setBackgroundImage(UIImage(named: "menu_download"), forState: UIControlState.Normal)
		button6.addTarget(self, action: Selector("button6OnClick"), forControlEvents: UIControlEvents.TouchDown)
		button6.alpha = 0
		self.view.addSubview(button6)
		
		button = UIButton(frame: originCGRect)
		button.setBackgroundImage(UIImage(named: "menu_cancel"), forState: UIControlState.Normal)
		button.addTarget(self, action: Selector("closeFrom"), forControlEvents: UIControlEvents.TouchDown)
		button.alpha = 0
		self.view.addSubview(button)
		
		
		
	}
	func buttonAnimateOpen(){
		let originCenter = CGPoint(x: WIDTH_MAIN / 2, y: HEIGHT_MAIN / 2)
		UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
			self.button.alpha = 1
			self.button.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		
		UIView.animateWithDuration(0.2, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = -self.radius / 2
			let yCenter = -sqrt(self.radius * self.radius - self.radius / 2 * self.radius / 2)
			let newCenter = CGPoint(x: originCenter.x + xCenter, y: originCenter.y + yCenter)
			self.button1.center = newCenter
			self.button1.alpha = 1
			self.button1.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.3, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = self.radius / 2
			let yCenter = -sqrt(self.radius * self.radius - self.radius / 2 * self.radius / 2)
			let newCenter = CGPoint(x: originCenter.x + xCenter, y: originCenter.y + yCenter)
			self.button2.center = newCenter
			self.button2.alpha = 1
			self.button2.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.4, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = -self.radius
			let yCenter:CGFloat = 0.0
			let newCenter = CGPoint(x: originCenter.x + xCenter , y: originCenter.y + yCenter)
			self.button3.center = newCenter
			self.button3.alpha = 1
			self.button3.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.5, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = self.radius
			let yCenter:CGFloat = 0.0
			let newCenter = CGPoint(x: originCenter.x + xCenter , y: originCenter.y + yCenter)
			self.button4.center = newCenter
			self.button4.alpha = 1
			self.button4.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.6, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = -self.radius / 2
			let yCenter = sqrt(self.radius * self.radius - self.radius / 2 * self.radius / 2)
			let newCenter = CGPoint(x: originCenter.x + xCenter, y: originCenter.y  + yCenter)
			self.button5.center = newCenter
			self.button5.alpha = 1
			self.button5.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.7, options: .CurveEaseOut, animations: { () -> Void in
			let xCenter = self.radius / 2
			let yCenter = sqrt(self.radius * self.radius - self.radius / 2 * self.radius / 2)
			let newCenter = CGPoint(x: originCenter.x + xCenter, y: originCenter.y  + yCenter)
			self.button6.center = newCenter
			self.button6.alpha = 1
			self.button6.transform = CGAffineTransformMakeScale(4, 4)
			}) { (finished) -> Void in
		}
	}
	func buttonAnimateClose(){
		let originCenter = CGPoint(x: WIDTH_MAIN / 2, y: HEIGHT_MAIN / 2)
		UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
			self.button.alpha = 0
			self.button.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
				self.dismissViewControllerAnimated(false) { () -> Void in}
		}
		
		UIView.animateWithDuration(0.2, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
			self.button1.center = originCenter
			self.button1.alpha = 0
			self.button1.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.3, options: .CurveEaseOut, animations: { () -> Void in
			self.button2.center = originCenter
			self.button2.alpha = 0
			self.button2.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.4, options: .CurveEaseOut, animations: { () -> Void in
			self.button3.center = originCenter
			self.button3.alpha = 0
			self.button3.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.5, options: .CurveEaseOut, animations: { () -> Void in
			self.button4.center = originCenter
			self.button4.alpha = 0
			self.button4.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.6, options: .CurveEaseOut, animations: { () -> Void in
			self.button5.center = originCenter
			self.button5.alpha = 0
			self.button5.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
		UIView.animateWithDuration(0.2, delay: 0.7, options: .CurveEaseOut, animations: { () -> Void in
			self.button6.center = originCenter
			self.button6.alpha = 0
			self.button6.transform = CGAffineTransformMakeScale(1/4, 1/4)
			}) { (finished) -> Void in
		}
	}
}
extension SettingViewController{
	func closeFrom(){
		buttonAnimateClose()
		//dismissViewControllerAnimated(false) { () -> Void in}
	}
	func button1OnClick(){
		
		delegate?.closeReadBook()
	}
	func button2OnClick(){
		delegate?.fontBig()
	}
	func button3OnClick(){
		delegate?.fontSmall()
	}
	func button4OnClick(){
		delegate?.lookMode()
	}
	func button5OnClick(){
		delegate?.showChapterList()
	}
	func button6OnClick(){
		delegate?.download()
	}
}