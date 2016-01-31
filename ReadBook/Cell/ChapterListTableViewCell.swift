//
//  ChapterListTableViewCell.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/18.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class ChapterListTableViewCell: UITableViewCell {

	@IBOutlet weak var chatperNameLabel: UILabel!
	@IBOutlet weak var statImage: UIImageView!
	var statShowImage:UIImage?{
		didSet {
			guard statImage != nil else {return}
			statImage.image = statShowImage
		}
	}
	var chapterName:String?{
		didSet {
			guard chatperNameLabel != nil else {return}
			chatperNameLabel.text = chapterName
		}
	}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
