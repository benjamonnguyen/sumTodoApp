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
    
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarTable.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        calendar.dataSource = self
        calendar.delegate = self
        calendarTable.dataSource = self
        calendarTable.delegate = self
        calendar.select(Date())
        calendar.appearance.separators = .none
        calendar.placeholderType = .fillHeadTail
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let par = parent as! ViewController
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
