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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
}

extension ViewController: MicManagerDelegate {
    func audioRecordingFailed() {
        print("failed")
    }
    
    func avgAudioVolumeResult(_ value: Double) {
        soundView.titleLabel.text = "Avg    : \(value * 120)"
        soundView.updateValue(CGFloat(value))
    }
    
    func peakAudioVolumeResult(_ value: Double) {
        peakSoundView.titleLabel.text = "Peak   : \(value * 120)"
        peakSoundView.updateValue(CGFloat(value))
    }
}
