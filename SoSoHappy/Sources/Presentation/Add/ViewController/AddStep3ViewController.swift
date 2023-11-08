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
import PhotosUI
import RxKeyboard

/*

 
 ## 사진 관련
 1. 갤러리 연결
 2. 사진 표시
 3. 등록한 사진 제거할 수 있도록
 ----------
 
 3. input accessary view 지연 문제 해결 필요 (시뮬에서만 그런 것 같기도 함)
 3 - 1. 키보드가 textView를 가리지 않도록 계속 scroll되어야 함 (완료)
 
 4. textView가 isEmpty - false일 경우 "저장"버튼 activate (완료)
 5. textView placeholder '오늘의 소소한 행복을 기록해주세요' (완료)
 5-1. 글자 수 제한 3000자
 5-2. 글자 counting label 추가
 
 6. 토스트 메시지
    - 성공하면 '등록했습니다' 하고 delay 좀 있다가 dismiss
    - 실패하면 '등록하지 못했습니다?"
    - 와이파이 연결 안되어 있으면 '네트워크에 연결할 수 없습니다'
 
 
 
 */

final class AddStep3ViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: AddCoordinatorInterface?
    
    // Identifier와 PHPickerResult (이미지 데이터를 저장하기 위해 만들어줌)
    private var selection = [String: PHPickerResult]()
    
    // 선택한 사진의 순서에 맞게 Identifier들을 배열로 저장
    // selection은 Dictionary이기 때문에 순서가 없음. 그래서 따로 식별자를 담을 배열 생성 (주 용도 - 순서)
    private var selectedAssetIdentifiers = [String]()

    
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 3)
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
    
    private lazy var addKeyboardToolBar = AddKeyboardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))

    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    private lazy var removeImageButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .medium), forImageIn: .normal)
        $0.tintColor = .white
        $0.isHidden = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .systemGray
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 3
    }
    
    lazy var textCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .lightGray
        $0.textAlignment = .right
//        $0.text = "(0 / 3000)"
    }
    
    private lazy var placeholderLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .lightGray
        $0.textAlignment = .left
           $0.text = "소소한 행복을 기록해보세요~"
       }
    
    override func viewDidLoad() {
        //        view.backgroundColor = .systemYellow
        print("AddStep3ViewController - viewDidLoad")
        super.viewDidLoad()
        print("scrollView.contentInset.bottom : \(scrollView.contentInset.bottom)")
        setup()
    }
    
    init(reactor: AddViewReactor, coordinator: AddCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - set up
extension AddStep3ViewController {
    private func setup() {
        setAttributes()
        setLayout()
    }
    
    private func setAttributes() {
        textView.isUserInteractionEnabled = true
        textView.inputAccessoryView = addKeyboardToolBar
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        print("editable \(textView.isEditable)")
    }
    
    private func setLayout() {
        self.contentView.addSubview(statusBarStackView)
        self.contentView.addSubview(textCountLabel)
        textView.addSubview(placeholderLabel)
        imageSlideView.addSubviews(removeImageButton)
        
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        // 카테고리 설정
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(80)
        }
        
        // 이미지 설정
        imageSlideView.snp.updateConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(36)
        }
        
        // 글자 수
        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(10)
            make.right.equalTo(contentBackground).inset(5)
        }
        
        // 선택한 이미지 제거 버튼
        removeImageButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(14)
            make.size.equalTo(24)
        }
        
        // placeholder
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(10)
        }
    }
}

