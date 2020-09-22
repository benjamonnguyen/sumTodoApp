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
    
    private func strikethru(_ text: String, reverse: Bool) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any]
        if reverse == false {
            attributes = [
                .font: UIFont.systemFont(ofSize: K.fontSize),
                .foregroundColor: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)]
        } else {
            attributes = [
                .font: UIFont.systemFont(ofSize: K.fontSize),
                .foregroundColor: #colorLiteral(red: 0.2458492062, green: 0.2458492062, blue: 0.2458492062, alpha: 1)]
        }
        let attributedText =  NSMutableAttributedString(string: text, attributes: attributes)
        if reverse == false {
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedText.length))
        }
        return attributedText
    }
    
    func setupCell(_ todo:Todo) {
        let blnCompleted = todo.dtmCompleted != nil
        
        // Check box
        checkBtn.tintColor = todo.blnStarred ? K.secondaryLightColor : #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: K.fontSize, weight: .semibold)
        let image = blnCompleted ? UIImage(systemName: "checkmark.square", withConfiguration: symbolConfig) : UIImage(systemName: "square", withConfiguration: symbolConfig)
        checkBtn.setImage(image, for: .normal)
        
        // Due Date
        if let dtmDue = todo.dtmDue {
            var date = F.dateFormatter.string(from: dtmDue)
            dateLabel.textColor = F.startOfDay(for: dtmDue) < F.startOfDay(for: Date()) ? K.red : K.lightGray
            if date == F.dateFormatter.string(from: Date()) {
                if todo.blnTime {
                    date = F.timeFormatter.string(from: dtmDue)
                    dateLabel.textColor = dtmDue < Date() ? K.red : K.lightGray
                } else {date = "Today"}
            }
            dateLabel.text = date
        } else {dateLabel.text = ""}
        
        todoLabel.attributedText = strikethru(todo.text ?? "", reverse: !blnCompleted)
        
        // Gray out if blnCompleted
        if blnCompleted {
            checkBtn.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            dateLabel.text = ""
            selectionStyle = .none
        } else {selectionStyle = .gray}
    }
    
    @IBAction private func checkTodo(_ sender: UIButton) {
        delegate?.didCheck(self)
    }
    
}

protocol CellDelegate: class {
    func didCheck(_ cell: TodoCell)
}
