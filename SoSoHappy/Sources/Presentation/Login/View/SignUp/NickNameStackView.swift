//
//  NickNameStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class NickNameStackView: UIView {
    private lazy var nickNameView: UIStackView = {
        let view = UIStackView(axis: .vertical, alignment: .leading, distribution: .fill, spacing: 4)
        return view
    }()
    
    private lazy var nickNameGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임을 입력해주세요 (최대 10자)"
        label.textColor = .darkGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    private lazy var nickNameTextFieldButton: UIStackView = {
        let stackView = UIStackView(axis: .horizontal, alignment: .leading, distribution: .fill, spacing: 10)
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .white
        textField.font = UIFont.systemFont(ofSize: 15)
//        textField.layer.borderColor = UIColor.lightGray.cgColor
//        textField.layer.borderWidth = 1
        textField.clearButtonMode = .always
        textField.layer.cornerRadius = 8
        textField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        let button = UIButton()
        button.setTitle("중복 검사", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(named: "buttonColor")
        button.layer.cornerRadius = 8
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
        
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(button)
        
        return stackView
    }()
    
    private lazy var warningMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임이 중복돼요."
        label.textColor = .red
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNickNamView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NickNameStackView {
    private func setNickNamView() {
        addSubview(nickNameView)
        nickNameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nickNameView.addArrangedSubview(nickNameGuideLabel)
        nickNameView.addArrangedSubview(nickNameTextFieldButton)
        nickNameTextFieldButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        nickNameView.addArrangedSubview(warningMessageLabel)
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

