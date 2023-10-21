//
//  AddStep3ViewController.swift
//  SoSoHappy
//
//  Created by Sue on 10/16/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

/*
 1. 갤러리 연결
 2. 사진 표시
 3. 키보드가 textView를 가리지 않도록 계속 scroll되어야 함
 4. textView가 isEmpty - false일 경우 "저장"버튼 activate
 5. textView placeholder '오늘의 소소한 행복을 기록해주세요'
 */

final class AddStep3ViewController: BaseDetailViewController {
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 3)
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
    
    private lazy var addKeyboardToolBar = AddKeyboardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))

    
    override func viewDidLoad() {
        //        view.backgroundColor = .systemYellow
        print("AddStep3ViewController - viewDidLoad")
        super.viewDidLoad()
        setup()
    }
    
    init(reactor: AddViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - set up
extension AddStep3ViewController {
    private func setup() {
        setLayout()
        setAttributes()
    }
    
    private func setAttributes() {
        textView.isUserInteractionEnabled = true
        textView.inputAccessoryView = addKeyboardToolBar
        
        print("editable \(textView.isEditable)")
    }
    
    private func setLayout() {
        self.scrollView.addSubview(statusBarStackView)
        self.navigationItem.rightBarButtonItem = saveButton
        
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        // 카테고리 설정
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(80)
        }
    }
}

// MARK: - bind func
extension AddStep3ViewController: View {
    func bind(reactor: AddViewReactor) {
        self.rx.viewDidLoad
            .map { Reactor.Action.fetchDatasForAdd3 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.addKeyboardToolBar.photoBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("picture tapped")
            })
            .disposed(by: disposeBag)
        
        self.addKeyboardToolBar.lockBarButton.rx.tap
            .map { Reactor.Action.tapLockButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.addKeyboardToolBar.keyboardDownBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("keyboardDownBarButton tapped")
                self.view.endEditing(true)
                //                toolBar.isHidden = true
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.dateString }
            .bind(to: self.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.happyAndCategory }
            .bind { [weak self] happyAndCategory in
                guard let self = self else { return }
                categoryStackView.addImageViews(images: happyAndCategory, imageSize: 62)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.weatherString }
            .bind { [weak self] weather in
                guard let self = self else { return }
                let imageName = weather + "Bg"
                let image = UIImage(named: imageName)!
                scrollView.backgroundColor = UIColor(patternImage: image)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isPrivate }
            .bind { [weak self] isPrivate in
                guard let self = self else { return }
                addKeyboardToolBar.setPrivateTo(isPrivate)
            }
            .disposed(by: disposeBag)
    }
}
