//
//  RescheduleCardViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/10/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class RescheduleCardViewController: UIViewController {

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
        let newDate = calendar.date(from: newComponents)
        DispatchQueue.main.async {
            todo.dtmDue = newDate
            try! par.context.save()
            par.fetchTodos()
        }
        par.handleDismiss()
    }
    
    @IBAction private func rescheduleToday(_ sender: UIButton) {
        reschedule(days: 0)
        //        var todayComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
        //        todayComponents.hour = nil
        //        todayComponents.minute = nil
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

//extension UIButton {
//
//    func centerVertically(padding: CGFloat = 2.0) {
//        guard
//            let imageViewSize = self.imageView?.frame.size,
//            let titleLabelSize = self.titleLabel?.frame.size else {
//            return
//        }
//
//        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
//
//        self.imageEdgeInsets = UIEdgeInsets(
//            top: -(totalHeight - imageViewSize.height),
//            left: 0.0,
//            bottom: 0.0,
//            right: -titleLabelSize.width
//        )
//
//        self.titleEdgeInsets = UIEdgeInsets(
//            top: 0.0,
//            left: -imageViewSize.width,
//            bottom: -(totalHeight - titleLabelSize.height),
//            right: 0.0
//        )
//
//        self.contentEdgeInsets = UIEdgeInsets(
//            top: 0.0,
//            left: 0.0,
//            bottom: titleLabelSize.height,
//            right: 0.0
//        )
//    }
//
//}
