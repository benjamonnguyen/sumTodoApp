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

    @IBOutlet weak var todayTableView: UITableView!
    @IBOutlet weak var addTodoBtn: UIButton!
    @IBOutlet weak var togglePlannerBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todos: [Todo] = []
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    var cardExpanded = false
    var cardHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        todayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
        todayTableView.delegate = self
        todayTableView.dataSource = self
        
        // Get items from Core Data
        fetchTodos()
        
        // Set button size based on screen width?
        let buttonSize = view.frame.width/6
        addTodoBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: buttonSize), forImageIn: .normal)
        togglePlannerBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: buttonSize), forImageIn: .normal)
        
        setupCard()
    }
    
    func fetchTodos() {
        todos = try! context.fetch(Todo.fetchRequest())
        DispatchQueue.main.async {
            self.todayTableView.reloadData()
        }
    }
    
    func setupCard() {
        // visualEffectView setup
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = view.frame
        view.addSubview(visualEffectView)
        visualEffectView.effect = UIBlurEffect(style: .dark)
        visualEffectView.alpha = 0.4
        visualEffectView.isHidden = true
        
        // cardViewController setup
        cardViewController = CardViewController(nibName: "CardView", bundle: nil)
        self.addChild(cardViewController)
        view.addSubview(cardViewController.view)
        
        // cardView setup
        cardHeight = self.view.frame.height/2
        cardViewController.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: cardHeight)
        cardViewController.view.layer.cornerRadius = 12
        
        // Gesture recognizer setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeGestureRecognizer.direction = .down
        visualEffectView.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func handleCard() {
        if cardExpanded {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.cardViewController.view.frame.origin.y = self.view.frame.height
                self.cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.cardHeight)
                self.visualEffectView.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - self.cardHeight, width: self.view.frame.width, height: self.cardHeight)
                self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                self.visualEffectView.isHidden = false
            })
        }
        cardExpanded = !cardExpanded
    }
    
    @objc func handleTap() {
        if cardViewController.todoTextField.isFirstResponder {
            cardViewController.todoTextField.resignFirstResponder()
        } else {
            handleCard()
        }
    }
    
    @objc func handleSwipeDown() {
        cardViewController.todoTextField.resignFirstResponder()
        handleCard()
    }
    
    @IBAction func addTodo(_ sender: UIButton) {
        handleCard()
    }
    
    @IBAction func togglePlanner(_ sender: UIButton) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row].text
        return cell
    }
    
}
