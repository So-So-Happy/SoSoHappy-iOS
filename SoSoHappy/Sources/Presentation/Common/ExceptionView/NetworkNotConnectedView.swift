//
//  NetworkNotConnectedView.swift
//  SoSoHappy
//
//  Created by Sue on 12/19/23.
//

import UIKit
import SnapKit
import Then

final class NetworkNotConnectedView: UIView {
    private lazy var wifiImageView = UIImageView().then {
        $0.image = UIImage(systemName: "wifi.slash")
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 18, weight: .bold)
        $0.text = "네트워크에 연결할 수 없습니다"
    }
    
    private lazy var subTitleLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.text = "네트워크 연결 상태를 확인 후 다시 시도해주세요"
    }
    
    lazy var retryButton = HappyButton().then {
        $0.setTitle("재시도", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.customFont(size: 18, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.setBackgroundColor(UIColor(named: "AccentColor"), for: .enabled)
    }
    
    convenience init(inset: Int) {
        self.init(frame: .zero)
        backgroundColor = UIColor(named: "BGgrayColor")
        setView()
        self.modifyInset(inset: inset)
    }
}

extension NetworkNotConnectedView {
    private func setView() {
        addSubviews()
        setLayout()
    }
    
    private func addSubviews() {
        addSubviews(wifiImageView)
        addSubviews(titleLabel)
        addSubviews(subTitleLabel)
        addSubviews(retryButton)
    }
    
    private func setLayout() {
        wifiImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(100)
            make.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(wifiImageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
        }
    }
}

extension NetworkNotConnectedView {
    func modifyInset(inset: Int) {
        wifiImageView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(inset)
        }
    }
}
