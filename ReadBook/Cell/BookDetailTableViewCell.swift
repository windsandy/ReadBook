//
//  BookDetailTableViewCell.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/13.
//  Copyright © 2016年 张旭. All rights reserved.
//

import UIKit

class BookDetailTableViewCell: UITableViewCell {

	
	@IBOutlet weak var otherLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var imageCover: UIImageView!
	var bookCoverImage:UIImage?{
		didSet {
			guard imageCover != nil else {return}
			imageCover.image = bookCoverImage
		}
	}
	var bookName:String?{
		didSet {
			guard nameLabel != nil else {return}
			nameLabel.text = bookName
		}
	}
	var bookAuthor:String?{
		didSet {
			guard authorLabel != nil else {return}
			authorLabel.text = bookAuthor
		}
	}
	var bookOther:String?{
		didSet {
			guard otherLabel != nil else {return}
			otherLabel.text = bookOther
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
