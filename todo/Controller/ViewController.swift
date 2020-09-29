//
//  ViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 8/30/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: TodoTableView!
    @IBOutlet weak var addTodoBtn: UIButton!
    @IBOutlet weak var undoDeleteBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var completedCount: UILabel!
    @IBOutlet weak var goalCount: UILabel!
    
    var audioPlayer = AVAudioPlayer()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var today:[Todo] = []
    var inbox:[Todo] = []
    var upcoming:[Todo] = []
    var completed:[Todo] = []
    var todoSections:[[Todo]] = []
    
    var activeTimer:[String:Any?] = ["todo":nil, "min":0, "sec":0,
                                     "session":1, "strokeEnd":0,
                                     "mode":"focus", "blnStarted": false,
                                     "canComplete":false, "active":false]
    
    var keyboardHeight:CGFloat! = 0
    var todoCardVC:TodoCardViewController!
    var rescheduleVC:RescheduleViewController!
    var calendarVC:CalendarViewController!
    var dimView:UIView!
    var cardHeight:CGFloat! = 175
    
    override func loadView() {
        super.loadView()
        initSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView setup
        todoTableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        // Core Data: Todo setup
        context.undoManager = UndoManager()
        fetchTodos()
        
        // Keyboard Handler
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Audio setup
        audioPlayer = try! AVAudioPlayer(contentsOf: K.completeDingURL)
        audioPlayer.prepareToPlay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if undoDeleteBtn.frame.origin.x == -100 {dismissUndo()}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        archiveCompletedTodos()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Class functions
    func fetchTodos() {
        
        let todos = try! context.fetch(Todo.fetchRequest()) as! [Todo]
        
        today = todos.filter {
            if let dtmDue = $0.dtmDue {
                if dtmDue < K.tomorrow && $0.dtmCompleted == nil {
                    return true
                }
            }
            return false
        }
        today = sort(today, byPriority: false)
        
        inbox = todos.filter {
            $0.dtmCompleted == nil && $0.dtmDue == nil
        }
        inbox = sort(inbox, byPriority: true)
        
        upcoming = todos.filter {
            if let dtmDue = $0.dtmDue {
                if dtmDue >= K.tomorrow && $0.dtmCompleted == nil {
                    return true
                }
            }
            return false
        }
        upcoming = sort(upcoming, byPriority: true)
        
        completed = todos.filter {
            $0.dtmCompleted != nil
        }
        completed.sort {
            $0.dtmCompleted! < $1.dtmCompleted!
        }

        todoSections = [today, inbox, upcoming, completed]
        
        todoTableView.reloadData()
        
        DispatchQueue.main.async {
            self.goalCount.text = "\(max(5, self.today.count + self.completed.count))"
            self.completedCount.text = "\(self.completed.count)"
        }
    }
    
    private func copyOf(_ todo:Todo) -> Todo {
        let copy = Todo(context: context)
        copy.blnStarred = todo.blnStarred
        copy.blnTime = todo.blnTime
        copy.dtmCompleted = todo.dtmCompleted
        copy.dtmCreated = todo.dtmCreated
        copy.dtmDue = todo.dtmDue
        copy.recur = todo.recur
        copy.text = todo.text
        return copy
    }
    
    private func sort(_ todos:[Todo], byPriority:Bool) -> [Todo] {
        var sortedTodos = todos
        sortedTodos.sort {$0.dtmCreated! < $1.dtmCreated!}
        if !byPriority {sortedTodos.sort {$0.blnStarred && !$1.blnStarred}}
        sortedTodos.sort {
            if var zero = $0.dtmDue, var one = $1.dtmDue {
                if !$0.blnTime {zero = F.endOfDay(for: zero)}
                if !$1.blnTime {one = F.endOfDay(for: one)}
                return zero < one
            }
            return false
        }
        if byPriority {sortedTodos.sort {$0.blnStarred && !$1.blnStarred}}
        return sortedTodos
    }
    
    private func archiveCompletedTodos() {
        fetchTodos()
        for todo in completed {
            if F.startOfDay(for: todo.dtmCompleted!) >= F.startOfDay(for: Date()) {continue}
            let archivedTodo = ArchivedTodo(context: context)
            archivedTodo.text = todo.text
            archivedTodo.blnStarred = todo.blnStarred
            archivedTodo.dtmCompleted = todo.dtmCompleted!
            archivedTodo.dtmDue = todo.dtmDue
            archivedTodo.dtmCreated = todo.dtmCreated
            archivedTodo.blnTime = todo.blnTime
            archivedTodo.recur = todo.recur
            self.context.delete(todo)
            try! self.context.save()
        }
    }
    
    private func initSubviews() {
        headerView.heightAnchor.constraint(equalToConstant: view.frame.height/8).isActive = true
        dimView = F.setupDimView(for: self, with: #selector(handleDismiss))
        
        // todoCardVC setup
        todoCardVC = TodoCardViewController(nibName: "TodoCard", bundle: nil)
        self.addChild(todoCardVC)
        view.addSubview(todoCardVC.view)
        todoCardVC.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: cardHeight)
        todoCardVC.view.layer.cornerRadius = 12
        
        // rescheduleVC setup
        rescheduleVC = RescheduleViewController(nibName: "RescheduleView", bundle: nil)
        self.addChild(rescheduleVC)
        view.addSubview(rescheduleVC.view)
        rescheduleVC.view.alpha = 0
        rescheduleVC.view.frame.size = CGSize(width: view.frame.width-50, height: view.frame.width/2)
        rescheduleVC.view.center = view.center
        rescheduleVC.view.layer.cornerRadius = 12
        
        // calendarVC setup
        calendarVC = CalendarViewController(nibName: "CalendarView", bundle: nil)
        self.addChild(calendarVC)
        view.addSubview(calendarVC.view)
        calendarVC.view.alpha = 0
        calendarVC.view.frame.size = CGSize(width: view.frame.width-50, height: 600)
        calendarVC.view.center = view.center
        calendarVC.view.layer.cornerRadius = 12
        
        
        // Gesture recognizer setup
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeGestureRecognizer.direction = .down
        let tapGestureRecogizer = UITapGestureRecognizer(target: self, action: #selector(dismissUndo))
        tapGestureRecogizer.cancelsTouchesInView = false
        todoCardVC.handleArea.addGestureRecognizer(swipeGestureRecognizer)
        addTodoBtn.addGestureRecognizer(tapGestureRecogizer)
        
        undoDeleteBtn.frame.origin.x = -100
    }
    
    func handleEdit() {
        todoCardVC.todoTextView.isHidden = false
        todoCardVC.todoTextField.isHidden = true
        dimView.isHidden = false
        todoCardVC.todoTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.keyboardHeight - self.cardHeight + 10
            self.dimView.alpha = 1
        })
    }
    
    // MARK: - @objc functions
    @objc func handleDismiss() {
        if todoCardVC.view.frame.origin.y < view.frame.height {
            todoCardVC.todoTextField.resignFirstResponder()
            todoCardVC.todoTextView.resignFirstResponder()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.todoCardVC.view.frame.origin.y = self.view.frame.height
            })
        } else {
            rescheduleVC.view.isHidden = true
            calendarVC.view.isHidden = true
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
        })
        dimView.isHidden = true
    }
    
    @objc func handleKeyboardShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    
    @objc func handleKeyboardHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.todoCardVC.view.frame.origin.y = self.view.frame.height
            })
        }
    }
    
    @objc public func dismissUndo() {
        if undoDeleteBtn.frame.origin.x == 20 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.undoDeleteBtn.frame.origin.x = -100
            })
            try! self.context.save()
            self.fetchTodos()
        }
    }
    
    // MARK: - @IBAction functions
    @IBAction func addTodo(_ sender: Any?) {
        todoCardVC.todo = nil
        DispatchQueue.main.async {
            if let text = sender as? String {
                self.todoCardVC.todoTextField.text = text
            } else {self.todoCardVC.setupCard()}
            self.todoCardVC.todoTextView.isHidden = true
            self.todoCardVC.todoTextField.isHidden = false
            self.dimView.isHidden = false
            self.todoCardVC.todoTextField.placeholder = K.addTodoPhrases.randomElement()
        }
        todoCardVC.todoTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.keyboardHeight - self.cardHeight + 45
            self.dimView.alpha = 1
        })
        if UserDefaults.standard.bool(forKey: "todaySelected") {
            DispatchQueue.main.async {
                self.todoCardVC.dtmDue = Date()
                self.todoCardVC.refreshCard()
            }
        }
    }
    
    @IBAction func undoDelete(_ sender: UIButton) {
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.undoDeleteBtn.frame.origin.x = -100
        })
        self.context.undo()
        try! self.context.save()
        self.fetchTodos()
    }
    
    @IBAction func unwindFromFocus(_ segue: UIStoryboardSegue) {
        let source = segue.source as! FocusViewController
        if segue.identifier == "CompleteTask" {
            source.todo.dtmCompleted = Date()
            try! self.context.save()
            self.fetchTodos()
        } else if segue.identifier == "ExitFocus" {
            activeTimer = ["todo":source.todo, "min":source.minutes, "sec":source.seconds,
                           "strokeEnd":source.strokeEnd, "session":source.currentSession,
                           "mode":source.mode, "canComplete":source.canComplete,
                           "blnStarted":source.blnStarted, "active":true]
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

// MARK: - Extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TodoHeaderView()
        headerView.tableView = tableView
        headerView.setupHeaderView(for: K.todoSectionNames[section],
                                   sectionCount: todoSections[section].count)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 1 && todoSections[section].count == 0 {
            return 0
        }
        return tableView.sectionHeaderHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == K.todoSectionNames.firstIndex(of: "upcoming") && !UserDefaults.standard.bool(forKey: "showUpcoming") {
            return 0
        } else if section == K.todoSectionNames.firstIndex(of: "completed") && !UserDefaults.standard.bool(forKey: "showCompleted") {
            return 0
        }
        return todoSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let todo = todoSections[indexPath.section][indexPath.row]
        cell.delegate = self
        cell.setupCell(todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print(todoSections[indexPath.section][indexPath.row].description)
        if indexPath.section == K.todoSectionNames.firstIndex(of: "completed") {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleEdit()
        todoCardVC.todo = todoSections[indexPath.section][indexPath.row]
        todoCardVC.setupCard()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            self.context.delete(self.todoSections[indexPath.section][indexPath.row])
            self.fetchTodos()
            self.undoDeleteBtn.frame.origin.y = self.addTodoBtn.frame.origin.y
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.undoDeleteBtn.frame.origin.x = 20
            })
            self.view.bringSubviewToFront(self.undoDeleteBtn)
        }
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: imgConfig)
        
        let reschedule = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.rescheduleVC.todo = self.todoSections[indexPath.section][indexPath.row]
            self.dimView.isHidden = false
            self.rescheduleVC.view.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0, animations: {
                self.dimView.alpha = 1
                self.rescheduleVC.view.alpha = 1
            })
            completionHandler(true)
        }
        reschedule.image = UIImage(systemName: "calendar", withConfiguration: imgConfig)
        reschedule.backgroundColor = K.secondaryLightColor
        
        let focus = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.performSegue(withIdentifier: "FocusSegue", sender: self.todoSections[indexPath.section][indexPath.row])
            completionHandler(true)
        }
        focus.image = UIImage(systemName: "timer", withConfiguration: imgConfig)
        focus.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.5843137255, blue: 0.6, alpha: 1)
        
        if indexPath.section == K.todoSectionNames.firstIndex(of: "completed") {
            return UISwipeActionsConfiguration(actions: [delete])
        }
        return UISwipeActionsConfiguration(actions: [delete, reschedule, focus])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "FocusSegue" {
            if let vc = segue.destination as? FocusViewController {
                let todo = sender as? Todo
                vc.todo = todo
                if todo == activeTimer["todo"] as? Todo {
                    vc.minutes = activeTimer["min"] as! Int
                    vc.seconds = activeTimer["sec"] as! Int
                    vc.currentSession = activeTimer["session"] as! Int
                    vc.mode = activeTimer["mode"] as! String
                    vc.canComplete = activeTimer["canComplete"] as! Bool
                    vc.strokeEnd = activeTimer["strokeEnd"] as! CGFloat
                    vc.blnStarted = activeTimer["blnStarted"] as! Bool
                    vc.active = activeTimer["active"] as! Bool
                }
            }
        }
    }
    
}

