//
//  FocusViewController.swift
//  todo
//
//  Created by Benjamin Nguyen on 9/9/20.
//  Copyright © 2020 Benjamin Nguyen. All rights reserved.
//

import UIKit

class FocusViewController: UIViewController {

    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var colonLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var timerView: UIView!
    
    var taskLabelText:String?
    var fontSize:CGFloat!
    var font:UIFont!
    var progressLayer = CAShapeLayer()
    var timer:Timer!
    var duration:Int!
    var minutes:Int!
    var seconds:Int!
    var blnStarted = false
    var pausedTime:CFTimeInterval?
    let durations = Array(stride(from: 5, through: 60, by: 5))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationPicker.delegate = self
        durationPicker.dataSource = self
        setupViews()
        setupTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        durationPicker.selectRow(4, inComponent: 0, animated: true)
    }
    
    private func setupViews() {
        taskLabel.text = taskLabelText
        seconds = 0
        minutes = 25
        durationPicker.isHidden = true
        view.bringSubviewToFront(timerView)
        timerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDuration)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        fontSize = view.frame.width*0.107
        font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        colonLabel.font = font
        minutesLabel.font = font
        secondsLabel.font = font
        let buttonSize = view.frame.width*0.35
        startBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        startBtn.heightAnchor.constraint(equalToConstant: buttonSize/3.5).isActive = true
        startBtn.layer.cornerRadius = 18
        fontSize = view.frame.width*0.05
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        endBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    private func setupTimer() {
        let center = view.center
        let radius = view.frame.width/3
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 1.5*CGFloat.pi, clockwise: true)
        
        let timerLayer = CAShapeLayer()
        timerLayer.path = circlePath.cgPath
        timerLayer.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        timerLayer.lineWidth = 25
        timerLayer.fillColor = UIColor.clear.cgColor
        
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = CGColor(srgbRed: 0.180, green: 0.584, blue: 0.600, alpha: 1.000)
        progressLayer.lineWidth = 25
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(timerLayer)
        view.layer.addSublayer(progressLayer)
    }
    
    private func startAnimation(minutes:CFTimeInterval) {
        let fillAnimation = CABasicAnimation(keyPath: "strokeEnd")
        fillAnimation.toValue = 1
        fillAnimation.duration = minutes*60
        fillAnimation.fillMode = .forwards
        fillAnimation.isRemovedOnCompletion = false
        progressLayer.add(fillAnimation, forKey: "fill")
    }
    
    private func pauseAnimation(){
        pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0.0
        progressLayer.timeOffset = pausedTime!
    }
    
    private func resumeAnimation(){
        pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime!
      progressLayer.beginTime = timeSincePause
    }
    
    @objc private func countdown() {
        minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        secondsLabel.text = seconds < 10 ? "0\(seconds!)" : "\(seconds!)"
        seconds -= 1
        if seconds < 0 {
            seconds = 59
            if minutes < 1 {
                // Time's up!
                colonLabel.text = "Done!"
                minutesLabel.text = ""
                secondsLabel.text = ""
                timerView.isUserInteractionEnabled = true
                startBtn.setTitle("restart", for: .normal)
                blnStarted = !blnStarted
                timer.invalidate()
                return
            } else {
                minutes -= 1
            }
        }
    }
    
    @objc private func changeDuration() {
        timerView.isHidden = true
        durationPicker.isHidden = false
    }
    
    @objc private func handleDismiss() {
        if !durationPicker.isHidden {
            minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
            durationPicker.isHidden = true
            timerView.isHidden = false
        }
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        if !blnStarted {
            minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
            durationPicker.isHidden = true
            timerView.isHidden = false
            timerView.isUserInteractionEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
            if pausedTime == nil {
                startAnimation(minutes: CFTimeInterval(minutes))
            } else {
                resumeAnimation()
            }
        } else {
            pauseAnimation()
            timer.invalidate()
        }
        blnStarted = !blnStarted
        let text = blnStarted ? "pause" : "start"
        startBtn.setTitle(text, for: .normal)
    }
    
    @IBAction func endTimer(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension FocusViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        minutes = durations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = "\(durations[row])"
        pickerLabel.font = font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
