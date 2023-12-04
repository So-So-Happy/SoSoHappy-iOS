//
//  LoadingView.swift
//  SoSoHappy
//
//  Created by Sue on 12/4/23.
//

import UIKit
import NVActivityIndicatorView
import SnapKit

class LoadingView: UIView {
    
    private lazy var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 27, height: 27), type: .circleStrokeSpin, color: UIColor(named: "GrayTextColor"), padding: 0).then {
        $0.startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingView {
    private func setView() {
        backgroundColor = UIColor(named: "BGgrayColor")
        addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(90)
        }
    }
}
