//
//  BookListTableViewCell.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/10.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class BookListTableViewCell: UITableViewCell {

	@IBOutlet weak var updateTimeLabel: UILabel!
	@IBOutlet weak var bookLastChapterLabel: UILabel!
	@IBOutlet weak var bookNameLabel: UILabel!
	@IBOutlet weak var bookCoverImageView: UIImageView!
	var bookCoverImage:UIImage?{
		didSet {
			guard bookCoverImageView != nil else {return}
			bookCoverImageView.image = bookCoverImage
		}
	}
	var bookName:String?{
		didSet {
			guard bookNameLabel != nil else {return}
			bookNameLabel.text = bookName
		}
	}
	var bookLastChapter:String?{
		didSet {
			guard bookLastChapterLabel != nil else {return}
			bookLastChapterLabel.text = bookLastChapter
		}
	}
	var updateTime:String?{
		didSet {
			guard updateTimeLabel != nil else {return}
			updateTimeLabel.text = updateTime
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
