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

    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addTodoBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todos: [Todo] = []
    var taskText:String?
    
    var todoCardVC:TodoCardViewController!
    var rescheduleCardVC:RescheduleCardViewController!
    var dimView:UIView!
    var cardHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.heightAnchor.constraint(equalToConstant: view.frame.height/8).isActive = true
        // tableView setup
        todoTableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        // Get items from Core Data
        archiveCompleted()
        fetchTodos()
        
        // Set button size based on screen width?
        let buttonSize = view.frame.width/6
        addTodoBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: buttonSize), forImageIn: .normal)
        
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
        
        initCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
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
    }
    
    private func archiveCompleted() {
        todos = try! context.fetch(Todo.fetchRequest())
        for todo in todos {
            if let dtmCompleted = todo.dtmCompleted {
                let dC = Calendar.current.startOfDay(for: dtmCompleted)
                let today = Calendar.current.startOfDay(for: Date())
                if dC >= today {continue}
                DispatchQueue.main.async {
                    let archivedTodo = ArchivedTodo(context: self.context)
                    archivedTodo.blnStarred = todo.blnStarred
                    archivedTodo.dtmCompleted = todo.dtmCompleted
                    archivedTodo.dtmCreated = todo.dtmCreated
                    archivedTodo.text = todo.text
                    archivedTodo.dtmDue = todo.dtmDue
                    self.context.delete(todo)
                    try! self.context.save()
                }
            }
        }
    }
    
    private func initCard() {
        // dimView setup
        dimView = UIView()
        dimView.frame = view.frame
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimView.alpha = 0
        dimView.isHidden = true
        
        // todoCardVC setup
        todoCardVC = TodoCardViewController(nibName: "TodoCard", bundle: nil)
        self.addChild(todoCardVC)
        view.addSubview(todoCardVC.view)
        cardHeight = self.view.frame.height/2
        todoCardVC.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: cardHeight)
        todoCardVC.view.clipsToBounds = true
        todoCardVC.view.layer.cornerRadius = 12
        
        // rescheduleCardVC setup
        rescheduleCardVC = RescheduleCardViewController(nibName: "RescheduleCard", bundle: nil)
        self.addChild(rescheduleCardVC)
        view.addSubview(rescheduleCardVC.view)
        rescheduleCardVC.view.isHidden = true
        rescheduleCardVC.view.frame.size = CGSize(width: view.frame.width-50, height: view.frame.width/2)
        rescheduleCardVC.view.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        rescheduleCardVC.view.clipsToBounds = true
        rescheduleCardVC.view.layer.cornerRadius = 12
        
        // Gesture recognizer setup
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeGestureRecognizer.direction = .down
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        todoCardVC.handleArea.addGestureRecognizer(swipeGestureRecognizer)
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
    
    private func handleEditTodo() {
        todoCardVC.todoTextView.isHidden = false
        todoCardVC.todoTextField.isHidden = true
        todoCardVC.todoTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.cardHeight*1.275
            self.dimView.isHidden = false
            self.dimView.alpha = 1
        })
    }
    
    @objc func handleDismiss() {
        if todoCardVC.view.frame.origin.y < view.frame.height {
            todoCardVC.todoTextField.resignFirstResponder()
            todoCardVC.todoTextView.resignFirstResponder()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.todoCardVC.view.frame.origin.y = self.view.frame.height
                self.dimView.isHidden = true
                self.dimView.alpha = 0
            })
            // Reset todoCard
            todoCardVC.blnDue = false
            todoCardVC.blnStarred = false
            todoCardVC.todoTextField.text = ""
            todoCardVC.index = nil
        } else {
            rescheduleCardVC.view.isHidden = true
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.dimView.isHidden = true
            self.dimView.alpha = 0
        })
    }

    @objc func handleKeyboardShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.todoCardVC.view.frame.origin.y = self.view.frame.height - keyboardHeight - 130
                })
        }
    }
    
    @objc func handleKeyboardHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.todoCardVC.view.frame.origin.y = self.view.frame.height - self.cardHeight
            })
        }
    }
    
    @IBAction private func addTodo(_ sender: UIButton) {
        todoCardVC.todoTextView.isHidden = true
        todoCardVC.todoTextField.isHidden = false
        todoCardVC.todoTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.dimView.isHidden = false
            self.dimView.alpha = 1
        })
    }
    
}

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
            try! self.context.save()
            self.fetchTodos()
        }
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        delete.image = UIImage(systemName: "trash.fill", withConfiguration: imgConfig)
        // Reschedule
        let reschedule = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.rescheduleCardVC.index = indexPath.row
            self.dimView.isHidden = false
            self.dimView.alpha = 1
            self.rescheduleCardVC.view.isHidden = false
            completionHandler(true)
        }
        reschedule.image = UIImage(systemName: "calendar", withConfiguration: imgConfig)
        reschedule.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        // Focus
        let focus = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            self.taskText = self.todos[indexPath.row].text
            self.performSegue(withIdentifier: "FocusSegue", sender: nil)
            completionHandler(true)
        }
        focus.image = UIImage(systemName: "timer", withConfiguration: imgConfig)
        focus.backgroundColor = UIColor(red: 0.180, green: 0.584, blue: 0.600, alpha: 0.9000)
        if todos[indexPath.row].dtmCompleted != nil {
            return UISwipeActionsConfiguration(actions: [delete])
        }
        return UISwipeActionsConfiguration(actions: [delete, reschedule, focus])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FocusSegue" {
            if let vc = segue.destination as? FocusViewController {
                vc.taskLabelText = taskText
            }
        }
    }
    
}

extension ViewController: CellDelegate {
    func didCheck(_ cell:TodoCell) {
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
