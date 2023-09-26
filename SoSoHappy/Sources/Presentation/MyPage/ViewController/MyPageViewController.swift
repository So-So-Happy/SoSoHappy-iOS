//
//  MyPageViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPageViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var testProfile = ProfileTemp(profileImage: UIImage(named: "pic2")!, profileNickName: "날씨조아", selfIntroduction: "나는야 날씨조아. 디저트 러버. 크로플, 도넛, 와플이 내 최애 디저트다. 음료는 아이스아메리카노 좋아함 !")
    
    // MARK: - UI Components
    private lazy var profileView = ProfileView()
    private lazy var stackView = SettingStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindEvent()
        profileView.update(with: testProfile) // test용
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension MyPageViewController {
    // MARK: - Layout
    private func setup() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubviews(profileView, stackView)
        self.view.backgroundColor = .white
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
    }
}

extension MyPageViewController {
    // Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    // 보통 coordinator로 네비게이션하는 일은 reactor가 필요없음
    func bindEvent() {
        self.profileView.profileSetButton.rx.tap
        
    }
}
