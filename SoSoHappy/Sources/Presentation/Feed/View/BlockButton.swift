//
//  BlockButton.swift
//  SoSoHappy
//
//  Created by Sue on 12/1/23.
//

import UIKit

protocol BlockButtonDelegate: AnyObject {
    func reportButtonDidTap(_ blockButton: BlockButton)
    func blockButtonDidTap(_ blockButton: BlockButton)
}

class BlockButton: UIButton {
    weak var delegate: BlockButtonDelegate?
    
    private lazy var report = UIAction() { _ in
        self.delegate?.reportButtonDidTap(self)
    }
    
    private lazy var block = UIAction() { _ in
        self.delegate?.blockButtonDidTap(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBlockButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBlockButton() {
        setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        showsMenuAsPrimaryAction = true
        let title = NSAttributedString(string: "신고하기", attributes: [
            NSAttributedString.Key.font: UIFont.customFont(size: 16, weight: .medium)
        ])
        
        let blockTitle = NSAttributedString(string: "작성자 차단", attributes: [
            NSAttributedString.Key.font: UIFont.customFont(size: 16, weight: .medium)
        ])
        
        report.setValue(title, forKey: "attributedTitle")
        block.setValue(blockTitle, forKey: "attributedTitle")
        
        menu = UIMenu(children: [report, block])
    }
}
