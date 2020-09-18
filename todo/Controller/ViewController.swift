//
//  ViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 8/30/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: TodoTableView!
    @IBOutlet weak var addTodoBtn: UIButton!
    @IBOutlet weak var undoDeleteBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var completedCount: UILabel!
    @IBOutlet weak var goalCount: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todos: [Todo] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.heightAnchor.constraint(equalToConstant: view.frame.height/8).isActive = true
        // tableView setup
        todoTableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        // Core Data: Todo setup
        context.undoManager = UndoManager()
        archiveCompleted()
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
        
        initSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissUndo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Class functions
    func fetchTodos() {
        todos = try! context.fetch(Todo.fetchRequest())
        DispatchQueue.main.async {
            self.todos.sort {$0.dtmCreated! < $1.dtmCreated!}
            self.todos.sort {
                if $0.dtmDue != nil && $1.dtmDue == nil {return true}
                if let zero = $0.dtmDue, let one = $1.dtmDue {return zero < one}
                return false
            }
            self.todos.sort {$0.blnStarred && !$1.blnStarred}
            self.todos.sort {
                if $0.dtmCompleted == nil && $1.dtmCompleted != nil {return true}
                if let zero = $0.dtmCompleted, let one = $1.dtmCompleted {return zero < one}
                return false
            }
            self.todoTableView.reloadData()
        }
        goalCount.text = "\(max(5, todos.count))"
        let completed = todos.filter { todo in
            if todo.dtmCompleted != nil {
                return true
            }
            return false
        }
        completedCount.text = "\(completed.count)"
    }
    
    private func archiveCompleted() {
        todos = try! context.fetch(Todo.fetchRequest())
        for todo in todos {
            if let dtmCompleted = todo.dtmCompleted {
                let dC = K.startOfDay(for: dtmCompleted)
                let today = K.startOfDay(for: Date())
                if dC >= today {continue}
                DispatchQueue.main.async {
                    let archivedTodo = ArchivedTodo(context: self.context)
                    archivedTodo.text = todo.text
                    archivedTodo.blnStarred = todo.blnStarred
                    archivedTodo.dtmCompleted = todo.dtmCompleted
                    archivedTodo.dtmDue = todo.dtmDue
                    archivedTodo.dtmCreated = todo.dtmCreated
                    self.context.delete(todo)
                    try! self.context.save()
                }
            }
        }
    }
    
    private func initSubviews() {
        // dimView setup
        dimView = UIView()
        dimView.frame = view.frame
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimView.alpha = 0
        dimView.isHidden = true
        
//         invisibleView setup
//        invisibleView = UIView()
//        invisibleView.frame = view.frame
//        view.addSubview(invisibleView)
//        invisibleView.backgroundColor = UIColor(white: 1, alpha: 0)
//        invisibleView.isHidden = true
        
        // todoCardVC setup
        todoCardVC = TodoCardViewController(nibName: "TodoCard", bundle: nil)
        self.addChild(todoCardVC)
        view.addSubview(todoCardVC.view)
        todoCardVC.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: cardHeight)
        todoCardVC.view.clipsToBounds = true
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
        calendarVC.view.frame.size = CGSize(width: view.frame.width-50, height: view.frame.height/1.5)
        calendarVC.view.center = view.center
        calendarVC.view.layer.cornerRadius = 12
        
        
        // Gesture recognizer setup
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeGestureRecognizer.direction = .down
        let tapGestureRecogizer = UITapGestureRecognizer(target: self, action: #selector(dismissUndo))
        tapGestureRecogizer.cancelsTouchesInView = false

        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        todoCardVC.handleArea.addGestureRecognizer(swipeGestureRecognizer)
        addTodoBtn.addGestureRecognizer(tapGestureRecogizer)
        
        undoDeleteBtn.frame.origin.x = -100
    }
    
    private func setupCard(with todos:[Todo], at index:Int) {
        // Set up todoCard with todo's properties
        let todo = todos[index]
        todoCardVC.index = index
        todoCardVC.todoTextView.text = todo.text
        todoCardVC.blnStarred = todo.blnStarred
        if todo.dtmDue != nil {
            todoCardVC.blnDue = true
//            todoCardVC.datePicker.date = todo.dtmDue!
        }
    }
    
    func handleEditTodo() {
        todoCardVC.todoTextView.isHidden = false
        todoCardVC.todoTextField.isHidden = true
        dimView.isHidden = false
        todoCardVC.todoTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.keyboardHeight - self.cardHeight + 10
            self.dimView.alpha = 1
        })
    }
    
    // MARK: @objc functions
    @objc func handleDismiss() {
        if todoCardVC.view.frame.origin.y < view.frame.height {
            todoCardVC.todoTextField.resignFirstResponder()
            todoCardVC.todoTextView.resignFirstResponder()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.todoCardVC.view.frame.origin.y = self.view.frame.height
            })
            // Reset todoCard
            todoCardVC.blnDue = false
            todoCardVC.blnStarred = false
            todoCardVC.todoTextField.text = ""
            todoCardVC.index = nil
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
            DispatchQueue.main.async {
                try! self.context.save()
                self.fetchTodos()
            }
        }
    }
    
    // MARK: @IBAction functions
    @IBAction func addTodo(_ sender: Any?) {
        todoCardVC.todoTextView.isHidden = true
        todoCardVC.todoTextField.isHidden = false
        dimView.isHidden = false
        todoCardVC.todoTextField.placeholder = K.addTodoPhrases.randomElement()
        todoCardVC.todoTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.keyboardHeight - self.cardHeight + 45
            self.dimView.alpha = 1
        })
    }
    
    @IBAction func undoDelete(_ sender: UIButton) {
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.undoDeleteBtn.frame.origin.x = -100
        })
        DispatchQueue.main.async {
            self.context.undo()
            try! self.context.save()
            self.fetchTodos()
        }
    }
    
    @IBAction func unwindFromFocus(_ segue: UIStoryboardSegue) {
        let source = segue.source as! FocusViewController
        if segue.identifier == "CompleteTask" {
            DispatchQueue.main.async {
                source.todo.dtmCompleted = Date()
                try! self.context.save()
                self.fetchTodos()
            }
        } else if segue.identifier == "ExitFocus" {
            activeTimer = ["todo":source.todo, "min":source.minutes, "sec":source.seconds,
                           "strokeEnd":source.strokeEnd, "session":source.currentSession,
                           "mode":source.mode, "canComplete":source.canComplete,
                           "blnStarted":source.blnStarted, "active":true]
        }
    }
}

