//
//  HappyButton.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/31.
//
// https://brontoxx.medium.com/proper-way-to-set-uibutton-background-color-for-disabled-state-15d4c6482bd

import UIKit

class HappyButton: UIButton {
    enum ButtonState {
        case enabled
        case disabled
    }
    
    private var disabledBackgroundColor: UIColor?
    
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    override var isEnabled: Bool {
        didSet {  //
            if isEnabled {
                if let color = defaultBackgroundColor {
                    self.backgroundColor = color
                }
            }
            else {
                if let color = disabledBackgroundColor {
                    self.backgroundColor = color
                }
            }
        }
    }

    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .enabled:
            defaultBackgroundColor = color
        }
    }
}
