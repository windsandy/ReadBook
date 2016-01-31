//
//  RightViewController.swift
//  ReadBook
//
//  Created by 张旭 on 16/1/26.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

protocol RightPanelViewControllerDelegate:class{
	func actionRightSelected(action:ActionOption)
}
class RightViewController: UIViewController {
	weak var delegate:RightPanelViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func btnSearchOnClick(sender: ButtonFromLeftSidePanel) {
		delegate?.actionRightSelected(ActionOption.Search)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
