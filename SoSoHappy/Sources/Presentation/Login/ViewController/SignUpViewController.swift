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
 1.  ReactorKit 작성한 코드 리팩토링
 */


/*
 1. 사진 접근 권한 확인  -> 딱히 확인을 안하는 것 같음
 - https://developer.apple.com/documentation/photokit/selecting_photos_and_videos_in_ios
 - https://stackoverflow.com/questions/48826060/uiimagepickercontroller-not-asking-for-permission
 - https://developer.apple.com/documentation/photokit/creating_photo_editing_extensions
 
 무신사(TOCropViewController)
 1-1. UIImagePickerViewController VS PhotoKit VS 새로운 라이브러리
        - 사진 1개만 select하면 되니깐 UIImagePickerViewController해도 될 것 같음
 1-2. 카메라로 찍기 (추가해볼까 생각중)
 
 2. textField에 입력할 때 키보드 위치 조정 필요 (scrollView) -> RxKeyboard 사용
    - scrollview 먼저 적용 (완료)
    - 첫번째 textfield부터 시작
    - textview
    - View를 탭 했을 때 keyboard 내려가야 함
 
 4. textView scroll? 되는 것 같던데 확인 필요 (스페이스 제한?) - 카카오톡 참고해서 수정하면 될 듯 (마지막 문자로부터 뒤에 있는 공백은 제거해서 저장)
 */


// 렌더링만 담당
final class SignUpViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var scrollView = UIScrollView()
        .then {
            $0.keyboardDismissMode = .interactive // 스크롤시 키보드 내리기
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
    
    // MARK: Binding
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
//        bindUI()
//        setUpKeyboardHiding()
    }
    // Add SubViews & Contstraints
    private func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubviews(contentView, signUpDescriptionStackView, profileImageEditButton, nickNameSection, selfIntroductionSection, signUpButton)
        
//        self.view.addSubviews(signUpDescriptionStackView, profileImageEditButton, nickNameSection, selfIntroductionSection, signUpButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(signUpButton).offset(100)
        }
        
        signUpDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(36)
//            make.top.equalTo(view.safeAreaLayoutGudie).inset(36)
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
//            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
//            make.bottom.equalTo(view.keyboardLayoutGuide.topAnchor)
//            make.bottom.equalTo(selfIntroductionSection.snp.top).offset(-30)
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
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // ViewController의 전체적인 속성 설정
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        self.navigationItem.title = "회원가입"
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) } // 구독
    }
    
//    private func setUpKeyboardHiding() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    private func bindUI() {
//        profileImageEditButton.cameraButton.rx.tap
//            .flatMapLatest { [weak self] _ in
//                return UIImagePickerController.rx.createWithParent(self) { (picker) in
//                    picker.allowsEditing = true
//                    picker.sourceType = .photoLibrary
//                }
//                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
//                .take(1)
//            }
//            .map{ info in
//                return info[.editedImage] as? UIImage
//            }
//            .bind(to: profileImageEditButton.profileImageWithBackgroundView.profileImageView.rx.image)
//            .disposed(by: disposeBag) // // UIImagePickerController가 메모리에서 해제되면 같이 해제
//    }

}

// MARK: Actions
extension SignUpViewController {
    
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
                .take(1)
            }
            .map{ info in
                let img = info[.editedImage] as? UIImage
                print("img ---------------")
                return Reactor.Action.selectImage(img)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameSection.nickNameTextField.rx.text.orEmpty
            .map { Reactor.Action.nickNameTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nickNameSection.duplicateCheckButton.rx.tap
            .map { Reactor.Action.checkDuplicate }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selfIntroductionSection.selfIntroductionTextView.rx.text.orEmpty
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
            .map { $0.duplicateMessage }
            .bind(to: nickNameSection.warningMessageLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selfIntroText }
            .bind(to: selfIntroductionSection.selfIntroductionTextView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selfIntroText.count }
            .map { "\($0) / 60"}
            .bind(to: selfIntroductionSection.textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.selfIntroText.isEmpty && !$0.isDuplicate }
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Adjust the content inset of scrollView when the keyboard is shown
        // 나타날 때 (호출 1)
        RxKeyboard.instance.willShowVisibleHeight
          .drive(onNext: { [scrollView] keyboardVisibleHeight in
              

          })
          .disposed(by: disposeBag)
        
        // 호출 2
        RxKeyboard.instance.visibleHeight
            .drive (onNext: { [scrollView] keyboardVisibleHeight in
            })
            .disposed(by: disposeBag)
        
        // 호출 3 - 보일 때(false), 안보일 때 (true)
        RxKeyboard.instance.isHidden
            .drive(onNext: { [weak self] isHidden in

            })
            .disposed(by: disposeBag)
        
        
        // 호출 4
        // Adjust the content inset of scrollView when the keyboard is shown
        RxKeyboard.instance.frame
            .drive(onNext: { [weak self] keyboardFrame in
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Action (Keyboard)
//extension SignUpViewController {
//    // 탭한 element를 키보드가 block하고 있는지에 따라서
//    // UITextfield, UITextView 상황 나누기
//    @objc func keyboardWillShow(sender: NSNotification) {
//           guard let userInfo = sender.userInfo,
//                 let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
//                 let currentTextField = UIResponder.currentFirst() as? UITextView else { return }
////
//           print("foo - userInfo: \(userInfo)")
//           print("foo - keyboardFrame: \(keyboardFrame)")
//           print("foo - currentTextField: \(currentTextField)")
//       }
//
//    @objc func keyboardWillHide(sender: NSNotification) {
//        view.frame.origin.y = 0
//    }
//}

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



//#if DEBUG
//import SwiftUI
//struct SignUpViewControllerRepresentable: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        SignUpViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct SignUpViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            SignUpViewControllerRepresentable()
//                .ignoresSafeArea()
//                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
//        }
//
//    }
//} #endif

