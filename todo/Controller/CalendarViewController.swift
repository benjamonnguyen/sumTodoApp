//
//  CalendarViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/13/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarTable: UITableView!
    // TODO: do separator image programmatically
    @IBOutlet weak var btnSeparatorImage: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var index:Int!
    var text:String! = ""
    var dtmDue:Date?
    var par:ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarTable.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        calendar.dataSource = self
        calendar.delegate = self
        calendarTable.dataSource = self
        calendarTable.delegate = self
        par = (parent as! ViewController)
        calendar.appearance.separators = .none
        calendar.placeholderType = .fillHeadTail
        cancelBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width/9).isActive = true
        doneBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.frame.width/7.5).isActive = true
        cancelBtn.tintColor = K.primaryLightColor
        doneBtn.tintColor = K.primaryLightColor
        btnSeparatorImage.transform = btnSeparatorImage.transform.rotated(by: .pi/2)
    }
    
    // func button tap to return to current month
    
    func setupCalendar() {
        let selectedDate = dtmDue != nil ? dtmDue! : index != nil ? par.todos[index].dtmDue ?? Date() : Date()
        calendar.select(selectedDate)
    }
    
    func dismissCalendar() {
        view.alpha = 0
        view.isHidden = true
        if index != nil {
            par.handleEdit(for: par.todos, at: index)
            par.todoCardVC.todoTextView.text = text
        } else {
            par.todoCardVC.todoTextField.text = text
            par.addTodo(nil)
        }
    }
    
    @IBAction private func cancel(_ sender: UIButton) {
        dismissCalendar()
    }
    
    @IBAction private func done(_ sender: UIButton) {
        dtmDue = calendar.selectedDate!
        dismissCalendar()
        par.todoCardVC.blnDue = !par.todoCardVC.blnDue
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectColor = K.startOfDay(for: date) < K.startOfDay(for: Date()) ? K.red : K.primaryLightColor
        calendar.appearance.selectionColor = selectColor
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for todo in par.todos {
            if let dtmDue = todo.dtmDue {
                if Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: dtmDue) {
                    return 1
                }
            }
        }
        return 0
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        var image:UIImage!
        var titleText:String!
        var detailText:String! = "None"
        if indexPath.row == 0 {
            image = UIImage(systemName: "clock.fill")
            titleText = "Time"
        } else if indexPath.row == 1 {
            image = UIImage(systemName: "arrow.2.circlepath")
            titleText = "Repeat"
        }
        cell.iconImage.image = image
        cell.titleLabel.text = titleText
        cell.detailLabel.text = detailText
        return cell
    }
    
}
