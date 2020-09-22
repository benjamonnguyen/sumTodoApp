//
//  TimeViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/19/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {
    
    var par:CalendarViewController!
    
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! CalendarViewController)
    }
    
    private func dismissTime() {
        view.alpha = 0
        view.isHidden = true
        par.dimView.alpha = 0
        par.dimView.isHidden = true
    }

    @IBAction private func clear(_ sender: UIButton) {
        par.timeComponents = nil
        dismissTime()
        par.calendarTable.reloadData()
    }
    
    @IBAction private func cancel(_ sender: UIButton) {
        dismissTime()
    }
    
    @IBAction private func done(_ sender: UIButton) {
        par.timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        dismissTime()
        par.calendarTable.reloadData()
    }
    
}