// MARK: extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let todo = todos[indexPath.row]
        cell.delegate = self
        cell.setupCell(todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print(todos[indexPath.row].description)
        if todos[indexPath.row].dtmCompleted != nil {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupCard(with: todos, at: indexPath.row)
        handleEditTodo()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Delete
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            self.context.delete(self.todos[indexPath.row])
            self.fetchTodos()
            self.undoDeleteBtn.frame.origin.y = self.addTodoBtn.frame.origin.y
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.undoDeleteBtn.frame.origin.x = 20
            })
            self.view.bringSubviewToFront(self.undoDeleteBtn)
        }
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: imgConfig)
        // Reschedule
        let reschedule = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.rescheduleVC.index = indexPath.row
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
        // Focus
        let focus = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.performSegue(withIdentifier: "FocusSegue", sender: self.todos[indexPath.row])
            completionHandler(true)
        }
        focus.image = UIImage(systemName: "timer", withConfiguration: imgConfig)
        focus.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.5843137255, blue: 0.6, alpha: 1)
        if todos[indexPath.row].dtmCompleted != nil {
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
        if let index = todoTableView.indexPath(for: cell)?.row {
            let todo = todos[index]
            DispatchQueue.main.async {
                todo.dtmCompleted = todo.dtmCompleted == nil ? Date() : nil
                try! self.context.save()
                self.fetchTodos()
            }
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
            DispatchQueue.main.async {
                try! del.context.save()
                del.fetchTodos()
            }
        }
    }
}
