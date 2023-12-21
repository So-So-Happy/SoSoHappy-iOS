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
    private lazy var emptyHappyImage = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "emptyImage")
        $0.contentMode = .scaleAspectFit
    }
    
    convenience init(title: String, inset: Int) {
        self.init(frame: .zero)
        backgroundColor = UIColor(named: "BGgrayColor")
        self.configureUI(title: title, inset: inset)
    }
}

extension ExceptionView {
    func configureUI(title: String, inset: Int) {
        titleLabel.font = UIFont.customFont(size: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "DarkGrayTextColor")
        titleLabel.text = title
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        titleLabel.setLineSpacing(lineSpacing: 10, alignment: .center)
        
        self.addSubview(emptyHappyImage)
        self.addSubview(titleLabel)

        emptyHappyImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.size.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyHappyImage.snp.bottom)
        }
    }
}
