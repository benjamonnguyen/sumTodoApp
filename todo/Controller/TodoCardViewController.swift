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
    
    var blnStarred = false
    var blnDue = false
    var index: Int?
    var par:ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! ViewController)
        todoTextView.delegate = self
        todoTextView.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.font = UIFont.systemFont(ofSize: K.fontSize)
        todoTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        todoTextField.placeholder = K.addTodoPhrases.randomElement()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let starImage = blnStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        starBtn.setImage(starImage, for: .normal)
        if blnDue {
            dueBtn.setImage(UIImage(systemName: "alarm.fill"), for: .normal)
//            datePicker.isHidden = false
        } else {
            dueBtn.setImage(UIImage(systemName: "alarm"), for: .normal)
//            datePicker.isHidden = true
        }
    }
    
    @objc private func textFieldDidChange(textField:UITextField) {
        saveBtn.isEnabled = todoTextField.text != "" ? true : false
    }

    @IBAction private func toggleStar(_ sender: UIButton) {
        blnStarred = !blnStarred
    }
    @IBAction private func toggleDue(_ sender: UIButton) {
        blnDue = !blnDue
        todoTextField.resignFirstResponder()
    }
    @IBAction private func saveTodo(_ sender: Any) {
        let todo = index == nil ? Todo(context: par.context) : par.todos[index!]
        DispatchQueue.main.async {
            if todo.dtmCreated == nil {
                todo.dtmCreated = Date()
            }
            todo.text = self.todoTextField.text! != "" ? self.todoTextField.text! : self.todoTextView.text!
            todo.blnStarred = self.blnStarred
            if self.blnDue {
//                todo.dtmDue = self.datePicker.date
            }
            try! self.par.context.save()
            self.par.fetchTodos()
            self.par.handleDismiss()
        }
    }
}

extension TodoCardViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveBtn.isEnabled = todoTextView.text != "" && todoTextView.text != par.todos[index!].text ? true : false
    }
    
}
