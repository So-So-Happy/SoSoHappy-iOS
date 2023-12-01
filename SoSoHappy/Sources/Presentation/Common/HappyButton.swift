//
//  HappyButton.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/31.
//
// https://brontoxx.medium.com/proper-way-to-set-uibutton-background-color-for-disabled-state-15d4c6482bd

import UIKit

class HappyButton: UIButton {
    // 버튼 상태 enum
    enum ButtonState {
        case enabled
        case disabled
    }
    
    // 버튼 상태에 따라 설정할 backgroundColor 변수 2개
    private var disabledBackgroundColor: UIColor?
    
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    // change background color on isEnabled value changed
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
    
    // our custom functions to set color for different state
    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .enabled:
            defaultBackgroundColor = color
        }
    }
}
