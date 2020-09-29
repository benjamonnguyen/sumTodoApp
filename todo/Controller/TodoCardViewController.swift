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
    var blnTime = false
    var dtmDue:Date? = nil
    var recur = "None"
    var todo:Todo?
    var par:ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! ViewController)
        todoTextView.delegate = self
        todoTextView.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        dateStackView.centerYAnchor.constraint(equalTo: dueBtn.centerYAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func refreshCard() {
        DispatchQueue.main.async {
            let starImage = self.blnStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            self.starBtn.setImage(starImage, for: .normal)
            if let dtmDue = self.dtmDue {
                self.dateLabel.isHidden = false
                self.dueBtn.tintColor = K.secondaryLightColor
                self.dateLabel.text = F.dateFormatter.string(from: dtmDue)
                if self.blnTime {
                    self.timeLabel.isHidden = false
                    self.timeLabel.text = F.timeFormatter.string(from: dtmDue)
                } else {
                    self.timeLabel.isHidden = true
                }
                if F.startOfDay(for: dtmDue) < F.startOfDay(for: Date()) {
                    self.dateLabel.textColor = K.red
                    self.timeLabel.textColor = K.red
                } else {
                    self.dateLabel.textColor = K.lightGray
                    self.timeLabel.textColor = K.lightGray
                }
            } else {
                self.dueBtn.tintColor = K.lightGray
                self.dateLabel.isHidden = true
                self.timeLabel.isHidden = true
            }
        }
        checkForChange()
    }
    
    func setupCard() {
        if let todo = self.todo {
            todoTextView.text = todo.text
            blnTime = todo.blnTime
            recur = todo.recur
            dtmDue = todo.dtmDue
            blnStarred = todo.blnStarred
        } else {
            todoTextView.text = nil
            todoTextField.text = nil
            blnTime = false
            recur = "None"
            dtmDue = nil
            blnStarred = false
        }
        refreshCard()
    }
    
    private func checkForChange() {
        if let todo = self.todo {
            if blnStarred != todo.blnStarred || blnTime != todo.blnTime ||
                (todoTextView.text != todo.text && todoTextView.text.count > 0) ||
                recur != todo.recur || dtmDue != todo.dtmDue {saveBtn.isEnabled = true}
            else {saveBtn.isEnabled = false}
        } else {saveBtn.isEnabled = todoTextField.text?.count ?? 0 > 0 ? true : false}
    }
    
    @objc private func textFieldDidChange(textField:UITextField) {
        checkForChange()
    }

    @IBAction private func toggleStar(_ sender: UIButton) {
        blnStarred = !blnStarred
        refreshCard()
    }
    @IBAction private func toggleCalendar(_ sender: UIButton) {
        par.handleDismiss()
        par.calendarVC.view.isHidden = false
        par.dimView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, animations: {
            self.par.dimView.alpha = 1
            self.par.calendarVC.view.alpha = 1
        })
        par.calendarVC.calendar.select(dtmDue ?? Date())
        par.calendarVC.timeComponents = blnTime ? Calendar.current.dateComponents([.hour, .minute], from: dtmDue!) : nil
        par.calendarVC.recur = recur
        par.calendarVC.calendarTableView.reloadData()
    }
    
    @IBAction private func saveTodo(_ sender: Any) {
        let todo = self.todo ?? Todo(context: par.context)
        if todo.dtmCreated == nil {
            todo.dtmCreated = Date()
            todo.text = todoTextField.text!
        } else {
            todo.text = todoTextView.text!
        }
        todo.blnStarred = blnStarred
        todo.dtmDue = dtmDue
        todo.blnTime = blnTime
        todo.recur = recur
        F.feedback(.soft)
        try! par.context.save()
        par.fetchTodos()
        par.handleDismiss()
    }
}

extension TodoCardViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkForChange()
    }
}
