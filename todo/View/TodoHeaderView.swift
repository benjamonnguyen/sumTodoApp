//
//  TodoHeaderView.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/27/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class TodoHeaderView:UITableViewHeaderFooterView {
    
    var sectionName:String!
    var tableView:UITableView!
    
    func setupHeaderView(for sectionName:String, sectionCount:Int) {
        self.sectionName = sectionName
        
        let title = UILabel()
        let count = UILabel()

        title.text = sectionName
        title.textColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
        title.font = UIFont.systemFont(ofSize: K.fontSize, weight: .regular)
        let titleW = title.text!.width(withConstrainedHeight: 0, font: title.font)
        let titleH = title.text!.height(withConstrainedWidth: 0, font: title.font)
        title.frame = CGRect(x: 0, y: 0, width: titleW, height: titleH)
        
        count.text = String(sectionCount)
        count.textColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
        count.font = UIFont.systemFont(ofSize: K.fontSize - 2, weight: .regular)
        let countW = count.text!.width(withConstrainedHeight: 0, font: count.font)
        let countH = count.text!.height(withConstrainedWidth: 0, font: count.font)
        count.frame = CGRect(x: 0, y: 0, width: countW, height: countH)
        
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(count)
        count.translatesAutoresizingMaskIntoConstraints = false
        count.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        if ["today", "inbox"].contains(sectionName) {
            count.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -13).isActive = true
            if sectionName == "today" {
                if UserDefaults.standard.bool(forKey: "todaySelected") {
                    contentView.backgroundColor = #colorLiteral(red: 0, green: 0.3450980484, blue: 0.8156862855, alpha: 0.3)
                    title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    count.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            } else {
                if !UserDefaults.standard.bool(forKey: "todaySelected") {
                    contentView.backgroundColor = #colorLiteral(red: 0, green: 0.3450980484, blue: 0.8156862855, alpha: 0.3)
                    title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    count.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            }
        } else if ["upcoming", "completed"].contains(sectionName) {
            let dropdown = UIButton()
            dropdown.translatesAutoresizingMaskIntoConstraints = false
            dropdown.frame.size = CGSize(width: titleH, height: titleH)
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .light)
            var imageName:String!
            if sectionName == "upcoming" {
                imageName = UserDefaults.standard.bool(forKey: "showUpcoming") ? "chevron.down" : "chevron.left"
            } else if sectionName == "completed" {
                imageName = UserDefaults.standard.bool(forKey: "showCompleted") ? "chevron.down" : "chevron.left"
            }
            dropdown.setBackgroundImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
            dropdown.tintColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            self.addSubview(dropdown)
            dropdown.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
            dropdown.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            count.trailingAnchor.constraint(equalTo: dropdown.leadingAnchor, constant: -13).isActive = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectSection))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func selectSection() {
        switch self.sectionName {
        case "today":
            UserDefaults.standard.setValue(true, forKey: "todaySelected")
            tableView.reloadData()
        case "inbox":
            UserDefaults.standard.setValue(false, forKey: "todaySelected")
            tableView.reloadData()
        case "upcoming":
            if UserDefaults.standard.bool(forKey: "showUpcoming") {
                UserDefaults.standard.set(false, forKey: "showUpcoming")
                } else {
                    UserDefaults.standard.set(true, forKey: "showUpcoming")
                }
            tableView.reloadSections(IndexSet(integer: 2), with: .fade)
        case "completed":
            if UserDefaults.standard.bool(forKey: "showCompleted") {
                UserDefaults.standard.set(false, forKey: "showCompleted")
            } else {
                UserDefaults.standard.set(true, forKey: "showCompleted")
            }
            tableView.reloadSections(IndexSet(integer: 3), with: .fade)
        default:
            print("errored at sectionToggle")
        }
    }
    
    }

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
