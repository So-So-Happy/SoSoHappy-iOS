//
//  AddStep3ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/14.
//

import UIKit
import SnapKit
import Then

final class AddStep3ViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var statusBarStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually // 뷰를 동일한 크기로 분배
    }
    private lazy var statusBarStep1 = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var statusBarStep2 = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var statusBarStep3 = UIView().then {
        $0.backgroundColor = UIColor(named: "AccentColor")
    }
        
    private lazy var saveButton = UIButton(type: .system).then {
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        $0.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private lazy var feelingStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    private lazy var happinessRate = UIImageView(image: UIImage(named: "happy100")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var happinessCategory1 = UIImageView(image: UIImage(named: "home")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.text = getCurrentDate()
    }
    
    private lazy var photoButton = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(photoButtonTapped)).then {
        $0.tintColor = .black
    }
    
    private lazy var lockButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(lockButtonTapped)).then {
        $0.tintColor = .black
    }
    
    private lazy var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    private lazy var downKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(downKeyboardButtonTapped)).then {
        $0.tintColor = .black
    }
    
    private lazy var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35)).then {
        $0.sizeToFit()
        $0.items = [photoButton, lockButton, flexibleSpaceButton, downKeyboardButton]
    }
    
    private lazy var textView = UITextView().then {
        $0.text = "오늘은..."
        $0.backgroundColor = .clear // Set background color to clear
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.inputAccessoryView = toolBar
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")

        setUpView()
        setConstraints()
    }
}

// MARK: - Layout & Atribute
private extension AddStep3ViewController {
    
    //  MARK: 뷰 구성요소 세팅
    private func setUpView() {
        statusBarStack.addArrangedSubview(statusBarStep1)
        statusBarStack.addArrangedSubview(statusBarStep2)
        statusBarStack.addArrangedSubview(statusBarStep3)

        view.addSubview(statusBarStack)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        feelingStack.addArrangedSubview(happinessRate)
        feelingStack.addArrangedSubview(happinessCategory1)
        view.addSubview(feelingStack)

        view.addSubview(dateLabel)
        view.addSubview(textView)
    }
    
    //  MARK: 뷰 구성요소 제약 설정
    private func setConstraints() {
        statusBarStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(5) // 높이 설정
        }
        
        happinessRate.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        happinessCategory1.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        feelingStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusBarStack).inset(65)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(feelingStack).inset(80)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel).inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(60)
        }
    }
}

// MARK: - Action
private extension AddStep3ViewController {
    
    // MARK: 저장 버튼 클릭 이벤트 함수
    @objc private func saveButtonTapped() {
        print("Save Button is clicked.")
    }
    
    // MARK: 현재 날짜를 가져오는 함수
    private func getCurrentDate() -> String {
        // Get the current date
        let currentDate = Date()
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        
        // Format the date as a string
        let dateString = dateFormatter.string(from: currentDate)
        
        return dateString
    }
    
    // MARK: 앨범 버튼 클릭 이벤트 함수
    @objc private func photoButtonTapped() {
        print("Photo Button is clicked.")
    }
    
    // MARK: 공개/비공개 버튼 클릭 이벤트 함수
    @objc private func lockButtonTapped() {
        print("Lock Button is clicked.")
    }
    
    // MARK: 키보드 내림 버튼 클릭 이벤트 함수
    @objc private func downKeyboardButtonTapped() {
        self.view.endEditing(true)
        print("DownKeyboard Button is clicked.")
    }
}
