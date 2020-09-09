//
//  TodoCell.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/7/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class TodoCell:UITableViewCell {
    
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    
    weak var delegate: CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(_ todo:Todo) {
        todoLabel.text = todo.text
        
        // Check box
        checkBtn.tintColor = todo.blnStarred ? #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1) : #colorLiteral(red: 0.6875833043, green: 0.6875833043, blue: 0.6875833043, alpha: 1)
        let image = todo.dtmCompleted == nil ? UIImage(systemName: "square") : UIImage(systemName: "checkmark.square")
        checkBtn.setImage(image, for: .normal)
        
        // Due Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd"
        if let dtmDue = todo.dtmDue {
            dateLabel.text = dateFormatter.string(from: dtmDue)
            dateLabel.textColor = dtmDue < Date() ? #colorLiteral(red: 0.7959826631, green: 0.09189335398, blue: 0.002260176236, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            dateLabel.text = ""
        }
    }
    
    @IBAction func completeTodo(_ sender: UIButton) {
        delegate?.didCheck(self)
    }
    
}

protocol CellDelegate: class {
    func didCheck(_ cell: TodoCell)
}