// MARK: - bind func
extension AddStep3ViewController: View {
    func bind(reactor: AddViewReactor) {
        // MARK: AddStep3 올 때마다 viewDidLoad 호출
        self.rx.viewDidLoad
            .map { Reactor.Action.fetchDatasForAdd3 }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty // orEmpty nil일 경우 빈 문자열로 반환
            .skip(1)
            // .debounce : 마지막 방출된 것으로부터 100 milisecond가 지나고 reactor로 보냄
            // 100개의 글자를 작성한다고 했을 때 debounce를 주면 reactor에 100이하 전달, 안 하면 100번
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.setContent($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty } // Invert the condition to hide when empty
            .distinctUntilChanged()
            .debug()
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
       
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                print("visibleHeight: \(keyboardVisibleHeight)") // 380, 0
                if keyboardVisibleHeight > 0 {
                    scrollView.contentInset.bottom = keyboardVisibleHeight + 15
                } else {
                    scrollView.contentInset.bottom = .zero
                }
            })
            .disposed(by: disposeBag)

        addKeyboardToolBar.photoBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("AddStep3 - show 앨범")
                self.view.endEditing(true)
                setAndPresentPicker()
                
            })
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.lockBarButton.rx.tap
            .map { Reactor.Action.tapLockButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addKeyboardToolBar.keyboardDownBarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("keyboardDownBarButton tapped")
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.tapSaveButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
       
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("AddStep3 - navigate Back")
                coordinator?.navigateBack()
            })
            .disposed(by: disposeBag)
        
        removeImageButton.rx.tap
            .map { Reactor.Action.setSelectedImages([])}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 행복 + 카테고리
        reactor.state
            .compactMap { $0.happyAndCategory }
            .distinctUntilChanged()
            .bind { [weak self] happyAndCategory in
                guard let self = self else { return }
                categoryStackView.addImageViews(images: happyAndCategory, imageSize: 62)
            }
            .disposed(by: disposeBag)
        
        // 날짜
        reactor.state
            .map { $0.dateString }
            .distinctUntilChanged()
            .bind(to: self.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 날씨 배경
        reactor.state
            .compactMap { $0.weatherString }
            .distinctUntilChanged()
            .bind { [weak self] weather in
                print("weather type: \(type(of: weather))")
                guard let self = self else { return }
                let imageName = weather + "Bg"
                let image = UIImage(named: imageName)!
                
                let color = UIColor(patternImage: image)
                scrollView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        // 작성 글
        reactor.state
            .map { "(\($0.content.count) / 3000)" }
            .distinctUntilChanged()
            .bind(to: self.textCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // isPrivate에 따라서 자물쇠 image 변경
        reactor.state
            .map { $0.isPrivate }
            .distinctUntilChanged()
            .bind { [weak self] isPrivate in
                guard let self = self else { return }
                addKeyboardToolBar.setPrivateTo(isPrivate)
            }
            .disposed(by: disposeBag)
        
        // 저장 버튼 활성화
        reactor.state
            .map { !$0.content.isEmpty }
            .distinctUntilChanged()
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.selectedImages }
            .distinctUntilChanged()
            .bind { [weak self] images in
                guard let self = self else { return }
                print("images.count : \(images.count)")
                setImageSlideView(imageList: images)
                removeImageButton.isHidden = images.isEmpty ? true : false
            }
            .disposed(by: disposeBag)

    }
}


// MARK: - PHPickerViewControllerDelegate & picker preseent
// 권한 요청이 필요없음
// iOS 14이상부터 지원 가능
extension AddStep3ViewController: PHPickerViewControllerDelegate {
    private func setAndPresentPicker() {
        // configuation - 설정
        var configuation = PHPickerConfiguration(photoLibrary: .shared())
        configuation.selectionLimit = 2 // 선택 최대 2개 제한
        configuation.filter = .images // image만 표시 (이외에도 video, live photo 등이 있음)
        configuation.selection = .ordered // 선택한 순서대로 번호 표시 iOS 15부터 가능
        configuation.preferredAssetRepresentationMode = .current
        
        // 선택했던 이미지를 기억해 표시하도록
        configuation.preselectedAssetIdentifiers = selectedAssetIdentifiers // [String]
        
        let picker = PHPickerViewController(configuration: configuation)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    // MARK: picker가 닫힐 때 호출됨
    // PHPickerResult - itemProviders(load and display photos) , asset identifiers
    // 미리 선택되어 있던 asset의 item provider은 empty
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1. picker dismiss
        
        // Picker 작업이 끝난 후, 새로 만들어질 selections를 담을 변수 생성
        let existingSelectio: [String: PHPickerResult] = self.selection
        var newSelection = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            // PHPickerResult : itemProvier & assetIdentifier (사진과 식별자)
            newSelection[identifier] = existingSelectio[identifier] ?? result
        }
         
        self.selection = newSelection
        // Picker에서 선택한 이미지의 Identifier들을 저장 (assetIdentifier은 옵셔널 값이라서 compactMap 받음)
        // 위의 PHPickerConfiguration에서 사용하기 위해서 입니다. (기억하는 용도)
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        var selectedImages: [UIImage] = [] // 2. 선택한 UIImage를 담고 있을 임시 변수
        
        for assetIdentifier in selectedAssetIdentifiers {
            // item provider : 선택한 item에 대한 representations, background async
            let itemProvider = selection[assetIdentifier]!.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) { // UIImage 타입으로 로드할 수 있는지 먼저 체크
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in // 로드
                    if let error {
                        print("Error loading image: \(error.localizedDescription)")
                    }
                    
                    if let selectedImage = image as? UIImage {
                        selectedImages.append(selectedImage)
                    }
                    
                    if selectedImages.count == results.count {
                        // Update the property of your view controller with all selected images
                        // UI와 관련된 self.reactor?.action.onNext(.setSelectedImages은
                        // main thread에서 처리가 되어야 한다.
                        DispatchQueue.main.async {
                            self.reactor?.action.onNext(.setSelectedImages(selectedImages))
                        }
                    }
                }
            }
        } // for문
        
    }
}
