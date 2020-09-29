//
//  Functions.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/22/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class F {
    static func startOfDay(for date:Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    static func endOfDay(for date:Date) -> Date {
        var newDate = startOfDay(for: date)
        newDate = Calendar.current.date(byAdding: .hour, value: 23, to: newDate)!
        newDate = Calendar.current.date(byAdding: .minute, value: 59, to: newDate)!
        return newDate
    }
    
    static func setupDimView(for viewController:UIViewController, with action: Selector) -> UIView {
        let dimView = UIView()
        dimView.frame = viewController.view.frame
        viewController.view.addSubview(dimView)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimView.alpha = 0
        dimView.isHidden = true
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: viewController, action: action))
        return dimView
    }
    
//    static func setupInvisibleView(for view:UIView) -> UIView {
//        let invisibleView = UIView()
//        invisibleView.frame = view.frame
//        view.addSubview(invisibleView)
//        invisibleView.backgroundColor = UIColor(white: 1, alpha: 0)
//        invisibleView.isHidden = true
//        return invisibleView
//    }
    
    static let timeFormatter:DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.amSymbol = "am"
        timeFormatter.pmSymbol = "pm"
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter
    }()
        
    static let dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter
    }()
    
    static func feedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
    }
}
