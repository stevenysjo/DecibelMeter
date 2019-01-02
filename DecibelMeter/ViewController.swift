//
//  ViewController.swift
//  DecibelMeter
//
//  Created by Steven Yonanta Siswanto on 02/10/18.
//  Copyright © 2018 Steven Yonanta Siswanto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var micButton: UIButton!
    @IBOutlet var soundViewContainer: UIView!
    @IBOutlet var peakSoundViewContainer: UIView!
    @IBOutlet var limitTextField: UITextField!
    @IBOutlet var intervalTextField: UITextField!

    let decibelLimit: Double = 120
    var upperLimit: Double = 110
    var interval: Double = 0.2

    let soundView: SoundLevelView = {
        guard let v = UINib(nibName: "SoundLevelView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SoundLevelView else {
            return SoundLevelView()
        }
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()
    
    let peakSoundView: SoundLevelView = {
        guard let v = UINib(nibName: "SoundLevelView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SoundLevelView else {
            return SoundLevelView()
        }
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()

    let micManager = MicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = soundViewContainer.frame
        frame.origin = .zero
        soundView.frame = frame
        
        peakSoundView.frame = frame
        peakSoundViewContainer.addSubview(peakSoundView)
        soundViewContainer.addSubview(soundView)
        peakSoundViewContainer.addSubview(peakSoundView)

        micManager.delegate = self
        limitTextField.text = "\(upperLimit)"
        limitTextField.delegate = self
        
        intervalTextField.text = "\(interval)"
        intervalTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupIntervals()
        soundView.calibrateView()
        peakSoundView.calibrateView()
    }

    @IBAction func micTapped() {
        if micManager.isAudioEngineRunning {
            self.updateView(isRecording: false)
            micManager.stopRecording()
        } else {
            micManager.checkForPermission { (success) in
                if success {
                    self.updateView(isRecording: true)
                    self.micManager.startRecording()

                } else {
                    self.updateView(isRecording: false)
                }
            }
        }
    }

    func updateView(isRecording: Bool) {
        view.backgroundColor = isRecording ? UIColor(white: 0.3, alpha: 0.5) : .white
    }
    
    func setupIntervals() {
        micManager.interval = interval
        soundView.interval = interval
        peakSoundView.interval = interval
    }
}

extension ViewController: MicManagerDelegate {
    func audioRecordingFailed() {
        print("failed")
    }
    
    func avgAudioVolumeResult(_ value: Double) {
        let db = value * decibelLimit
        soundView.titleLabel.text = "Avg    : \(db)"
        soundView.updateValue(getRatio(from: db))
    }
    
    func peakAudioVolumeResult(_ value: Double) {
        let db = value * decibelLimit
        peakSoundView.titleLabel.text = "Peak   : \(db)"
        peakSoundView.updateValue(getRatio(from: db))
    }
    
    private func getRatio(from value: Double) -> CGFloat {
        return CGFloat(value / upperLimit)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case limitTextField:
            let val: Double
            if let text = textField.text, let value = Double(text) {
                val = value
            } else {
                val = upperLimit
            }
            textField.text = "\(val)"
            upperLimit = val
            
        case intervalTextField:
            let val: Double
            if let text = textField.text, let value = Double(text) {
                val = value
            } else {
                val = 0.2
            }
            textField.text = "\(val)"
            interval = val
        default: break
        }
        setupIntervals()
        if micManager.isAudioEngineRunning {
            micTapped()
        }
        return true
    }
}