extension ViewController: CellDelegate {
    func didCheck(_ cell:TodoCell) {
        dismissUndo()
        if let indexPath = todoTableView.indexPath(for: cell) {
            let todo = todoSections[indexPath.section][indexPath.row]
            if todo.dtmCompleted == nil {
                if let dtmDue = todo.dtmDue {
                    var newDtmDue:Date?
                    switch todo.recur {
                    case "None":
                        break
                    case "Daily":
                        newDtmDue = Calendar.current.date(byAdding: .day, value: 1, to: dtmDue)
                    case "Weekdays":
                        repeat {
                            newDtmDue = Calendar.current.date(byAdding: .day, value: 1, to: dtmDue)
                        } while Calendar.current.isDateInWeekend(newDtmDue!)
                    case "Weekly":
                        newDtmDue = Calendar.current.date(byAdding: .day, value: 7, to: dtmDue)
                    case "Monthly":
                        newDtmDue = Calendar.current.date(byAdding: .day, value: 35, to: dtmDue)
                    default:
                        print("No case found for \(todo.recur)")
                    }
                    if newDtmDue != nil {
                        let newTodo = copyOf(todo)
                        newTodo.dtmCreated = Date()
                        newTodo.dtmDue = newDtmDue
                    }
                }
                todo.dtmCompleted = Date()
                if Int(completedCount.text!)! != Int(goalCount.text!)! - 1 {
                    audioPlayer.currentTime = 0
                    audioPlayer.play()
                    F.feedback(.rigid)
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(1262))
                }
            } else {todo.dtmCompleted = nil}
            try! self.context.save()
            self.fetchTodos()
        }
    }
}

class TodoTableView: UITableView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let del = delegate as! ViewController
        if del.undoDeleteBtn.frame.origin.x == 20 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                del.undoDeleteBtn.frame.origin.x = -100
            })
            try! del.context.save()
            del.fetchTodos()
        }
    }
}
