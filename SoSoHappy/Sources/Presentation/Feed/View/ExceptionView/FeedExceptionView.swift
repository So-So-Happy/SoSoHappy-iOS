//
//  FeedExceptionView.swift
//  SoSoHappy
//
//  Created by Sue on 10/14/23.
//

import UIKit

// 올라온 피드가 없습니다
final class FeedExceptionView: UIView {
    convenience init(title: String, topOffset: Int) {
        self.init(frame: .zero)
        self.configureUI(title: title, topOffset: topOffset)
    }
}

extension FeedExceptionView {
    func configureUI(title: String, topOffset: Int) {
        let titleLabel = UILabel()
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        titleLabel.textColor = UIColor(named: "DarkGrayTextColor")
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(topOffset)
        }
    }
}
