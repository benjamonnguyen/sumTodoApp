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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
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
