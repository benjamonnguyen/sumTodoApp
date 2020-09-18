//
//  CardViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/3/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit
import CoreData

class TodoCardViewController: UIViewController {

    @IBOutlet var cardView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoTextView: UITextView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var dueBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var blnStarred = false
    var blnDue = false
    var index: Int?
    var par:ViewController!
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! ViewController)
        todoTextView.delegate = self
        todoTextView.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        timeFormatter.amSymbol = "am"
        timeFormatter.pmSymbol = "pm"
        timeFormatter.dateFormat = "h:mm a"
        dateFormatter.dateFormat = "MMM dd"
        dateStackView.centerYAnchor.constraint(equalTo: dueBtn.centerYAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            let starImage = self.blnStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            self.starBtn.setImage(starImage, for: .normal)
            if self.blnDue {
                self.dateLabel.isHidden = false
                self.dueBtn.tintColor = K.secondaryLightColor
                if let date = self.par.calendarVC.dtmDue {
                    self.dateLabel.text = self.dateFormatter.string(from: date)
                    
                    // TODO: if blnTime isHidden = false
                    if K.startOfDay(for: date) < K.startOfDay(for: Date()) {
                    
                    }
                    self.dateLabel.textColor = K.startOfDay(for: date) < K.startOfDay(for: Date()) ? K.red : K.lightGray
                }
            } else {
                self.dueBtn.tintColor = K.lightGray
                self.dateLabel.isHidden = true
                self.timeLabel.isHidden = true
            }
        }
    }
    
    @objc private func textFieldDidChange(textField:UITextField) {
        // FIXME: saveBtn.isEnabled
//        saveBtn.isEnabled = todoTextField.text != "" ? true : false
    }

    @IBAction private func toggleStar(_ sender: UIButton) {
        blnStarred = !blnStarred
    }
    @IBAction private func toggleDue(_ sender: UIButton) {
        par.calendarVC.index = index
        if index != nil {
            par.calendarVC.dtmDue = par.todos[index!].dtmDue
        }
        par.handleDismiss()
        par.calendarVC.view.isHidden = false
        par.dimView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, animations: {
            self.par.dimView.alpha = 1
            self.par.calendarVC.view.alpha = 1
        })
        par.calendarVC.setupCalendar()
    }
    @IBAction private func saveTodo(_ sender: Any) {
        let todo = index == nil ? Todo(context: par.context) : par.todos[index!]
        if todo.dtmCreated == nil {
            todo.dtmCreated = Date()
        }
        todo.text = self.todoTextField.text! != "" ? self.todoTextField.text! : self.todoTextView.text!
        todo.blnStarred = self.blnStarred
        if self.blnDue {
            todo.dtmDue = self.par.calendarVC.dtmDue
        }
        try! self.par.context.save()
        self.par.fetchTodos()
        self.par.handleDismiss()
    }
}

extension TodoCardViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // FIXME: saveBtn.isEnabled
//        saveBtn.isEnabled = todoTextView.text != "" && todoTextView.text != par.todos[index!].text ? true : false
    }
}
