//
//  TableViewCell.swift
//  Voice Pimp Demo
//
//  Created by Javid Sheikh on 20/02/2016.
//  Copyright © 2016 Javid Sheikh. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDate: UILabel!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    
}
