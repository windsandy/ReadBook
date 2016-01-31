//
//  ButtonFromLeftSidePanel.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/11.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class ButtonFromLeftSidePanel: UIButton {

	override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
		return CGRectMake(70, 10, 25, 25)
		
	}
	override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
		return CGRectMake(100, 12,100, 21)
	}

}
