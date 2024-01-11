//
//  NickNameStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

final class NickNameStackView: UIView {
    private lazy var nickNameStackView = UIStackView(
        axis: .vertical,
        alignment: .leading,
        distribution: .fill,
        spacing: 6
    )
    
    private lazy var nickNameGuideLabel = UILabel().then {
        $0.text = "닉네임을 입력해주세요. (최대 10자)"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 15, weight: .medium)
    }
    
    private lazy var nickNameTextFieldWithButtonStackView = UIStackView(
        axis: .horizontal,
        alignment: .leading,
        distribution: .fill,
        spacing: 10
    )
    
    lazy var nickNameTextField = UITextField().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.clearButtonMode = .always
        $0.layer.cornerRadius = 8
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: $0.frame.height))
        $0.leftViewMode = .always
    }
    
    lazy var duplicateCheckButton = HappyButton().then {
        $0.setTitle("중복 검사", for: .normal)
        $0.titleLabel?.textColor = UIColor(named: "CellColor")
        $0.titleLabel?.font = UIFont.customFont(size: 15, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
        $0.setBackgroundColor(UIColor.lightGray, for: .disabled)
        $0.setBackgroundColor(UIColor(named: "AccentColor"), for: .enabled)
    }
    
    lazy var warningMessageLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 13, weight: .medium)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NickNameStackView {
    private func setStackView() {
        addSubview(nickNameStackView)
        nickNameStackView.addArrangedSubview(nickNameGuideLabel)
        nickNameStackView.addArrangedSubview(nickNameTextFieldWithButtonStackView)
        nickNameStackView.addArrangedSubview(warningMessageLabel)
        nickNameTextFieldWithButtonStackView.addArrangedSubview(nickNameTextField)
        nickNameTextFieldWithButtonStackView.addArrangedSubview(duplicateCheckButton)
        
        nickNameStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        nickNameTextFieldWithButtonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        nickNameTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    func checkIsNickNameTextFieldFirstResponder() {
        if nickNameTextField.isFirstResponder {
            nickNameTextField.resignFirstResponder()
        }
    }
}
