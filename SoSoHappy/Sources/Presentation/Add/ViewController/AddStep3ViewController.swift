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
 1. 갤러리 연결 (자료 다시 읽고 수정하기)
 2. 사진 표시 (완료)
 
 3. input accessary view 지연 문제 해결 필요
 3 - 1. 키보드가 textView를 가리지 않도록 계속 scroll되어야 함 (완료)
 
 4. textView가 isEmpty - false일 경우 "저장"버튼 activate (완료)
 5. textView placeholder '오늘의 소소한 행복을 기록해주세요'
 5-1. 글자 수 제한 3000자
 
 6. 토스트 메시지
    - 성공하면 '등록했습니다' 하고 delay 좀 있다가 dismiss
    - 실패하면 '등록하지 못했습니다?"
 
 
 7. 사진 등록한거 제거할 수 있도록 (완료)
 
 */

final class AddStep3ViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: AddCoordinatorInterface?
    private var didSetupViewConstraints = false
    
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 3)
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
    
    private lazy var addKeyboardToolBar = AddKeyboardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    let toolBar = AddKeyboardToolBar2()

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
//        textView.inputAccessoryView = addKeyboardToolBar
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        print("editable \(textView.isEditable)")
    }
    
    private func setLayout() {
        self.view.addSubview(toolBar)
        self.scrollView.addSubview(statusBarStackView)
        imageSlideView.addSubviews(removeImageButton)
        
        statusBarStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        // 카테고리 설정
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(80)
        }
        
        removeImageButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(14)
            make.size.equalTo(24)
        }
        
        toolBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
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
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.setContent($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
//        textView.rx.text.orEmpty
//            .compactMap { [weak self] _ in
//                return self?.textView.contentSize.height
//            }
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] height in
//                print("textview height: \(height)")
//                if height > 110 {
//                    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height - 93, right: 0)
//                    self?.scrollView.contentInset = contentInset
//                    self?.scrollView.scrollIndicatorInsets = contentInset
//                    if let targetRect = self?.imageSlideView.frame.insetBy(dx: 0, dy: -50) {
//                        print("if - let")
//                        self?.scrollView.scrollRectToVisible(targetRect, animated: true)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
        
//        
//        RxKeyboard.instance.isHidden
//            .skip(1)
//            .drive(onNext: { [weak self] isHidden in
//                if isHidden { // 키보드가 안 보일 때
//                    print("키보드 안 보인다")
//                    self?.scrollView.scrollIndicatorInsets = .zero
//                    self?.scrollView.contentInset = .zero
//                } else { // 키보드 보일대
//                    print("키보드 보인다")
//                    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
//                    self?.scrollView.contentInset = contentInset
//                    self?.scrollView.scrollIndicatorInsets = contentInset
//                    
//                }
//            })
//            .disposed(by: disposeBag)
        

        
        
        
        // MARK: 원래 사용하던 부분
        RxKeyboard.instance.frame
            .drive(onNext: { [weak self] frame in
                print("frame: \(frame)")
                // 키보드 올라올 때 : (0.0, 472.0, 393.0, 380.0)
                // 키보드 내려갈 때 : (0.0, 852.0, 393.0, 380.0)
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                print("visibleHeight: \(keyboardVisibleHeight)") // 380, 0
                if keyboardVisibleHeight > 0 {
                    toolBar.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view.snp.bottom).offset(-keyboardVisibleHeight)
                    }
                    
                    
                    scrollView.contentInset.bottom = keyboardVisibleHeight
                } else {
                    toolBar.snp.updateConstraints { make in
                        make.bottom.equalTo(self.view.snp.bottom)
                    }
                    
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
                //                toolBar.isHidden = true
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
                print("weather type: \(type(of: weather))")
                guard let self = self else { return }
                let imageName = weather + "Bg"
                let image = UIImage(named: imageName)!
                
                let color = UIColor(patternImage: image)
                scrollView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        // MARK: isPrivate에 따라서 자물쇠 image 변경 
        reactor.state
            .map { $0.isPrivate }
            .bind { [weak self] isPrivate in
                guard let self = self else { return }
                addKeyboardToolBar.setPrivateTo(isPrivate)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.content.isEmpty }
            .distinctUntilChanged()
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.selectedImages }
            .bind { [weak self] images in
                guard let self = self else { return }
                print("images.count : \(images.count)")
                setImageSlideView(imageList: images)
                removeImageButton.isHidden = images.isEmpty ? true : false
            }
            .disposed(by: disposeBag)

    }
    
    override func updateViewConstraints() {
      super.updateViewConstraints()
      guard !self.didSetupViewConstraints else { return }
      self.didSetupViewConstraints = true

      self.scrollView.snp.makeConstraints { make in
        make.edges.equalTo(0)
      }
      self.toolBar.snp.makeConstraints { make in
        make.left.right.equalTo(0)
        if #available(iOS 11.0, *) {
          make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        } else {
          make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
      }
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      if self.scrollView.contentInset.bottom == 0 {
        self.scrollView.contentInset.bottom = 44
        self.scrollView.scrollIndicatorInsets.bottom = self.scrollView.contentInset.bottom
      }
    }
    
}

// MARK: - PHPickerViewControllerDelegate & picker preseent
extension AddStep3ViewController: PHPickerViewControllerDelegate {
    private func setAndPresentPicker() {
        var configuation = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuation.selectionLimit = 2 // 최대 3개 제한
        configuation.filter = .images
        let picker = PHPickerViewController(configuration: configuation)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    // MARK: 선택한 asset
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        var selectedImages: [UIImage] = [] // Create a local array to store selected images

        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error {
                        print("Error loading image: \(error.localizedDescription)")
                    }
                    if let selectedImage = image as? UIImage {
                        selectedImages.append(selectedImage)
                    }

                    // Check if this is the last image being loaded
                    if selectedImages.count == results.count {
                        // Update the property of your view controller with all selected images
                        // UI와 관련된 self.reactor?.action.onNext(.setSelectedImages은
                        // main thread에서 처리가 되어야 한다.
                        DispatchQueue.main.async {
                            self.reactor?.action.onNext(.setSelectedImages(selectedImages))
                            print("images.count - \(selectedImages.count)")
                        }
                    }
                }
            }
        }
    }
}
