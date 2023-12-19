//
//  AddKeyboardToolBarForCalendar.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/18.
//

import UIKit

final class AddKeyboardToolBarForCalender: UIToolbar {
    // MARK: - UI Components
    lazy var lockBarButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: nil, action: nil)
    private lazy var flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
    lazy var keyboardDownBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.items = [lockBarButton, flexibleSpace, keyboardDownBarButton]
        self.sizeToFit()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setting functions
extension AddKeyboardToolBarForCalender {
    // MARK: isPrivate에 따라 lockBarButton 이미지 세팅
    func setPrivateTo(_ isPrivate: Bool) {
        let systemName = isPrivate ? "lock" : "lock.open"
        let image = UIImage(systemName: systemName)
        lockBarButton.image = image
    }
}
