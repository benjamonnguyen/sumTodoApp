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
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    var separator = UIImageView()
    
    var text:String?
    var dateComponents:DateComponents!
    var timeComponents:DateComponents?
    var recur:String!
    var par:ViewController!
    
    var timeVC:TimeViewController!
    var dimView:UIView!
    
    override func loadView() {
        super.loadView()
        setupButtons(view, cancelBtn, doneBtn, clearBtn, separator)
        cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/6.5).isActive = true
        initSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! ViewController)
        //calendar
        calendarTableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        calendar.dataSource = self
        calendar.delegate = self
        calendarTableView.dataSource = self
        calendarTableView.delegate = self
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
        timeVC.view.frame.size = CGSize(width: view.frame.width, height: 450)
        timeVC.recurTableView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        timeVC.recurTableView.widthAnchor.constraint(equalTo: timeVC.view.widthAnchor).isActive = true
        timeVC.view.center = view.center
        timeVC.view.layer.cornerRadius = 12
        setupButtons(timeVC.view, timeVC.cancelBtn, timeVC.doneBtn, timeVC.clearBtn, timeVC.separator)
    }
    
    private func setupButtons(_ view:UIView, _ cancelBtn:UIButton, _ doneBtn:UIButton, _ clearBtn:UIButton, _ separator:UIImageView) {
        // buttons
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.tintColor = K.primaryLightColor
        doneBtn.tintColor = K.primaryLightColor
        clearBtn.tintColor = K.primaryLightColor
        // separatorImageView
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.frame.size = CGSize(width: 40, height: 20)
        separator.tintColor = K.lightGray
        separator.alpha = 0.2
        separator.image = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight, scale: .large))
        view.addSubview(separator)
        separator.transform = separator.transform.rotated(by: .pi/2)
        
        NSLayoutConstraint.activate([
            doneBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width/6.5),
            separator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            separator.centerYAnchor.constraint(equalTo: cancelBtn.centerYAnchor)
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
        dimView.alpha = 0
        dimView.isHidden = true
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
        par.todoCardVC.recur = recur
        par.todoCardVC.refreshCard()
        dismissCalendar()
    }
    
    @IBAction private func clear(_ sender: UIButton) {
        dateComponents = nil
        par.todoCardVC.dtmDue = nil
        par.todoCardVC.blnTime = false
        par.todoCardVC.refreshCard()
        dismissCalendar()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectColor = F.startOfDay(for: date) < F.startOfDay(for: Date()) ? K.red : K.primaryLightColor
        calendar.appearance.selectionColor = selectColor
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
            if let tC = timeComponents {
                detailText = F.timeFormatter.string(from: Calendar.current.date(from: tC)!)
            }
        } else if indexPath.row == 1 {
            image = UIImage(systemName: "arrow.2.circlepath")
            titleText = "Repeat"
            if let recur = self.recur {
                detailText = recur
            }
        }
        cell.iconImage.image = image
        cell.titleLabel.text = titleText
        cell.detailLabel.text = detailText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        calendarTableView.deselectRow(at: indexPath, animated: true)
        timeVC.cancelBtnXConstraint.isActive = false
        if indexPath.row == 0 {
            var currentTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
            currentTimeComponents.minute = Int(round(Float(currentTimeComponents.minute!)/5.0) * 5.0)
            if let tC = timeComponents {
                timeVC.timePicker.date = Calendar.current.date(from: tC)!
            } else {
                timeVC.timePicker.date = Calendar.current.date(from: currentTimeComponents)!
            }
            timeVC.setupTimeView(for: indexPath.row)
            dimView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.timeVC.view.alpha = 1
                self.dimView.alpha = 1
            }
        } else if indexPath.row == 1 {
            timeVC.setupTimeView(for: indexPath.row)
            dimView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.timeVC.view.alpha = 1
                self.dimView.alpha = 1
            }
            timeVC.recurTableView.reloadData()
        }
    }
    
}
