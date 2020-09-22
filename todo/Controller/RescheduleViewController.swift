//
//  RescheduleViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/10/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class RescheduleViewController: UIViewController {

    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var tomorrowBtn: UIButton!
    @IBOutlet weak var nextWkBtn: UIButton!
    @IBOutlet weak var thisSatBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let todayDate = dateFormatter.string(from: Date())
        if let nextWkDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
            let nextWk = dateFormatter.string(from: nextWkDate)
            nextWkBtn.setImage(UIImage(systemName: "\(nextWk).square"), for: .normal)
        }
        todayBtn.setImage(UIImage(systemName: "\(todayDate).square"), for: .normal)
    }
    
    private func reschedule(days:Int) {
        let par = parent as! ViewController
        let todo = par.todos[index]
        let calendar = Calendar.current
        var newComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
        if let originalDate = todo.dtmDue {
            let originalComponents = calendar.dateComponents([.hour, .minute], from: originalDate)
            newComponents.day! += days
            newComponents.hour = originalComponents.hour
            newComponents.minute = originalComponents.minute
        }
        todo.dtmDue = calendar.date(from: newComponents)
        try! par.context.save()
        par.fetchTodos()
        par.handleDismiss()
    }
    
    @IBAction private func rescheduleToday(_ sender: UIButton) {
        reschedule(days: 0)
    }
    @IBAction private func rescheduleTmr(_ sender: UIButton) {
        reschedule(days: 1)
    }
    @IBAction private func rescheduleNextWk(_ sender: UIButton) {
        reschedule(days: 7)
    }
    @IBAction private func rescheduleThisSat(_ sender: UIButton) {
        let saturday = Calendar.current.nextWeekend(startingAfter: Date())!.start
        let days = Calendar.current.dateComponents([.day], from: Date(), to: saturday)
        reschedule(days: days.day!)
    }
    @IBAction private func clearDueDate(_ sender: UIButton) {
        let par = parent as! ViewController
        let todo = par.todos[index]
        DispatchQueue.main.async {
            todo.dtmDue = nil
            try! par.context.save()
            par.fetchTodos()
        }
        par.handleDismiss()
    }
}
