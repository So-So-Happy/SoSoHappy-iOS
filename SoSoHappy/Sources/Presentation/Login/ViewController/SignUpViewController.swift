//
//  SignUpViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Then
import RxKeyboard

/*
 1. ReactorKit 작성한 코드 리팩토링 - 버튼에 throttle, debouce 적용해보기 (중복검사, 시작하기 연타 방지)
 2. 이미지 설정 카메라로 찍기도 추가해볼까 생각중
 3. .onDrag로 keyboard 내려가게 했는데 tap했을 때도 해놓으면 좋을 것 같긴 함
 4. 시간이 괜찮다면 keyboard contentInset를 좀 더 정확히 계산해서 넣어주는 코드를 작성해봐도 좋을 듯
 */

final class SignUpViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var contentInset: UIEdgeInsets?
    
    // MARK: - UI Components
    private lazy var scrollView = UIScrollView()
        .then {
            $0.keyboardDismissMode = .onDrag // 스크롤시 키보드 내리기
    }
    
    private lazy var contentView = UIView()
    private lazy var signUpDescriptionStackView = SignUpDescriptionStackView()
    private lazy var profileImageEditButton = ImageEditButtonView()
    private lazy var nickNameSection = NickNameStackView()
    private lazy var selfIntroductionSection = SelfIntroductionStackView()
    private lazy var signUpButton = HappyButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        $0.backgroundColor = UIColor(named: "buttonColor")
        $0.layer.cornerRadius = 8
        $0.setBackgroundColor(UIColor(named: "buttonColor"), for: .disabled)
        $0.setBackgroundColor(UIColor.orange, for: .enabled)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Initializing
    init(reactor: SignUpViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension SignUpViewController {
    private func setup() {
        setLayout()
        setAttribute()
    }
    
    // Add SubViews & Contstraints
    private func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(signUpDescriptionStackView, profileImageEditButton, nickNameSection, selfIntroductionSection, signUpButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(signUpButton).offset(40)
        }
        
        signUpDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(36)
        }
        
        profileImageEditButton.snp.makeConstraints { make in
            make.top.equalTo(signUpDescriptionStackView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }
        
        nickNameSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageEditButton.snp.bottom).offset(56)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        selfIntroductionSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nickNameSection.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(selfIntroductionSection.snp.bottom).offset(40)
            make.width.equalTo(selfIntroductionSection)
            make.height.equalTo(44)
        }
    }
    
    // ViewController의 전체적인 속성 설정
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        self.navigationItem.title = "회원가입"
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) } // 구독
    }
}

// MARK: - ReactorKit - bind func
extension SignUpViewController: View {
    // MARK: bind - reactor에 새로운 값이 들어올 때만 트리거
    func bind(reactor: SignUpViewReactor) {
        // MARK: Action (View -> Reactor) 인풋
        profileImageEditButton.cameraButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.allowsEditing = true
                    picker.sourceType = .photoLibrary
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo } // 사진 다 골랐다
                .take(1) // 단 1개의 아이템(사진)만 내보내는 것을 보장
            }
            .map{ info in
                let img = info[.editedImage] as? UIImage // UIImage 옵셔널 type
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
        
        signUpButton.rx.tap
            .map { Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: State (Reactor -> State) 아웃풋
        reactor.state
            .map { $0.profileImage }
            .bind(to: profileImageEditButton.profileImageWithBackgroundView.profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.nickNameText }
            .bind(to: nickNameSection.nickNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.nickNameText.isEmpty }
            .bind(to: nickNameSection.duplicateCheckButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                let text: String
                let color: UIColor
                
                if let isDuplicate = state.isDuplicate {
                    text =  isDuplicate ? "이미 사용중인 닉네임입니다" : "멋진 닉네임이네요!"
                    color = isDuplicate ? UIColor.systemRed : UIColor.systemBlue
                } else { // nil이면
                    text = ""
                    color = .systemBlue
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
            .map {
                guard let isDuplicate = $0.isDuplicate else { return false }
                return !$0.selfIntroText.isEmpty && !isDuplicate
            }
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)

        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
            
                if UIResponder.currentFirst() is UITextField {  // textfield
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0) //80
                } else {    // textview
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 217 , right: 0) // 240
                }
            })
            .disposed(by: disposeBag)
    
        RxKeyboard.instance.isHidden
            .skip(1)
            .drive(onNext: { [weak self] isHidden in
                guard let `self` = self, let contentInset = contentInset else { return }
                
                if isHidden { // 키보드가 안보일 때
                    self.scrollView.scrollIndicatorInsets = .zero
                    self.scrollView.contentInset = .zero
                } else { // 키보드가 보일 때
                    self.scrollView.contentInset = contentInset
                    self.scrollView.scrollIndicatorInsets = contentInset
                    self.scrollView.scrollRectToVisible(self.signUpButton.frame, animated: true)
                }
                
            })
            .disposed(by: disposeBag)
    }
}

//extension SignUpViewController: ProfileEditReactorDelegate {
//    func showImagePicker() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = .photoLibrary
//
//        imagePicker.rx.didFinishPickingMediaWithInfo
//            .map { info in
//                return SignUpViewReactor.Action.selectedImage(info[.editedImage] as? UIImage)
//            }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//
//        // Present the image picker
//        self.present(imagePicker, animated: true, completion: nil)
//    }
//}


// MARK: - ImagePicker Delegate
//extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//}


