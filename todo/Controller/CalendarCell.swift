//
//  CalendarCell.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/14/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class CalendarCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    weak var delegate: CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
