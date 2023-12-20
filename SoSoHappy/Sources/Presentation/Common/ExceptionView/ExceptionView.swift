//
//  FeedExceptionView.swift
//  SoSoHappy
//
//  Created by Sue on 10/14/23.
//

import UIKit
import SnapKit


final class ExceptionView: UIView {
    lazy var titleLabel = UILabel()
    
    convenience init(title: String, inset: Int) {
        self.init(frame: .zero)
        backgroundColor = UIColor(named: "BGgrayColor")
        self.configureUI(title: title, inset: inset)
    }
}

extension ExceptionView {
    func configureUI(title: String, inset: Int) {
        titleLabel.font = UIFont.customFont(size: 18, weight: .medium)
        titleLabel.textColor = UIColor(named: "DarkGrayTextColor")
        titleLabel.text = title
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(inset)
            make.horizontalEdges.equalToSuperview()
        }
    }
}