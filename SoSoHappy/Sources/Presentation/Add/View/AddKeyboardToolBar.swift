//
//  AddKeyboardToolBar.swift
//  SoSoHappy
//
//  Created by Sue on 10/17/23.
//

import UIKit
import SnapKit


final class AddKeyboardToolBar: UIToolbar {
    // MARK: - UI Components
    lazy var photoBarButton = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: nil, action: nil)
    
    lazy var lockBarButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: nil, action: nil)
    
    private lazy var flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
    
    lazy var keyboardDownBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.items = [photoBarButton, lockBarButton, flexibleSpace, keyboardDownBarButton]
        self.sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setting functions
extension AddKeyboardToolBar {
    func setPublicTo(_ isPublic: Bool) {
        let systemName = isPublic ? "lock.open" : "lock"
        let image = UIImage(systemName: systemName)
        lockBarButton.image = image
    }
}
