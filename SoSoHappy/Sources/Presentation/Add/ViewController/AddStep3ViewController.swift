//
//  AddStep3ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/14.
//

import UIKit
import SnapKit

class AddStep3ViewController: UIViewController {
    // MARK: - Properties
    let statusBarStack = UIStackView()
    let statusBarStep1 = UIView()
    let statusBarStep2 = UIView()
    let statusBarStep3 = UIView()
    
    let saveButton = UIButton(type: .system)
    
    let feelingStack = UIStackView()
    var happinessRate = UIImageView(image: UIImage(named: "happy100"))
    var happinessCategory1 = UIImageView(image: UIImage(named: "home"))
    
    let dateLabel = UILabel()
    
    let textView = UITextView()
    
    var toolBar = UIToolbar()
    let photoButton = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(photoButtonTapped))
    let lockButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(lockButtonTapped))
    let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let downKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(downKeyboardButtonTapped))
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        ㅌ
        setUpValue()
        setUpView()
        setConstraints()
    }
    
    // MARK: - 요소 내용 설정
    func setUpValue() {
        statusBarStack.axis = .horizontal
        statusBarStep1.backgroundColor = .white
        statusBarStep2.backgroundColor = .white
        statusBarStep3.backgroundColor = UIColor(named: "AccentColor")
        
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        
        dateLabel.textColor = .darkGray
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        
        textView.text = "오늘은..."
        textView.backgroundColor = .clear // Set background color to clear
        textView.font = UIFont.systemFont(ofSize: 15)
        
        photoButton.tintColor = .black
        lockButton.tintColor = .black
        downKeyboardButton.tintColor = .black

        toolBar.sizeToFit()
        toolBar.items = [photoButton, lockButton, flexibleSpaceButton, downKeyboardButton]
        textView.inputAccessoryView = toolBar
    }
    
    //  MARK: - 뷰 구성요소 세팅
    func setUpView() {
        statusBarStack.addArrangedSubview(statusBarStep1)
        statusBarStack.addArrangedSubview(statusBarStep2)
        statusBarStack.addArrangedSubview(statusBarStep3)
        statusBarStack.distribution = .fillEqually // 뷰를 동일한 크기로 분배
        view.addSubview(statusBarStack)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        happinessRate.contentMode = .scaleAspectFit
        happinessCategory1.contentMode = .scaleAspectFit
        
        feelingStack.axis = .horizontal
        feelingStack.spacing = 10
        feelingStack.addArrangedSubview(happinessRate)
        feelingStack.addArrangedSubview(happinessCategory1)
        view.addSubview(feelingStack)
        
        dateLabel.text = getCurrentDate()
        view.addSubview(dateLabel)
        
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        view.addSubview(textView)
    }
    
    //  MARK: - 뷰 구성요소 제약 설정
    func setConstraints() {
        statusBarStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(5) // 높이 설정
        }
        
        feelingStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusBarStack).inset(UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0))
        }
        
        happinessRate.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        happinessCategory1.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(feelingStack).inset(UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0))
        }
        
        textView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 60, right: 20))
            make.top.equalTo(dateLabel).inset(UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        }
    }
    
    // MARK: - 저장 버튼 클릭 이벤트 함수
    @objc func saveButtonTapped() {
        print("Save Button is clicked.")
    }
    
    // MARK: - 현재 날짜를 가져오는 함수
    func getCurrentDate() -> String {
        // Get the current date
        let currentDate = Date()
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E요일"
        
        // Format the date as a string
        let dateString = dateFormatter.string(from: currentDate)
        
        return dateString
    }
    
    // MARK: - 앨범 버튼 클릭 이벤트 함수
    @objc func photoButtonTapped() {
        print("Photo Button is clicked.")
    }
    
    // MARK: - 공개/비공개 버튼 클릭 이벤트 함수
    @objc func lockButtonTapped() {
        print("Lock Button is clicked.")
    }
    
    // MARK: - 키보드 내림 버튼 클릭 이벤트 함수
    @objc func downKeyboardButtonTapped() {
        self.view.endEditing(true)
        print("DownKeyboard Button is clicked.")
    }
}

#if DEBUG
import SwiftUI
struct AddStep3ViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        AddStep3ViewController()
    }
}
@available(iOS 13.0, *)
struct AddStep3ViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AddStep3ViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        }
        
    }
} #endif
