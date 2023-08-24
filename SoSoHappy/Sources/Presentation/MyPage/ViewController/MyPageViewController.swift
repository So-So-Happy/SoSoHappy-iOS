//
//  MyPageViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

final class MyPageViewController: UIViewController {
    
    private lazy var profileView = ProfileView()
    private lazy var stackView = SettingStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension MyPageViewController {
    
    func setup() {
        setLayout()
        setAttribute()
    }
    
    func setLayout() {
        self.view.addSubviews(profileView, stackView)
        self.view.backgroundColor = .white
        
        profileView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.35)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
//            $0.height.equalToSuperview().multipliedBy(0.3)
        }
        
    }
    
    
    func setAttribute() {
        
    }
}
