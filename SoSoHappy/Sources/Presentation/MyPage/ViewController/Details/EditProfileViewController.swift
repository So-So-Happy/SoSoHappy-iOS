//
//  EditProfileViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/10/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Then
import RxKeyboard

final class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var contentInset: UIEdgeInsets?
    private let coordinator: MyPageCoordinatorProtocol?
    
    // MARK: - UI Components
    private lazy var scrollView = UIScrollView().then {
        $0.keyboardDismissMode = .onDrag
        $0.showsVerticalScrollIndicator = false
    }
    private lazy var contentView = UIView()
    private lazy var profileImageEditButton = ImageEditButtonView(image: "camera.fill")
    private lazy var nickNameSection = NickNameStackView()
    private lazy var selfIntroductionSection = SelfIntroductionStackView()
    private lazy var saveButton = HappyButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.customFont(size: 18, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.setBackgroundColor(UIColor.lightGray, for: .disabled)
        $0.setBackgroundColor(UIColor(named: "AccentColor"), for: .enabled)
    }

    // MARK: Initializing
    init(reactor: EditProfileViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = false
        }
    }
}

//MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension EditProfileViewController {
    private func setup() {
        setLayout()
        setAttribute()
    }

    private func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubviews(contentView)
        self.view.addSubview(saveButton)
        contentView.addSubviews(profileImageEditButton, nickNameSection, selfIntroductionSection)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(selfIntroductionSection).offset(40)
        }

        profileImageEditButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }
        
        nickNameSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageEditButton.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        selfIntroductionSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nickNameSection.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalToSuperview().inset(20)
            make.width.equalTo(selfIntroductionSection)
            make.height.equalTo(44)
        }
    }

    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "BGgrayColor")
    }
}

// MARK: - ReactorKit - bind func
extension EditProfileViewController: View {
    func bind(reactor: EditProfileViewReactor) {
        profileImageEditButton.editButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.allowsEditing = true
                    picker.sourceType = .photoLibrary
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map{ info in
                let img = info[.editedImage] as? UIImage
                return Reactor.Action.selectImage(img)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameSection.nickNameTextField.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.nickNameTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameSection.duplicateCheckButton.rx.tap
            .map {
                self.view.endEditing(true)
                return Reactor.Action.checkDuplicate
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selfIntroductionSection.selfIntroductionTextView.rx.text.orEmpty
            .skip(1)
            .map { Reactor.Action.selfIntroTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.tapSignUpButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.profileImage }
            .bind(to: profileImageEditButton.profileImageWithBackgroundView.profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.nickNameText }
            .bind(to: nickNameSection.nickNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.nickNameText.isEmpty && !$0.isSameNickName }
            .bind(to: nickNameSection.duplicateCheckButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                let text: String
                let color: UIColor
                
                if let isDuplicate = state.isDuplicate {
                    text =  isDuplicate ? "이미 사용 중인 닉네임이에요." : "멋진 닉네임이네요!"
                    color = isDuplicate ? UIColor.systemRed : UIColor(named: "CustomBlueColor") ?? .systemBlue
                } else {
                    text = " "
                    color = UIColor(named: "CustomBlueColor") ?? .systemBlue
                }
                
                return (text, color)
            }
            .bind { [weak self] text, color in
                guard let `self` = self else { return }
                nickNameSection.warningMessageLabel.text = text
                nickNameSection.warningMessageLabel.textColor = color
            }
            .disposed(by: disposeBag)
                
        reactor.state
            .map { $0.selfIntroText }
            .bind(to: selfIntroductionSection.selfIntroductionTextView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { "\($0.selfIntroText.count) / 60" }
            .bind(to: selfIntroductionSection.textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { (!$0.selfIntroText.isEmpty && !($0.isDuplicate ?? true)) || $0.isSameNickName }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.showFinalAlert }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if result {
                    CustomAlert.presentCheckAndCancelAlert(title: "해당 정보로 프로필 수정을 완료하시겠어요?", message: "", buttonTitle: "완료") { self.reactor?.action.onNext(.signUp) }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.goToMain }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if result {
                    coordinator?.goBackToMypage()
                }
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
            
                if UIResponder.currentFirst() is UITextField {
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
                } else {    // textview
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 217 , right: 0)
                }
            })
            .disposed(by: disposeBag)
    
        RxKeyboard.instance.isHidden
            .skip(1)
            .drive(onNext: { [weak self] isHidden in
                guard let `self` = self, let contentInset = contentInset else { return }
                
                if isHidden {
                    self.scrollView.scrollIndicatorInsets = .zero
                    self.scrollView.contentInset = .zero
                } else {
                    self.scrollView.contentInset = contentInset
                    self.scrollView.scrollIndicatorInsets = contentInset
                    let targetRect = selfIntroductionSection.frame.insetBy(dx: 0, dy: -50)
                    self.scrollView.scrollRectToVisible(targetRect, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        selfIntroductionSection.addKeyboardToolBar.keyboardDownBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                selfIntroductionSection.checkIsTextViewFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
