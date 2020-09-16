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
    @IBOutlet weak var primaryBtn: UIButton!
    @IBOutlet weak var secondaryBtn: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var checkBtn: UIButton!
    
    let modeToColor = ["focus":#colorLiteral(red: 0.1803921569, green: 0.5843137255, blue: 0.6, alpha: 1), "break":#colorLiteral(red: 0.3137254902, green: 0.5882352941, blue: 0.9411764706, alpha: 1)]
    var taskLabelText:String!
    var index:Int!
    var canComplete = false
    var fontSize:CGFloat!
    var font:UIFont!
    var progressLayer = CAShapeLayer()
    var timer:Timer!
    var minutes:Int!
    var seconds:Int!
    var pausedTime:CFTimeInterval?
    var blnStarted = false
    var mode = "focus"
    var durations = Array(stride(from: 5, through: 60, by: 5))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationPicker.delegate = self
        durationPicker.dataSource = self
        setupViews()
        setupTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let text = blnStarted ? "pause" : "start"
        primaryBtn.setTitle(text, for: .normal)
        if canComplete && mode == "focus" {
            checkBtn.isHidden = false
        }
    }
    
    private func setupViews() {
        taskLabel.text = taskLabelText
        seconds = 0
        minutes = UserDefaults.standard.integer(forKey: "focusDuration")
        durationPicker.selectRow(minutes/5-1, inComponent: 0, animated: false)
        durationPicker.isHidden = true
        minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        view.bringSubviewToFront(timerView)
        timerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDuration)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        fontSize = view.frame.width*0.107
        font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        colonLabel.font = font
        minutesLabel.font = font
        secondsLabel.font = font
        let buttonSize = view.frame.width*0.35
        primaryBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        primaryBtn.heightAnchor.constraint(equalToConstant: buttonSize/3.5).isActive = true
        primaryBtn.layer.cornerRadius = 18
        fontSize = view.frame.width*0.05
        primaryBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        secondaryBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    private func setupTimer() {
        let center = view.center
        let radius = view.frame.width/3
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi*0.48, endAngle: CGFloat.pi*1.52, clockwise: true)

        let timerLayer = CAShapeLayer()
        timerLayer.path = circlePath.cgPath
        timerLayer.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        timerLayer.lineWidth = 25
        timerLayer.fillColor = UIColor.clear.cgColor
        
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = modeToColor["focus"]?.cgColor
        progressLayer.lineWidth = 25
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(timerLayer)
        view.layer.addSublayer(progressLayer)
    }
    
    // MARK: Class functions
    private func
        startAnimation(minutes:CFTimeInterval) {
        let fillAnimation = CABasicAnimation(keyPath: "strokeEnd")
        fillAnimation.toValue = 1
        fillAnimation.duration = minutes*60
        fillAnimation.fillMode = .forwards
        fillAnimation.isRemovedOnCompletion = false
        progressLayer.speed = 1.0
        progressLayer.add(fillAnimation, forKey: "fill")
    }
    
    private func pauseAnimation(){
        pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0.0
        progressLayer.timeOffset = pausedTime!
    }
    
    private func resumeAnimation() {
        pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime!
      progressLayer.beginTime = timeSincePause
    }
    
    private func timesUp() {
        minutes = UserDefaults.standard.integer(forKey: "\(mode)Duration")
        resetTimer(mode)
        canComplete = true
    }
    
    private func resetTimer(_ fromMode:String) {
        timer.invalidate()
        if fromMode == "focus" {
            mode = "break"
            taskLabel.text = "Break"
            secondaryBtn.setTitle("skip", for: .normal)
            durations = Array(stride(from: 5, through: 30, by: 5))
        } else {
            mode = "focus"
            taskLabel.text = taskLabelText
            secondaryBtn.setTitle("end", for: .normal)
            secondaryBtn.isHidden = true
            durations = Array(stride(from: 5, through: 60, by: 5))
        }
        seconds = 0
        minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        secondsLabel.text = seconds < 10 ? "0\(seconds!)" : "\(seconds!)"
        durationPicker.selectRow(minutes/5-1, inComponent: 0, animated: true)
        timerView.isUserInteractionEnabled = true
        pausedTime = nil
        blnStarted = false
        primaryBtn.setTitle("start", for: .normal)
        primaryBtn.backgroundColor = modeToColor[mode]
        progressLayer.strokeColor = modeToColor[mode]?.cgColor
    }
    
    // MARK: @objc functions
    @objc private func countdown() {
        minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        secondsLabel.text = seconds < 10 ? "0\(seconds!)" : "\(seconds!)"
        seconds -= 1
        if seconds < 0 {
            seconds = 59
            if minutes < 1 {
                timesUp()
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
    
    // MARK: @IBAction functions
    @IBAction private func pressPrimary(_ sender: UIButton) {
        if !blnStarted {
            if pausedTime == nil {
                if mode == "focus" {
                    UserDefaults.standard.set(minutes, forKey: "focusDuration")
                    secondaryBtn.isHidden = false
                } else {
                    UserDefaults.standard.set(minutes, forKey: "breakDuration")
                }
                minutesLabel.text = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
                secondsLabel.text = seconds < 10 ? "0\(seconds!)" : "\(seconds!)"
                durationPicker.isHidden = true
                timerView.isHidden = false
                timerView.isUserInteractionEnabled = false
                startAnimation(minutes: CFTimeInterval(minutes))
            } else {
                resumeAnimation()
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            pauseAnimation()
        }
        blnStarted = !blnStarted
    }
    
    @IBAction private func pressSecondary(_ sender: UIButton) {
        minutes = UserDefaults.standard.integer(forKey: "focusDuration")
        resetTimer("break")
        progressLayer.removeAnimation(forKey: "fill")
        secondaryBtn.isHidden = true
    }

    @IBAction func exitFocus(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completeTask(_ sender: UIButton) {
        checkBtn.setImage(UIImage(systemName: ""), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000)) {
            self.performSegue(withIdentifier: "TodoUnwind", sender: nil)
        }
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
