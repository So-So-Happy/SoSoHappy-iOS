//
//  NickNameStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

/*
 1. textfield 입력 처리
    - 최대 10자
 2. 중복 검사
    - enabled (10자 입력되었을 때)
 */

final class NickNameStackView: UIView {
    private lazy var nickNameStackView = UIStackView(
        axis: .vertical,
        alignment: .leading,
        distribution: .fill,
        spacing: 4
    )
    
    private lazy var nickNameGuideLabel = UILabel().then {
        $0.text = "닉네임을 입력해주세요 (최대 10자)"
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
    }
    
    private lazy var nickNameTextFieldWithButtonStackView = UIStackView(
        axis: .horizontal,
        alignment: .leading,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var nickNameTextField = UITextField().then {
        $0.delegate = self
        $0.backgroundColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
//        textField.layer.borderColor = UIColor.lightGray.cgColor
//        textField.layer.borderWidth = 1
        $0.clearButtonMode = .always
        $0.layer.cornerRadius = 8
        $0.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    private lazy var duplicateCheckButton = UIButton().then {
        $0.setTitle("중복 검사", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(named: "buttonColor")
        $0.layer.cornerRadius = 8
        $0.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
    }
    
    private lazy var warningMessageLabel = UILabel().then {
        $0.text = "닉네임이 중복돼요."
        $0.textColor = .red
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 12, weight: .light)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NickNameStackView {
    private func setupStackView() {
        addSubview(nickNameStackView)
        nickNameStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nickNameStackView.addArrangedSubview(nickNameGuideLabel)
        
        // nickNameTextFieldWithButtonStackView에 텍스트 필드와 중복 버튼 추가
        nickNameTextFieldWithButtonStackView.addArrangedSubview(nickNameTextField)
        nickNameTextFieldWithButtonStackView.addArrangedSubview(duplicateCheckButton)
        
        nickNameStackView.addArrangedSubview(nickNameTextFieldWithButtonStackView)
        nickNameTextFieldWithButtonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        nickNameStackView.addArrangedSubview(warningMessageLabel)
    }
}

extension NickNameStackView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < 10 else { return false }
        return true
    }
}

