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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todos: [Todo] = []
    
    var cardViewController:CardViewController!
    var dimView:UIView!
    var cardVisible = false
    var keyboardVisible = false
    var cardHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView setup
        todoTableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        // Get items from Core Data
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
    
    func fetchTodos() {
        todos = try! context.fetch(Todo.fetchRequest())
        DispatchQueue.main.async {
            //Sort
            self.todos.sort {$0.dtmCreated! < $1.dtmCreated!}
            self.todos.sort {$0.blnStarred && !$1.blnStarred}
                
            self.todoTableView.reloadData()
        }
    }
    
    func initCard() {
        // dimView setup
        dimView = UIView()
        dimView.frame = view.frame
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimView.alpha = 0
        dimView.isHidden = true
        
        // cardViewController setup
        cardViewController = CardViewController(nibName: "CardView", bundle: nil)
        self.addChild(cardViewController)
        view.addSubview(cardViewController.view)
        
        // cardView setup
        cardHeight = self.view.frame.height/2
        cardViewController.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        cardViewController.view.layer.cornerRadius = 12
        
        // Gesture recognizer setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeGestureRecognizer.direction = .down
        dimView.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func setupCard(with todos:[Todo], at index:Int) {
        // Set up cardView with todo's properties
        let todo = todos[index]
        cardViewController.index = index
        cardViewController.todoTextField.text = todo.text
        cardViewController.blnStarred = todo.blnStarred
        if todo.dtmDue != nil {
            cardViewController.blnDue = true
            cardViewController.datePicker.date = todo.dtmDue!
        }
    }
    
    func handleCard() {
        if cardVisible {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.cardViewController.view.frame.origin.y = self.view.frame.height
                self.dimView.isHidden = true
                self.dimView.alpha = 0
            })
            // Reset cardView
            self.cardViewController.blnDue = false
            self.cardViewController.blnStarred = false
            self.cardViewController.todoTextField.text = ""
            self.cardViewController.index = nil
        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                if !self.cardViewController.todoTextField.isFirstResponder {
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                }
                self.dimView.isHidden = false
                self.dimView.alpha = 1
            })
        }
        cardVisible = !cardVisible
    }
    
    @objc func handleDismiss() {
        cardViewController.todoTextField.resignFirstResponder()
        handleCard()
    }
    
    @objc func handleKeyboardShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - keyboardHeight - 130
                })
        }
    }
    
    @objc func handleKeyboardHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
            })
        }
    }
    
    @IBAction func addTodo(_ sender: UIButton) {
        cardViewController.todoTextField.becomeFirstResponder()
        handleCard()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setupCard(with: todos, at: indexPath.row)
        handleCard()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.context.delete(self.todos[indexPath.row])
            try! self.context.save()
            self.fetchTodos()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ViewController: CellDelegate {
    func didCheck(_ cell:TodoCell) {
        if let index = todoTableView.indexPath(for: cell)?.row {
            let todo = todos[index]
            todo.dtmCompleted = todo.dtmCompleted == nil ? Date() : nil
            try! context.save()
            fetchTodos()
        }
    }
}
