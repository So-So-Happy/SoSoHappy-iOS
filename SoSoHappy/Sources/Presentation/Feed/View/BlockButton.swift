//
//  BlockButton.swift
//  SoSoHappy
//
//  Created by Sue on 12/1/23.
//

import UIKit

protocol BlockButtonDelegate: AnyObject {
    func blockButtonDidTap(_ blockButton: BlockButton)
}

class BlockButton: UIButton {
    weak var delegate: BlockButtonDelegate?
    
    private lazy var block = UIAction(title: "작성자 차단") { _ in
        print("작성자 차단 tapped")
        self.delegate?.blockButtonDidTap(self)
    }
    
    private lazy var menus = UIMenu(children: [block])

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
        menu = UIMenu(children: [block])
    }
}