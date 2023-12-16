//
//  MyFeedDetailViewController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/04.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import PhotosUI
import RxKeyboard
import Kingfisher


final class MyFeedDetailViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: MyFeedDetailCoordinatorInterface?
    var tapSave: Bool = false
    private var selection = [String: PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    
    private var feed: MyFeed?
    private var selectedImages: [UIImage] = []
    
    // MARK: - UI Components
    private lazy var statusBarStackView = StatusBarStackView(step: 3)
    private lazy var saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil).then {
        $0.setTitleTextAttributes([.font: UIFont.customFont(size: 16, weight: .bold)], for: .normal)
    }
    
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
    }
    
    private lazy var placeholderLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .lightGray
        $0.textAlignment = .left
           $0.text = "소소한 행복을 기록해보세요~"
       }
    
    // 스텍뷰 UITapGestureRecognizer
    private let categoryTapGesture = UITapGestureRecognizer()
    private let happyTapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(reactor: MyFeedDetailViewReactor,
         coordinator: MyFeedDetailCoordinatorInterface,
         feed: MyFeed
    ) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = MyFeedDetailViewReactor(feedRepository: FeedRepository() )
        self.coordinator = coordinator
        print("myfeeddetailviewcontroller feed: \(feed)")
        self.feed = feed
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
// MARK: - set up
extension MyFeedDetailViewController {
    
    private func setup() {
        setAttributes()
        setLayoutForAddStep3()
    }
    
    private func setAttributes() {
        textView.isUserInteractionEnabled = true
        textView.inputAccessoryView = addKeyboardToolBar
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        print("editable \(textView.isEditable)")
    }
    
    private func setLayoutForAddStep3() {
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
        imageSlideView.snp.makeConstraints { make in
            make.height.equalTo(0)
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
extension MyFeedDetailViewController: View {
    
    func bind(reactor: MyFeedDetailViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: MyFeedDetailViewReactor) {
        
        // FIXME: - setFeed func 사용
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear(self.feed ?? MyFeed()) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .skip(1)
            .map {
                print("💖🔆 content - \($0)")
                return Reactor.Action.setContent($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.view.rx.tapGesture().when(.recognized)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if textView.isFirstResponder {
                    print("textview가 대답중")
                    textView.resignFirstResponder()
                }
            }
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
       
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
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
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        // TODO: debouce ? throttle 적용 필요
        saveButton.rx.tap
            .map {
                print("save button tapped")
                self.view.endEditing(true)
                self.tapSave = true
                return Reactor.Action.tapSaveButton
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
       
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("back button tapped")
                coordinator?.finished()
            })
            .disposed(by: disposeBag)
        
        removeImageButton.rx.tap
            .map {
                self.selectedAssetIdentifiers = []
                self.selection = [:]
                return Reactor.Action.setSelectedImages([])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: 작업용 (임시)
//        categoryStackView.rx.tapGesture()
//            .subscribe(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                print("AddStep3 - show 앨범")
//                setAndPresentPicker()
//            })
//            .disposed(by: disposeBag)
        
        
    }
    
    func bindState(_ reactor: MyFeedDetailViewReactor) {
        
        // 행복 + 카테고리
        reactor.state
            .compactMap { $0.happyAndCategory }
            .distinctUntilChanged()
            .bind { [weak self] happyAndCategory in
                guard let self = self else { return }
                categoryStackView.addImageViews(images: happyAndCategory, imageSize: 62)
            }
            .disposed(by: disposeBag)
        
        // TODO: stackview - 날씨, 행복이미지, 카테고리 선택했을때 모달 띄우기
        // MARK: - CategoryStackView tapGesture Action
        happyTapGesture.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd1Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        categoryTapGesture.rx.event
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.coordinator?.showAdd2Modal(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        // 날짜
        /// 바뀔일 없음.
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
//                print("weather type: \(type(of: weather))")
                guard let self = self else { return }
                let imageName = weather + "Bg"
                let image = UIImage(named: imageName)!
                
                let color = UIColor(patternImage: image)
                scrollView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map {
                print("🔆reactor.state - \($0.content)")
                return $0.content
            }
            .bind(to: self.textView.rx.text)
            .disposed(by: disposeBag)

        // 작성 글자 수 label
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
        
        // 선택된 이미지
        reactor.state
            .compactMap { $0.selectedImages }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] images in
                guard let self = self else { return }
                setImageSlideView(imageList: images)
                removeImageButton.isHidden = images.isEmpty ? true : false
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { self.tapSave ? $0.isSaveFeedSuccess : nil }
            .subscribe(onNext: { [weak self] save in
                self?.showToast(save.rawValue, withDuration: 2.0, delay: 0.8)
                self?.tapSave = false
                
                if save == .saved {
                    Observable<Void>
                        .just(())
                        .delay(.milliseconds(3100), scheduler: MainScheduler.instance) // Adjust the delay duration as needed
                        .subscribe(onNext: { [weak self] _ in
                            self?.coordinator?.dismiss()
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag())
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    /// arrangedSubviews는 UIView의 배열이기 때문에 바로 tapGesture() 메서드를 호출할 수 없습니다.
    /// 각 서브뷰에 Gesture Recognizer를 추가하고 이를 RxSwift로 처리해야 합니다.
    func setGestureRecognizer() {
        for (index, subview) in categoryStackView.stackView.arrangedSubviews.enumerated() {
            guard let imageView = subview as? UIImageView else { continue }
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(index == 0 ? happyTapGesture : categoryTapGesture)
        }
    }
    
    
}


// MARK: - PHPickerViewControllerDelegate & picker preseent
// 권한 요청이 필요없음
// iOS 14이상부터 지원 가능
extension MyFeedDetailViewController: PHPickerViewControllerDelegate {
    private func setAndPresentPicker() {
        // configuation - 설정
        var configuation = PHPickerConfiguration(photoLibrary: .shared())
        configuation.selectionLimit = 2
        configuation.filter = .images
        configuation.selection = .ordered
        configuation.preferredAssetRepresentationMode = .current
        configuation.preselectedAssetIdentifiers = selectedAssetIdentifiers
        let picker = PHPickerViewController(configuration: configuation)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var selectedImages: [UIImage] = []
        picker.dismiss(animated: true)
        
        let existingSelection = self.selection
        var newSelection = [String: PHPickerResult]()
        let newSelectedAssetIdentifiers: [String] = results.map(\.assetIdentifier!)
        
        if selectedAssetIdentifiers == newSelectedAssetIdentifiers {
            return
        }
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelection[identifier] = existingSelection[identifier] ?? result
        }
        
        selection = newSelection
        selectedAssetIdentifiers = newSelectedAssetIdentifiers
        
        if selection.isEmpty {
            self.reactor?.action.onNext(.setSelectedImages([]))
        } else {
            loadAndAppendImages()
            
        }
    }

    private func loadAndAppendImages() {
        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        var imagesDict = [String: UIImage]()
        
        for assetIdentifier in selectedAssetIdentifiers {
            dispatchGroup.enter()
            
            let itemProvider = selection[assetIdentifier]!.itemProvider
    
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        imagesDict[assetIdentifier] = image
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            for identifier in self.selectedAssetIdentifiers {
                if let image = imagesDict[identifier] {
                    selectedImages.append(image)
                }
            }
            
            reactor?.action.onNext(.setSelectedImages(selectedImages))
        }
    }
}

