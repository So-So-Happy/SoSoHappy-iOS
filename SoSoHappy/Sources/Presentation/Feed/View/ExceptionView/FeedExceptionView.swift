//
//  FeedExceptionView.swift
//  SoSoHappy
//
//  Created by Sue on 10/14/23.
//

import UIKit
import SnapKit

// 올라온 피드가 없습니다
final class FeedExceptionView: UIView {
    convenience init(title: String, inset: Int) {
        self.init(frame: .zero)
        self.configureUI(title: title, inset: inset)
    }
}

extension FeedExceptionView {
    func configureUI(title: String, inset: Int) {
        let titleLabel = UILabel()
        
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
