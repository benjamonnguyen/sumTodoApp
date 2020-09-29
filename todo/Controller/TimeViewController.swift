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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var recurTableView: UITableView!
    var separator = UIImageView()
    var cancelBtnXConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        par = (parent as! CalendarViewController)
        recurTableView.delegate = self
        recurTableView.dataSource = self
    }
    
    func setupTimeView(for row:Int) {
        cancelBtnXConstraint.isActive = false
        switch row {
        case 0:
            cancelBtnXConstraint = cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.frame.width/4)
            cancelBtnXConstraint.isActive = true
            titleLabel.isHidden = true
            clearBtn.isHidden = false
            doneBtn.isHidden = false
            separator.isHidden = false
            timePicker.isHidden = false
            recurTableView.isHidden = true
            view.isHidden = false
        case 1:
            cancelBtnXConstraint = cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            cancelBtnXConstraint.isActive = true
            titleLabel.isHidden = false
            clearBtn.isHidden = true
            doneBtn.isHidden = true
            separator.isHidden = true
            timePicker.isHidden = true
            recurTableView.isHidden = false
            view.isHidden = false
        default:
            print("case \(row) out of bounds")
        }
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
        par.calendarTableView.reloadData()
    }
    
    @IBAction private func cancel(_ sender: UIButton) {
        dismissTime()
    }
    
    @IBAction private func done(_ sender: UIButton) {
        par.timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        dismissTime()
        par.calendarTableView.reloadData()
    }
    
}

extension TimeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return K.recurFrequencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let button = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        
        button.image = UIImage(systemName: "circle", withConfiguration: imageConfig)
        button.highlightedImage = UIImage(systemName: "circle.fill", withConfiguration: imageConfig)
        cell.contentView.addSubview(button)
        
        if let recur = par.recur {
            if K.recurFrequencies[indexPath.row] == recur {
                button.isHighlighted = true
                button.tintColor = K.primaryLightColor
            } else {
                button.isHighlighted = false
                button.tintColor = K.lightGray
            }
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            cell.textLabel!.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 10),
            cell.textLabel!.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        cell.textLabel?.textColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        cell.textLabel?.text = K.recurFrequencies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recurTableView.deselectRow(at: indexPath, animated: true)
        par.calendarTableView.reloadData()
        dismissTime()
        par.recur = K.recurFrequencies[indexPath.row]
    }
    
}
