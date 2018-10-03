//
//  MicManager.swift
//  DecibelMeter
//
//  Created by Steven Yonanta Siswanto on 02/10/18.
//  Copyright © 2018 Steven Yonanta Siswanto. All rights reserved.
//

import Foundation
import AVKit

protocol MicManagerDelegate {
    func audioRecordingFailed()
    func avgAudioVolumeResult(_ value: Double)
    func peakAudioVolumeResult(_ value: Double)
}

class MicManager: NSObject {
    let audioSession = AVAudioSession.sharedInstance()
    var delegate: MicManagerDelegate?
    private let audioEngine = AVAudioEngine()

    private var recorder : AVAudioRecorder? = nil
    private var timer: Timer?
    var interval: Double = 0.2

    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls.first!
        return documentDirectory.appendingPathComponent("recording.m4a")
    }
    
    var isAudioEngineRunning: Bool {
        return self.recorder?.isRecording == true
    }
    
    func checkForPermission(_ result: @escaping (_ success: Bool)->()) {
        switch audioSession.recordPermission() {
        case .granted:
            initRecorder()
            result(true)
        case .denied: result(false)
        case .undetermined:
            audioSession.requestRecordPermission { _ in
                self.checkForPermission(result)
            }
        }
    }

    func initRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
            
            try recorder = AVAudioRecorder(url: getDocumentsDirectory(), settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            if recorder?.prepareToRecord() != true {
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            print("Error: AVAudioRecorder creation failed")
        }
    }
    
    func startRecording() {
        recorder?.record()
        startTimer()
    }
    
    func stopRecording() {
        timer?.invalidate()
        recorder?.stop()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.getDispersyPercent), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func getDispersyPercent() {
        recorder?.updateMeters()
        let db = Double(recorder?.averagePower(forChannel: 0) ?? -160)
        let result = pow(10.0, db / 20.0)
        delegate?.avgAudioVolumeResult(result)
        
        let db2 = Double(recorder?.peakPower(forChannel: 0) ?? -160)
        let result2 = pow(10.0, db2 / 20.0)
        delegate?.peakAudioVolumeResult(result2)
    }
}

extension MicManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recorder.stop()
        recorder.deleteRecording()
        recorder.prepareToRecord()
    }
}
