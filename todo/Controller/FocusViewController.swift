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
    @IBOutlet weak var sessionsStackView: UIStackView!
    
    let modeToColor = ["focus":#colorLiteral(red: 0.1803921569, green: 0.5843137255, blue: 0.6, alpha: 1), "break":#colorLiteral(red: 0.3137254902, green: 0.5882352941, blue: 0.9411764706, alpha: 1), "longBreak":#colorLiteral(red: 0.3137254902, green: 0.5882352941, blue: 0.9411764706, alpha: 1)]
    var mode = "focus"
    var todo:Todo!
    var canComplete = false
    var blnStarted = false
    var active = false
    var totalSessions = 4
    var currentSession = 1
    
    var progressLayer = CAShapeLayer()
    var strokeEnd:CGFloat = 0
    var timer:Timer!
    var minutes:Int = UserDefaults.standard.integer(forKey: "focusDuration")
    var seconds:Int = 0
    var pausedTime:CFTimeInterval?
    var durations = Array(stride(from: 5, through: 60, by: 5))
    
    var fontSize:CGFloat!
    var font:UIFont!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationPicker.delegate = self
        durationPicker.dataSource = self
        DispatchQueue.main.async {
            self.setupViews()
            self.setupTimer()
        }
        if blnStarted {startTimer()}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        primaryBtn.setTitle(blnStarted ? "pause" : "start", for: .normal)
        if self.canComplete && self.mode == "focus" {
            self.checkBtn.isHidden = false
        } else {
            self.checkBtn.isHidden = true
        }
    }
    
// MARK: Class functions
    
    // MARK: Setup
    private func setupViews() {
        taskLabel.text = todo.text
        durationPicker.selectRow(minutes/5-1, inComponent: 0, animated: false)
        durationPicker.isHidden = true
        minutesLabel.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        secondsLabel.text = seconds < 10 ? "0\(seconds)" : "\(seconds)"
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
        primaryBtn.backgroundColor = modeToColor[mode]
        secondaryBtn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        setupSessions(totalSessions, currentSession)
    }
    
    private func setupSessions(_ totalCount:Int, _ currentCount:Int) {
        for n in 0..<totalCount {
            let imageName = n < currentCount ? "circle.fill" : "circle"
            let dotImage = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
            if sessionsStackView.arrangedSubviews.count > n {
                let dotImageView = sessionsStackView.arrangedSubviews[n] as! UIImageView
                dotImageView.image = dotImage
            } else {
                let imageView = UIImageView()
                imageView.image = dotImage
                imageView.tintColor = K.lightGray
                sessionsStackView.addArrangedSubview(imageView)
            }
        }
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
        progressLayer.strokeColor = modeToColor[mode]?.cgColor
        progressLayer.lineWidth = 25
        progressLayer.strokeEnd = strokeEnd
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(timerLayer)
        view.layer.addSublayer(progressLayer)
    }
    
    // MARK: Timer Animation
    private func
        startAnimation(minutes:CFTimeInterval) {
        let fillAnimation = CABasicAnimation(keyPath: "strokeEnd")
        fillAnimation.toValue = 1
        fillAnimation.duration = CFTimeInterval(seconds) + minutes*60
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    // MARK: Timer
    private func timesUp() {
        if mode == "focus" {
            if currentSession == totalSessions {
                currentSession = 1
                setupSessions(totalSessions, currentSession)
            } else {
                let filledDot = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
                let imageView = sessionsStackView.arrangedSubviews[currentSession] as! UIImageView
                imageView.image = filledDot
                currentSession += 1
            }
        }
        resetTimer(mode)
        canComplete = true
    }
    
    private func resetTimer(_ fromMode:String) {
        timer.invalidate()
        if fromMode == "focus" {
            if currentSession == 1 && canComplete {
                mode = "longBreak"
                taskLabel.text = "Long break"
                durations = Array(stride(from: 5, through: 60, by: 5))
            } else {
                mode = "break"
                taskLabel.text = "Break"
                durations = Array(stride(from: 5, through: 30, by: 5))
            }
            secondaryBtn.setTitle("skip", for: .normal)
        } else {
            mode = "focus"
            taskLabel.text = todo.text
            secondaryBtn.setTitle("end", for: .normal)
            secondaryBtn.isHidden = true
            durations = Array(stride(from: 5, through: 60, by: 5))
        }
        minutes = UserDefaults.standard.integer(forKey: "\(mode)Duration")
        seconds = 0
        minutesLabel.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        secondsLabel.text = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        durationPicker.selectRow(minutes/5-1, inComponent: 0, animated: false)
        timerView.isUserInteractionEnabled = true
        pausedTime = nil
        blnStarted = false
        primaryBtn.setTitle("start", for: .normal)
        primaryBtn.backgroundColor = modeToColor[mode]
        progressLayer.strokeColor = modeToColor[mode]?.cgColor
        strokeEnd = 0
        progressLayer.strokeEnd = strokeEnd
    }
    
    private func startTimer() {
        if !active {
            if mode == "focus" {
                UserDefaults.standard.set(minutes, forKey: "focusDuration")
            } else if mode == "longBreak" {
                UserDefaults.standard.set(minutes, forKey: "longBreakDuration")
            } else {
                UserDefaults.standard.set(minutes, forKey: "breakDuration")
            }
        }
        minutesLabel.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        secondsLabel.text = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        secondaryBtn.isHidden = false
        durationPicker.isHidden = true
        timerView.isHidden = false
        timerView.isUserInteractionEnabled = false
        startAnimation(minutes: CFTimeInterval(minutes))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    // MARK: @objc functions
    @objc private func countdown() {
        minutesLabel.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        secondsLabel.text = seconds < 10 ? "0\(seconds)" : "\(seconds)"
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
            minutesLabel.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
            durationPicker.isHidden = true
            timerView.isHidden = false
        }
    }
    
    // MARK: @IBAction functions
    @IBAction private func pressPrimary(_ sender: UIButton) {
        if !blnStarted {
            if pausedTime == nil {startTimer()}
            else {resumeAnimation()}
        } else {
            timer.invalidate()
            pauseAnimation()
        }
        blnStarted = !blnStarted
        primaryBtn.setTitle(blnStarted ? "pause" : "start", for: .normal)
    }
    
    @IBAction private func pressSecondary(_ sender: UIButton) {
        minutes = UserDefaults.standard.integer(forKey: "focusDuration")
        resetTimer("break")
        progressLayer.removeAnimation(forKey: "fill")
        secondaryBtn.isHidden = true
        setupSessions(totalSessions, currentSession)
    }
    
    @IBAction func exitFocus(_ sender: UIButton) {
        strokeEnd = 1 - (CGFloat(minutes)+CGFloat(seconds)/60)/CGFloat(UserDefaults.standard.integer(forKey: "\(mode)Duration"))
        performSegue(withIdentifier: "ExitFocus", sender: nil)
    }
    
    @IBAction func completeTask(_ sender: UIButton) {
        checkBtn.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3000)) {
            self.performSegue(withIdentifier: "CompleteTask", sender: nil)
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
