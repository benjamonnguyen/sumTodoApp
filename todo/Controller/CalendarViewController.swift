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
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    var text:String?
    var dateComponents:DateComponents!
    var timeComponents:DateComponents?
    var par:ViewController!
    
    var timeVC:TimeViewController!
    var dimView:UIView!
    
    override func loadView() {
        super.loadView()
        setupButtons(view, cancelBtn, doneBtn, clearBtn)
        initSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! ViewController)
        //calendar
        calendarTable.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        calendar.dataSource = self
        calendar.delegate = self
        calendarTable.dataSource = self
        calendarTable.delegate = self
        calendar.appearance.separators = .none
        calendar.placeholderType = .fillHeadTail
    }
    
    // TODO: func button tap to return to current month + custom title header view
    
    private func initSubviews() {
        dimView = F.setupDimView(for: self, with: #selector(dismissTime))
        
        // timeVC setup
        timeVC = TimeViewController(nibName: "TimeView", bundle: nil)
        self.addChild(timeVC)
        view.addSubview(timeVC.view)
        view.bringSubviewToFront(timeVC.view)
        timeVC.view.frame.size = CGSize(width: view.frame.width, height: view.frame.height/1.5)
        timeVC.view.center = view.center
        timeVC.view.layer.cornerRadius = 12
        setupButtons(timeVC.view, timeVC.cancelBtn, timeVC.doneBtn, timeVC.clearBtn)
    }
    
    private func setupButtons(_ view:UIView, _ cancelBtn:UIButton, _ doneBtn:UIButton, _ clearBtn:UIButton) {
        // buttons
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/6).isActive = true
        doneBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width/6).isActive = true
        cancelBtn.tintColor = K.primaryLightColor
        doneBtn.tintColor = K.primaryLightColor
        clearBtn.tintColor = K.primaryLightColor
        // separatorImageView
        let separatorImageView = UIImageView()
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorImageView.frame.size = CGSize(width: 40, height: 20)
        separatorImageView.tintColor = K.lightGray
        separatorImageView.alpha = 0.2
        separatorImageView.image = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight, scale: .large))
        view.addSubview(separatorImageView)
        separatorImageView.transform = separatorImageView.transform.rotated(by: .pi/2)
        NSLayoutConstraint.activate([
            separatorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            separatorImageView.topAnchor.constraint(equalTo: cancelBtn.topAnchor)
        ])
    }
    
    private func dismissCalendar() {
        view.alpha = 0
        view.isHidden = true
        if par.todoCardVC.todo != nil {par.handleEdit()}
        else {par.addTodo(par.todoCardVC.todoTextField.text)}
    }
    
    @objc private func dismissTime() {
        timeVC.view.alpha = 0
        timeVC.view.isHidden = true
    }
    
    @IBAction private func cancel(_ sender: UIButton) {
        dismissCalendar()
    }
    
    @IBAction private func done(_ sender: UIButton) {
        dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: calendar.selectedDate!)
        if timeComponents != nil {
            dateComponents.hour = timeComponents!.hour
            dateComponents.minute = timeComponents!.minute
            par.todoCardVC.blnTime = true
        }
        par.todoCardVC.dtmDue = Calendar.current.date(from: dateComponents)
        dismissCalendar()
        par.todoCardVC.refreshCard()
    }
    
    @IBAction private func clear(_ sender: UIButton) {
        dateComponents = nil
        par.todoCardVC.dtmDue = nil
        par.todoCardVC.blnTime = false
        dismissCalendar()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectColor = F.startOfDay(for: date) < F.startOfDay(for: Date()) ? K.red : K.primaryLightColor
        calendar.appearance.selectionColor = selectColor
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for todo in par.todos where todo.dtmDue != nil {
            if F.startOfDay(for: date) == F.startOfDay(for: todo.dtmDue!) {return 1}
        }
        return 0
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        var image:UIImage!
        var titleText:String!
        var detailText:String! = "None"
        if timeComponents != nil {
            let time = Calendar.current.date(from: timeComponents!)!
            detailText = F.timeFormatter.string(from: time)
        }
        if indexPath.row == 0 {
            image = UIImage(systemName: "clock.fill")
            titleText = "Time"
        }
        // TODO: Recurring tasks
//        else if indexPath.row == 1 {
//            image = UIImage(systemName: "arrow.2.circlepath")
//            titleText = "Repeat"
//        }
        cell.iconImage.image = image
        cell.titleLabel.text = titleText
        cell.detailLabel.text = detailText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        calendarTable.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            var currentTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
            currentTimeComponents.minute = Int(round(Float(currentTimeComponents.minute!)/5.0) * 5.0)
            if timeComponents != nil {
                timeVC.timePicker.date = Calendar.current.date(from: timeComponents!)!
            } else {
                timeVC.timePicker.date = Calendar.current.date(from: currentTimeComponents)!
            }
            timeVC.view.isHidden = false
            dimView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.timeVC.view.alpha = 1
                self.dimView.alpha = 1
            }
        }
    }
    
}
