//
//  SoundLevelView.swift
//  DecibelMeter
//
//  Created by Steven Yonanta Siswanto on 02/10/18.
//  Copyright © 2018 Steven Yonanta Siswanto. All rights reserved.
//

import UIKit

class SoundLevelView: UIView {
    @IBOutlet var coverLeftConstraint: NSLayoutConstraint!
    @IBOutlet var coverView: UIView!
    @IBOutlet var maxLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    var interval: Double = 0.2

    var width: CGFloat = 0
    
    func calibrateView() {
        width = self.coverView.frame.width
        updateValue(0)
    }
    
    //value between 0...1
    func updateValue(_ value: CGFloat) {
        var val = max(value, 0)
        val = min(value, 1)
        let const = val * self.width
        UIView.animate(withDuration: interval) {
            self.coverLeftConstraint.constant = const
            self.maxLabel.textColor = val >= 1 ? .red : .lightGray
            self.layoutIfNeeded()
        }
    }
}
