//
//  CardViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/3/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit
import CoreData

class CardViewController: UIViewController {

    @IBOutlet var cardView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var dueBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var blnStarred = false
    var blnDue = false
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        let starImage = blnStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        starBtn.setImage(starImage, for: .normal)
        if blnDue {
            dueBtn.setImage(UIImage(systemName: "alarm.fill"), for: .normal)
            datePicker.isHidden = false
        } else {
            dueBtn.setImage(UIImage(systemName: "alarm"), for: .normal)
            datePicker.isHidden = true
        }
        saveBtn.isEnabled = todoTextField.text != "" ? true : false
    }

    @IBAction func toggleStar(_ sender: UIButton) {
        blnStarred = !blnStarred
    }
    @IBAction func toggleDue(_ sender: UIButton) {
        blnDue = !blnDue
        todoTextField.resignFirstResponder()
    }
    @IBAction func saveTodo(_ sender: Any) {
        let par = parent as! ViewController
        let todo = index == nil ? Todo(context: par.context) : par.todos[index!]
        DispatchQueue.main.async {
            if todo.dtmCreated == nil {
                todo.dtmCreated = Date()
            }
            todo.text = self.todoTextField.text!
            todo.blnStarred = self.blnStarred
            if self.blnDue {
                todo.dtmDue = self.datePicker.date
            }
            try! par.context.save()
            par.handleDismiss()
            par.fetchTodos()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
